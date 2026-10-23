import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/features/transactions/domain/category_detail_summary.dart';

/// 构造分类详情口径的交易：金额为规范化 decimal 字符串。
TransactionDisplay buildTx({
  required String id,
  required String amount,
  String? nativeAmount,
  required DateTime happenedAt,
  String? categoryId,
}) => TransactionDisplay(
  id: id,
  ledgerId: '1',
  txType: 'expense',
  amount: amount,
  happenedAt: happenedAt,
  categoryId: categoryId,
  currencyCode: 'CNY',
  nativeAmount: nativeAmount ?? amount,
  version: 1,
  createdAt: happenedAt,
  updatedAt: happenedAt,
);

void main() {
  group('分类详情汇总 summarizeCategoryDetail', () {
    test('父分类 10.00 + 子分类 20.00：总额 30、笔数 2、平均 15', () {
      final day = DateTime(2026, 7, 20);
      final summary = summarizeCategoryDetail([
        buildTx(id: '1', amount: '10.00', happenedAt: day, categoryId: '10'),
        buildTx(id: '2', amount: '20.00', happenedAt: day, categoryId: '101'),
      ]);

      expect(summary.totalCount, 2);
      expect(summary.totalAmount, 30);
      expect(summary.averageAmount, 15);
    });

    test('总额按 Decimal 累加：0.1 + 0.2 精确等于 0.3，无浮点尾差', () {
      final day = DateTime(2026, 7, 20);
      final summary = summarizeCategoryDetail([
        buildTx(id: '1', amount: '0.1', happenedAt: day),
        buildTx(id: '2', amount: '0.2', happenedAt: day),
      ]);

      // 直接 double 相加会得到 0.30000000000000004。
      expect(summary.totalAmount, 0.3);
      expect(summary.averageAmount, 0.15);
    });

    test('平均 = 总额 / 笔数，除不尽时保留完整精度', () {
      final day = DateTime(2026, 7, 20);
      final summary = summarizeCategoryDetail([
        buildTx(id: '1', amount: '10.00', happenedAt: day),
        buildTx(id: '2', amount: '10.00', happenedAt: day),
        buildTx(id: '3', amount: '10.00', happenedAt: day),
      ]);

      expect(summary.totalAmount, 30);
      expect(summary.averageAmount, 10);
    });

    test('金额口径：优先 nativeAmount，空串回退原币金额，解析失败按 0', () {
      final day = DateTime(2026, 7, 20);
      expect(
        categoryDetailAmountOf(
          buildTx(
            id: '1',
            amount: '7.00',
            nativeAmount: '50.75',
            happenedAt: day,
          ),
        ).toDouble(),
        50.75,
        reason: '有折本位币金额时以它为准',
      );
      expect(
        categoryDetailAmountOf(
          buildTx(id: '2', amount: '7', nativeAmount: '', happenedAt: day),
        ).toDouble(),
        7,
        reason: 'nativeAmount 为空串时回退原币金额',
      );
      expect(
        categoryDetailAmountOf(
          buildTx(id: '3', amount: 'abc', nativeAmount: '', happenedAt: day),
        ).toDouble(),
        0,
        reason: '非法金额兜底 0，不能让单条脏数据拖垮整组汇总',
      );
    });

    test('无交易：笔数、总额、平均都为 0，不做除零', () {
      final summary = summarizeCategoryDetail([]);

      expect(summary.totalCount, 0);
      expect(summary.totalAmount, 0);
      expect(summary.averageAmount, 0);
    });
  });

  group('日期分组 groupCategoryDetailByDate', () {
    test('父子分类交易同一天合并为一组，日小计合并统计', () {
      final groups = groupCategoryDetailByDate(
        [
          buildTx(
            id: '1',
            amount: '10.00',
            happenedAt: DateTime(2026, 7, 20, 12),
            categoryId: '10',
          ),
          buildTx(
            id: '2',
            amount: '20.00',
            happenedAt: DateTime(2026, 7, 20, 18),
            categoryId: '101',
          ),
        ],
        isAmountSort: false,
        timeDesc: true,
      );

      expect(groups, hasLength(1), reason: '同一平铺列表只按日期分组');
      expect(groups.single.dateKey, '2026-07-20');
      expect(groups.single.expense, 30, reason: '日小计汇总父分类与子分类交易');
      expect(groups.single.transactions.map((t) => t.id), ['1', '2']);
    });

    test('不同日期各自成组，日小计按组独立计算', () {
      final groups = groupCategoryDetailByDate(
        [
          buildTx(
            id: '1',
            amount: '10.00',
            happenedAt: DateTime(2026, 7, 20, 9),
          ),
          buildTx(
            id: '2',
            amount: '20.00',
            happenedAt: DateTime(2026, 7, 21, 9),
          ),
          buildTx(
            id: '3',
            amount: '5.50',
            happenedAt: DateTime(2026, 7, 21, 20),
          ),
        ],
        isAmountSort: false,
        timeDesc: true,
      );

      expect(groups.map((g) => g.dateKey), ['2026-07-21', '2026-07-20']);
      expect(groups.first.expense, 25.5);
      expect(groups.last.expense, 10);
    });

    test('时间升序时日期标题按日期键升序', () {
      final groups = groupCategoryDetailByDate(
        [
          buildTx(
            id: '1',
            amount: '10.00',
            happenedAt: DateTime(2026, 7, 21, 9),
          ),
          buildTx(
            id: '2',
            amount: '20.00',
            happenedAt: DateTime(2026, 7, 20, 9),
          ),
        ],
        isAmountSort: false,
        timeDesc: false,
      );

      expect(groups.map((g) => g.dateKey), ['2026-07-20', '2026-07-21']);
    });

    test('金额排序时保持传入顺序，只切日期标题', () {
      // 金额降序：7-20 的 100 排在 7-21 的 1 之前，日期标题不得再按日期重排。
      final groups = groupCategoryDetailByDate(
        [
          buildTx(
            id: '1',
            amount: '100.00',
            happenedAt: DateTime(2026, 7, 20, 9),
          ),
          buildTx(
            id: '2',
            amount: '1.00',
            happenedAt: DateTime(2026, 7, 21, 9),
          ),
        ],
        isAmountSort: true,
        timeDesc: true,
      );

      expect(groups.map((g) => g.dateKey), ['2026-07-20', '2026-07-21']);
      expect(groups.first.transactions.single.id, '1');
    });

    test('空列表：无分组', () {
      expect(
        groupCategoryDetailByDate([], isAmountSort: false, timeDesc: true),
        isEmpty,
      );
    });
  });
}
