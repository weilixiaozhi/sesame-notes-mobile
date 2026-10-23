import 'package:flutter/services.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/models/memo.dart';

/// 两个手机平台共用中文名称排序规则，正文和密码字段不进入系统通道。
class MemoNameOrder {
  static const _channel = MethodChannel('com.sesame_notes.memo_name_order');

  /// 系统排序固定使用中文、自然数字和基础字母权重，同名以身份稳定排列。
  Future<List<MemoEntry>> sort(List<MemoEntry> entries) async {
    try {
      if (entries.length < 2) return List.of(entries);
      final ids = await _channel.invokeListMethod<String>('sortNames', [
        for (final entry in entries) {'id': entry.id, 'title': entry.title},
      ]);
      final byId = {for (final entry in entries) entry.id: entry};
      if (ids == null ||
          ids.length != entries.length ||
          ids.toSet().length != entries.length ||
          ids.any((id) => !byId.containsKey(id))) {
        throw StateError('MEMO_NAME_ORDER_INVALID');
      }
      return [for (final id in ids) byId[id]!];
    } catch (error, stackTrace) {
      logger.error(
        'MemoNameOrder',
        '卡片名称排序失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }
}
