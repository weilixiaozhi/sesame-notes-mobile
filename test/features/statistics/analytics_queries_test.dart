import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/statistics/application/analytics_queries.dart';
import 'package:sesame_notes/features/statistics/application/statistics_queries.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/utils/date/analytics_sub_tabs.dart';
import 'package:sesame_notes/utils/date/month_range.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 按固定查询结果验证分类组合，不依赖页面生命周期。
class _Queries extends Fake implements StatisticsQueries {
  List<CategoryHierarchyTotal> hierarchy = [];
  Map<String, CategoryDisplay> synthetic = {};
  Map<String, CategoryDisplay> categories = {};
  Set<String> requestedCategoryIds = {};
  String? requestedLedgerId;
  int categoryReads = 0;
  final requestedRanges = <DateRange>[];
  Object? failure;

  /// 当前区间提供分类层级行，错误场景模拟读取失败。
  @override
  Future<List<CategoryHierarchyTotal>> totalsByCategoryWithHierarchy({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    if (failure case final error?) throw error;
    return hierarchy;
  }

  /// 记录日序列读取范围，确保只为当前展示期间取数。
  @override
  Future<List<({DateTime day, double total})>> totalsByDay({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async {
    requestedRanges.add((start: start, end: end));
    return [(day: start, total: 11.0)];
  }

  /// 笔数直接由测试提供的分类聚合行数量决定。
  @override
  Future<int> countByTypeInRange({
    required String ledgerId,
    required String type,
    required DateTime start,
    required DateTime end,
  }) async => hierarchy.length;

  /// 返回共享账本本次查询固定的分类快照。
  @override
  Future<Map<String, CategoryDisplay>> sharedSyntheticCategories(
    String ledgerId,
  ) async => synthetic;

  /// 记录批量分类查询，确保父子分类不会逐个读取。
  @override
  Future<Map<String, CategoryDisplay>> categoriesByIds(
    Iterable<String> ids, {
    String? ledgerId,
  }) async {
    categoryReads++;
    requestedCategoryIds = ids.toSet();
    requestedLedgerId = ledgerId;
    return categories;
  }
}

/// 构造分类快照，名称可区别于聚合行以验证显示优先级。
CategoryDisplay _category(String id, String name, {String? parentId}) =>
    CategoryDisplay(
      id: id,
      name: name,
      kind: 'expense',
      level: parentId == null ? 1 : 2,
      sortOrder: 0,
      parentId: parentId,
    );

/// 构造区间聚合行，允许空分类标识和缺失的分类快照。
CategoryHierarchyTotal _row(
  String? id,
  String name,
  double total, {
  String? parentId,
}) => (
  id: id,
  name: name,
  icon: null,
  parentId: parentId,
  level: parentId == null ? 1 : 2,
  total: total,
);

/// 使用固定的月账期执行应用查询。
Future<AnalyticsData> _loadMonth(StatisticsQueries queries) =>
    AnalyticsQueries(queries).load(
      ledgerId: 'ledger',
      type: 'expense',
      period: AnalyticsPeriod.month,
      selectedYear: 2028,
      monthStartDay: 1,
      current: (start: DateTime(2028, 3), end: DateTime(2028, 4)),
    );

/// 验证分类组合、账期边界和读取失败的真实业务行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await logger.clear();
  });

  tearDown(() async => logger.clear());

  test('分类合并保留共享名称、未分类、缺失快照和子分类顺序', () async {
    final queries = _Queries()
      ..hierarchy = [
        _row('child-b', '旧子类乙', 20, parentId: 'parent'),
        _row('shared-child', '旧共享子类', 9, parentId: 'shared-parent'),
        _row('parent', '旧父类', 5),
        _row('child-a', '旧子类甲', 3, parentId: 'parent'),
        _row(null, '未分类', 7),
        _row('missing', '已删除分类', 6),
      ]
      ..synthetic = {
        'shared-parent': _category('shared-parent', '共享父类'),
        'shared-child': _category(
          'shared-child',
          '共享子类',
          parentId: 'shared-parent',
        ),
      }
      ..categories = {
        'parent': _category('parent', '本地父类'),
        'child-b': _category('child-b', '子类乙', parentId: 'parent'),
        'child-a': _category('child-a', '子类甲', parentId: 'parent'),
        'shared-parent': _category('shared-parent', '同名本地父类'),
        'shared-child': _category('shared-child', '同名本地子类'),
      };

    final data = await _loadMonth(queries);

    expect(data.catData.map((row) => row.id), [
      'parent',
      'shared-parent',
      null,
      'missing',
    ]);
    expect(data.catData.first.total, 28);
    expect(data.catData.first.name, '本地父类');
    expect(data.catData.first.subCategories.map((row) => row.id), [
      'child-b',
      'child-a',
    ]);
    expect(data.catData[1].name, '共享父类');
    expect(data.catData[1].subCategories.single.name, '共享子类');
    expect(data.catData[2].category, isNull);
    expect(data.catData[3].name, '已删除分类');
    expect(data.catData[3].category, isNull);
    expect(data.sum, 50);
    expect(data.txCount, 6);
    expect(queries.requestedRanges, [
      (start: DateTime(2028, 3), end: DateTime(2028, 4)),
    ]);
    expect(data.series, isA<DailyAnalyticsSeries>());
    expect(queries.categoryReads, 1);
    expect(queries.requestedLedgerId, 'ledger');
    expect(queries.requestedCategoryIds, {
      'parent',
      'child-b',
      'child-a',
      'missing',
    });
  });

  test('空分类结果保留零总额和空排行榜', () async {
    final data = await _loadMonth(_Queries());
    expect(data.catData, isEmpty);
    expect(data.sum, 0);
    expect(data.txCount, 0);
  });

  test('并发读取失败保留原始异常供界面重试', () async {
    final failure = StateError('读取分类失败');
    final queries = _Queries()..failure = failure;
    await expectLater(_loadMonth(queries), throwsA(same(failure)));
    expect(queries.categoryReads, 0);
  });

  group('真实仓储账期查询', () {
    late SesameDatabase database;
    late LocalRepository repository;
    late ProviderContainer container;
    late String ledgerId;

    setUp(() async {
      database = SesameDatabase.withExecutor(NativeDatabase.memory());
      repository = LocalRepository(database);
      container = ProviderContainer(
        overrides: [statisticsDataAccessProvider.overrideWithValue(repository)],
      );
      ledgerId = await repository.createLedger(
        name: '统计账本',
        monthStartDay: 31,
        storageMode: 'local',
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    /// 写入指定日期的支出，交由真实仓储处理筛选与金额聚合。
    Future<void> addExpense(DateTime date, String amount) async {
      await repository.addTransaction(
        ledgerId: ledgerId,
        type: 'expense',
        amount: amount,
        happenedAt: date,
      );
    }

    /// 查询完整年度或已截止到指定日期的当前年度。
    Future<AnalyticsData> loadYear(int year, {DateTime? end}) {
      final current = yearRangeFor(year, 31);
      return container
          .read(analyticsQueriesProvider)
          .load(
            ledgerId: ledgerId,
            type: 'expense',
            period: AnalyticsPeriod.year,
            selectedYear: year,
            monthStartDay: 31,
            current: (start: current.start, end: end ?? current.end),
          );
    }

    test('当前年度趋势和分类均截止今天，未来同账期交易不混入曲线', () async {
      await addExpense(DateTime(2028, 1, 30), '500');
      await addExpense(DateTime(2028, 1, 31), '10');
      await addExpense(DateTime(2028, 2, 29), '20');
      await addExpense(DateTime(2028, 3, 4), '0.1');
      await addExpense(DateTime(2028, 3, 5, 23), '0.2');
      // 3 月 6 日仍属二月账期，但晚于本次查询的今天，不能进入二月曲线。
      await addExpense(DateTime(2028, 3, 6), '90');
      await addExpense(DateTime(2028, 3, 31), '100');

      final data = await loadYear(2028, end: DateTime(2028, 3, 6));
      final points = (data.series as MonthlyAnalyticsSeries).points;

      expect(points, hasLength(12));
      expect(points[0].total, 10);
      expect(points[1].total, 20.3);
      expect(points.skip(2).every((point) => point.total == 0), isTrue);
      expect(data.sum, 30.3);
      expect(data.txCount, 4);
      expect(
        points.fold<double>(0, (sum, point) => sum + point.total),
        data.sum,
      );
    });

    test('历史年度保留十二账期，次年一月底以前的数据属于十二月', () async {
      await addExpense(DateTime(2027, 1, 31), '3');
      await addExpense(DateTime(2027, 2, 28), '4');
      await addExpense(DateTime(2028, 1, 30), '5');
      await addExpense(DateTime(2028, 1, 31), '100');

      final data = await loadYear(2027);
      final points = (data.series as MonthlyAnalyticsSeries).points;

      expect(points, hasLength(12));
      expect(points.map((point) => point.month.year).toSet(), {2027});
      expect(points[0].total, 3);
      expect(points[1].total, 4);
      expect(points.last.total, 5);
      expect(data.sum, 12);
      expect(data.txCount, 3);
    });
  });
}
