import 'dart:convert';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart'
    show TransactionSplitInput;

/// AA 分摊字段统一工具。
///
/// AA 分摊收敛为 transaction_splits 关系表(user_id/virtual_user_id
/// 二选一 + amount),本地 UI 编辑模型仍以「参与人标识列表 + 标识→金额映射」
/// 表达,这里提供关系表行与 UI 模型之间的双向转换,所有调用方共享同一份
/// 实现(虚拟用户区分、空值语义只定义一次)。

/// 把关系表行转换为 UI 编辑模型(参与人列表 + 指定金额映射)。
///
/// 仅指定分摊(aa_mode=2)落行;人均/不分摊模式不落行,返回 null
/// (语义:全部成员运行时展开,与后端契约一致)。
({List<String>? participantIds, Map<String, String>? splits}) aaRowsToEditModel(
  List<TransactionSplitDisplay> rows,
) {
  if (rows.isEmpty) return (participantIds: null, splits: null);
  final splits = <String, String>{};
  for (final row in rows) {
    splits[row.memberId] = row.amount;
  }
  return (participantIds: splits.keys.toList(), splits: splits);
}

/// 把 UI 编辑模型转换为关系表写入行。
///
/// 参与人标识即成员 id（单轨模型：真实/虚拟用户均以成员形态参与），
/// 直接透传写入 member_id。
/// aaMode != 2(非指定分摊)时返回 null,调用方整批清空关系表。
List<TransactionSplitInput>? aaEditModelToSplitInputs({
  required int? aaMode,
  required Map<String, String>? splits,
  required Set<String> virtualUserIds,
}) {
  // aaMode 为 null = 账本未开启 AA:调用方不更新 AA 字段(保留原值)。
  if (aaMode == null) return null;
  // 人均/不分摊(0/1)或未填金额:显式返回空列表,调用方整批清空关系表,
  // 避免切换分摊方式后残留旧指定分摊行。
  if (aaMode != 2 || splits == null || splits.isEmpty) return const [];
  return [
    for (final entry in splits.entries)
      TransactionSplitInput(memberId: entry.key, amount: entry.value),
  ];
}

/// 解析历史 aaParticipants JSON(兼容存量旧格式数据)。
///
/// 空 / 解析失败返回 null(语义:全部成员运行时展开)。
List<String>? parseAaParticipantIds(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    return (jsonDecode(json) as List).map((e) => e.toString()).toList();
  } catch (e, st) {
    logger.warning('AaFields', '解析 aaParticipants 失败', '$e\n$st');
    return null;
  }
}

/// 解析历史 aaSplits JSON(兼容存量旧格式数据)。
Map<String, String>? parseAaSplits(String? json) {
  if (json == null || json.isEmpty) return null;
  try {
    final obj = jsonDecode(json) as Map<String, dynamic>;
    return {for (final e in obj.entries) e.key: e.value.toString()};
  } catch (e, st) {
    logger.warning('AaFields', '解析 aaSplits 失败', '$e\n$st');
    return null;
  }
}
