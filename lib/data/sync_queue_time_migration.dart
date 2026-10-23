import 'dart:convert';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';

/// 旧队列秒列保存绝对时间，只从同一次意图的有效 UTC 元数据补回亚秒精度。
int legacySyncQueueMilliseconds({
  required int queueId,
  required int seconds,
  required String entityType,
  required String entityId,
  required String mutationId,
  required String action,
  required String payload,
  required String? frozenRequest,
  required Map<String, String?> scopes,
}) {
  if (seconds < -62135596800 || seconds > 253402300799) {
    throw const FormatException('待上传队列的历史时间无法安全转换');
  }
  final baseline = seconds * 1000;

  /// 只接受显式 UTC 且历法合法的时间；本地 ISO 无法证明原时区，不参与推断。
  int? parseUtc(Object? raw) {
    final value = tryParseUtcWireTimestamp(raw);
    if (value == null) {
      return null;
    }
    final precise = value.millisecondsSinceEpoch;
    // 列与包络的绝对秒不同表示元数据矛盾，迁移不能代替用户改写编辑意图。
    if (precise ~/ 1000 != seconds) {
      logger.warning(
        'SyncQueueTime',
        '旧队列时间元数据不一致，保留原绝对时间：queue=$queueId，type=$entityType',
      );
      return null;
    }
    return precise;
  }

  /// 请求必须属于同一条队列身份与父范围，不能使用另一条请求的时间。
  int? envelopeTime() {
    if (frozenRequest == null) return null;
    final data = jsonDecode(frozenRequest);
    if (data is! Map ||
        data['mutation_id'] != mutationId ||
        data['entity_type'] != entityType ||
        data['entity_id'] != entityId ||
        data['action'] != action ||
        scopes.entries.any((entry) => data[entry.key] != entry.value)) {
      logger.warning(
        'SyncQueueTime',
        '旧冻结时间身份或父范围不一致，保留队列绝对时间：queue=$queueId，type=$entityType',
      );
      return null;
    }
    return parseUtc(data['updated_at']);
  }

  try {
    final frozen = envelopeTime();
    if (frozen != null) return frozen;
  } catch (error, stack) {
    logger.error(
      'SyncQueueTime',
      '旧冻结时间无法确认，继续保留原请求：queue=$queueId',
      safeErrorSummary(error),
      stack,
    );
  }
  try {
    final body = jsonDecode(payload);
    if (body is Map && (body['id'] == null || body['id'] == entityId)) {
      return parseUtc(body['updated_at']) ?? baseline;
    }
  } catch (error, stack) {
    logger.error(
      'SyncQueueTime',
      '旧载荷时间无法确认，保留原绝对时间：queue=$queueId',
      safeErrorSummary(error),
      stack,
    );
  }
  return baseline;
}
