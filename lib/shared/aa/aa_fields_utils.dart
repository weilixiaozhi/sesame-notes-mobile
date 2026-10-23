import 'package:sesame_notes/data/models/transaction_split_input.dart';
import 'package:decimal/decimal.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/split_money.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';

/// AA 分摊字段统一工具。
///
/// AA 指定分摊存于 transaction_splits 关系表（member_id + amount），
/// 注册成员与占位成员统一使用成员 id。本地 UI 编辑模型以「成员标识列表 +
/// 标识→金额映射」表达，这里提供关系表行与 UI 模型之间的双向转换。

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
/// aaMode 为 null 时保留原值；非指定分摊时返回空列表，清空旧分摊行。
List<TransactionSplitInput>? aaEditModelToSplitInputs({
  required int? aaMode,
  required Map<String, String>? splits,
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

/// 详情与两个编辑入口共同把持久化的本位币分摊转为交易原币。
Map<String, String> originalSplitAmounts(
  Map<String, String> splits, {
  required String amount,
  required String nativeAmount,
  required String? payerMemberId,
}) {
  if (splits.isEmpty) return splits;
  final keys = splits.keys.toList();
  final converted = convertSplits(
    splits: splits.values.map(Decimal.parse).toList(),
    fromTotal: Decimal.parse(nativeAmount),
    toTotal: Decimal.parse(amount),
    remainderIndex: keys.indexOf(payerMemberId ?? ''),
  );
  return {
    for (var i = 0; i < keys.length; i++)
      keys[i]: normalizeDecimal(converted[i]),
  };
}
