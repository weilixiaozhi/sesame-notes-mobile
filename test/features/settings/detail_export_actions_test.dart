import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/contracts/category_query_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/settings/application/detail_export_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/day_csv_service.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';

import '../../helpers/test_isolation.dart';

/// 账本明细导出用仓储：本用例只关心财务 CSV 的生成时机，交易内容不参与断言。
class _LedgerRepository extends Mock implements LocalRepository {}

/// 分类查询独立注入，导入导出不能依赖组合仓储的查询转发。
class _CategoryQueries extends Mock implements CategoryQueryRepository {}

String _categoryLabel(String? name) => name ?? '未分类';

/// 导出文案由页面按当前语言组装，逻辑测试用固定文案。
const _copy = (
  ledgerBusiness: '记账',
  dayBusiness: '日子',
  memoBusiness: '备忘录',
  fitnessBusiness: '健身',
  memoTypeNormal: '普通',
  memoTypeCredentials: '凭证',
  ledgerLabels: (
    type: '类型',
    category: '分类',
    subCategory: '二级分类',
    amount: '金额',
    currency: '币种',
    note: '备注',
    time: '时间',
    expense: '支出',
  ),
  categoryLabel: _categoryLabel,
);

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const a = '11111111-1111-4111-8111-111111111111';
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const shareChannel = MethodChannel('dev.fluttercommunity.plus/share');
  late Directory temp;
  late SesameDatabase db;
  late DayRepository days;
  late _LedgerRepository ledgers;
  late _CategoryQueries categoryQueries;
  late ProviderContainer container;
  late WidgetRef widgetRef;
  late Completer<void> ledgerStarted;
  late Completer<void> continueLedger;
  late List<List<String>> shared;
  String? account;
  var generation = 0;
  final now = DateTime.utc(2026, 9, 7);
  final ledger = Ledger(
    id: 'ledger',
    name: '账本',
    currency: 'CNY',
    role: 'owner',
    memberCount: 1,
    monthStartDay: 1,
    storageMode: 'local',
    aaEnabled: false,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() async {
    resetGlobalTestState();
    temp = await Directory('Temp').absolute.createTemp('day-export-actions-');
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    days = DayRepository(db, validateAndProject: validateAndProject);
    await days.createBook(id: a, name: '日子A');
    await days.createBook(
      id: '22222222-2222-4222-8222-222222222222',
      name: '日子B',
    );
    await days.saveEvent(
      DayEvent(
        id: '33333333-3333-4333-8333-333333333333',
        dayBookId: a,
        definition: DayEventDefinition(
          name: '仅属于A的生日',
          category: DayCategory.birthday,
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.day,
          event: OriginalDate.solar(DateOnly(2020, 1, 1)),
        ),
        createdAt: now,
        updatedAt: now,
      ),
    );
    ledgers = _LedgerRepository();
    categoryQueries = _CategoryQueries();
    when(() => ledgers.getLedgerById('ledger')).thenAnswer((_) async => ledger);
    when(
      () => categoryQueries.getAllCategoriesIncludingShared(ledgerId: 'ledger'),
    ).thenAnswer((_) async => []);
    ledgerStarted = Completer<void>();
    continueLedger = Completer<void>();
    when(
      () => ledgers.transactionsWithCategoryAll(ledgerId: 'ledger'),
    ).thenAnswer((_) async {
      ledgerStarted.complete();
      await continueLedger.future;
      return [];
    });
    shared = [];
    account = null;
    generation = 0;
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(ledgers),
        categoryQueriesProvider.overrideWithValue(categoryQueries),
        dayRepositoryProvider.overrideWithValue(days),
        currentAccountIdProvider.overrideWith((ref) => account),
        authIdentityGenerationProvider.overrideWith((ref) => generation),
      ],
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      pathChannel,
      (call) async => temp.path,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(shareChannel, (
      call,
    ) async {
      final args = call.arguments as Map;
      final paths = (args['paths'] as List).cast<String>();
      shared.add([for (final path in paths) await File(path).readAsString()]);
      return 'dev.fluttercommunity.plus/share/success';
    });
  });

  tearDown(() async {
    container.dispose();
    await db.close();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, null);
    binding.defaultBinaryMessenger.setMockMethodCallHandler(shareChannel, null);
    await temp.delete(recursive: true);
  });

  /// 捕获与容器绑定的 WidgetRef：导出动作与页面走同一入口形态。
  Future<void> pumpHarness(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (_, ref, _) {
            widgetRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );
  }

  /// 启动导出并停在财务 CSV 生成中，让测试在文件尚未全部完成时注入干扰。
  Future<Future<ShareResult?>> startExport(WidgetTester tester) async {
    late Future<ShareResult?> exporting;
    await tester.runAsync(() async {
      exporting = DetailExportActions(widgetRef.read).export(
        (
          ledgerId: 'ledger',
          dayBookId: a,
          memoBookId: null,
          fitnessSpaceId: null,
        ),
        copy: _copy,
        isPageActive: () => true,
      );
      await ledgerStarted.future;
    });
    return exporting;
  }

  /// 失败导出不得在临时目录留下残缺文件。
  List<File> generatedFiles() =>
      temp.listSync(recursive: true).whereType<File>().toList();

  testWidgets('财务生成期间来源A被删除，整次导出失败且不替换成B或分享部分文件', (tester) async {
    await pumpHarness(tester);
    final exporting = await startExport(tester);
    await tester.runAsync(() async {
      await days.deleteBook(await days.target(a));
      continueLedger.complete();
    });
    await tester.runAsync(
      () => expectLater(exporting, throwsA(isA<StateError>())),
    );
    expect(shared, isEmpty, reason: '来源失效时不得交付任何文件');
    expect(
      await tester.runAsync(() => days.getBooks()),
      hasLength(1),
      reason: '来源A被删除后只剩B，导出不得改用B继续',
    );
    expect(generatedFiles(), isEmpty, reason: '失败后清理已生成的残缺文件');
  });

  testWidgets('财务生成期间账号会话变化，不能按新会话继续交付旧选择的日子文件', (tester) async {
    await pumpHarness(tester);
    final exporting = await startExport(tester);
    await tester.runAsync(() async {
      account = 'new-account';
      generation++;
      container.invalidate(currentAccountIdProvider);
      container.invalidate(authIdentityGenerationProvider);
      continueLedger.complete();
    });
    await tester.runAsync(
      () => expectLater(exporting, throwsA(isA<StateError>())),
    );
    expect(shared, isEmpty, reason: '会话变化后旧选择作废，不交付任何文件');
    expect(generatedFiles(), isEmpty);
  });

  testWidgets('仅导出财务时换号也不得交付原会话文件', (tester) async {
    await pumpHarness(tester);
    await tester.runAsync(() async {
      final exporting = DetailExportActions(widgetRef.read).export(
        (
          ledgerId: 'ledger',
          dayBookId: null,
          memoBookId: null,
          fitnessSpaceId: null,
        ),
        copy: _copy,
        isPageActive: () => true,
      );
      final assertion = expectLater(exporting, throwsA(isA<StateError>()));
      await ledgerStarted.future;
      account = 'another-account';
      generation++;
      container.invalidate(currentAccountIdProvider);
      container.invalidate(authIdentityGenerationProvider);
      continueLedger.complete();
      await assertion;
    });
    expect(shared, isEmpty);
    expect(generatedFiles(), isEmpty);
  });

  testWidgets('来源保持有效时两种文件全部完成后仅分享一次且日子仍来自A', (tester) async {
    await pumpHarness(tester);
    final exporting = await startExport(tester);
    final result = await tester.runAsync(() async {
      continueLedger.complete();
      return exporting;
    });
    expect(result?.status, ShareResultStatus.success);
    expect(shared, hasLength(1), reason: '全部文件完成后只交付一次');
    expect(shared.single, hasLength(2), reason: '财务 CSV 与日子 CSV 一次交付');
    final csv = shared.single.singleWhere((text) => text.contains('仅属于A的生日'));
    expect(
      DayCsvService.decode(utf8.encode(csv)).entries.single.definition.name,
      '仅属于A的生日',
      reason: '日子文件仍来自入口选定的 A',
    );
  });

  for (final failSecondShare in [false, true]) {
    testWidgets('并行同名导出独占目录，后完成或失败的分享不能删除先前文件（失败=$failSecondShare）', (
      tester,
    ) async {
      await pumpHarness(tester);
      await tester.runAsync(() async {
        when(
          () => ledgers.transactionsWithCategoryAll(ledgerId: 'ledger'),
        ).thenAnswer((_) async => []);
        final unrelated = File(
          '${temp.path}${Platform.pathSeparator}cache.txt',
        );
        await unrelated.writeAsString('其他操作的缓存');
        final firstSharing = Completer<List<String>>();
        final releaseFirst = Completer<void>();
        final deliveries = <List<String>>[];
        binding.defaultBinaryMessenger.setMockMethodCallHandler(shareChannel, (
          call,
        ) async {
          final paths = ((call.arguments as Map)['paths'] as List)
              .cast<String>();
          deliveries.add(paths);
          // 分享期间文件必须保持可读；第一次交付停住以制造真实重叠。
          for (final path in paths) {
            expect(await File(path).readAsString(), contains('类型'));
          }
          if (deliveries.length == 1) {
            firstSharing.complete(paths);
            await releaseFirst.future;
          } else if (failSecondShare) {
            throw PlatformException(code: 'share_failed', message: '交付失败');
          }
          return 'dev.fluttercommunity.plus/share/success';
        });
        final actions = DetailExportActions(widgetRef.read);
        const selection = (
          ledgerId: 'ledger',
          dayBookId: null,
          memoBookId: null,
          fitnessSpaceId: null,
        );
        final first = actions.export(
          selection,
          copy: _copy,
          isPageActive: () => true,
        );
        try {
          final firstPaths = await firstSharing.future;
          final second = actions.export(
            selection,
            copy: _copy,
            isPageActive: () => true,
          );
          if (failSecondShare) {
            await expectLater(second, throwsA(isA<PlatformException>()));
          } else {
            expect((await second)?.status, ShareResultStatus.success);
          }
          expect(deliveries, hasLength(2));
          final firstFile = File(firstPaths.single);
          final secondFile = File(deliveries.last.single);
          expect(firstFile.parent.path, isNot(secondFile.parent.path));
          expect(await firstFile.exists(), isTrue);
          expect(await secondFile.parent.exists(), isFalse);
          expect(await unrelated.readAsString(), '其他操作的缓存');
        } finally {
          releaseFirst.complete();
          expect((await first)?.status, ShareResultStatus.success);
        }
        expect(
          temp.listSync().whereType<Directory>(),
          isEmpty,
          reason: '两个操作结束后分别回收各自目录',
        );
        expect(await unrelated.readAsString(), '其他操作的缓存');
      });
    });
  }
}
