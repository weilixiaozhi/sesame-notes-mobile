import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

import 'package:sesame_notes/data/models.dart';

// providers 层「叶子」模块：跨域共享的刷新 tick + 首屏缓存。
//
// 本文件不 import 任何其他 providers 子文件，处于 providers 层依赖链最底端；
// sync_providers / ui_state_providers 均单向依赖本文件。
//
// 消费方无需感知本文件：sync_providers.dart / ui_state_providers.dart
// 均对其做了 re-export，可见符号不变。

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

// 首页切换到 Stream 模式触发器（用户交互时触发）
final homeSwitchToStreamProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

/// 完整的交易展示数据（不含标签、附件字段）
/// 用于首页列表一次性加载，避免二次查询闪烁
typedef TransactionDisplayItem = ({
  TransactionDisplay t,
  CategoryDisplay? category,
});

// 两侧使用方：sync_providers 的 bootstrap 完成时清缓存，
// ui_state_providers 的启屏预加载时写缓存。
final cachedTransactionsProvider =
    NotifierProvider<
      SimpleStateNotifier<List<TransactionDisplayItem>?>,
      List<TransactionDisplayItem>?
    >(() => SimpleStateNotifier((ref) => null));
