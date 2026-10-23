import 'dart:async';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

import '../helpers/test_isolation.dart';

/// 将第二次目标复核的返回固定在可控边界，验证最终状态提交的身份检查。
class _FinalValidationPausedDayBookNotifier extends CurrentDayBookNotifier {
  final finalValidationCompleted = Completer<void>();
  final releaseFinalValidation = Completer<void>();
  var _validationCount = 0;

  /// 真实仓储完成复核后才暂停返回，让测试可以在最终提交前切换账号。
  @override
  Future<DayBook> requireTarget(PrivateBookTarget target) async {
    try {
      final book = await super.requireTarget(target);
      if (++_validationCount == 2) {
        finalValidationCompleted.complete();
        await releaseFinalValidation.future;
      }
      return book;
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

/// 写入同步后已经发布的各类云端本子，直接模拟数据库提交而不发手动刷新信号。
Future<void> _insertCloudBooks(
  SesameDatabase db,
  String account, {
  String? idSuffix,
  DateTime? updatedAt,
}) async {
  final suffix = idSuffix ?? account;
  final now = updatedAt ?? DateTime.utc(2026, 9, 30);
  try {
    await db.transaction(() async {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'ledger-$suffix',
              name: '云端账本',
              updatedAt: now,
              storageMode: const d.Value('cloud'),
              scopeAccountId: d.Value(account),
            ),
          );
      await db
          .into(db.dayBooks)
          .insert(
            DayBooksCompanion.insert(
              id: 'day-$suffix',
              name: '云端纪念日本',
              createdAt: now,
              updatedAt: now,
              storageMode: const d.Value('cloud'),
              scopeAccountId: d.Value(account),
              syncId: d.Value('sync-day-$suffix'),
              serverRevision: const d.Value(1),
              fullCursor: const d.Value('1'),
            ),
          );
      for (final type in ['normal', 'credentials']) {
        await db
            .into(db.memoBooks)
            .insert(
              MemoBooksCompanion.insert(
                id: '$type-$suffix',
                name: '云端$type本',
                type: type,
                createdAt: now,
                updatedAt: now,
                storageMode: const d.Value('cloud'),
                scopeAccountId: d.Value(account),
                syncId: d.Value('sync-$type-$suffix'),
                serverRevision: const d.Value(1),
                fullCursor: const d.Value('1'),
              ),
            );
      }
      await db
          .into(db.fitnessSpaces)
          .insert(
            FitnessSpacesCompanion.insert(
              id: 'fitness-$suffix',
              name: '云端健身空间',
              createdAt: now,
              updatedAt: now,
              storageMode: const d.Value('cloud'),
              scopeAccountId: d.Value(account),
              syncId: d.Value('sync-fitness-$suffix'),
              serverRevision: const d.Value(1),
              fullCursor: const d.Value('1'),
            ),
          );
    });
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(StateError('测试云端本子夹具写入失败：$error'), stackTrace);
  }
}

/// 提交登录身份，保持同步事实与身份变化独立，避免测试借用选本动作。
void _signIn(ProviderContainer container, String account) {
  container
      .read(authSessionProvider.notifier)
      .signIn(
        AuthSession(accessToken: 'token', userId: account, deviceId: 'device'),
      );
}

/// 让数据库流与异步偏好读取收敛，再核对每个业务域的当前选择。
Future<void> _expectSelections(
  ProviderContainer container,
  String? account,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  expect(
    {
      '账本': container.read(currentLedgerIdProvider),
      '纪念日本': container.read(currentDayBookIdProvider).value,
      '备忘录本': container.read(currentMemoBookIdProvider).value,
      '账号密码本': container.read(currentCredentialBookIdProvider).value,
      '健身空间': container.read(currentFitnessSpaceIdProvider).value,
    },
    {
      '账本': account == null ? '' : 'ledger-$account',
      '纪念日本': account == null ? null : 'day-$account',
      '备忘录本': account == null ? null : 'normal-$account',
      '账号密码本': account == null ? null : 'credentials-$account',
      '健身空间': account == null ? null : 'fitness-$account',
    },
    reason: '每个业务域应选中当前账号的有效本子，并保持已有选择',
  );
}

/// 覆盖登录、分批同步和身份切换时，各业务域共享的自动选本行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;

  setUp(() async {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    // 各业务首页持续观察当前选择，数据库和身份变化必须沿正式依赖自动生效。
    container.listen(currentLedgerPersistProvider, (_, _) {});
    container.listen(currentDayBookIdProvider, (_, _) {});
    container.listen(currentMemoBookIdProvider, (_, _) {});
    container.listen(currentCredentialBookIdProvider, (_, _) {});
    container.listen(currentFitnessSpaceIdProvider, (_, _) {});
    await container.read(currentLedgerPersistProvider.future);
    await container.read(currentDayBookIdProvider.future);
    await container.read(currentMemoBookIdProvider.future);
    await container.read(currentCredentialBookIdProvider.future);
    await container.read(currentFitnessSpaceIdProvider.future);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    resetGlobalTestState();
  });

  test('未登录空本子，登录后同步提交首本时每个业务域自动选中', () async {
    await _expectSelections(container, null);
    _signIn(container, 'account');
    await _expectSelections(container, null);

    await _insertCloudBooks(db, 'account');

    await _expectSelections(container, 'account');
  });

  test('未登录时隐藏云端缓存，登录后仅身份变化也自动选中当前账号首本', () async {
    await _insertCloudBooks(db, 'account');
    await _insertCloudBooks(db, 'other-account');
    await _expectSelections(container, null);

    _signIn(container, 'account');

    await _expectSelections(container, 'account');
  });

  test('空状态自动选中首本后，后续同步到位的更新本子不抢占有效选择', () async {
    _signIn(container, 'account');
    await _insertCloudBooks(db, 'account');
    await _expectSelections(container, 'account');

    // 私有本目录按更新时间倒序排列，后到的本子会变成列表首本。
    // 目录排序变化只能补全空选择或失效选择，已有有效选择应继续保留。
    await _insertCloudBooks(
      db,
      'account',
      idSuffix: 'later',
      updatedAt: DateTime.utc(2026, 10, 1),
    );

    await _expectSelections(container, 'account');
  });

  test('切换账号时不能把旧账号的有效选择沿用到新账号', () async {
    await _insertCloudBooks(db, 'account');
    await _insertCloudBooks(db, 'other-account');
    _signIn(container, 'account');
    await _expectSelections(container, 'account');

    _signIn(container, 'other-account');

    await _expectSelections(container, 'other-account');
  });

  test('自动选中的首本删除后，五个业务域均回落到剩余有效本子', () async {
    _signIn(container, 'account');
    await _insertCloudBooks(db, 'account');
    await _expectSelections(container, 'account');
    await _insertCloudBooks(
      db,
      'account',
      idSuffix: 'replacement',
      updatedAt: DateTime.utc(2026, 10, 1),
    );
    await _expectSelections(container, 'account');

    // 保留另一套同账号本子，只删除当前父本，模拟同步提交的本子失效事实。
    await db.transaction(() async {
      await (db.delete(
        db.ledgers,
      )..where((row) => row.id.equals('ledger-account'))).go();
      await (db.delete(
        db.dayBooks,
      )..where((row) => row.id.equals('day-account'))).go();
      await (db.delete(db.memoBooks)..where(
            (row) => row.id.isIn(['normal-account', 'credentials-account']),
          ))
          .go();
      await (db.delete(
        db.fitnessSpaces,
      )..where((row) => row.id.equals('fitness-account'))).go();
    });

    await _expectSelections(container, 'replacement');
  });

  test('同账号退出重登的新会话恢复偏好，不能复用旧会话的自动选择', () async {
    _signIn(container, 'account');
    await _insertCloudBooks(db, 'account');
    await _expectSelections(container, 'account');
    await _insertCloudBooks(
      db,
      'account',
      idSuffix: 'saved',
      updatedAt: DateTime.utc(2026, 10, 1),
    );
    await _expectSelections(container, 'account');

    // 建立新会话应恢复的合法偏好；当前会话仍保有首本的自动选择。
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_day_book_id_account', 'day-saved');
    await prefs.setString('current_memo_book_id_account', 'normal-saved');
    await prefs.setString(
      'current_credential_book_id_account',
      'credentials-saved',
    );
    await prefs.setString('current_fitness_space_id_account', 'fitness-saved');

    // 同一轮事件循环退出后重新登录，账号文本相同，只有身份代次发生变化。
    container.read(authSessionProvider.notifier).signOut();
    _signIn(container, 'account');
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(
      {
        '纪念日本': container.read(currentDayBookIdProvider).value,
        '备忘录本': container.read(currentMemoBookIdProvider).value,
        '账号密码本': container.read(currentCredentialBookIdProvider).value,
        '健身空间': container.read(currentFitnessSpaceIdProvider).value,
      },
      {
        '纪念日本': 'day-saved',
        '备忘录本': 'normal-saved',
        '账号密码本': 'credentials-saved',
        '健身空间': 'fitness-saved',
      },
      reason: '内存选择必须按会话隔离，新会话从当前账号的合法偏好恢复',
    );
  });

  test('用户保存的本子晚于临时首本同步到位时，四类私有本恢复原偏好', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_day_book_id_account', 'day-saved');
    await prefs.setString('current_memo_book_id_account', 'normal-saved');
    await prefs.setString(
      'current_credential_book_id_account',
      'credentials-saved',
    );
    await prefs.setString('current_fitness_space_id_account', 'fitness-saved');
    _signIn(container, 'account');

    // 已保存的本子尚未到位时先显示可用首本，保留原偏好等待后续同步。
    await _insertCloudBooks(db, 'account');
    await _expectSelections(container, 'account');
    await _insertCloudBooks(
      db,
      'account',
      idSuffix: 'saved',
      updatedAt: DateTime.utc(2026, 10, 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));

    expect(
      {
        '纪念日本': container.read(currentDayBookIdProvider).value,
        '备忘录本': container.read(currentMemoBookIdProvider).value,
        '账号密码本': container.read(currentCredentialBookIdProvider).value,
        '健身空间': container.read(currentFitnessSpaceIdProvider).value,
      },
      {
        '纪念日本': 'day-saved',
        '备忘录本': 'normal-saved',
        '账号密码本': 'credentials-saved',
        '健身空间': 'fitness-saved',
      },
      reason: '临时自动选本不能阻止同步到位后恢复用户保存的合法偏好',
    );
  });

  test('最后一次异步目标复核后切换账号，迟到选本不得覆盖新账号选择', () async {
    final notifier = _FinalValidationPausedDayBookNotifier();
    container.dispose();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
        currentDayBookIdProvider.overrideWith(() => notifier),
      ],
    );
    container.listen(currentDayBookIdProvider, (_, _) {});
    await _insertCloudBooks(db, 'account');
    await _insertCloudBooks(db, 'other-account');
    _signIn(container, 'account');
    expect(
      await container.read(currentDayBookIdProvider.future),
      'day-account',
    );

    final selecting = notifier.select('day-account');
    final rejected = expectLater(selecting, throwsStateError);
    try {
      await notifier.finalValidationCompleted.future.timeout(
        const Duration(seconds: 3),
      );
      _signIn(container, 'other-account');
      expect(
        await container.read(currentDayBookIdProvider.future),
        'day-other-account',
      );
    } finally {
      // 即使用例失败，也释放异步选择，确保容器销毁前不会残留挂起任务。
      notifier.releaseFinalValidation.complete();
    }
    await rejected;

    expect(
      container.read(currentDayBookIdProvider).value,
      'day-other-account',
      reason: '目标复核与状态提交之间发生换号时，应拒绝旧会话的选本结果',
    );
  });
}
