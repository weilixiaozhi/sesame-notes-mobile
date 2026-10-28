import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/presentation/analytics_summary.dart';

/// 验证分类汇总的比例完整性和零金额边界。
void main() {
  group('分类占比聚合', () {
    /// 6 个分类（金额降序），合计 2050。
    List<({String name, double total})> sixCategories() => [
      (name: '餐饮', total: 600),
      (name: '交通', total: 500),
      (name: '购物', total: 400),
      (name: '娱乐', total: 300),
      (name: '医疗', total: 200),
      (name: '教育', total: 50),
    ];

    test('归并分类后占比仍按完整总额计算', () {
      final donut = buildDonutCategories(
        categories: sixCategories(),
        total: 2050,
        otherLabel: '其他',
      );

      expect(donut.first.percent, closeTo(600 / 2050, 1e-9));
      expect(
        donut.last.percent,
        closeTo(50 / 2050, 1e-9),
        reason: '「其他」占比按剩余分类合计计算（50/2050≈2.4%），不是被丢弃',
      );
      expect(
        donut.fold<double>(0, (sum, e) => sum + e.percent),
        closeTo(1, 1e-9),
        reason: '各扇区占比合计必须恒等于 100%，避免只画 Top5 形成「假 100%」',
      );
    });

    test('总支出为 0：占比为 0，不做除法', () {
      final donut = buildDonutCategories(
        categories: [(name: '餐饮', total: 0.0)],
        total: 0,
        otherLabel: '其他',
      );

      expect(donut.single.percent, 0);
    });
  });
}
