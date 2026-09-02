// ConfigExportService 扩展测试。
//
// 锚点：
//   - 配置模型 toMap/fromMap 往返不失真；
//   - 导出：按 options 过滤账本/分类/周期/应用设置，关联数据强制导出；
//   - 导入：按「父级作用域唯一」去重、跳过已存在、找不到父分类/账本时跳过
//     并记录；
//   - detectContent 正确识别配置项类型。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/config_export_service.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';

class _MockRepo extends Mock implements LocalRepository {}

Category _cat(String id, String name, {String? parentId, int level = 1}) =>
    Category(
      id: id,
      name: name,
      kind: 'expense',
      icon: 'utensils',
      sortOrder: 0,
      parentId: parentId,
      level: level,
      updatedAt: DateTime(2026, 1, 1),
    );

Ledger _ledger(String id, String name, {String currency = 'CNY'}) => Ledger(
  id: id,
  name: name,
  currency: currency,
  monthStartDay: 1,
  aaEnabled: false,
  role: 'owner',
  memberCount: 1,
  storageMode: 'local',
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

RecurringTransaction _recurring(
  String id, {
  required String ledgerId,
  String currencyCode = 'CNY',
  String? categoryId,
  String? note,
  int? dayOfMonth,
  DateTime? endDate,
}) => RecurringTransaction(
  id: id,
  ledgerId: ledgerId,
  txType: 'expense',
  amount: '123.45',
  currencyCode: currencyCode,
  categoryId: categoryId,
  note: note,
  frequency: 'monthly',
  interval: 1,
  dayOfMonth: dayOfMonth,
  dayOfWeek: null,
  monthOfYear: null,
  startDate: DateTime(2026, 1, 15),
  endDate: endDate,
  lastGeneratedDate: null,
  enabled: true,
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('配置模型往返', () {
    test('AppSettingsConfig 全字段往返', () {
      final cfg = AppSettingsConfig(
        reminderEnabled: true,
        reminderHour: 21,
        reminderMinute: 30,
        languageCode: 'zh',
        countryCode: 'CN',
        fontScaleLevel: 2,
        customFontScale: 1.25,
        themeMode: 'dark',
      );
      final restored = AppSettingsConfig.fromMap(cfg.toMap());
      expect(restored.reminderEnabled, isTrue);
      expect(restored.reminderHour, 21);
      expect(restored.reminderMinute, 30);
      expect(restored.languageCode, 'zh');
      expect(restored.countryCode, 'CN');
      expect(restored.fontScaleLevel, 2);
      expect(restored.customFontScale, 1.25);
      expect(restored.themeMode, 'dark');
      // 空配置往返不抛错
      expect(AppSettingsConfig.fromMap(const {}).languageCode, isNull);
    });

    test('LedgerItem / LedgersConfig 往返与 fromDb', () {
      final fromDb = LedgerItem.fromDb(_ledger('led-1', '账本', currency: 'USD'));
      expect(fromDb.currency, 'USD');
      final restored = LedgerItem.fromMap(fromDb.toMap());
      expect(restored.name, '账本');
      expect(restored.type, 'personal');
      expect(restored.createdAt, isNotNull);

      final config = LedgersConfig(items: [fromDb]);
      final round = LedgersConfig.fromMap(config.toMap());
      expect(round.items.single.name, '账本');
      // 缺 currency 时默认 CNY
      expect(LedgerItem.fromMap(const {'name': 'x'}).currency, 'CNY');
    });

    test('RecurringTransactionItem 全字段往返与 fromDb', () {
      final fromDb = _recurring(
        'rt-1',
        ledgerId: 'led-1',
        categoryId: 'cat-2',
        note: '房租',
        dayOfMonth: 15,
        endDate: DateTime(2027, 1, 1),
      );
      final item = RecurringTransactionItem.fromDb(
        fromDb,
        ledgerIdToName: const {'led-1': '账本'},
        categoryIdToName: const {'cat-2': '住房'},
      );
      expect(item.ledgerName, '账本');
      expect(item.categoryName, '住房');
      expect(item.amount, '123.45');
      expect(item.currencyCode, 'CNY');
      expect(item.dayOfMonth, 15);
      expect(item.endDate, isNotNull);

      final restored = RecurringTransactionItem.fromMap(item.toMap());
      expect(restored.ledgerName, '账本');
      expect(restored.amount, '123.45');
      expect(restored.currencyCode, 'CNY');
      expect(restored.enabled, isTrue);

      // 未知账本名兜底
      final unknown = RecurringTransactionItem.fromDb(
        _recurring('rt-2', ledgerId: 'led-99'),
        ledgerIdToName: const {},
        categoryIdToName: const {},
      );
      expect(unknown.ledgerName, 'Unknown');
      expect(unknown.categoryName, isNull);
    });

    test('CategoryItem 往返、fromDb 与父级映射', () {
      final child = _cat('cat-2', '外卖', parentId: 'cat-1', level: 2);
      final item = CategoryItem.fromDb(child, '餐饮');
      expect(item.parentName, '餐饮');
      expect(item.level, 2);
      expect(item.id, 'cat-2');

      final restored = CategoryItem.fromMap(item.toMap());
      expect(restored.name, '外卖');
      expect(restored.parentName, '餐饮');
      // 缺省字段兜底
      final minimal = CategoryItem.fromMap(const {
        'name': 'x',
        'kind': 'expense',
      });
      expect(minimal.sortOrder, 0);
      expect(minimal.level, 1);

      final config = CategoriesConfig(items: [item]);
      expect(CategoriesConfig.fromMap(config.toMap()).items.single.name, '外卖');
    });

    test('AppConfig.toYaml/fromYaml 全段往返', () {
      final config = AppConfig(
        appSettings: const AppSettingsConfig(languageCode: 'zh'),
        ledgers: const LedgersConfig(items: []),
        recurringTransactions: const RecurringTransactionsConfig(items: []),
        categories: const CategoriesConfig(items: []),
      );
      final yaml = config.toYaml();
      expect(
        yaml.keys,
        containsAll([
          'app_settings',
          'ledgers',
          'recurring_transactions',
          'categories',
        ]),
      );
      final restored = AppConfig.fromYaml(Map<dynamic, dynamic>.from(yaml));
      expect(restored.appSettings?.languageCode, 'zh');

      // 无业务配置时仍保留文件身份，避免生成无法再次导入的空文件。
      final empty = AppConfig.fromYaml(const {});
      expect(empty.appSettings, isNull);
      expect(const AppConfig().toYaml(), {
        'app_id': 'sesame_notes',
        'format_version': 1,
      });
    });
  });

  group('detectContent', () {
    test('识别各段配置', () {
      final info = ConfigExportService.detectContent(
        'ledgers:\n  items: []\ncategories:\n  items: []\n'
        'recurring_transactions:\n  items: []\napp_settings: {}\n',
      );
      expect(info.hasLedgers, isTrue);
      expect(info.hasCategories, isTrue);
      expect(info.hasRecurringTransactions, isTrue);
      expect(info.hasAppSettings, isTrue);
    });

    test('非 Map / 非法 YAML → 全 false', () {
      expect(ConfigExportService.detectContent('- 1\n- 2').hasLedgers, isFalse);
      final broken = ConfigExportService.detectContent(':::bad yaml:::');
      expect(broken.hasLedgers, isFalse);
      expect(broken.hasCategories, isFalse);
    });

    test('仅应用设置也算 appSettings', () {
      final info = ConfigExportService.detectContent('app_settings: {}');
      expect(info.hasAppSettings, isTrue);
      expect(info.hasLedgers, isFalse);
    });
  });

  group('exportToYaml 全量数据', () {
    test('导出账本/分类/周期/应用设置', () async {
      final repo = _MockRepo();
      when(() => repo.getAllLedgers()).thenAnswer(
        (_) async => [
          _ledger('led-1', '账本'),
          _ledger('led-2', '美元账本', currency: 'USD'),
        ],
      );
      when(() => repo.getAllCategories()).thenAnswer(
        (_) async => [
          _cat('cat-1', '餐饮'),
          _cat('cat-2', '外卖', parentId: 'cat-1', level: 2),
        ],
      );
      when(
        () => repo.getTopLevelCategories(any()),
      ).thenAnswer((_) async => [_cat('cat-1', '餐饮')]);
      when(() => repo.getSubCategories(any())).thenAnswer(
        (_) async => [_cat('cat-2', '外卖', parentId: 'cat-1', level: 2)],
      );
      when(() => repo.getAllRecurringTransactions()).thenAnswer(
        (_) async => [
          _recurring('rt-1', ledgerId: 'led-1', categoryId: 'cat-2'),
        ],
      );
      SharedPreferences.setMockInitialValues({
        ReminderPrefs.enabled: true,
        ReminderPrefs.hour: 21,
        ReminderPrefs.minute: 30,
        'selected_language': 'zh',
        'selected_language_country': 'CN',
        'fontScaleLevel': 1,
        'customFontScale': 1.1,
        'themeMode': 'dark',
      });

      final yaml = await ConfigExportService.exportToYaml(repository: repo);
      final doc = loadYaml(yaml) as Map;
      expect((doc['ledgers'] as Map)['items'], hasLength(2));
      expect((doc['categories'] as Map)['items'], hasLength(2));
      expect((doc['recurring_transactions'] as Map)['items'], hasLength(1));
      final settings = doc['app_settings'] as Map;
      expect(settings[ReminderPrefs.enabled], isTrue);
      expect(settings['language_code'], 'zh');
      expect(settings['theme_mode'], 'dark');
    });

    test('options 关闭账本/分类时关联数据仍强制导出', () async {
      final repo = _MockRepo();
      when(() => repo.getAllLedgers()).thenAnswer(
        (_) async => [_ledger('led-1', '账本'), _ledger('led-2', '无关联')],
      );
      when(() => repo.getAllCategories()).thenAnswer(
        (_) async => [
          _cat('cat-1', '餐饮'),
          _cat('cat-2', '外卖', parentId: 'cat-1', level: 2),
        ],
      );
      when(
        () => repo.getTopLevelCategories(any()),
      ).thenAnswer((_) async => [_cat('cat-1', '餐饮')]);
      when(() => repo.getSubCategories(any())).thenAnswer(
        (_) async => [_cat('cat-2', '外卖', parentId: 'cat-1', level: 2)],
      );
      when(() => repo.getAllRecurringTransactions()).thenAnswer(
        (_) async => [
          _recurring('rt-1', ledgerId: 'led-1', categoryId: 'cat-2'),
        ],
      );

      final yaml = await ConfigExportService.exportToYaml(
        repository: repo,
        options: const ExportOptions(
          ledgers: false,
          categories: false,
          recurringTransactions: true,
          appSettings: false,
        ),
      );
      final doc = loadYaml(yaml) as Map;
      // 只导出有关联的账本 1 与关联分类（父+子）
      final ledgerItems = (doc['ledgers'] as Map)['items'] as List;
      expect(ledgerItems.single['name'], '账本');
      final catItems = (doc['categories'] as Map)['items'] as List;
      expect(
        catItems.map((e) => (e as Map)['name']),
        containsAll(['餐饮', '外卖']),
      );
    });

    test('仓库读名称映射抛错时导出不中断', () async {
      final repo = _MockRepo();
      when(() => repo.getAllLedgers()).thenThrow(Exception('boom'));
      final yaml = await ConfigExportService.exportToYaml(repository: repo);
      expect(yaml, contains('# Sesame Notes 应用配置'));
    });
  });

  group('importFromYaml 全量数据', () {
    String fullYaml() => '''
app_id: sesame_notes
format_version: 1
app_settings:
  reminder_enabled: true
  reminder_hour: 20
  reminder_minute: 15
  language_code: "zh"
  country_code: "CN"
  font_scale_level: 2
  custom_font_scale: 1.2
  theme_mode: "dark"
ledgers:
  items:
    - name: "新账本"
      currency: "USD"
    - name: "重复账本"
      currency: "USD"
categories:
  items:
    - name: "新一级"
      kind: "expense"
      sort_order: 1
      level: 1
    - name: "重复一级"
      kind: "expense"
      sort_order: 2
      level: 1
    - name: "新子"
      kind: "expense"
      parent_name: "新一级"
      sort_order: 1
      level: 2
    - name: "孤儿子"
      kind: "expense"
      parent_name: "不存在的父"
      sort_order: 1
      level: 2
recurring_transactions:
  items:
    - ledger_name: "重复账本"
      type: "expense"
      amount: 12.34
      category_name: "新一级"
      frequency: "monthly"
      interval: 1
      day_of_month: 15
      start_date: "2026-01-15T00:00:00.000"
      enabled: true
    - ledger_name: "不存在的账本"
      type: "expense"
      amount: 5.0
      frequency: "weekly"
      interval: 1
      start_date: "2026-01-15T00:00:00.000"
      enabled: true
''';

    test('导入应用设置、账本、分类与周期', () async {
      final repo = _MockRepo();
      // 有状态 mock：导入流程创建账本后 getAllLedgers 必须能看到它，
      // 周期账单才能按名称匹配到新建账本。
      final ledgers = <Ledger>[_ledger('led-1', '重复账本')];
      when(
        () => repo.getAllLedgers(),
      ).thenAnswer((_) async => List.of(ledgers));
      // 有状态分类集合：批量插入后第二步按 parentName 反查父分类。
      final categories = <Category>[_cat('cat-1', '重复一级')];
      when(
        () => repo.getAllCategories(),
      ).thenAnswer((_) async => List.of(categories));
      when(
        () => repo.createLedger(
          name: any(named: 'name'),
          currency: any(named: 'currency'),
          storageMode: any(named: 'storageMode'),
        ),
      ).thenAnswer((inv) async {
        final name = inv.namedArguments[#name] as String;
        ledgers.add(_ledger('led-${100 + ledgers.length}', name));
        return ledgers.last.id;
      });
      when(() => repo.batchInsertCategories(any())).thenAnswer((inv) async {
        final list = inv.positionalArguments.first as List<CategoriesCompanion>;
        for (final c in list) {
          categories.add(
            Category(
              id: 'cat-${categories.length + 1}',
              name: c.name.value,
              kind: c.kind.value,
              icon: c.icon.value,
              sortOrder: c.sortOrder.value,
              parentId: c.parentId.present ? c.parentId.value : null,
              level: c.level.value,
              updatedAt: c.updatedAt.value,
            ),
          );
        }
      });
      when(
        () => repo.addRecurringTransaction(
          ledgerId: any(named: 'ledgerId'),
          type: any(named: 'type'),
          amount: any(named: 'amount'),
          currencyCode: any(named: 'currencyCode'),
          categoryId: any(named: 'categoryId'),
          note: any(named: 'note'),
          frequency: any(named: 'frequency'),
          interval: any(named: 'interval'),
          dayOfMonth: any(named: 'dayOfMonth'),
          dayOfWeek: any(named: 'dayOfWeek'),
          monthOfYear: any(named: 'monthOfYear'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          enabled: any(named: 'enabled'),
        ),
      ).thenAnswer((_) async => 'rt-imported');

      await ConfigExportService.importFromYaml(fullYaml(), repository: repo);

      // 应用设置落盘
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ReminderPrefs.enabled), isTrue);
      expect(prefs.getInt(ReminderPrefs.hour), 20);
      expect(prefs.getString('selected_language'), 'zh');
      expect(prefs.getDouble('customFontScale'), 1.2);
      expect(prefs.getString('themeMode'), 'dark');

      // 账本：跳过已存在，只建新账本
      verify(
        () => repo.createLedger(
          name: any(named: 'name'),
          currency: any(named: 'currency'),
          storageMode: any(named: 'storageMode'),
        ),
      ).called(1);
      verifyNever(
        () => repo.createLedger(
          name: '重复账本',
          currency: any(named: 'currency'),
          storageMode: any(named: 'storageMode'),
        ),
      );

      // 分类：一级跳过已存在、二级孤儿跳过；批量插入包含新一级+新子
      final insertedCompanions = verify(
        () => repo.batchInsertCategories(captureAny()),
      ).captured.cast<List<CategoriesCompanion>>().expand((e) => e).toList();
      expect(
        insertedCompanions.map((c) => c.name.value),
        containsAll(['新一级', '新子']),
      );
      expect(
        insertedCompanions.map((c) => c.name.value),
        isNot(contains('孤儿子')),
      );

      // 周期：导入成功 1 条、缺账本跳过 1 条
      verify(
        () => repo.addRecurringTransaction(
          ledgerId: any(named: 'ledgerId'),
          type: any(named: 'type'),
          amount: any(named: 'amount'),
          currencyCode: 'USD',
          categoryId: any(named: 'categoryId'),
          note: any(named: 'note'),
          frequency: any(named: 'frequency'),
          interval: any(named: 'interval'),
          dayOfMonth: any(named: 'dayOfMonth'),
          dayOfWeek: any(named: 'dayOfWeek'),
          monthOfYear: any(named: 'monthOfYear'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          enabled: any(named: 'enabled'),
        ),
      ).called(1);
    });

    test('非 Map YAML 抛 FormatException', () async {
      expect(
        () => ConfigExportService.importFromYaml('- 1\n- 2'),
        throwsFormatException,
      );
    });

    test('options.none 时不导入任何内容', () async {
      final repo = _MockRepo();
      when(() => repo.getAllLedgers()).thenAnswer((_) async => <Ledger>[]);
      when(() => repo.getAllCategories()).thenAnswer((_) async => <Category>[]);
      await ConfigExportService.importFromYaml(
        fullYaml(),
        repository: repo,
        options: ExportOptions.none,
      );
      verifyNever(
        () => repo.createLedger(
          name: any(named: 'name'),
          currency: any(named: 'currency'),
          storageMode: any(named: 'storageMode'),
        ),
      );
      verifyNever(() => repo.batchInsertCategories(any()));
      verifyNever(
        () => repo.addRecurringTransaction(
          ledgerId: any(named: 'ledgerId'),
          type: any(named: 'type'),
          amount: any(named: 'amount'),
          currencyCode: any(named: 'currencyCode'),
          categoryId: any(named: 'categoryId'),
          note: any(named: 'note'),
          frequency: any(named: 'frequency'),
          interval: any(named: 'interval'),
          dayOfMonth: any(named: 'dayOfMonth'),
          dayOfWeek: any(named: 'dayOfWeek'),
          monthOfYear: any(named: 'monthOfYear'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          enabled: any(named: 'enabled'),
        ),
      );
    });
  });
}
