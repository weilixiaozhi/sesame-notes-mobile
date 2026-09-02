// LocalRepository 契约:
//  - upsertAutoRates 同日覆盖、getLatestAutoRates 取每 quote 最新日期
//  - setOverride 按币对 upsert(主键按 uuidV5(EXCHANGE_RATE_NAMESPACE,
//    '<账号id>:<BASE>:<QUOTE>') 确定性派生,同账号同币对复用同一 id)并记
//    user-global change;removeOverride 记 delete change
//  - 自动汇率写入【绝不】记 change(防 sync_changes 膨胀回归)
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/utils/exchange_rate_id.dart';

/// 测试用变更记录器，把仓储登记的变更直接写入同步队列以便断言。
class _TestChangeRecorder implements ChangeRecorder {
  _TestChangeRecorder(this.db);
  final SesameDatabase db;

  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            updatedAt: updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
  }

  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    await db
        .into(db.syncChanges)
        .insert(
          SyncChangesCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            ledgerId: d.Value(ledgerId),
            action: action,
            payload: payload,
            updatedAt: updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
  }

  @override
  Future<void> recordLedgerChanges({
    required List<SyncChangeRecord> changes,
  }) async {
    await db.batch((b) {
      for (final ch in changes) {
        b.insert(
          db.syncChanges,
          SyncChangesCompanion.insert(
            entityType: ch.entityType,
            entityId: ch.entityId,
            ledgerId: d.Value(ch.ledgerId),
            action: ch.action,
            payload: ch.payload,
            updatedAt: ch.updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
      }
    });
  }

  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) async {
    await db.batch((b) {
      for (final ch in changes) {
        b.insert(
          db.syncChanges,
          SyncChangesCompanion.insert(
            entityType: ch.entityType,
            entityId: ch.entityId,
            action: ch.action,
            payload: ch.payload,
            updatedAt: ch.updatedAt,
            mutationId: const Uuid().v4(),
          ),
        );
      }
    });
  }
}

/// 模拟登录态云账号 userId（v4 UUID，与跨端 golden 测试同 ownerId）。
const testAccountId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置全局状态（prefs mock / 平台 TestValue / 通知单例），
  // 防止跨用例残留导致的顺序依赖。详见 test/helpers/test_isolation.dart。
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      changeTracker: _TestChangeRecorder(db),
      accountIdGetter: () => testAccountId,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('upsertAutoRates 同日覆盖 + getLatestAutoRates 取最新日期,且不记 change', () async {
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-06-09',
      rates: {'USD': '7.10', 'JPY': '0.047'},
      source: 'fawazahmed0',
      fetchedAt: DateTime.utc(2026, 6, 9),
    );
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-06-10',
      rates: {'USD': '7.20'},
      source: 'frankfurter',
      fetchedAt: DateTime.utc(2026, 6, 10),
    );
    final latest = await repo.getLatestAutoRates('CNY');
    final usd = latest.firstWhere((r) => r.quoteCurrency == 'USD');
    final jpy = latest.firstWhere((r) => r.quoteCurrency == 'JPY');
    expect(usd.rate, '7.20');
    expect(usd.rateDate, '2026-06-10');
    expect(jpy.rate, '0.047'); // 06-10 没有 JPY → 最新仍是 06-09
    expect(
      (await repo.getLastFetchedAt('CNY'))?.toUtc(),
      DateTime.utc(2026, 6, 10),
    );
    expect(await db.select(db.syncChanges).get(), isEmpty); // 红线
  });

  test('setOverride 按派生 v5 建行;币对 upsert 复用 id;removeOverride 记 delete', () async {
    await repo.setOverride(base: 'CNY', quote: 'USD', rate: '7.5');
    var rows = await repo.getOverrides('CNY');
    expect(rows.length, 1);
    final firstId = rows.first.id;
    // 主键即服务端契约的确定性 UUIDv5（跨端 golden 同源派生），push 才不会被
    // 服务端 INVALID_RATE_ID 拒绝。
    expect(firstId, exchangeRateOverrideId(testAccountId, 'CNY', 'USD'));
    expect(
      firstId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );

    await repo.setOverride(base: 'CNY', quote: 'USD', rate: '7.8');
    rows = await repo.getOverrides('CNY');
    expect(rows.length, 1);
    expect(rows.first.rate, '7.8');
    expect(rows.first.id, firstId);

    await repo.removeOverride(base: 'CNY', quote: 'USD');
    expect(await repo.getOverrides('CNY'), isEmpty);

    final changes = await db.select(db.syncChanges).get();
    // 新建与更新都登记 upsert(复用同一 entityId),删除登记 delete
    expect(changes.map((c) => c.action).toList(), [
      'upsert',
      'upsert',
      'delete',
    ]);
    expect(
      changes.every((c) => c.entityType == 'exchange_rate_override'),
      isTrue,
    );
    // user-global 实体:ledgerId 恒为 null
    expect(changes.every((c) => c.ledgerId == null), isTrue);
  });

  test('未登录(null 账号)时 id 按本地兜底键确定性派生,重复设置复用同一 id', () async {
    final localRepo = LocalRepository(
      db,
      changeTracker: _TestChangeRecorder(db),
    );
    await localRepo.setOverride(base: 'CNY', quote: 'USD', rate: '7.5');
    final firstId = (await localRepo.getOverrides('CNY')).first.id;
    // 本地域永不推送（sync_service 过滤 accountId==null 的变更），
    // 但 id 仍需确定性,保证同币对 upsert 复用。
    await localRepo.setOverride(base: 'CNY', quote: 'USD', rate: '7.6');
    final rows = await localRepo.getOverrides('CNY');
    expect(rows.length, 1);
    expect(rows.first.id, firstId);
    // 与服务端派生(真实 userId)不同,避免登录后与云端行撞主键。
    expect(firstId, isNot(exchangeRateOverrideId(testAccountId, 'CNY', 'USD')));
  });

  test('get/watch 忽略当前账号域的 tombstone，且不影响其他账号域', () async {
    final repoB = LocalRepository(
      db,
      changeTracker: _TestChangeRecorder(db),
      accountIdGetter: () => 'account-b-id',
    );
    await repo.setOverride(base: 'CNY', quote: 'USD', rate: '7.5');
    await repoB.setOverride(base: 'CNY', quote: 'USD', rate: '7.4');
    final aId = exchangeRateOverrideId(testAccountId, 'CNY', 'USD');
    await (db.update(
      db.exchangeRateOverrides,
    )..where((row) => row.id.equals(aId))).write(
      ExchangeRateOverridesCompanion(
        deletedAt: d.Value(DateTime.now().toUtc()),
      ),
    );

    final queried = await repo.getOverrides('CNY');
    final watched = await repo.watchOverrides('CNY').first;

    expect(queried, isEmpty, reason: '远端 tombstone 不得继续覆盖自动汇率');
    expect(watched, isEmpty, reason: '监听结果必须与一次性读取遵循同一删除语义');
    expect((await repoB.getOverrides('CNY')).single.rate, '7.4');
  });

  test('setOverride 复活同账号 tombstone，并登记可被该账号 push 的 upsert', () async {
    final scopedRepo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(
        db,
        accountIdGetter: () => testAccountId,
      ),
      accountIdGetter: () => testAccountId,
    );
    final id = exchangeRateOverrideId(testAccountId, 'CNY', 'USD');
    await scopedRepo.setOverride(base: 'CNY', quote: 'USD', rate: '7.5');
    await (db.update(
      db.exchangeRateOverrides,
    )..where((row) => row.id.equals(id))).write(
      ExchangeRateOverridesCompanion(
        deletedAt: d.Value(DateTime.now().toUtc()),
      ),
    );
    await db.delete(db.syncChanges).go();

    await scopedRepo.setOverride(base: 'CNY', quote: 'USD', rate: '7.8');

    final raw = await (db.select(
      db.exchangeRateOverrides,
    )..where((row) => row.id.equals(id))).getSingle();
    final changes = await db.select(db.syncChanges).get();
    expect(raw.deletedAt, isNull, reason: '同一确定性实体再次设置时必须显式复活');
    expect(raw.rate, '7.8');
    expect(raw.scopeAccountId, testAccountId);
    expect(await scopedRepo.getOverrides('CNY'), hasLength(1));
    expect(changes, hasLength(1));
    expect(changes.single.entityId, id);
    expect(changes.single.action, 'upsert');
    expect(changes.single.accountId, testAccountId);
  });

  group('账号域隔离（10.5）', () {
    test('A/B 两账号同币对覆盖各自一行、互不可见，且各自可 upsert', () async {
      final repoB = LocalRepository(
        db,
        changeTracker: _TestChangeRecorder(db),
        accountIdGetter: () => 'account-b-id',
      );
      // A 写 CNY/USD
      await repo.setOverride(base: 'CNY', quote: 'USD', rate: '7.5');
      // B 写同币对：不得与 A 冲突（partial unique 按账号域分桶）
      await repoB.setOverride(base: 'CNY', quote: 'USD', rate: '7.4');

      final aRows = await repo.getOverrides('CNY');
      final bRows = await repoB.getOverrides('CNY');
      expect(aRows, hasLength(1));
      expect(bRows, hasLength(1));
      expect(aRows.single.rate, '7.5');
      expect(bRows.single.rate, '7.4');
      expect(
        aRows.single.id,
        exchangeRateOverrideId(testAccountId, 'CNY', 'USD'),
      );
      expect(
        bRows.single.id,
        exchangeRateOverrideId('account-b-id', 'CNY', 'USD'),
      );
      // B 再次 upsert 同币对：复用 B 自己的行
      await repoB.setOverride(base: 'CNY', quote: 'USD', rate: '7.3');
      final bRows2 = await repoB.getOverrides('CNY');
      expect(bRows2, hasLength(1));
      expect(bRows2.single.rate, '7.3');
      expect(bRows2.single.id, bRows.single.id);
      // A 的行不受 B 的 upsert 影响
      expect((await repo.getOverrides('CNY')).single.rate, '7.5');
      // B removeOverride 只删 B 自己的行
      await repoB.removeOverride(base: 'CNY', quote: 'USD');
      expect(await repoB.getOverrides('CNY'), isEmpty);
      expect(await repo.getOverrides('CNY'), hasLength(1));
    });

    test('本地域与账号域同币对共存；未登录写入本地域、登录后读不到', () async {
      final localRepo = LocalRepository(
        db,
        changeTracker: _TestChangeRecorder(db),
      );
      // 未登录写本地域
      await localRepo.setOverride(base: 'EUR', quote: 'USD', rate: '1.08');
      // 登录后写账号域同币对
      await repo.setOverride(base: 'EUR', quote: 'USD', rate: '1.09');

      final localRows = await localRepo.getOverrides('EUR');
      final accountRows = await repo.getOverrides('EUR');
      expect(localRows, hasLength(1));
      expect(accountRows, hasLength(1));
      expect(localRows.single.rate, '1.08');
      expect(accountRows.single.rate, '1.09');
      // 本地域行 scope 为 null，账号域行 scope 为当前账号
      final localRow = await (db.select(
        db.exchangeRateOverrides,
      )..where((t) => t.id.equals(localRows.single.id))).getSingle();
      expect(localRow.scopeAccountId, isNull);
      final accountRow = await (db.select(
        db.exchangeRateOverrides,
      )..where((t) => t.id.equals(accountRows.single.id))).getSingle();
      expect(accountRow.scopeAccountId, testAccountId);
    });
  });
}
