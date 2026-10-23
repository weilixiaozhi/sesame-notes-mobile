import 'dart:convert';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// 已观测云态必须属于同一账号与分类，并包含可比较的权威 UTC 时间。
Map<String, dynamic>? decodeCategoryCloudState(
  String? encoded, {
  required String id,
  required String account,
}) {
  if (encoded == null) return null;
  try {
    final value = jsonDecode(encoded);
    if (value is! Map ||
        value['id'] != id ||
        value['owner_id'] != account ||
        value['updated_at'] is! String ||
        (value['version_token'] != null && value['version_token'] is! String)) {
      throw const FormatException('分类云端状态无法确认，请先同步后再重试');
    }
    final timestamp = DateTime.tryParse(value['updated_at'] as String);
    if (timestamp == null || !timestamp.isUtc) {
      throw const FormatException('分类云端状态无法确认，请先同步后再重试');
    }
    return Map<String, dynamic>.from(value);
  } catch (error, stack) {
    logger.error(
      'CategoryCloudState',
      '读取分类云态失败: category=$id',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}
