import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/statistics/application/aa_statistics_providers.dart';

/// 成员支出汇总口径：合计金额、总笔数与单人占比。
void main() {
  test('成员支出合计、笔数与占比按统计数据计算', () {
    const stats = [
      MemberExpenseStatItem(
        participantId: 'self',
        displayName: '这是需要省略展示的很长的成员姓名',
        expenseTotal: 123456.75,
        txCount: 12,
        isSelf: true,
      ),
      MemberExpenseStatItem(
        participantId: 'other',
        displayName: '另一位成员',
        expenseTotal: 41152.25,
        txCount: 4,
      ),
    ];

    final summary = MemberExpenseSummary.from(stats);

    // 合计为两名成员金额之和：123456.75 + 41152.25 = 164609。
    expect(summary.totalExpense, closeTo(164609, 0.001));
    // 汇总口径：支出人数与总笔数。
    expect(summary.memberCount, 2);
    expect(summary.txCount, 16);
    // 占比按各自金额占合计的比例计算：75% / 25%。
    expect(summary.sharePercentOf(stats[0]), closeTo(75, 0.001));
    expect(summary.sharePercentOf(stats[1]), closeTo(25, 0.001));
  });

  test('合计为 0 时占比按 0 处理，不产生除零', () {
    const stats = [
      MemberExpenseStatItem(
        participantId: 'u1',
        displayName: '张三',
        expenseTotal: 0,
        txCount: 3,
      ),
    ];

    final summary = MemberExpenseSummary.from(stats);

    expect(summary.totalExpense, 0);
    expect(summary.sharePercentOf(stats.single), 0);
  });

  test('无成员支出时合计、笔数与人数均为 0', () {
    final summary = MemberExpenseSummary.from(const []);

    expect(summary.totalExpense, 0);
    expect(summary.txCount, 0);
    expect(summary.memberCount, 0);
  });
}
