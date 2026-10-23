import 'package:sesame_notes/utils/member_id.dart';

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
