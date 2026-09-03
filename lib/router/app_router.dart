/// go_router 全局路由层：名称 → 页面实例的唯一映射。
///
/// 设计意图：go_router 接管命名路由后，本文件是唯一允许 import 具体页面
/// （pages 层）的路由层文件，页面之间不互相 import。所有路由均注册为
/// GoRoute（name == path，pushNamed 与路径解析共用同一标识），参数经
/// GoRouterState.extra 传递（record 与对象均可），替代原 RouteSettings.arguments。
///
/// 行为变更说明：原 appRoute 对缺失参数返回 null（调用方回退不 push）；
/// go_router 下 push 必然发生，参数由调用点保证，非法 extra 在 builder 中
/// 强转快速失败（编程错误立即暴露），可空参数型路由（新建/默认模式）保留
/// 兜底值语义。
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/shared/widgets/app_route.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/features/auth/presentation/avatar_preview_page.dart';
import 'package:sesame_notes/features/auth/presentation/change_password_page.dart';
import 'package:sesame_notes/features/auth/presentation/edit_profile_pages.dart';
import 'package:sesame_notes/features/auth/presentation/login_page.dart';
import 'package:sesame_notes/features/auth/presentation/profile_page.dart';
import 'package:sesame_notes/features/auth/presentation/register_page.dart';
import 'package:sesame_notes/features/auth/presentation/pin_setup_page.dart';
import 'package:sesame_notes/features/categories/presentation/category_edit_page.dart';
import 'package:sesame_notes/features/categories/presentation/category_manage_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/join_shared_ledger_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledger_edit_page.dart';
import 'package:sesame_notes/features/ledgers/presentation/ledgers_page.dart';
import 'package:sesame_notes/features/settings/presentation/app_lock_settings_page.dart';
import 'package:sesame_notes/features/settings/presentation/appearance_settings_page.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_service_page.dart';
import 'package:sesame_notes/features/settings/presentation/local_backup_page.dart';
import 'package:sesame_notes/features/settings/presentation/config_import_export_page.dart';
import 'package:sesame_notes/features/settings/presentation/detail_export_page.dart';
import 'package:sesame_notes/features/settings/presentation/detail_import_export_page.dart';
import 'package:sesame_notes/features/settings/presentation/import_confirm_page.dart';
import 'package:sesame_notes/features/settings/presentation/language_settings_page.dart';
import 'package:sesame_notes/features/settings/presentation/reminder_settings_page.dart';
import 'package:sesame_notes/features/settings/presentation/restore_backup_page.dart';
import 'package:sesame_notes/features/statistics/presentation/aa_edit_page.dart';
import 'package:sesame_notes/features/statistics/presentation/aa_member_detail_page.dart';
import 'package:sesame_notes/features/statistics/presentation/aa_statistics_page.dart';
import 'package:sesame_notes/features/transactions/presentation/category_detail_page.dart';
import 'package:sesame_notes/features/transactions/presentation/currency_manage_page.dart';
import 'package:sesame_notes/features/transactions/presentation/exchange_rate_page.dart';
import 'package:sesame_notes/features/transactions/presentation/recurring_transaction_edit_page.dart';
import 'package:sesame_notes/features/transactions/presentation/recurring_transaction_page.dart';
import 'package:sesame_notes/shared/aa/aa_edit_models.dart';
import 'package:sesame_notes/features/statistics/application/aa_member_detail_models.dart';

import '../router/route_consts.dart';

/// 构建全部命名路由的 GoRoute 表。
///
/// [stubs] 仅供测试：命中 name 时用桩页面替换真实页面，避免测试拉起
/// 重依赖页面；生产调用不传。
List<GoRoute> buildAppRoutes({Map<String, WidgetBuilder> stubs = const {}}) {
  // 统一页面解析入口：stub 优先，否则走真实页面 builder。
  Widget page(
    BuildContext context,
    String path,
    Widget Function(GoRouterState state) build,
    GoRouterState state,
  ) {
    final stub = stubs[path];
    if (stub != null) return stub(context);
    return build(state);
  }

  // 统一页面包装：所有命名路由经 AppRouterPage 创建，保持全局 200ms
  // 转场与 opaque 语义（覆盖后下层页面转场完成即 offstage）。
  Page<dynamic> pageFor(
    BuildContext context,
    String path,
    Widget Function(GoRouterState state) build,
    GoRouterState state,
  ) => AppRouterPage<dynamic>(
    name: path,
    child: page(context, path, build, state),
  );

  // 无参路由快捷构造。
  GoRoute plain(String path, WidgetBuilder builder) => GoRoute(
    path: path,
    name: path,
    pageBuilder: (context, state) =>
        pageFor(context, path, (_) => builder(context), state),
  );

  // 参数经 extra 传递的路由：可空参数保留兜底，必填参数强转快速失败。
  GoRoute extraRoute(String path, Widget Function(GoRouterState state) build) =>
      GoRoute(
        path: path,
        name: path,
        pageBuilder: (context, state) => pageFor(context, path, build, state),
      );

  return [
    plain(Routes.categoryManage, (_) => const CategoryManagePage()),
    // 账本 id 由调用方(账本编辑页)经 extra 传入,遵循"从哪里进入
    // 就是哪个账本";缺失/类型不符(如新建态)时传 null,统计页按空数据渲染。
    extraRoute(
      Routes.aaStatistics,
      (state) => AaStatisticsPage(
        ledgerId: state.extra is String ? state.extra as String : null,
      ),
    ),
    // AA 分摊编辑页：参数由调用方(记账编辑器)经 extra 传入，必填强转；
    // 退场固定为下滑动画（见 [aaPageTransitionBuilder]）：AA 页通常在
    // 记账编辑器 sheet 之上 push，保存时 sheet 同步下滑收起，两者同向视觉统一。
    // go_router 17 起 GoRoute 无 customTransitionPageBuilder，自定义转场
    // 直接经 pageBuilder 返回 CustomTransitionPage 实现。
    GoRoute(
      path: Routes.aaEdit,
      name: Routes.aaEdit,
      // 自定义转场例外：AA 页退场需与记账 sheet 下滑同步（见
      // [aaPageTransitionBuilder]），不套用 appPageRoute 的左右滑动。
      pageBuilder: (context, state) => CustomTransitionPage<dynamic>(
        key: state.pageKey,
        child: page(
          context,
          Routes.aaEdit,
          (s) => AaEditPage(args: s.extra as AaEditPageArgs),
          state,
        ),
        transitionDuration: kAppTransitionDuration,
        // 退场下滑时长硬编码，不跟随全局转场参数，保证与 sheet 收起动画同步
        reverseTransitionDuration: kAaPageSlideDuration,
        transitionsBuilder: aaPageTransitionBuilder,
      ),
    ),
    // AA 成员账单详情：参数由分摊统计页经 extra 传入，必填强转。
    extraRoute(
      Routes.aaMemberDetail,
      (state) => AaMemberDetailPage(args: state.extra as AaMemberDetailArgs),
    ),
    plain(Routes.auth, (_) => const AuthPage()),
    plain(Routes.authLogin, (_) => const AuthPage()),
    plain(Routes.authRegister, (_) => const RegisterPage()),
    plain(Routes.profile, (_) => const ProfilePage()),
    plain(Routes.profileName, (_) => const EditNicknamePage()),
    plain(Routes.profileAvatar, (_) => const AvatarPreviewPage()),
    plain(Routes.profileGender, (_) => const EditGenderPage()),
    plain(Routes.accountPassword, (_) => const ChangePasswordPage()),
    plain(Routes.cloudService, (_) => const CloudServicePage()),
    plain(Routes.ledgers, (_) => const LedgersPage()),
    // 参数经 extra 传 LedgerDisplayItem?；null = 新建模式。
    extraRoute(
      Routes.ledgerEdit,
      (state) => LedgerEditPage(ledger: state.extra as LedgerDisplayItem?),
    ),
    plain(Routes.joinSharedLedger, (_) => const JoinSharedLedgerPage()),
    // 参数经 extra 传分类展示项、kind 与可选父分类展示项。
    extraRoute(Routes.categoryEdit, (state) {
      final args = state.extra as (CategoryDisplay?, String, CategoryDisplay?);
      return CategoryEditPage(
        category: args.$1,
        kind: args.$2,
        parentCategory: args.$3,
      );
    }),
    plain(Routes.currencyManage, (_) => const CurrencyManagePage()),
    plain(Routes.exchangeRate, (_) => const ExchangeRatePage()),
    plain(Routes.recurringTransaction, (_) => const RecurringTransactionPage()),
    // 参数经 extra 传 RecurringTransactionDisplay?；null = 新建。
    extraRoute(
      Routes.recurringTransactionEdit,
      (state) => RecurringTransactionEditPage(
        recurring: state.extra is RecurringTransactionDisplay
            ? state.extra as RecurringTransactionDisplay
            : null,
      ),
    ),
    // 参数经 extra 传 (String, String, DateTime?, DateTime?, String?)
    // = (categoryId, categoryName, startDate, endDate, periodLabel)。
    extraRoute(Routes.categoryDetail, (state) {
      final args =
          state.extra as (String, String, DateTime?, DateTime?, String?);
      return CategoryDetailPage(
        categoryId: args.$1,
        categoryName: args.$2,
        startDate: args.$3,
        endDate: args.$4,
        periodLabel: args.$5,
      );
    }),
    plain(Routes.reminderSettings, (_) => const ReminderSettingsPage()),
    plain(Routes.appearanceSettings, (_) => const AppearanceSettingsPage()),
    plain(Routes.languageSettings, (_) => const LanguageSettingsPage()),
    plain(Routes.appLockSettings, (_) => const AppLockSettingsPage()),
    // 模式经 extra 传 PinSetupMode?；缺失默认 create。
    // 返回 bool（设置成功与否），调用方据此决定开关回弹。
    extraRoute(
      Routes.pinSetup,
      (state) => PinSetupPage(
        mode: state.extra is PinSetupMode
            ? state.extra as PinSetupMode
            : PinSetupMode.create,
      ),
    ),
    plain(Routes.detailImportExport, (_) => const DetailImportExportPage()),
    plain(Routes.configImportExport, (_) => const ConfigImportExportPage()),
    plain(Routes.detailExport, (_) => const DetailExportPage()),
    // 参数经 extra 传 (String, bool, String)
    // = (csvText, hasHeader, targetLedgerId)。
    extraRoute(Routes.importConfirm, (state) {
      final args = state.extra as (String, bool, String);
      return ImportConfirmPage(
        csvText: args.$1,
        hasHeader: args.$2,
        targetLedgerId: args.$3,
      );
    }),
    // 参数经 extra 传外部 .snbak 路径（本机备份页/云端恢复传入），可空。
    extraRoute(
      Routes.backupRestore,
      (state) => RestoreBackupPage(
        initialBackupPath: state.extra is String ? state.extra as String : null,
      ),
    ),
    plain(Routes.localBackup, (_) => const LocalBackupPage()),
  ];
}

/// 创建全局 GoRouter 实例。
///
/// [home] 为 '/' 根路由页面工厂（MainApp 的欢迎/初始化/锁屏状态机）；
/// [navigatorKey] 供 service 层（无 BuildContext）取导航器；[stubs] 仅测试用。
GoRouter createAppRouter({
  required Widget Function() home,
  GlobalKey<NavigatorState>? navigatorKey,
  Map<String, WidgetBuilder> stubs = const {},
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/',
    routes: [
      // 根路由：欢迎页/初始化闸门/锁屏由 home 工厂按状态机决定渲染。
      GoRoute(path: '/', builder: (context, state) => home()),
      ...buildAppRoutes(stubs: stubs),
    ],
  );
}
