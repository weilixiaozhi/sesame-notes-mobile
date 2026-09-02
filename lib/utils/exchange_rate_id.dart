/// 汇率覆盖确定性 id 派生工具。
///
/// 设计意图：手动汇率覆盖是 user-global 同步实体，服务端 push 契约强制
/// entity_id 等于确定性 UUIDv5（apps/api entity-id.ts 的
/// exchangeRateOverrideId），客户端必须用同一算法派生主键：
/// 同账号同币对在离线端独立写入时收敛到同一实体（重装/多设备可重算），
/// 否则 push 会被服务端以 INVALID_RATE_ID 拒绝。
library;

import 'member_id.dart';

/// 冻结命名空间：与服务端 EXCHANGE_RATE_NAMESPACE 逐字节一致，
/// 改动会破坏跨端 id 映射，必须保持稳定。
const String exchangeRateNamespace = 'cefe9382-b932-5eb7-827d-18944198fbb9';

/// 派生汇率覆盖主键：uuidV5(exchangeRateNamespace, `'<ownerId>:<BASE>:<QUOTE>'`)。
///
/// 币种统一大写规范化后再派生，与账本 id 无关（用户级实体）；
/// ownerId 即云账号 userId，未登录本地域由调用方传入固定兜底键，
/// 保证本地域行确定性且永不与云端行（真实 userId 派生）撞主键。
String exchangeRateOverrideId(
  String ownerId,
  String baseCurrency,
  String quoteCurrency,
) => uuidV5(
  exchangeRateNamespace,
  '$ownerId:${baseCurrency.toUpperCase()}:${quoteCurrency.toUpperCase()}',
);
