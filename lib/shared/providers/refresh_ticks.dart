import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

// 跨域共享的刷新 tick 仅依赖 simple_state_notifier。
// database_providers、sync_providers 单向导入本文件。
//
// ui_state_providers.dart 通过 re-export 提供这些状态。

/// 刷新账本列表的触发器
final ledgerListRefreshProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

/// 手动刷新业务数据的统一触发器。
///
/// 数据库写入仍由 Drift 自动通知；仅当用户主动刷新或同步
/// 失败后需强制重查本地快照时 tick，避免页面逐个 invalidate。
final manualDataRefreshProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);
