import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/presentation/category_template_flat_page.dart';
import 'package:sesame_notes/features/categories/presentation/category_template_hierarchical_page.dart';
import 'package:sesame_notes/features/categories/presentation/category_template_widgets.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';

import '../../helpers/test_isolation.dart';

/// 恢复真正写库后模拟错误，由正式外层事务回滚这一轮。
class _RestoreFailureRepository extends LocalRepository {
  /// 保留正式数据库与账号域，只有已确认恢复的故障由测试控制。
  _RestoreFailureRepository(super.db, {required super.accountIdGetter});

  bool failRestore = true;
  int failedRestores = 0;

  /// 先执行实际恢复，再抛出错误，以验证失败轮回滚和前轮提交相互独立。
  @override
  Future<CanonicalCategoryInsertResult> insertCanonicalCategory({
    required String id,
    required String name,
    required String kind,
    required int level,
    String? icon,
    int? sortOrder,
    String? parentId,
    bool restoreLocalDeleted = false,
  }) async {
    try {
      final result = await super.insertCanonicalCategory(
        id: id,
        name: name,
        kind: kind,
        level: level,
        icon: icon,
        sortOrder: sortOrder,
        parentId: parentId,
        restoreLocalDeleted: restoreLocalDeleted,
      );
      if (restoreLocalDeleted && failRestore) {
        failedRestores++;
        throw StateError('模拟恢复落库后的异常');
      }
      return result;
    } catch (error, stack) {
      debugPrint('测试仓储恢复失败：$error\n$stack');
      rethrow;
    }
  }
}

/// 两种布局共用真实本地仓储，账号变化独立于持久化夹具。
class _PageFixture {
  /// Provider 只替换账号来源与数据库，模板会话和提交均使用正式实现。
  _PageFixture(this.hierarchical) {
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _RestoreFailureRepository(
      database,
      accountIdGetter: () => account,
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        repositoryProvider.overrideWithValue(repository),
        currentAccountIdProvider.overrideWith((ref) => account),
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
  }

  final bool hierarchical;
  late final SesameDatabase database;
  late final _RestoreFailureRepository repository;
  late final ProviderContainer container;
  String? account;

  /// 二级布局在同一父分类选择两个子项，一级布局选择两个独立分类。
  List<String> get selectedKeys => hierarchical
      ? ['dining_breakfast', 'dining_lunch']
      : ['dining', 'transport'];

  /// 首项为本机墓碑，第二项尚未存在，首轮只能实际创建第二项。
  Future<void> seed() async {
    try {
      final parentId = defaultCategoryId(level: 1, key: 'dining');
      if (hierarchical) {
        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                id: parentId,
                name: '餐饮',
                kind: 'expense',
                level: 1,
                scopeAccountId: drift.Value(account),
                updatedAt: DateTime.utc(2026, 1, 1),
              ),
            );
      }
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              id: defaultCategoryId(
                level: hierarchical ? 2 : 1,
                key: selectedKeys.first,
              ),
              name: hierarchical ? '早餐' : '餐饮',
              kind: 'expense',
              level: hierarchical ? 2 : 1,
              parentId: drift.Value(hierarchical ? parentId : null),
              scopeAccountId: drift.Value(account),
              updatedAt: DateTime.utc(2026, 1, 1),
              deletedAt: drift.Value(DateTime.utc(2026, 1, 2)),
            ),
          );
    } catch (error, stack) {
      debugPrint('建立模板墓碑夹具失败：$error\n$stack');
      rethrow;
    }
  }

  /// 读取持久化行验证独立提交与当前恢复轮的回滚结果。
  Future<Category> row(String key) async {
    try {
      return await (database.select(database.categories)..where(
            (table) => table.id.equals(
              defaultCategoryId(level: hierarchical ? 2 : 1, key: key),
            ),
          ))
          .getSingle();
    } catch (error, stack) {
      debugPrint('读取模板持久化夹具失败：$key，$error\n$stack');
      rethrow;
    }
  }

  /// 账号切换改变目录域，登录退出使身份代次失效但最终仍回到本机目录。
  void changeSession({required bool relogin}) {
    try {
      if (relogin) {
        final notifier = container.read(authSessionProvider.notifier);
        notifier.signIn(
          const AuthSession(
            accessToken: 'fixture',
            userId: 'account-a',
            deviceId: 'test',
          ),
        );
        notifier.signOut();
      } else {
        account = 'account-b';
        container.invalidate(currentAccountIdProvider);
      }
    } catch (error, stack) {
      debugPrint('切换模板测试会话失败：$error\n$stack');
      rethrow;
    }
  }

  /// 页面已卸载后释放流、数据库和日志保存计时器。
  Future<void> dispose() async {
    try {
      container.dispose();
      await database.close();
      await logger.clear();
    } catch (error, stack) {
      debugPrint('释放模板页面夹具失败：$error\n$stack');
      rethrow;
    }
  }
}

/// 原生数据库在真实事件循环处理，界面动画在测试时钟推进。
Future<void> _settle(WidgetTester tester) async {
  try {
    for (var frame = 0; frame < 30; frame++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        await tester.pumpAndSettle();
        return;
      }
    }
    throw StateError('模板页面未完成本机数据库处理');
  } catch (error, stack) {
    debugPrint('等待模板页面稳定失败：$error\n$stack');
    rethrow;
  }
}

/// 根据真正的模板 key 操作卡片，不依赖名称或内部页面状态。
Finder _tile(String key) => find.byWidgetPredicate(
  (widget) => widget is TemplateItemTile && widget.item.key == key,
);

/// 确认操作定位真实按钮，避免恢复标题与按钮同名产生歧义。
Future<void> _tapAction(WidgetTester tester, String label) async {
  try {
    await tester.tap(
      find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate(
          (widget) => widget is ButtonStyleButton,
        ),
      ),
    );
    await _settle(tester);
  } catch (error, stack) {
    debugPrint('模板页面动作失败：$label，$error\n$stack');
    rethrow;
  }
}

/// 打开指定模板布局、选择两项并完成首轮写入，停在恢复确认框。
Future<void> _openRestoreDialog(
  WidgetTester tester,
  _PageFixture fixture,
) async {
  try {
    await tester.runAsync(fixture.seed);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: fixture.container,
        child: MaterialApp(
          theme: AppTheme.lightTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: fixture.hierarchical
              ? const CategoryTemplateHierarchicalPage()
              : const CategoryTemplateFlatPage(),
        ),
      ),
    );
    await _settle(tester);
    if (fixture.hierarchical) {
      await tester.tap(find.byKey(const ValueKey('templateParentCard_dining')));
      await tester.pumpAndSettle();
    }
    for (final key in fixture.selectedKeys) {
      await tester.tap(_tile(key));
      await tester.pumpAndSettle();
    }
    final l10n = lookupAppLocalizations(const Locale('zh'));
    await _tapAction(tester, l10n.commonAdd);
    await _tapAction(tester, l10n.commonConfirm);
    expect(find.text(l10n.categoryTemplateRestoreTitle), findsWidgets);
    final created = await tester.runAsync(
      () => fixture.row(fixture.selectedKeys.last),
    );
    expect(created!.deletedAt, isNull, reason: '等待恢复确认时首轮必须已经提交');
    expect(
      tester
          .widget<TemplateBottomBar>(find.byType(TemplateBottomBar))
          .isWriting,
      isFalse,
    );
  } catch (error, stack) {
    debugPrint('打开模板恢复确认失败：$error\n$stack');
    rethrow;
  }
}

/// 两种真实页面均须反馈部分成功、保留重试选择，并隔离旧会话结果。
void main() {
  final l10n = lookupAppLocalizations(const Locale('zh'));
  setUp(resetGlobalTestState);

  for (final hierarchical in [false, true]) {
    testWidgets('层级=$hierarchical：恢复失败展示已提交数量、刷新目录并可重试剩余项', (tester) async {
      final fixture = _PageFixture(hierarchical);
      try {
        await _openRestoreDialog(tester, fixture);
        await _tapAction(tester, l10n.categoryTemplateRestoreConfirm);
        expect(fixture.repository.failedRestores, 1);
        expect(
          find.text(
            l10n.categoryTemplatePartiallyCompleted(
              l10n.categoryTemplateAddSuccess(1),
            ),
          ),
          findsOneWidget,
        );
        final tombstone = await tester.runAsync(
          () => fixture.row(fixture.selectedKeys.first),
        );
        expect(tombstone!.deletedAt, isNotNull, reason: '异常所在恢复轮必须回滚');
        var bar = tester.widget<TemplateBottomBar>(
          find.byType(TemplateBottomBar),
        );
        expect(bar.selectedCount, 1, reason: '已完成项从选择中排除，未完成项保持可重试');
        expect(bar.isAdding, isFalse);
        expect(bar.isWriting, isFalse);
        final completedTile = tester.widget<TemplateItemTile>(
          _tile(fixture.selectedKeys.last),
        );
        expect(completedTile.item.alreadyAdded, isTrue);

        fixture.repository.failRestore = false;
        await _tapAction(tester, l10n.commonAdd);
        expect(
          find.text(l10n.categoryTemplateConfirmMessage(1)),
          findsOneWidget,
        );
        await _tapAction(tester, l10n.commonConfirm);
        await _tapAction(tester, l10n.categoryTemplateRestoreConfirm);
        expect(find.text(l10n.categoryTemplateRestored(1)), findsOneWidget);
        final restored = await tester.runAsync(
          () => fixture.row(fixture.selectedKeys.first),
        );
        expect(restored!.deletedAt, isNull);
        bar = tester.widget<TemplateBottomBar>(find.byType(TemplateBottomBar));
        expect(bar.selectedCount, 0);
        expect(bar.isAdding, isFalse);
        expect(bar.isWriting, isFalse);
      } catch (error, stack) {
        debugPrint('模板页面部分成功与重试验证失败：层级=$hierarchical，$error\n$stack');
        rethrow;
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 3));
        await tester.runAsync(fixture.dispose);
      }
    });

    for (final relogin in [false, true]) {
      for (final confirmRestore in [false, true]) {
        testWidgets(
          '层级=$hierarchical 身份代次失效=$relogin 确认恢复=$confirmRestore：旧会话摘要不展示',
          (tester) async {
            final fixture = _PageFixture(hierarchical);
            try {
              await _openRestoreDialog(tester, fixture);
              fixture.changeSession(relogin: relogin);
              await _tapAction(
                tester,
                confirmRestore
                    ? l10n.categoryTemplateRestoreConfirm
                    : l10n.commonCancel,
              );
              expect(
                find.text(l10n.categoryTemplateAddSuccess(1)),
                findsNothing,
              );
              expect(
                find.text(
                  l10n.categoryTemplatePartiallyCompleted(
                    l10n.categoryTemplateAddSuccess(1),
                  ),
                ),
                findsNothing,
              );
              expect(
                find.text(
                  l10n.categoryTemplateAddFailed(l10n.commonOperationFailed),
                ),
                findsOneWidget,
              );
              final bar = tester.widget<TemplateBottomBar>(
                find.byType(TemplateBottomBar),
              );
              expect(bar.isAdding, isFalse);
              expect(bar.isWriting, isFalse);
            } catch (error, stack) {
              debugPrint(
                '模板旧会话结果隔离验证失败：层级=$hierarchical，同号=$relogin，确认=$confirmRestore，$error\n$stack',
              );
              rethrow;
            } finally {
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump(const Duration(seconds: 3));
              await tester.runAsync(fixture.dispose);
            }
          },
        );
      }
    }
  }
}
