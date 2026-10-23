/// 数据模型统一出口（barrel）。
///
/// presentation 页面与共享组件通过展示模型访问数据，不直接使用
/// db.dart 中的表、Companion、SesameDatabase 或查询 API。
/// 本出口限制直接可见符号；所导出类型仍可能传递依赖 schema。
///
/// 分层约定：
/// - 写路径与查询：UI 调 application 用例或查询 Provider，由其访问仓储；
/// - 读路径：Provider 或应用层方法向 UI 提供展示对象及其 Stream；
/// - 模型类型：本 barrel 提供展示对象、选择树与导入模型。
///
/// 新增展示模型应显式评估公共出口；不因新增数据库表而导出 Drift Row。
library;

export 'models/fitness.dart';
export 'models/fitness_sync_status.dart';

export 'models/day_book.dart';
export 'models/day_event.dart';
export 'models/fitness_catalog.dart';

// 展示模型与层级构建器统一经本 barrel 出口。
export 'models/ledger_display_item.dart';
export 'models/category_display.dart';
export 'models/transaction_display.dart';
export 'models/ledger_member_display.dart';
export 'models/recurring_transaction_display.dart';
export 'models/transaction_metadata_display.dart';
// 冲突展示模型：页面不接触 Drift 生成的 SyncConflict Row。
export 'models/sync_rejection_view.dart';
export 'models/category_picker_tree.dart' show CategoryPickerTree;
// 统一数据导入模型：
// 导入流程共享 Import* 数据类型；落库编排位于
// features/settings/infrastructure/data_import_service.dart。
export 'models/import_models.dart'
    show
        ImportCategory,
        ImportCategoryPath,
        ImportTransaction,
        ImportData,
        ImportResult;

/// 周期记账频率枚举。
///
/// 数据模型层定义,页面与 Provider 统一经本门面引用,
/// 避免页面直接依赖服务层文件。
enum RecurringFrequency {
  daily('daily'), // 每天
  weekly('weekly'), // 每周
  monthly('monthly'), // 每月
  yearly('yearly'); // 每年

  final String value;
  const RecurringFrequency(this.value);

  static RecurringFrequency fromString(String value) {
    return RecurringFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RecurringFrequency.monthly,
    );
  }
}
