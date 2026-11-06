import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_statistics_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';

/// 记录真实交易查询的次数和返回规模，不以机器耗时作为性能断言。
class _TransactionReads extends d.QueryInterceptor {
  final statements = <String>[];
  final rowCounts = <int>[];
  final resultColumns = <Set<String>>[];

  /// 在数据库结果边界计数，能够识别先读取全账本再内存筛选的实现。
  @override
  Future<List<Map<String, Object?>>> runSelect(
    d.QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final rows = await executor.runSelect(statement, args);
      if (RegExp(
        r'FROM\s+"?transactions"?\b',
        caseSensitive: false,
      ).hasMatch(statement)) {
        statements.add(statement);
        rowCounts.add(rows.length);
        resultColumns.add(rows.firstOrNull?.keys.toSet() ?? const {});
      }
      return rows;
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '统计查询计数失败', error, stackTrace);
      rethrow;
    }
  }
}

/// 验证范围快照精度、半开日期边界和成员查询的数据库过滤规模。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _TransactionReads reads;

  setUp(() async {
    reads = _TransactionReads();
    db = SesameDatabase.withExecutor(
      d.ApplyInterceptor(NativeDatabase.memory()).interceptWith(reads),
    );
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

  /// 直接写入固定金额快照，避免写入流程的辅助查询影响读取计数。
  Future<void> add(
    String id,
    DateTime date,
    String amount, {
    String ledger = 'ledger',
    String member = 'member',
    bool deleted = false,
    String? note,
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
              nativeAmount: amount,
              currencyCode: 'CNY',
              happenedAt: date,
              note: d.Value(note),
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

  test('范围聚合只读取一次必要字段，精确相加并排除墓碑与区间外账单', () async {
    try {
      await add('a', DateTime(2026, 10, 1), '0.1');
      await add('b', DateTime(2026, 10, 1, 23, 59, 59, 999), '0.2');
      await add('before', DateTime(2026, 9, 30, 23, 59, 59, 999), '100');
      await add('after', DateTime(2026, 10, 3), '100');
      await add('deleted', DateTime(2026, 10, 1), '100', deleted: true);
      await add('other', DateTime(2026, 10, 1), '100', ledger: 'other');
      reads.statements.clear();
      reads.rowCounts.clear();

      final totals = await LocalStatisticsRepository(db).totalsForRange(
        ledgerId: 'ledger',
        type: 'expense',
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 3),
      );

      expect(reads.rowCounts, [2]);
      expect(reads.statements.single, isNot(contains('*')));
      expect(reads.statements.single, isNot(contains('note')));
      expect(totals.txCount, 2);
      expect(totals.total, 0.3);
      expect(totals.categories.single.total, 0.3);
      expect(totals.days, [
        (day: DateTime(2026, 10, 1), total: 0.3),
        (day: DateTime(2026, 10, 2), total: 0.0),
      ]);
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '范围统计精度及读取规模验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('成员详情数据库只返回目标成员账单，不读取其他成员或账本', () async {
    try {
      await add('mine', DateTime(2026, 10, 1), '1');
      await add('mine-later', DateTime(2026, 10, 2), '2');
      await add('deleted', DateTime(2026, 10, 3), '3', deleted: true);
      await add('other-book', DateTime(2026, 10, 3), '3', ledger: 'other');
      for (var index = 0; index < 40; index++) {
        await add('other-$index', DateTime(2026, 10, 3), '3', member: 'other');
      }
      reads.statements.clear();
      reads.rowCounts.clear();

      final rows = await LocalTransactionRepository(db)
          .transactionsWithCategoryForMember(
            ledgerId: 'ledger',
            memberId: 'member',
          );
      expect(rows.map((row) => row.t.id), ['mine-later', 'mine']);
      expect(reads.rowCounts, [2]);
      expect(
        await LocalTransactionRepository(
          db,
        ).transactionsWithCategoryForMember(ledgerId: 'ledger', memberId: ''),
        isEmpty,
      );
      expect(reads.rowCounts, [2], reason: '空成员身份不应读取无归属账单');
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '成员账单过滤规模验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('首页合计和每日趋势只读取金额及日期，不搬运长备注', () async {
    try {
      await add('a', DateTime(2026, 10, 1), '0.1', note: '备注' * 4096);
      await add('b', DateTime(2026, 10, 2), '0.2', note: '备注' * 4096);
      final statistics = LocalStatisticsRepository(db);
      reads.resultColumns.clear();
      expect(
        await statistics.totalsInRange(
          ledgerId: 'ledger',
          start: DateTime(2026, 10),
          end: DateTime(2026, 11),
        ),
        0.3,
      );
      expect(reads.resultColumns.single, hasLength(2));

      reads.resultColumns.clear();
      expect(
        await statistics.totalsByDay(
          ledgerId: 'ledger',
          type: 'expense',
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 3),
        ),
        [
          (day: DateTime(2026, 10, 1), total: 0.1),
          (day: DateTime(2026, 10, 2), total: 0.2),
        ],
      );
      expect(reads.resultColumns.single, hasLength(3));
      expect(
        reads.resultColumns.single.any((name) => name.contains('note')),
        isFalse,
      );
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '首页查询字段与精度验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('支出存在性只返回首条标识，空账本和墓碑均不产生结果行', () async {
    try {
      for (var index = 0; index < 20; index++) {
        await add('row-$index', DateTime(2026, 10, 1), '1', note: '备注' * 4096);
      }
      await add(
        'deleted-other',
        DateTime(2026, 10, 1),
        '1',
        ledger: 'other',
        deleted: true,
      );
      reads.rowCounts.clear();
      reads.resultColumns.clear();
      final statistics = LocalStatisticsRepository(db);
      expect(await statistics.hasAnyExpenseTx(ledgerId: 'ledger'), isTrue);
      expect(await statistics.hasAnyExpenseTx(ledgerId: 'other'), isFalse);
      expect(reads.rowCounts, [1, 0]);
      expect(reads.resultColumns.first, hasLength(1));
    } catch (error, stackTrace) {
      logger.error('StatisticsRangeTest', '支出存在性读取规模验证失败', error, stackTrace);
      rethrow;
    }
  });
}
