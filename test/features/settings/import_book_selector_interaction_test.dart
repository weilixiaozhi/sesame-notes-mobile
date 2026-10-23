import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/settings/application/import_book_options.dart';
import 'package:sesame_notes/features/settings/presentation/widgets/import_book_selector.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/widgets/app_empty.dart';
import 'package:sesame_notes/shared/widgets/app_radio_tile.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 记录状态、回调及完整堆栈，失败信息可直接定位对应业务域和阶段。
void _reportFailure(String message, Object error, StackTrace stack) {
  debugPrint('$message：$error');
  debugPrintStack(stackTrace: stack);
}

/// 使用公开候选入口驱动真实选择器，仅以本机目录读取次数观察真实重试动作。
class _SelectorFixture {
  /// 目录状态由测试控制，未登录身份使重试不依赖同步协调器或网络。
  _SelectorFixture(this.mode, {required this.options, this.selectedId}) {
    try {
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          currentAccountIdProvider.overrideWithValue(null),
          importBookOptionsProvider.overrideWith((ref, mode) => options),
          dayBooksProvider.overrideWith((ref) {
            directoryReads++;
            return Stream<List<DayBook>>.value(const []);
          }),
        ],
      );
      // 保持真实重试所刷新的目录处于订阅状态，使 invalidate 能被观察到。
      directorySubscription = container.listen(dayBooksProvider, (_, _) {});
    } catch (error, stack) {
      _reportFailure('创建导入目标选择器夹具失败 mode=${mode.name}', error, stack);
      rethrow;
    }
  }

  final AppMode mode;
  final String? selectedId;
  AsyncValue<List<ImportBookOption>> options;
  final enabled = ValueNotifier<bool>(true);
  final publications = <String?>[];
  int directoryReads = 0;
  late final ProviderContainer container;
  late final ProviderSubscription<AsyncValue<List<DayBook>>>
  directorySubscription;

  /// 将组件放入窄屏和大字号环境，状态变化沿用同一个组件实例。
  Future<void> show(WidgetTester tester) async {
    try {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: ValueListenableBuilder<bool>(
                  valueListenable: enabled,
                  builder: (context, value, _) => ImportBookSelector(
                    mode: mode,
                    selectedId: selectedId,
                    enabled: value,
                    onChanged: publications.add,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // 加载态持续转圈，只推进有限帧，避免等待永不静止的动画。
      await tester.pump();
      await tester.pump();
    } catch (error, stack) {
      _reportFailure('挂载导入目标选择器失败 mode=${mode.name}', error, stack);
      rethrow;
    }
  }

  /// 发布新的候选快照，保留选择器已记住的目标和单次回调去重状态。
  Future<void> setOptions(
    WidgetTester tester,
    AsyncValue<List<ImportBookOption>> next,
  ) async {
    try {
      options = next;
      container.invalidate(importBookOptionsProvider(mode));
      await tester.pump();
      await tester.pump();
    } catch (error, stack) {
      _reportFailure('切换导入目标目录状态失败 mode=${mode.name}', error, stack);
      rethrow;
    }
  }

  /// 禁用只限制手动操作，组件实例和已记住的首选目标继续保留。
  Future<void> setEnabled(WidgetTester tester, bool value) async {
    try {
      enabled.value = value;
      await tester.pump();
      await tester.pump();
    } catch (error, stack) {
      _reportFailure('切换导入目标可用状态失败 mode=${mode.name}', error, stack);
      rethrow;
    }
  }

  /// 卸载组件后关闭测试订阅，防止候选状态和控件资源影响后续用例。
  Future<void> dispose(WidgetTester tester) async {
    try {
      await tester.pumpWidget(const SizedBox.shrink());
      directorySubscription.close();
      container.dispose();
      enabled.dispose();
    } catch (error, stack) {
      _reportFailure('释放导入目标选择器夹具失败 mode=${mode.name}', error, stack);
      rethrow;
    }
  }
}

/// 直接定位共享错误态的实际文字按钮，包含 TextButton.icon 的具体实现类型。
Finder _retryButton() => find.descendant(
  of: find.byType(AppLoadError),
  matching: find.byWidgetPredicate((widget) => widget is TextButton),
);

/// 读取真实单选行的业务选中标识，不依赖图标颜色或私有实现结构。
String _selectedTitle(WidgetTester tester) => tester
    .widgetList<AppRadioTile<dynamic>>(find.byType(AppRadioTile<dynamic>))
    .singleWhere((tile) => tile.selected)
    .title;

/// 四个业务域共用空态、真实重试、选择回落及禁用期间的交互契约。
void main() {
  final l10n = lookupAppLocalizations(const Locale('zh'));
  const books = <ImportBookOption>[
    (id: 'first', name: '第一个目标本'),
    (id: 'second', name: '第二个目标本'),
  ];

  for (final mode in AppMode.values) {
    testWidgets('${mode.name}：加载、禁用重试、启用重试与空态保持一致', (tester) async {
      final fixture = _SelectorFixture(
        mode,
        options: const AsyncLoading<List<ImportBookOption>>(),
      );
      try {
        await fixture.show(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byType(AppEmpty), findsNothing);
        expect(fixture.publications, [null]);
        expect(fixture.directoryReads, 1);

        await fixture.setEnabled(tester, false);
        await fixture.setOptions(
          tester,
          AsyncError(StateError('内部目录异常'), StackTrace.current),
        );
        expect(find.byType(AppLoadError), findsOneWidget);
        expect(find.text(l10n.analyticsLoadFailed), findsOneWidget);
        expect(find.textContaining('内部目录异常'), findsNothing);
        expect(tester.widget<TextButton>(_retryButton()).onPressed, isNull);
        await tester.tap(find.text(l10n.commonRetry));
        await tester.pump();
        expect(fixture.directoryReads, 1, reason: '禁用按钮不能刷新目录');
        expect(fixture.publications, [null]);

        await fixture.setEnabled(tester, true);
        final retry = tester.widget<TextButton>(_retryButton()).onPressed;
        expect(retry, isNotNull);
        await fixture.setEnabled(tester, false);
        retry!();
        await tester.pump();
        expect(fixture.directoryReads, 1, reason: '禁用后到达的旧回调不能刷新目录');

        await fixture.setEnabled(tester, true);
        await tester.tap(find.text(l10n.commonRetry));
        await tester.pump();
        await tester.pump();
        expect(fixture.directoryReads, 2, reason: '启用重试必须执行真实目录失效动作');
        expect(fixture.publications, [null]);

        await fixture.setOptions(
          tester,
          const AsyncData<List<ImportBookOption>>([]),
        );
        expect(find.byType(AppLoadError), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(AppEmpty), findsOneWidget);
        expect(
          find.text(switch (mode) {
            AppMode.bookkeeping => l10n.ledgersEmpty,
            AppMode.days => l10n.dayBookEmpty,
            AppMode.memos => l10n.memoNoBooks,
            AppMode.fitness => l10n.fitnessNoSpaces,
          }),
          findsOneWidget,
        );
        await fixture.setOptions(
          tester,
          const AsyncData<List<ImportBookOption>>([]),
        );
        expect(fixture.publications, [null], reason: '连续加载、错误和空结果只发布一次空选择');
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        _reportFailure(
          '导入目标状态交互验证失败 mode=${mode.name}，'
          '目录读取=${fixture.directoryReads}，回调=${fixture.publications}',
          error,
          stack,
        );
        rethrow;
      } finally {
        await fixture.dispose(tester);
      }
    });

    testWidgets('${mode.name}：选择、禁用和目录刷新保留首选及单次回落', (tester) async {
      final fixture = _SelectorFixture(
        mode,
        selectedId: 'missing',
        options: const AsyncData<List<ImportBookOption>>(books),
      );
      try {
        await fixture.show(tester);
        expect(_selectedTitle(tester), books.first.name);
        expect(fixture.publications, ['first'], reason: '已失效的初始目标回落到首个候选');

        await tester.tap(find.text(books.last.name));
        await tester.pump();
        expect(_selectedTitle(tester), books.last.name);
        expect(fixture.publications, ['first', 'second']);
        await tester.tap(find.text(books.last.name));
        await tester.pump();
        expect(fixture.publications, [
          'first',
          'second',
        ], reason: '重复选择同一项只发布一次');

        await fixture.setEnabled(tester, false);
        for (final tile in tester.widgetList<AppRadioTile<dynamic>>(
          find.byType(AppRadioTile<dynamic>),
        )) {
          expect(tile.onTap, isNull);
        }
        await tester.tap(find.text(books.first.name));
        await tester.pump();
        expect(_selectedTitle(tester), books.last.name);
        expect(fixture.publications, ['first', 'second']);

        await fixture.setOptions(
          tester,
          const AsyncLoading<List<ImportBookOption>>(),
        );
        expect(fixture.publications, ['first', 'second', null]);
        await fixture.setOptions(
          tester,
          AsyncError(StateError('刷新目录失败'), StackTrace.current),
        );
        expect(fixture.publications, ['first', 'second', null]);
        await fixture.setOptions(
          tester,
          const AsyncData<List<ImportBookOption>>(books),
        );
        expect(_selectedTitle(tester), books.last.name);
        expect(fixture.publications, ['first', 'second', null, 'second']);

        await fixture.setOptions(
          tester,
          AsyncData<List<ImportBookOption>>([books.first]),
        );
        expect(_selectedTitle(tester), books.first.name);
        expect(fixture.publications, [
          'first',
          'second',
          null,
          'second',
          'first',
        ]);
        await fixture.setOptions(
          tester,
          AsyncData<List<ImportBookOption>>([books.first]),
        );
        await fixture.setEnabled(tester, true);
        expect(fixture.publications, [
          'first',
          'second',
          null,
          'second',
          'first',
        ]);
        expect(tester.takeException(), isNull);
      } catch (error, stack) {
        _reportFailure(
          '导入目标选择回落验证失败 mode=${mode.name}，回调=${fixture.publications}',
          error,
          stack,
        );
        rethrow;
      } finally {
        await fixture.dispose(tester);
      }
    });
  }
}
