import 'package:sesame_notes/utils/member_id.dart';

/// 导出及映射使用真实分类目录归属；共享账本不能冒充当前查看账号的目录。
String ledgerCategorySourceScope({
  required String ledgerId,
  required String storageMode,
  required String? ownerAccountId,
}) {
  if (storageMode == 'local') return 'local:$ledgerId';
  if (ownerAccountId == null || ownerAccountId.isEmpty) {
    throw StateError('账本分类归属尚未同步，请同步后重试');
  }
  return 'account:$ownerAccountId';
}

/// CSV 导入行的确定性交易同步 ID（UUIDv5）。
///
/// 同一逻辑文件（解析后 rows 的稳定 JSON 哈希）+ 同一逻辑行号 + 同一目标
/// 账本必然派生同一个 ID：重复导入同一 CSV 时按主键幂等去重；行号参与
/// 派生保证同文件内两条完全相同但真实存在的账单不会互相去重。名称中再次
/// 携带账本 ID，防止非标准账本 ID 被 uuidV5 容错为零 namespace 时跨账本碰撞。
String csvImportSyncId({
  required String targetLedgerId,
  required String fileHash,
  required int rowIndex,
}) => uuidV5(
  targetLedgerId,
  "csv:${targetLedgerId.toLowerCase()}:$fileHash:row:$rowIndex",
);
