/// 全局路由名常量表。
///
/// 设计意图：将页面跳转从「页面直接 import 目标页」解耦为「按路由名跳转」，
/// 由 app_router.dart 这一唯一路由层负责名称 → 页面实例的映射。
/// 页面之间因此不存在编译期 import 环，满足 pages → widgets 单向依赖。
///
/// 约束：本文件不得 import 任何页面/项目文件，仅存放纯常量。
class Routes {
  Routes._();

  /// 分类管理页
  static const String categoryManage = '/category/manage';

  /// AA 分摊统计页
  static const String aaStatistics = '/statistics/aa';

  /// AA 分摊编辑页(纯选择器,参数经 extra 传 [AaEditPageArgs],
  /// 返回 [AaEditResult?],null = 取消)
  static const String aaEdit = '/statistics/aa/edit';

  /// AA 分摊统计-成员账单详情页(按支出人维度汇总,
  /// 参数经 extra 传 [AaMemberDetailArgs])
  static const String aaMemberDetail = '/statistics/aa/member-detail';

  /// 登录页（兼容旧名；内部新调用使用 [authLogin]）
  static const String auth = '/auth';

  /// 登录页（明确路由）
  static const String authLogin = '/auth/login';

  /// 注册页
  static const String authRegister = '/auth/register';

  /// 个人资料页
  static const String profile = '/profile';

  /// 编辑昵称页
  static const String profileName = '/profile/name';

  /// 头像预览/设置页
  static const String profileAvatar = '/profile/avatar';

  /// 性别设置页
  static const String profileGender = '/profile/gender';

  /// 修改密码页
  static const String accountPassword = '/account/password';

  /// 云服务页（账户与同步 + 第三方备份）
  static const String cloudService = '/cloud/service';

  /// 账本列表页
  static const String ledgers = '/ledgers';

  /// 账本编辑页（新建/编辑；参数经 extra 传 LedgerDisplayItem?，null = 新建）
  static const String ledgerEdit = '/ledgers/edit';

  /// 加入共享账本页
  static const String joinSharedLedger = '/ledgers/join';

  /// 分类编辑页
  static const String categoryEdit = '/category/edit';

  /// 币种管理页
  static const String currencyManage = '/currency/manage';

  /// 汇率页
  static const String exchangeRate = '/exchange/rate';

  /// 周期交易页
  static const String recurringTransaction = '/recurring';

  /// 周期交易编辑页（新建 null 参数；编辑经 extra 传展示模型）
  static const String recurringTransactionEdit = '/recurring/edit';

  /// 分类详情页（参数经 extra 传 (String, String) = (categoryId, categoryName)）
  static const String categoryDetail = '/category/detail';

  /// 提醒设置页
  static const String reminderSettings = '/settings/reminder';

  /// 外观设置页
  static const String appearanceSettings = '/settings/appearance';

  /// 语言设置页
  static const String languageSettings = '/settings/language';

  /// 应用锁设置页
  static const String appLockSettings = '/settings/app-lock';

  /// PIN 设置页
  static const String pinSetup = '/settings/pin';

  /// 明细导入导出页
  static const String detailImportExport = '/import-export/detail';

  /// 配置导入导出页
  static const String configImportExport = '/import-export/config';

  /// 明细导出页
  static const String detailExport = '/export/detail';

  /// 导入字段映射页（参数经 extra 传 (String, bool, String)
  /// = (csvText, hasHeader, targetLedgerId)）
  static const String importConfirm = '/import/confirm';

  /// 第三方备份配置页（参数经 extra 传云备份后端展示模型）
  static const String cloudBackupConfig = '/cloud/backup-config';

  /// 备份恢复页（4 步流程：选择备份 → 查看内容 → 选择策略 → 确认应用）
  static const String backupRestore = '/backup/restore';

  /// 全量路由名清单：路由表测试据此双向校验 GoRoute 注册无遗漏/无漂移。
  /// 新增路由时必须同步登记到本表。
  static const List<String> all = [
    categoryManage,
    aaStatistics,
    aaEdit,
    aaMemberDetail,
    auth,
    authLogin,
    authRegister,
    profile,
    profileName,
    profileAvatar,
    profileGender,
    accountPassword,
    cloudService,
    ledgers,
    ledgerEdit,
    joinSharedLedger,
    categoryEdit,
    currencyManage,
    exchangeRate,
    recurringTransaction,
    recurringTransactionEdit,
    categoryDetail,
    reminderSettings,
    appearanceSettings,
    languageSettings,
    appLockSettings,
    pinSetup,
    detailImportExport,
    configImportExport,
    detailExport,
    importConfirm,
    cloudBackupConfig,
    backupRestore,
  ];
}
