import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/transaction_display_mapper.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_statistics_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/features/transactions/domain/category_detail_summary.dart';

/// 验证范围汇总的金额精度、半开日期边界和成员数据隔离。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    for (final id in ['ledger', 'other']) {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: id,
              name: id,
              updatedAt: DateTime.utc(2026),
            ),
          );
    }
  });

  tearDown(() async => db.close());

  /// 直接写入固定金额快照，构造不同日期、成员、账本和删除状态的交易。
  Future<void> add(
    String id,
    DateTime date,
    String amount, {
    String ledger = 'ledger',
    String member = 'member',
    bool deleted = false,
    String? category,
    String currency = 'CNY',
    String? nativeAmount,
  }) async {
    try {
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              ledgerId: ledger,
              txType: 'expense',
              amount: amount,
              nativeAmount: nativeAmount ?? amount,
              currencyCode: currency,
              categoryId: d.Value(category),
              happenedAt: date,
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
              payerMemberId: d.Value(member),
              deletedAt: d.Value(deleted ? DateTime.utc(2026) : null),
            ),
          );
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '统计验证数据准备失败', error, stackTrace);
      rethrow;
    }
  }

  test('范围汇总精确相加并排除墓碑与区间外账单', () async {
    try {
      await add('a', DateTime(2026, 10, 1), '0.1');
      await add('b', DateTime(2026, 10, 1, 23, 59, 59, 999), '0.2');
      await add('before', DateTime(2026, 9, 30, 23, 59, 59, 999), '100');
      await add('after', DateTime(2026, 10, 3), '100');
      await add('deleted', DateTime(2026, 10, 1), '100', deleted: true);
      await add('other', DateTime(2026, 10, 1), '100', ledger: 'other');

      final totals = await LocalStatisticsRepository(db).totalsForRange(
        ledgerId: 'ledger',
        type: 'expense',
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 3),
      );

      expect(totals.txCount, 2);
      expect(totals.total, 0.3);
      expect(totals.categories.single.total, 0.3);
      expect(totals.days, [
        (day: DateTime(2026, 10, 1), total: 0.3),
        (day: DateTime(2026, 10, 2), total: 0.0),
      ]);
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '范围统计精度及数据边界验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('成员账单只包含目标成员和账本，空成员身份返回空列表', () async {
    try {
      await add('mine', DateTime(2026, 10, 1), '1');
      await add('mine-later', DateTime(2026, 10, 2), '2');
      await add('deleted', DateTime(2026, 10, 3), '3', deleted: true);
      await add('other-book', DateTime(2026, 10, 3), '3', ledger: 'other');
      for (var index = 0; index < 40; index++) {
        await add('other-$index', DateTime(2026, 10, 3), '3', member: 'other');
      }

      final rows = await LocalTransactionRepository(db)
          .transactionsWithCategoryForMember(
            ledgerId: 'ledger',
            memberId: 'member',
          );
      expect(rows.map((row) => row.t.id), ['mine-later', 'mine']);
      expect(
        await LocalTransactionRepository(
          db,
        ).transactionsWithCategoryForMember(ledgerId: 'ledger', memberId: ''),
        isEmpty,
      );
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '成员账单数据隔离验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('分类详情与区间统计均按本位币汇总完整金额', () async {
    try {
      final categories = LocalCategoryRepository(db);
      final category = await categories.createCategory(
        name: '餐饮',
        kind: 'expense',
      );
      final day = DateTime(2026, 10, 1);
      await add(
        'foreign',
        day,
        '10.00',
        category: category,
        currency: 'USD',
        nativeAmount: '72.00',
      );
      await add('local-a', day, '5.00', category: category);
      await add('local-b', day, '3.00', category: category);

      final rows = await categories
          .watchTransactionsByCategory(category, ledgerId: 'ledger')
          .first;
      final summary = summarizeCategoryDetail(
        rows.map((row) => row.toDisplay()).toList(growable: false),
      );
      expect(summary.totalCount, 3);
      expect(summary.totalAmount, 80.0);
      expect(summary.averageAmount, 80 / 3);
      final totals = await LocalStatisticsRepository(db).totalsForRange(
        ledgerId: 'ledger',
        type: 'expense',
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 11, 1),
      );
      expect(totals.categories.single.id, category);
      expect(totals.categories.single.total, 80.0);
    } catch (error, stackTrace) {
      logger.error('StatisticsScopeTest', '分类本位币金额汇总验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('同一分类在不同本位币账本中的金额保持隔离', () async {
    try {
      await (db.update(db.ledgers)..where((row) => row.id.equals('other')))
          .write(const LedgersCompanion(currency: d.Value('USD')));
      final categories = LocalCategoryRepository(db);
      final category = await categories.createCategory(
        name: '共用分类',
        kind: 'expense',
      );
      final day = DateTime(2026, 10, 1);
      await add('cny-a', day, '50.00', category: category);
      await add('cny-b', day, '30.00', category: category);
      await add(
        'usd',
        day,
        '25.00',
        ledger: 'other',
        category: category,
        currency: 'USD',
      );

      final cny = await categories
          .watchTransactionsByCategory(category, ledgerId: 'ledger')
          .first;
      final usd = await categories
          .watchTransactionsByCategory(category, ledgerId: 'other')
          .first;
      final cnySummary = summarizeCategoryDetail(
        cny.map((row) => row.toDisplay()).toList(growable: false),
      );
      expect(cnySummary, (
        totalCount: 2,
        totalAmount: 80.0,
        averageAmount: 40.0,
      ));
      expect(cny.every((row) => row.ledgerId == 'ledger'), isTrue);
      expect(usd.single.ledgerId, 'other');
      expect(
        summarizeCategoryDetail(
          usd.map((row) => row.toDisplay()).toList(growable: false),
        ),
        (totalCount: 1, totalAmount: 25.0, averageAmount: 25.0),
      );
    } catch (error, stackTrace) {
      logger.error('StatisticsScopeTest', '分类跨账本金额隔离验证失败', error, stackTrace);
      rethrow;
    }
  });
}
