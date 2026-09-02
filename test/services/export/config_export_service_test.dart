// 配置导出服务测试。
//
// 覆盖两个安全/正确性契约：
//   1. 配置导入拒绝缺少 Sesame Notes 格式头的文件；
//   2. 手工 YAML 输出对特殊字符（引号、换行）正确转义，往返解析不失真。

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaml/yaml.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/config_export_service.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.getAllLedgers()).thenAnswer((_) async => <Ledger>[]);
    when(() => repo.getAllCategories()).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.getTopLevelCategories(any()),
    ).thenAnswer((_) async => <Category>[]);
    when(
      () => repo.getAllRecurringTransactions(),
    ).thenAnswer((_) async => <RecurringTransaction>[]);
  });

  test('配置导入拒绝缺少 Sesame Notes 格式头的文件', () async {
    SharedPreferences.setMockInitialValues({});

    await expectLater(
      ConfigExportService.importFromYaml('{}'),
      throwsA(isA<FormatException>()),
    );
  });

  test('账本名含引号/换行时导出 YAML 仍可解析且值不失真', () async {
    // 本用例需要 SharedPreferences mock 才能调 exportToYaml;
    // 随机顺序下可能先于其它用例执行,必须自备初始值,不能依赖同文件前序用例。
    SharedPreferences.setMockInitialValues({});
    when(() => repo.getAllLedgers()).thenAnswer(
      (_) async => [
        Ledger(
          id: 'led-1',
          name: '引号"账本\n新行',
          currency: 'CNY',
          monthStartDay: 1,
          aaEnabled: false,
          role: 'owner',
          memberCount: 1,
          storageMode: 'local',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    final yaml = await ConfigExportService.exportToYaml(
      repository: repo,
      options: const ExportOptions(
        ledgers: true,
        categories: false,
        recurringTransactions: false,
        appSettings: false,
      ),
    );
    final doc = loadYaml(yaml) as Map;
    final items = (doc['ledgers'] as Map)['items'] as List;
    expect((items.single as Map)['name'], '引号"账本\n新行');
  });
}
