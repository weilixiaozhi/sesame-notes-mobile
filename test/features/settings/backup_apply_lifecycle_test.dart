import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/reconnect_service.dart';

import '../../helpers/test_isolation.dart';

/// 只读会话不访问磁盘，关闭次数可验证恢复期间源库的所有权。
class _Session extends Fake implements RecoverySession {
  _Session(this.id, {this.cloud = false});

  final String id;
  final bool cloud;
  int closeCalls = 0;

  @override
  final Map<String, RecoveryDecision> decisions = {};
  @override
  final Map<String, RecoveryDecision> dayBookDecisions = {};
  @override
  final Map<String, RecoveryDecision> memoBookDecisions = {};
  @override
  final Map<String, RecoveryDecision> fitnessSpaceDecisions = {};
  @override
  final Map<String, String> dayTargetSnapshots = {};
  @override
  final Map<String, String> memoTargetSnapshots = {};
  @override
  final Map<String, String> fitnessTargetSnapshots = {};

  /// 清单提供与账本同属当前账号的日子本，覆盖两类提交后重连目标。
  @override
  BackupManifest get manifest => BackupManifest(
    formatVersion: 1,
    dbSchemaVersion: 1,
    createdAt: DateTime.utc(2026),
    deviceId: 'device',
    ledgers: [],
    accounts: [],
    dayBooks: [
      ManifestDayBook(
        dayBookId: '$id-day',
        name: '日子本',
        storageOrigin: cloud
            ? LedgerStorageOrigin.cloud
            : LedgerStorageOrigin.local,
        sourceAccountId: cloud ? 'account-a' : null,
        syncId: cloud ? 'sync-day' : null,
        eventCount: 0,
        categoryCounts: {},
        pendingCount: 0,
        rejectedCount: 0,
        openConflictCount: 0,
        fullyDownloaded: true,
      ),
    ],
  );

  /// 记录真实关闭调用，重复调用也计数以发现资源所有权错误。
  @override
  Future<void> close() async {
    closeCalls++;
  }
}

/// 在真实数据库事务提交前设置屏障，验证身份变化会回滚写入。
class _ApplyCall {
  _ApplyCall(this.session, this.accountId);

  final _Session session;
  final String? accountId;
  final release = Completer<void>();
  bool fail = false;
  bool committed = false;
  void Function()? afterCommit;
}

/// 预览返回内存会话，恢复使用真实事务和生产传入的身份校验闭包。
class _Importer extends BackupImportService {
  final sessions = <String, _Session>{};
  final opened = <String>[];
  final calls = <_ApplyCall>[];
  final started = Completer<_ApplyCall>();

  /// 按文件名提供独立的预览会话，文件本身不落盘。
  @override
  Future<RecoverySession> openBackup({required File backupFile}) async {
    final id = backupFile.uri.pathSegments.last;
    opened.add(id);
    return sessions[id]!;
  }

  /// 提供最小账本预览以验证决策快照和恢复后重连目标。
  @override
  Future<List<RecoveryItem>> listRecoveryItems(RecoverySession session) async {
    final source = session as _Session;
    return [
      RecoveryItem(
        ledgerBackupId: source.id,
        name: source.id,
        storageOrigin: source.cloud
            ? LedgerStorageOrigin.cloud
            : LedgerStorageOrigin.local,
        accountReference: source.cloud
            ? const ManifestAccount(accountId: 'account-a', accountName: '甲')
            : null,
        syncId: source.cloud ? 'sync-ledger' : null,
        currency: 'CNY',
        expenseTotal: 0,
        memberCount: 0,
        transactionCount: 0,
        pendingCount: 0,
        conflictCount: 0,
      ),
    ];
  }

  /// 屏障前先写事务，释放后重新校验，确保失败断言锚定真实回滚行为。
  @override
  Future<BackupApplyReport> apply({
    required RecoverySession session,
    required SesameDatabase liveDb,
    required String localSelfId,
    String? currentAccountId,
    void Function()? validateContext,
  }) async {
    final call = _ApplyCall(session as _Session, currentAccountId);
    calls.add(call);
    final report = await liveDb.transaction(() async {
      validateContext?.call();
      await liveDb
          .into(liveDb.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: '${call.session.id}-restored',
              name: '已恢复内容',
              updatedAt: DateTime.utc(2026),
              scopeAccountId: d.Value(currentAccountId),
            ),
          );
      if (!started.isCompleted) started.complete(call);
      await call.release.future;
      if (call.session.closeCalls != 0) throw StateError('源会话在恢复途中被关闭');
      if (call.fail) throw StateError('模拟恢复事务失败');
      validateContext?.call();
      return const BackupApplyReport(entries: []);
    });
    call.committed = true;
    call.afterCommit?.call();
    return report;
  }
}

/// 同步仅记录目标集合，避免生命周期回归依赖网络或第三方配置。
class _Sync extends Fake implements SyncCoordinator {
  final reconnects =
      <
        ({
          Set<String> ledgers,
          Set<String> days,
          Set<String> memos,
          Set<String> fitness,
        })
      >[];
  bool failReconnect = false;
  int runs = 0;

  /// 复制入参，断言后续选择变化不能改变已提交的同步目标。
  @override
  Future<ReconnectReport> reconnect({
    Set<String>? ledgerIds,
    Set<String>? dayBookIds,
    Set<String>? memoBookIds,
    Set<String>? fitnessSpaceIds,
  }) async {
    reconnects.add((
      ledgers: Set.of(ledgerIds ?? <String>{}),
      days: Set.of(dayBookIds ?? <String>{}),
      memos: Set.of(memoBookIds ?? <String>{}),
      fitness: Set.of(fitnessSpaceIds ?? <String>{}),
    ));
    if (failReconnect) throw StateError('模拟云端不可用');
    return ReconnectReport(
      refreshed: [
        ...?ledgerIds,
        ...?dayBookIds,
        ...?memoBookIds,
        ...?fitnessSpaceIds,
      ],
      stale: [],
      gone: [],
    );
  }

  /// 记录备忘录与健身恢复后的增量补跑。
  @override
  Future<SyncRunResult> run() async {
    runs++;
    return const SyncRunResult();
  }
}

/// 恢复页面退出只解绑反馈，已确认操作在同身份下完成并安全释放资源。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late BackupRestoreFlowNotifier flow;
  late _Importer importer;
  late _Sync sync;
  var disposed = false;

  /// 使用真实身份代次，覆盖同账号重新登录与切换账号两个失效入口。
  void signIn(String account) {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          AuthSession(
            accessToken: 'token-$account',
            userId: account,
            deviceId: 'device',
          ),
        );
  }

  /// 打开可受控的备份预览并确认会话已发布。
  Future<_Session> open(String id, {bool cloud = false}) async {
    final session = _Session(id, cloud: cloud);
    importer.sessions[id] = session;
    await flow.openBackup(file: File('Temp/$id'));
    expect(container.read(backupRestoreFlowProvider).session, same(session));
    return session;
  }

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    importer = _Importer();
    sync = _Sync();
    disposed = false;
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(SesameApiClient()),
        localSelfIdProvider.overrideWith((ref) async => 'local-self'),
        syncCoordinatorProvider.overrideWithValue(sync),
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(importService: importer),
        ),
      ],
    );
    signIn('account-a');
    flow = container.read(backupRestoreFlowProvider.notifier);
  });

  tearDown(() async {
    for (final call in importer.calls) {
      if (!call.release.isCompleted) call.release.complete();
    }
    await flow.closeSession();
    if (!disposed) container.dispose();
    await db.close();
    await logger.clear();
  });

  for (final fail in [false, true]) {
    test('恢复${fail ? '失败' : '成功'}前退出并打开下一份备份，源库等待事务且结果不污染新预览', () async {
      final first = await open('first');
      final pending = flow.apply();
      final call = await importer.started.future;
      call.fail = fail;
      final closing = flow.closeSession();
      expect(container.read(backupRestoreFlowProvider).session, isNull);
      expect(container.read(backupRestoreFlowProvider).loading, isFalse);
      final second = _Session('second');
      importer.sessions['second'] = second;
      final opening = flow.openBackup(file: File('Temp/second'));
      expect(first.closeCalls, 0);
      expect(importer.opened, ['first']);
      call.release.complete();
      expect(await pending, !fail);
      await closing;
      await opening;
      final state = container.read(backupRestoreFlowProvider);
      expect(state.session, same(second));
      expect(state.loading, isFalse);
      expect(state.error, RestoreFlowError.none);
      expect(first.closeCalls, 1);
      expect(second.closeCalls, 0);
      expect(await db.select(db.ledgers).get(), hasLength(fail ? 0 : 1));
    });
  }

  for (final account in ['account-b', 'account-a']) {
    test(
      '恢复提交前${account == 'account-a' ? '同账号重新登录' : '切换账号'}，固定身份校验回滚事务',
      () async {
        await open('first');
        final pending = flow.apply();
        final call = await importer.started.future;
        signIn(account);
        call.release.complete();
        expect(await pending, isFalse);
        expect(call.accountId, 'account-a');
        expect(call.committed, isFalse);
        expect(await db.select(db.ledgers).get(), isEmpty);
        expect(
          container.read(backupRestoreFlowProvider).error,
          RestoreFlowError.applyFailed,
        );
      },
    );
  }

  test('销毁容器使提交前校验失败，恢复结束后源会话仅关闭一次', () async {
    final session = await open('first');
    final pending = flow.apply();
    final call = await importer.started.future;
    container.dispose();
    disposed = true;
    expect(session.closeCalls, 0);
    call.release.complete();
    expect(await pending, isFalse);
    await flow.closeSession();
    expect(session.closeCalls, 1);
    expect(await db.select(db.ledgers).get(), isEmpty);
  });

  test('重复点击恢复共用在途结果，事务和恢复数据只产生一份', () async {
    await open('first');
    final first = flow.apply();
    final second = flow.apply();
    expect(identical(first, second), isTrue);
    final call = await importer.started.future;
    expect(importer.calls, hasLength(1));
    call.release.complete();
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect(await db.select(db.ledgers).get(), hasLength(1));
  });

  test('四类恢复决策和云端重连目标固定于确认时，不采用随后变化的选择', () async {
    final session = await open('first', cloud: true);
    flow.setMemoBookDecision('memo-first', RestoreDecision.reconnect);
    flow.setFitnessSpaceDecision('fitness-first', RestoreDecision.reconnect);
    final pending = flow.apply();
    flow.setDecision('first', RestoreDecision.skip);
    flow.setDayBookDecision('first-day', RestoreDecision.skip);
    flow.setMemoBookDecision('memo-first', RestoreDecision.skip);
    flow.setFitnessSpaceDecision('fitness-first', RestoreDecision.skip);
    final call = await importer.started.future;
    expect(session.decisions, {'first': RecoveryDecision.reconnect});
    expect(session.dayBookDecisions, {'first-day': RecoveryDecision.reconnect});
    expect(session.memoBookDecisions, {
      'memo-first': RecoveryDecision.reconnect,
    });
    expect(session.fitnessSpaceDecisions, {
      'fitness-first': RecoveryDecision.reconnect,
    });
    expect(sync.reconnects.single.memos, {'memo-first'});
    expect(sync.reconnects.single.fitness, {'fitness-first'});
    call.release.complete();
    expect(await pending, isTrue);
    await pumpEventQueue();
    expect(sync.reconnects, hasLength(2));
    expect(sync.reconnects.last.ledgers, {'first'});
    expect(sync.reconnects.last.days, {'first-day'});
    expect(sync.runs, 1);
  });

  test('事务提交后身份变化保留成功结果，不触发新账号同步也不误报回滚', () async {
    await open('first', cloud: true);
    final pending = flow.apply();
    final call = await importer.started.future;
    call.afterCommit = () => signIn('account-b');
    call.release.complete();
    expect(await pending, isTrue);
    expect(call.committed, isTrue);
    expect(await db.select(db.ledgers).get(), hasLength(1));
    expect(sync.reconnects, isEmpty);
    expect(
      container.read(backupRestoreFlowProvider).error,
      RestoreFlowError.none,
    );
    expect(
      logger.logs.where((entry) => entry.message.contains('应用备份未完成')),
      isEmpty,
    );
  });

  test('已提交恢复的后续云端失败只记录同步错误，不把恢复结果改为失败', () async {
    await open('first', cloud: true);
    sync.failReconnect = true;
    final pending = flow.apply();
    final call = await importer.started.future;
    call.release.complete();
    expect(await pending, isTrue);
    await pumpEventQueue();
    expect(await db.select(db.ledgers).get(), hasLength(1));
    final state = container.read(backupRestoreFlowProvider);
    expect(state.error, RestoreFlowError.none);
    expect(state.cloudRestorePending, isTrue);
    expect(
      logger.logs.any((entry) => entry.message.contains('恢复后 Reconnect 失败')),
      isTrue,
    );
  });
}
