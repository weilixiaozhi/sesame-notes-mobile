/// 账本归属判定统一出口（Dart 谓词 + SQL 工厂同源）。
///
/// 设计意图：
/// 云同步判定账本是「云端账本」还是「本地账本」的逻辑散落在
/// sync 引擎、序列化、ChangeTracker、UI 模型多处,各写各的
/// (`storageMode == 'cloud'` / `storageMode == 'local'`),既容易
/// 漏掉 `isShared` 兜底,也容易被 null 取反翻转。本文件把两套
/// 判定收敛成两个纯函数 + 一个挂在 [Ledger] 上的 extension +
/// 一个 SQL 表达式工厂,所有调用方只认这里,语义变更只改一处。
library;

import 'package:drift/drift.dart' as d;

import 'package:sesame_notes/data/db.dart' show Ledger, Ledgers;

/// 判定账本是否属于「云端账本」(参与被动同步、退出登录时会被清理)。
///
/// 统一规则:`storageMode == 'cloud' || isShared`。
///
/// 为什么这样写:
/// - `storageMode` 是账本归属的唯一权威(用户可以把云端账本移回本地,
///   那时 storageMode 被改回 'local' 但心智仍是同一本账);
/// - `isShared` 为 true 说明该账本是从云端共享进来的,必然是云端账本。
///   即便 storageMode 尚未回填为 'cloud',共享账本也绝不能被当作纯本地账本
///   处理(否则会绕过同步闸门,把别人的数据当本地数据留存)。
bool isCloudLedgerOf(String? storageMode, {required bool isShared}) =>
    storageMode == 'cloud' || isShared;

/// 判定账本是否属于「本地账本」(纯本地,不参与被动同步)。
///
/// 统一规则:`storageMode == 'local' && !isShared`。
///
/// 为什么这样写:不能写成 `!isCloudLedgerOf(...)` 的取反 ——
/// storageMode 为 null 或未知值时取反会翻转成"本地账本",导致漏同步;
/// 只有显式 'local' **且** 非共享才拦截,语义最保守。
bool isLocalLedgerOf(String? storageMode, {required bool isShared}) =>
    storageMode == 'local' && !isShared;

/// 挂在 [Ledger] 上的便捷判定。
extension LedgerKindX on Ledger {
  /// 是否为共享账本:成员数 > 1(共享性以 member_count 表达;
  /// Owner 单人账本 member_count == 1)。
  bool get isShared => memberCount > 1;

  /// 是否为云端账本(参与被动同步、退出登录时被清理)。
  bool get isCloudLedger => isCloudLedgerOf(storageMode, isShared: isShared);

  /// 是否为本地账本(纯本地,不参与被动同步)。
  bool get isLocalLedger => isLocalLedgerOf(storageMode, isShared: isShared);
}

/// 云端账本归属判定的 SQL 表达式工厂,与 [isCloudLedgerOf] 同源同义。
///
/// 为什么是工厂(而非 extension / 内联 SQL):
/// - 这是「归属判定」在 Drift 查询里的唯一形态,与 Dart 谓词是同一规则的
///   孪生副本,改一处极易漏改另一处;
/// - 抽成工厂后,SQL 与 Dart 两个形态都指向 `ledger_kind.dart` 一处,规则变更
///   只改这里,并有 `ledger_kind_test.dart` 的逐行等价性测试兜底。
///
/// 边界(刻意不加的东西):本工厂只封装「归属判定」两个条件,**不含**
/// `syncId.isNotNull()` 与空串过滤 —— 那些是同步引擎的增量过滤(syncId 为空
/// 的账本无法 push/stats),属于 sync_engine 私有逻辑,不进统一出口。
d.Expression<bool> cloudLedgerFilter(Ledgers l) =>
    l.storageMode.equals('cloud') | l.memberCount.isBiggerThanValue(1);
