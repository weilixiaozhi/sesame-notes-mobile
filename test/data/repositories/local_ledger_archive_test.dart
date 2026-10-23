import 'dart:convert';

import 'package:drift/native.dart';
import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/infrastructure/sharing/sharing_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

class _FailingRecorder extends Mock implements ChangeRecorder {}

class _Sharing extends Mock implements SharingService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => registerFallbackValue(DateTime.utc(2026)));
  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account-a'),
      accountIdGetter: () => 'account-a',
    );
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('本地归档可恢复，后台列表持续包含账本且不产生云端变更', () async {
    final id = await repo.createLedger(name: '本地旧账', storageMode: 'local');
    await repo.setLedgerArchived(id, true);
    expect((await repo.getLedgerById(id))!.archivedAt, isNotNull);
    expect((await repo.getAllLedgers()).map((row) => row.id), contains(id));
    expect(
      (await repo.watchLedgers().first).map((row) => row.id),
      contains(id),
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);

    await repo.setLedgerArchived(id, false);
    final restored = (await repo.getLedgerById(id))!;
    expect(restored.archivedAt, isNull);
    expect(restored.archiveUpdatedAt, isNotNull);
  });

  test('前台写入校验阻止归档账本，使用中账本保持原调用语义', () async {
    final id = await repo.createLedger(name: '账本', storageMode: 'local');
    await repo.requireActiveLedger(id);
    await repo.setLedgerArchived(id, true);
    await expectLater(
      repo.requireActiveLedger(id),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          '友好提示',
          '账本已归档，请先恢复使用',
        ),
      ),
    );
  });

  test('updateLedger 拒绝已不存在的账本', () async {
    await expectLater(
      repo.updateLedger(id: 'missing', name: '改名'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('无法更新'),
        ),
      ),
    );
  });

  // 另一台设备删除账本后，本机过期页面里的保存/清空必须明确失败：
  // 放行会删 0 行却以"已清空"返回，把账本已不存在这件事藏起来。
  test('账本被远端 tombstone 后前台写入明确失败且数据不变', () async {
    final id = await repo.createLedger(name: '旧账', storageMode: 'cloud');
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '88',
      happenedAt: DateTime.utc(2026, 9, 6),
    );
    await (db.update(db.ledgers)..where((row) => row.id.equals(id))).write(
      LedgersCompanion(deletedAt: d.Value(DateTime.utc(2026, 9, 7))),
    );

    final actions = container.read(ledgerActionsProvider);
    await expectLater(actions.update(id: id, name: '改名'), throwsStateError);
    await expectLater(actions.clearTransactions(id), throwsStateError);

    expect((await repo.getTransactionById(txId))!.amount, '88');
    expect(
      (await (db.select(
        db.ledgers,
      )..where((row) => row.id.equals(id))).getSingle()).name,
      '旧账',
    );
  });

  // 前台 guard 的语义是「账本可写」：账本被删除（或被同步 tombstone）后，
  // 过期页面里的保存/清空必须失败，不能静默变成零副作用的"成功"。
  test('前台写入校验拒绝已不存在的账本', () async {
    await expectLater(
      repo.requireActiveLedger('missing'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          '友好提示',
          '账本已不存在，请刷新后重试',
        ),
      ),
    );
  });

  test('清空确认打开后归档，确认时拒绝清空并保留记录', () async {
    final id = await repo.createLedger(name: '旧账', storageMode: 'local');
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '88',
      happenedAt: DateTime.utc(2026, 9, 6),
    );
    final actions = container.read(ledgerActionsProvider);
    final opened = await actions.getById(id);
    expect(opened!.isArchived, isFalse);
    await repo.setLedgerArchived(id, true);

    await expectLater(actions.clearTransactions(opened.id), throwsStateError);
    expect((await repo.getTransactionById(txId))!.amount, '88');

    await actions.setArchived(id, false);
    expect(await actions.clearTransactions(id), 1);
  });

  test('换币确认打开后归档，提交时币种和历史折算均保持原值', () async {
    final id = await repo.createLedger(name: '旧账', storageMode: 'local');
    final txId = await repo.addTransaction(
      ledgerId: id,
      type: 'expense',
      amount: '88',
      happenedAt: DateTime.utc(2026, 9, 6),
    );
    final actions = container.read(ledgerActionsProvider);
    final opened = await actions.getById(id);
    expect(opened!.isArchived, isFalse);
    await repo.setLedgerArchived(id, true);

    await expectLater(
      actions.changeCurrency(ledgerId: opened.id, currency: 'USD'),
      throwsStateError,
    );
    expect((await repo.getLedgerById(id))!.currency, 'CNY');
    expect((await repo.getTransactionById(txId))!.nativeAmount, '88');
  });

  test('归档账本拒绝前台修改、成员新增和转本地，后台仓储写入仍可继续', () async {
    final id = await repo.createLedger(name: '旧账', storageMode: 'cloud');
    await repo.setLedgerArchived(id, true);
    final actions = container.read(ledgerActionsProvider);
    for (final write in <Future<Object?> Function()>[
      () => actions.update(id: id, name: '改名'),
      () => actions.createPlaceholderMember(ledgerId: id, name: '同行人'),
      () => actions.detachFromCloud(id),
    ]) {
      await expectLater(write(), throwsStateError);
    }
    expect((await repo.getLedgerById(id))!.storageMode, 'cloud');
    expect(await repo.getMembersByLedger(id), isEmpty);
    await repo.updateLedger(id: id, name: '后台同步名称', recordChanges: false);
    expect((await repo.getLedgerById(id))!.name, '后台同步名称');
  });

  test('归档账本拒绝邀请、移除成员且不发送请求', () async {
    final id = await repo.createLedger(name: '共享旧账', storageMode: 'cloud');
    await repo.setLedgerArchived(id, true);
    final sharing = _Sharing();
    container.dispose();
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        sharingServiceProvider.overrideWithValue(sharing),
      ],
    );
    final actions = container.read(ledgerActionsProvider);
    for (final write in <Future<Object?> Function()>[
      () => actions.createInvite(ledgerId: id, expiresInHours: 24),
      () => actions.removeMember(
        ledgerId: id,
        memberId: 'member',
        accountId: 'other',
      ),
    ]) {
      await expectLater(write(), throwsStateError);
    }
    verifyZeroInteractions(sharing);
    expect(await repo.getLedgerById(id), isNotNull);
  });

  for (final storageMode in ['local', 'cloud']) {
    test('归档的$storageMode个人账本可直接删除并清理偏好，云端登记删除同步', () async {
      final id = await repo.createLedger(name: '旧账', storageMode: storageMode);
      if (storageMode == 'cloud') {
        await (db.update(db.ledgers)..where((b) => b.id.equals(id))).write(
          const LedgersCompanion(syncId: d.Value('binding')),
        );
      }
      await repo.setLedgerArchived(id, true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('visibleCurrencies.$id', ['CNY']);

      await container.read(ledgerActionsProvider).delete(id);

      expect(await repo.getLedgerById(id), isNull);
      expect(prefs.containsKey('visibleCurrencies.$id'), isFalse);
      final changes = await (db.select(
        db.syncChanges,
      )..where((row) => row.ledgerId.equals(id))).get();
      if (storageMode == 'cloud') {
        expect(changes, hasLength(1));
        expect(changes.single.action, 'delete');
        expect(changes.single.entityId, id);
      } else {
        expect(changes, isEmpty);
      }
    });
  }

  for (final owner in [true, false]) {
    test('归档共享账本${owner ? '所有者离线登记删除' : '协作者在线确认退出'}', () async {
      final id = await repo.createLedger(name: '共享旧账', storageMode: 'cloud');
      await (db.update(db.ledgers)..where((b) => b.id.equals(id))).write(
        const LedgersCompanion(syncId: d.Value('binding')),
      );
      await repo.setLedgerArchived(id, true);
      final sharing = _Sharing();
      container.dispose();
      container = ProviderContainer(
        overrides: [
          repositoryProvider.overrideWithValue(repo),
          sharingServiceProvider.overrideWithValue(sharing),
        ],
      );
      final actions = container.read(ledgerActionsProvider);
      if (owner) {
        await actions.deleteSharedAsOwner(id);
        verifyZeroInteractions(sharing);
        expect(
          (await (db.select(
            db.ledgers,
          )..where((b) => b.id.equals(id))).getSingle()).deletedAt,
          isNotNull,
        );
        final pending = await (db.select(
          db.syncChanges,
        )..where((c) => c.ledgerId.equals(id) & c.pushedAt.isNull())).get();
        expect(pending, hasLength(1));
        expect(pending.single.action, 'delete');
        return;
      }
      var fail = true;

      /// 云端失败时本地仍保留完整归档账本，成功后才允许清理。
      Future<void> cloudResult() async {
        expect((await repo.getLedgerById(id))!.archivedAt, isNotNull);
        if (fail) throw StateError('cloud-delete-failed');
      }

      when(() => sharing.leaveLedger(id)).thenAnswer((_) => cloudResult());
      final remove = actions.leaveSharedLedger;
      await expectLater(
        remove(id),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'cloud-delete-failed',
          ),
        ),
      );
      expect((await repo.getLedgerById(id))!.archivedAt, isNotNull);
      fail = false;
      await remove(id);
      expect(await repo.getLedgerById(id), isNull);
      verify(() => sharing.leaveLedger(id)).called(2);
      verifyNoMoreInteractions(sharing);
    });
  }

  test('归档账本经本地恢复、云备份、保护副本与云转本地后仍保持归档', () async {
    final copier = LocalLedgerRepository(
      db,
      accountIdGetter: () => 'account-a',
    );
    final source = await repo.createLedger(name: '已归档旧账', storageMode: 'cloud');
    await repo.setLedgerArchived(source, true, deviceId: 'device-a');
    await (db.update(db.ledgers)..where((row) => row.id.equals(source))).write(
      const LedgersCompanion(
        ownerAccountId: d.Value('account-a'),
        archiveServerCursor: d.Value('9223372036854775807'),
      ),
    );
    final original = (await repo.getLedgerById(source))!;
    final localSource = await repo.createLedger(
      name: '本地旧账',
      storageMode: 'local',
    );
    await repo.setLedgerArchived(localSource, true, deviceId: 'device-a');
    final localOriginal = (await repo.getLedgerById(localSource))!;
    const targets = [
      '11111111-1111-4111-8111-111111111111',
      '22222222-2222-4222-8222-222222222222',
      '33333333-3333-4333-8333-333333333333',
      '44444444-4444-4444-8444-444444444444',
    ];
    await copier.restoreLocalLedger(
      sourceLedgerId: localSource,
      targetLedgerId: targets[0],
      localSelfId: 'self',
      originBackupId: 'backup',
    );
    await copier.forkCloudLedgerToLocal(
      sourceLedgerId: source,
      newLedgerId: targets[1],
      localSelfId: 'self',
      originBackupId: 'backup',
    );
    await repo.protectCloudLedgerToLocalFork(
      sourceLedgerId: source,
      targetLedgerId: targets[2],
      localSelfId: 'self',
    );
    await repo.forkCloudLedgerToLocalPendingMove(
      sourceLedgerId: source,
      newLedgerId: targets[3],
      localSelfId: 'self',
      currentAccountId: 'account-a',
    );

    for (final target in targets) {
      final copy = (await repo.getLedgerById(target))!;
      final expected = target == targets.first ? localOriginal : original;
      expect(copy.archivedAt, expected.archivedAt, reason: '复制不得使归档账本重新进入常用列表');
      expect(copy.archiveUpdatedAt, expected.archiveUpdatedAt);
      expect(copy.archiveDeviceId, expected.archiveDeviceId);
      expect(copy.archiveServerCursor, isNull, reason: '本地副本不继承云端投影位置');
    }
  });

  test('云端个人归档登记独立变更，既有待上传数据及账本元信息保持原值', () async {
    final id = await repo.createLedger(name: '共享旧账', storageMode: 'cloud');
    final before = (await repo.getLedgerById(id))!;
    final pending = await db.select(db.syncChanges).get();
    await repo.setLedgerArchived(id, true, deviceId: 'device-a');

    final ledger = (await repo.getLedgerById(id))!;
    final changes = await db.select(db.syncChanges).get();
    final archive = changes.singleWhere(
      (row) => row.entityType == 'ledger_archive',
    );
    expect(
      changes.map((row) => row.id),
      containsAll(pending.map((row) => row.id)),
    );
    expect(archive.entityId, id);
    expect(archive.ledgerId, id);
    expect(archive.accountId, 'account-a');
    expect(archive.action, 'upsert');
    expect(jsonDecode(archive.payload), {'archived': true});
    expect(archive.updatedAt.isUtc, isTrue);
    expect(
      ledger.archiveUpdatedAt!.millisecondsSinceEpoch,
      archive.updatedAt.millisecondsSinceEpoch ~/ 1000 * 1000,
      reason: '归档实体秒列与独立队列毫秒时间属于同一次编辑',
    );
    expect(ledger.archiveDeviceId, 'device-a');
    expect(ledger.updatedAt, before.updatedAt);
    expect(ledger.deletedAt, isNull);

    await repo.setLedgerArchived(id, false, deviceId: 'device-a');
    final restoredChanges = await db.select(db.syncChanges).get();
    expect(jsonDecode(restoredChanges.last.payload), {'archived': false});
  });

  test('登记归档变更失败时整笔回滚', () async {
    final id = await repo.createLedger(name: '云账', storageMode: 'cloud');
    final tracker = _FailingRecorder();
    when(
      () => tracker.recordLedgerChange(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        ledgerId: any(named: 'ledgerId'),
        action: any(named: 'action'),
        payload: any(named: 'payload'),
        updatedAt: any(named: 'updatedAt'),
      ),
    ).thenThrow(StateError('outbox unavailable'));
    repo.changeTracker = tracker;

    await expectLater(repo.setLedgerArchived(id, true), throwsStateError);
    expect((await repo.getLedgerById(id))!.archivedAt, isNull);
    expect((await repo.getLedgerById(id))!.archiveUpdatedAt, isNull);
  });

  test('常用与归档查询精确分开，归档当前账本回退且最后一本归档后保持空选择', () async {
    final first = await repo.createLedger(name: '旧账', storageMode: 'local');
    final second = await repo.createLedger(name: '常用账', storageMode: 'local');
    final actions = container.read(ledgerActionsProvider);
    container.read(currentLedgerIdProvider.notifier).set(first);

    await actions.setArchived(first, true);
    expect(container.read(currentLedgerIdProvider), second);
    expect((await actions.getAll()).map((row) => row.id), [second]);
    expect((await actions.getAll(archived: true)).map((row) => row.id), [
      first,
    ]);
    expect(
      (await actions.getAllWithStats(archived: true)).single.isArchived,
      isTrue,
    );

    await actions.setArchived(second, true);
    expect(container.read(currentLedgerIdProvider), isEmpty);
    expect(await actions.getAllWithStats(), isEmpty);

    await actions.setArchived(first, false);
    expect(container.read(currentLedgerIdProvider), first);
    await actions.setArchived(second, false);
    expect(container.read(currentLedgerIdProvider), first);
  });
}
