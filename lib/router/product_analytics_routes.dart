import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../core/logging/logger_service.dart';
import '../data/models/app_mode.dart';
import '../data/models/memo.dart';
import '../data/models/fitness_library.dart';
import '../data/models/private_book.dart';
import '../domain/analytics/product_analytics_actions.dart';
import '../domain/analytics/product_analytics_context.dart';
import '../providers/product_analytics_providers.dart';
import '../shared/application/provider_reader.dart';
import '../shared/providers/ui_state_providers.dart';
import '../shared/presentation/analytics/product_analytics_presentation.dart';

/// 导航携带显式操作上下文，普通业务参数保持自身的数据形状。
class ProductAnalyticsNavigation {
  /// 随机上下文不包含业务正文，不建立全局当前操作流。
  const ProductAnalyticsNavigation({
    required this.arguments,
    required this.context,
  });
  final Object? arguments;
  final ProductAnalyticsContext context;
}

/// 只解包明确的导航包装，普通参数保持原样。
Object? productAnalyticsArguments(Object? extra) =>
    extra is ProductAnalyticsNavigation ? extra.arguments : extra;

/// 应用路由适配器把明确的界面登记依赖交给通用组件，不依赖特殊根注入。
Widget productAnalyticsPresentation({
  required BuildContext context,
  required ProviderReader read,
  required String pageId,
  required Widget child,
  ProductAnalyticsContext? analyticsContext,
  bool routePage = false,
}) {
  String? owner;
  try {
    if (GoRouter.maybeOf(context) != null) {
      owner = GoRouterState.of(context).pageKey.value;
    }
  } catch (error, stack) {
    logger.error(
      'ProductAnalytics',
      '页面路由归属暂不可用，界面功能不受影响',
      error.runtimeType,
      stack,
    );
  }
  return ProductAnalyticsPresentation(
    registry: read(productAnalyticsPageStateProvider),
    ownerRouteKey: owner,
    pageId: pageId,
    analyticsContext: analyticsContext,
    routePage: routePage,
    child: child,
  );
}

/// 命令式 push 的顶层页面以最后匹配项为准，根 URI 可能仍然停在首页。
({String path, String key}) productAnalyticsRoute(GoRouter router) {
  final match = router.routerDelegate.currentConfiguration.lastOrNull;
  return (path: match?.matchedLocation ?? '/', key: match?.pageKey.value ?? '');
}

/// 固定映射受控业务页面；认证、备份、密码及未知路径不采集。
String? productAnalyticsPage(String path) {
  if (path.startsWith('/auth/') ||
      path == '/account/password' ||
      path.startsWith('/settings/pin')) {
    return null;
  }
  return switch (path) {
    '/fitness/exercises' => 'fitness.exercises',
    '/fitness/exercises/custom/edit' => 'fitness.exercises.edit',
    '/fitness/exercises/detail' => 'fitness.exercise',
    '/fitness/templates' => 'fitness.templates',
    '/fitness/templates/library' => 'fitness.templates.library',
    '/fitness/templates/edit' => 'fitness.templates.edit',
    '/fitness/templates/detail' => 'fitness.template',
    '/fitness/plans' => 'fitness.plans',
    '/fitness/plans/library' => 'fitness.plans.library',
    '/fitness/plans/edit' => 'fitness.plans.edit',
    '/fitness/plans/detail' => 'fitness.plans.edit',
    '/fitness/workout' => 'fitness.workout',
    '/fitness/spaces' => 'fitness.spaces',
    '/fitness/spaces/edit' => 'fitness.spaces.edit',
    '/memos/editor' => 'memos.editor',
    '/memos/books' => 'memos.books',
    '/memos/books/edit' => 'memos.books.edit',
    '/memos/credentials' => 'credentials',
    '/days/detail' => 'days.detail',
    '/days/edit' => 'days.editor',
    '/days/books' => 'days.books',
    '/days/books/edit' => 'days.books.edit',
    '/category/manage' => 'accounting.categories',
    '/category/templates' => 'accounting.categories.templates.flat',
    '/category/templates/flat' => 'accounting.categories.templates.flat',
    '/category/templates/hierarchical' =>
      'accounting.categories.templates.hierarchical',
    '/category/edit' => 'accounting.categories.edit',
    '/category/detail' => 'accounting.categories.detail',
    '/statistics/aa' => 'accounting.aa_statistics',
    '/statistics/aa/member-detail' => 'accounting.aa_member.detail',
    '/statistics/aa/edit' => 'accounting.aa_split.editor',
    '/ledgers' => 'accounting.ledgers',
    '/ledgers/archived' => 'accounting.ledgers.archived',
    '/ledgers/edit' => 'accounting.ledgers.edit',
    '/ledgers/join' => 'accounting.ledgers.join',
    '/currency/manage' => 'accounting.currency',
    '/exchange/rate' => 'accounting.exchange_rate',
    '/recurring/edit' => 'accounting.recurring.editor',
    '/profile' => 'settings.profile',
    '/profile/name' => 'settings.profile.name',
    '/profile/avatar' => 'settings.profile.avatar',
    '/profile/gender' => 'settings.profile.gender',
    '/settings/reminder' => 'settings.reminder',
    '/settings/language' => 'settings.language',
    '/settings/theme' => 'settings.theme',
    '/settings/app-lock' => 'settings.app_lock',
    '/cloud/service' => 'settings.cloud',
    '/sync' => 'settings.sync',
    _ => null,
  };
}

/// 根导航的业务模式与页签组合对应真实显示页面，点击来源与访问统计共用映射。
String productAnalyticsRootPage(AppMode mode, int tab) {
  if (tab == 2) return 'calendar';
  if (tab == 3) return 'settings';
  return switch (mode) {
    AppMode.bookkeeping => tab == 1 ? 'accounting.statistics' : 'accounting',
    AppMode.fitness =>
      tab == 1
          ? 'fitness.statistics'
          : tab == 4
          ? 'fitness.plans'
          : 'fitness',
    AppMode.days => tab == 1 ? 'days.tools' : 'days',
    AppMode.memos =>
      tab == 4
          ? 'credentials'
          : tab == 1
          ? 'memos.tools'
          : 'memos',
  };
}

/// 当前已提交的路由与根标签共用页面映射，账号密码仅检查类型，不读取内容。
String? productAnalyticsCurrentPage(GoRouter router, ProviderReader read) {
  final route = productAnalyticsRoute(router);
  final path = route.path;
  final presentation = read(
    productAnalyticsPageStateProvider,
  ).presentation(route.key);
  if (presentation != null) return presentation.pageId;
  final visible = read(productAnalyticsPageStateProvider).page(route.key);
  if (visible != null) return visible;
  if (path == '/') {
    return productAnalyticsRootPage(
      read(currentModeProvider),
      read(bottomTabIndexProvider),
    );
  }
  final configuration = router.routerDelegate.currentConfiguration;
  final match = configuration.lastOrNull;
  final raw = match is ImperativeRouteMatch
      ? match.matches.extra
      : configuration.extra;
  final extra = productAnalyticsArguments(raw);
  if (path == '/memos/books/edit' &&
      extra is MemoBook &&
      extra.type == 'credentials') {
    return 'credentials.books.edit';
  }
  if (path == '/fitness/templates/detail' && extra is OfficialFitnessTemplate) {
    return 'fitness.templates.library.detail';
  }
  if (path == '/fitness/plans/edit' && extra is FitnessPlanImportDraft) {
    return 'fitness.plans.library.detail';
  }
  if (path == '/memos/editor') {
    if (extra
        is ({
          MemoBook book,
          PrivateBookTarget target,
          String entryId,
          MemoEntry? entry,
        })) {
      if (extra.book.type == 'credentials') return 'credentials.editor';
      return extra.entry == null ? 'memos.editor' : 'memos.detail';
    }
  }
  return productAnalyticsPage(path);
}

/// 路由及业务弹层的显式上下文归属页面访问，首页不会套用后续操作流。
ProductAnalyticsContext? productAnalyticsRouteContext(
  GoRouter router,
  ProviderReader read,
) {
  final route = productAnalyticsRoute(router);
  final presentation = read(
    productAnalyticsPageStateProvider,
  ).presentation(route.key);
  if (presentation != null) return presentation.context;
  final configuration = router.routerDelegate.currentConfiguration;
  final match = configuration.lastOrNull;
  final extra = match is ImperativeRouteMatch
      ? match.matches.extra
      : configuration.extra;
  return extra is ProductAnalyticsNavigation ? extra.context : null;
}

/// 在操作发起时读取页面来源，异步准备和关闭弹层之后仍可沿用该固定标识。
String productAnalyticsEntryPage(
  BuildContext uiContext,
  ProviderReader read, {
  required String fallbackPageId,
}) {
  try {
    final router = GoRouter.maybeOf(uiContext);
    return router == null
        ? fallbackPageId
        : productAnalyticsCurrentPage(router, read) ?? fallbackPageId;
  } catch (error, stackTrace) {
    logger.error('ProductAnalytics', '页面来源暂不可用，应用功能不受影响', error, stackTrace);
    return fallbackPageId;
  }
}

/// 入口点击归属当下实际显示的页面，共享日历和业务工具入口不会混入业务首页。
void trackProductEntryAction(
  BuildContext uiContext,
  ProviderReader read, {
  required String fallbackPageId,
  required ProductAction action,
  ProductAnalyticsContext? context,
}) {
  try {
    read(productAnalyticsControllerProvider).trackAction(
      pageId: productAnalyticsEntryPage(
        uiContext,
        read,
        fallbackPageId: fallbackPageId,
      ),
      action: action,
      context: context,
    );
  } catch (error, stackTrace) {
    logger.error('ProductAnalytics', '使用统计暂不可用，应用功能不受影响', error, stackTrace);
  }
}
