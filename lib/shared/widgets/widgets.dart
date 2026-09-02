// ────────────────────────────────────────────────────────────────
// ⚠️ 护栏：本文件是 barrel（聚合导出）文件。
// 被下方 export 的子文件「禁止」import 本文件，
// 否则形成循环依赖（barrel → export 子文件 → 子文件 import barrel → 死环）。
// 子文件如需引用同 barrel 下其他符号，请直接 import 对应同级子文件。
// 新增 export 前先做符号级使用审计：只导出确实经 barrel 被消费的符号，
// 直接 import 消费的组件不应进入 barrel。
// ────────────────────────────────────────────────────────────────

// ===== 基础通用组件 =====
export 'app_empty.dart';
export 'app_list_tile.dart';
export 'app_sheet.dart';
export 'app_dialog.dart';
export 'app_route.dart';
export 'day_section_header.dart';
export 'primary_header.dart';
export 'section_card.dart';
export 'skeleton.dart';
export 'swipe_hint.dart';
export 'capsule_switcher.dart';
export 'toast.dart';
export 'app_logo.dart';
export 'app_popup_menu.dart';

// ===== 金额 / 数字 / 键盘 =====
export 'amount_text.dart';
export 'format_money.dart';
export 'pin_entry_pad.dart';

// ===== 时间选择 =====
export 'wheel_picker.dart';
export 'wheel_date_picker.dart';
export 'wheel_time_picker.dart';

// ===== 分类相关 =====
export 'category_icon.dart';

// ===== 账本相关 =====
export 'ledger_card.dart';

// ===== 货币相关 =====
export 'currency_flag.dart';

// ===== 统计图表 =====
export 'line_chart.dart';
export 'category_donut_chart.dart';
export 'category_rank_row.dart';

// ===== 账号 / 登录 / 安全 =====
export 'mine_page_header.dart';
