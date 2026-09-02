/// CSV/JSON 导入路径的多币种契约:
///   - 无币种指定 → currencyCode=本位币, nativeAmount=amount
///   - CSV 显式指定币种列 → 优先于本位币兜底
///     (有汇率→折算, 无汇率→拒绝该行，绝不按 1:1 伪造快照)
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:drift/native.dart';
import 'package:decimal/decimal.dart';
import '../helpers/test_isolation.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';
import 'package:sesame_notes/shared/services/exchange_rate_service.dart';

/// 可控汇率服务：隔离公网，同时记录导入是否发起了不必要的补拉。
class _FakeRateService implements ExchangeRateService {
  RateFetchResult? result;
  Object? error;
  int fetchCount = 0;

  @override
  Future<RateFetchResult> fetch(String base) async {
    fetchCount++;
    if (error case final error?) throw error;
    return result ??
        const RateFetchResult(
          rateDate: '2026-07-10',
          source: 'fake',
          ratesBaseToQuote: {},
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 测试用变更记录器，把仓储登记的变更直接写入同步队列以验证事务回滚。
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // 每个用例前重置全局状态（prefs mock / 平台 TestValue / 通知单例），
  // 防止跨用例残留导致的顺序依赖。详见 test/helpers/test_isolation.dart。
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;
  late DataImportService service;
  late _FakeRateService rateService;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    rateService = _FakeRateService();
    service = DataImportService(exchangeRateService: rateService);
  });

  tearDown(() async => db.close());

  Future<void> seed() async {
    await db.customStatement(
      "INSERT INTO ledgers (id, name, currency, updated_at) "
      "VALUES (1, 'L', 'CNY', strftime('%s','now'))",
    );
  }

  Future<List<Transaction>> allTx() => (db.select(
    db.transactions,
  )..orderBy([(t) => d.OrderingTerm.asc(t.id)])).get();

  test('导入:无币种指定 → currencyCode=CNY, native=amount', () async {
    await seed();

    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('100'),
        happenedAt: DateTime(2026, 7, 1),
      ),
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('50'),
        happenedAt: DateTime(2026, 7, 2),
      ),
    ], categoryCache: {});
    expect(result.inserted, 2);

    final txs = await allTx();
    expect(txs, hasLength(2));
    for (final t in txs) {
      expect(t.currencyCode, 'CNY'); // 无币种 → 本位币兜底
    }
    // 主键为随机 UUID，行序不定，按金额集合断言 native=amount。
    expect(txs.map((t) => t.nativeAmount).toSet(), {'100', '50'});
  });

  test('导入:CSV 显式币种规范为大写后优先于本位币兜底', () async {
    await seed();
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-07-10',
      rates: {'JPY': '0.0488'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 7, 10),
    );
    final result = await service.importTransactions(repo, '1', [
      // CSV 带币种列 JPY → 按 JPY 折算
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('1000'),
        currencyCode: ' jpy ',
        happenedAt: DateTime(2026, 7, 1),
      ),
    ], categoryCache: {});
    expect(result.inserted, 1);
    final txs = await allTx();
    expect(txs[0].currencyCode, 'JPY');
    expect(txs[0].nativeAmount, '48.8'); // 1000 × 0.0488
    expect(rateService.fetchCount, 0, reason: '本地已有有效汇率时不应访问网络');
  });

  test('导入:源数据已携带 nativeAmount 时保留快照且不补拉汇率', () async {
    await seed();
    rateService.error = StateError('不应请求汇率');
    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('12'),
        currencyCode: 'USD',
        nativeAmount: Decimal.parse('86.4'),
        happenedAt: DateTime(2026, 7, 3),
      ),
    ], categoryCache: {});
    expect(result.inserted, 1);
    expect(result.failed, 0);

    final txs = await allTx();
    expect(txs[0].currencyCode, 'USD');
    expect(txs[0].nativeAmount, '86.4', reason: '恢复数据必须保留源端历史折算快照');
    expect(rateService.fetchCount, 0, reason: '已有历史快照时无需获取当前汇率');
  });

  test('导入:本地缺失汇率时补拉成功并按有效汇率折算', () async {
    await seed();
    rateService.result = const RateFetchResult(
      rateDate: '2026-07-10',
      source: 'fake',
      ratesBaseToQuote: {'USD': '0.2'},
    );

    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('12'),
        currencyCode: 'USD',
        happenedAt: DateTime(2026, 7, 3),
      ),
    ], categoryCache: {});

    expect(result.inserted, 1);
    expect(result.failed, 0);
    expect(rateService.fetchCount, 1);
    final txs = await allTx();
    expect(txs.single.currencyCode, 'USD');
    expect(
      txs.single.nativeAmount,
      '60',
      reason: '1 CNY = 0.2 USD，所以 1 USD = 5 CNY',
    );
  });

  test('导入:补拉失败仍缺汇率时该行失败且不落库', () async {
    await seed();
    rateService.error = StateError('network down');

    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('12'),
        currencyCode: 'USD',
        happenedAt: DateTime(2026, 7, 3),
      ),
    ], categoryCache: {});

    expect(result.inserted, 0);
    expect(result.failed, 1);
    expect(rateService.fetchCount, 1);
    expect(await allTx(), isEmpty, reason: '无汇率时按 1:1 落库会永久污染统计');
  });

  test('导入:本位币与缺汇率外币混合时仅导入本位币', () async {
    await seed();
    rateService.error = StateError('network down');

    final result = await service.importTransactions(repo, '1', [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('20'),
        currencyCode: 'CNY',
        happenedAt: DateTime(2026, 7, 3),
      ),
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('12'),
        currencyCode: 'USD',
        happenedAt: DateTime(2026, 7, 4),
      ),
    ], categoryCache: {});

    expect(result.inserted, 1);
    expect(result.failed, 1);
    final txs = await allTx();
    expect(txs.single.currencyCode, 'CNY');
    expect(txs.single.nativeAmount, '20');
  });

  test('导入换本位币重算失败时元数据、快照与同步变更全部回滚', () async {
    await db.customStatement('''
      INSERT INTO ledgers (id, name, currency, storage_mode, updated_at)
      VALUES ('1', 'L', 'CNY', 'cloud', strftime('%s','now'))
    ''');
    await db.customStatement('''
      INSERT INTO transactions
        (id, ledger_id, tx_type, amount, currency_code, native_amount,
         happened_at, created_at, updated_at)
      VALUES ('tx-sync', '1', 'expense', '100', 'CNY', '200',
              strftime('%s','now'), strftime('%s','now'), strftime('%s','now'))
    ''');
    repo.changeTracker = _TestChangeRecorder(db);
    // native 快照与原金额刻意不同，确保换币重算会执行 UPDATE 并命中触发器。
    await db.customStatement('''
      CREATE TRIGGER fail_import_native_recalc
      BEFORE UPDATE OF native_amount ON transactions
      BEGIN
        SELECT RAISE(ABORT, 'forced import recalc failure');
      END;
    ''');

    await expectLater(
      service.importData(repo, '1', const ImportData(currency: ' usd ')),
      throwsA(anything),
    );

    expect((await repo.getLedgerById('1'))?.currency, 'CNY');
    final tx = await repo.getTransactionById('tx-sync');
    expect(tx?.currencyCode, 'CNY');
    expect(tx?.nativeAmount, '200');
    // 同步变更登记走 ChangeRecorder 端口落 sync_changes 表：事务回滚后必须为空。
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('恢复导入 recordChanges=false 时元数据换币与重算均不反向同步', () async {
    await db.customStatement('''
      INSERT INTO ledgers (id, name, currency, storage_mode, updated_at)
      VALUES ('1', 'L', 'CNY', 'cloud', strftime('%s','now'))
    ''');
    await db.customStatement('''
      INSERT INTO transactions
        (id, ledger_id, tx_type, amount, currency_code, native_amount,
         happened_at, created_at, updated_at)
      VALUES ('tx-restore', '1', 'expense', '100', 'CNY', '100',
              strftime('%s','now'), strftime('%s','now'), strftime('%s','now'))
    ''');
    await repo.upsertAutoRates(
      base: 'USD',
      rateDate: '2026-08-21',
      rates: {'CNY': '0.14'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 8, 21),
    );
    repo.changeTracker = _TestChangeRecorder(db);

    await service.importData(
      repo,
      '1',
      const ImportData(currency: 'USD'),
      recordChanges: false,
    );

    expect((await repo.getLedgerById('1'))?.currency, 'USD');
    expect((await repo.getTransactionById('tx-restore'))?.nativeAmount, '14');
    expect(
      await db.select(db.syncChanges).get(),
      isEmpty,
      reason: '恢复路径禁止把备份元数据与历史快照作为本地编辑反向推云',
    );
  });

  test('导入过程 onPhase 先报告汇率阶段再报告写入阶段', () async {
    await seed();
    rateService.result = const RateFetchResult(
      rateDate: '2026-07-10',
      source: 'fake',
      ratesBaseToQuote: {'USD': '0.2'},
    );
    final phases = <String>[];
    final result = await service.importTransactions(
      repo,
      '1',
      [
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse('12'),
          currencyCode: 'USD',
          happenedAt: DateTime(2026, 7, 3),
        ),
      ],
      categoryCache: {},
      onPhase: phases.add,
    );
    expect(result.inserted, 1);
    // 缺少汇率需补拉 → 必须先报 rate 阶段；批处理开始前报 write 阶段。
    expect(phases, ['rate', 'write']);
  });

  test('导入过程本地汇率齐全时不报告汇率阶段', () async {
    await seed();
    await repo.upsertAutoRates(
      base: 'CNY',
      rateDate: '2026-07-10',
      rates: {'USD': '7.2'},
      source: 'test',
      fetchedAt: DateTime.utc(2026, 7, 10),
    );
    final phases = <String>[];
    final result = await service.importTransactions(
      repo,
      '1',
      [
        ImportTransaction(
          type: 'expense',
          amount: Decimal.parse('12'),
          currencyCode: 'USD',
          happenedAt: DateTime(2026, 7, 3),
        ),
      ],
      categoryCache: {},
      onPhase: phases.add,
    );
    expect(result.inserted, 1);
    expect(phases, ['write'], reason: '本地有汇率时直接落库，不进入汇率阶段');
  });
}
