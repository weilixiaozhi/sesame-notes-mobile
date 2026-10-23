/// 全量命名路由与稳定路径，具体页面由应用路由层装配。
///
/// 本库只提供常量，不引入页面或其他项目实现。
class Routes {
  Routes._();

  static const String syncCenter = '/sync';

  /// 分类管理页
  static const String categoryManage = '/category/manage';

  /// 分类模板库的两个独立入口。
  static const String categoryTemplateFlat = '/category/templates/flat';
  static const String categoryTemplateHierarchical =
      '/category/templates/hierarchical';

  /// AA 分摊统计页
  static const String aaStatistics = '/statistics/aa';

  /// AA 分摊编辑页(纯选择器,参数经 extra 传 [AaEditPageArgs],
  /// 返回 [AaEditResult?],null = 取消)
  static const String aaEdit = '/statistics/aa/edit';

  /// AA 分摊统计-成员账单详情页(按支出人维度汇总,
  /// 参数经 extra 传 [AaMemberDetailArgs])
  static const String aaMemberDetail = '/statistics/aa/member-detail';

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

  /// 个人归档账本列表页。
  static const String archivedLedgers = '/ledgers/archived';

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

  /// 周期交易编辑页（新建 null 参数；编辑经 extra 传展示模型）
  static const String recurringTransactionEdit = '/recurring/edit';

  /// 分类详情页：extra 包含分类标识、名称、起止日期与周期文案。
  static const String categoryDetail = '/category/detail';

  /// 通知设置页
  static const String reminderSettings = '/settings/reminder';

  /// 语言设置页
  static const String languageSettings = '/settings/language';

  static const String fitnessSpaces = '/fitness/spaces';
  static const String fitnessSpaceEdit = '/fitness/spaces/edit';
  static const String fitnessWorkout = '/fitness/workout';
  static const String fitnessTemplates = '/fitness/templates';
  static const String fitnessTemplateLibrary = '/fitness/templates/library';
  static const String fitnessTemplateEdit = '/fitness/templates/edit';
  static const String fitnessPlans = '/fitness/plans';
  static const String fitnessPlanLibrary = '/fitness/plans/library';
  static const String fitnessPlanDetail = '/fitness/plans/detail';
  static const String fitnessTemplateDetail = '/fitness/templates/detail';
  static const String fitnessPlanEdit = '/fitness/plans/edit';
  static const String fitnessExercises = '/fitness/exercises';
  static const String fitnessExerciseDetail = '/fitness/exercises/detail';

  /// 自定义动作新建或编辑，参数为可选的动作定义。
  static const String fitnessCustomExerciseEdit =
      '/fitness/exercises/custom/edit';

  /// 备忘本与记录使用独立命名路由。
  static const String memoEditor = '/memos/editor';
  static const String memoBooks = '/memos/books';
  static const String memoBookEdit = '/memos/books/edit';

  /// 账号密码列表页，使用独立的当前账号密码本。
  static const String memoCredentials = '/memos/credentials';
  static const String dayBooks = '/days/books';
  static const String dayBookEdit = '/days/books/edit';
  static const String dayEventDetail = '/days/detail';
  static const String dayEventEdit = '/days/edit';

  /// 应用主题与显示模式设置页。
  static const String themeSettings = '/settings/theme';

  /// 应用锁设置页
  static const String appLockSettings = '/settings/app-lock';

  /// PIN 设置页
  static const String pinSetup = '/settings/pin';

  /// 数据导入导出页
  static const String detailImportExport = '/import-export/detail';

  /// 明细导出页
  static const String detailExport = '/export/detail';

  /// 导入字段映射页（参数经 extra 传 (String, TransferKind, DataImportTarget)
  /// = (csvText, kind, target)）。
  static const String importConfirm = '/import/confirm';

  /// 本机备份页（自动备份开关 / 立即备份 / 快照列表 / 恢复流程入口）
  static const String localBackup = '/backup/local';

  /// 备份恢复页（4 步流程：参数经 extra 传外部 .snbak 路径，可空）
  static const String backupRestore = '/backup/restore';

  /// 全量路由名清单：路由表测试据此双向校验 GoRoute 注册无遗漏/无漂移。
  /// 新增路由时必须同步登记到本表。
  static const List<String> all = [
    syncCenter,
    categoryManage,
    categoryTemplateFlat,
    categoryTemplateHierarchical,
    aaStatistics,
    aaEdit,
    aaMemberDetail,
    authLogin,
    authRegister,
    profile,
    profileName,
    profileAvatar,
    profileGender,
    accountPassword,
    cloudService,
    ledgers,
    archivedLedgers,
    ledgerEdit,
    joinSharedLedger,
    categoryEdit,
    currencyManage,
    exchangeRate,
    recurringTransactionEdit,
    categoryDetail,
    reminderSettings,
    languageSettings,
    fitnessSpaces,
    fitnessSpaceEdit,
    fitnessWorkout,
    fitnessTemplates,
    fitnessTemplateLibrary,
    fitnessTemplateEdit,
    fitnessPlans,
    fitnessPlanLibrary,
    fitnessPlanEdit,
    fitnessPlanDetail,
    fitnessTemplateDetail,
    fitnessExercises,
    fitnessExerciseDetail,
    fitnessCustomExerciseEdit,
    memoEditor,
    memoBooks,
    memoBookEdit,
    memoCredentials,
    dayBooks,
    dayBookEdit,
    dayEventDetail,
    dayEventEdit,
    themeSettings,
    appLockSettings,
    pinSetup,
    detailImportExport,
    detailExport,
    importConfirm,
    localBackup,
    backupRestore,
  ];
}
