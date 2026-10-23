/// 同步与备份统一使用 UTC 毫秒精度，截去协议不支持的微秒。
String wireTimestamp(DateTime value) => DateTime.fromMillisecondsSinceEpoch(
  value.millisecondsSinceEpoch,
  isUtc: true,
).toIso8601String();

/// 只解析显式 UTC 且历法合法的协议时间，不以当前设备时区猜测无时区内容。
DateTime? tryParseUtcWireTimestamp(Object? raw) {
  try {
    if (raw is! String ||
        raw.startsWith('0000') ||
        !RegExp(
          r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?Z$',
        ).hasMatch(raw)) {
      return null;
    }
    final value = DateTime.tryParse(raw);
    // DateTime 会把越界日期归一化，协议校验需要拒绝这种内容。
    if (value == null ||
        raw.substring(0, 19) != value.toIso8601String().substring(0, 19)) {
      return null;
    }
    return value;
  } catch (_) {
    // 调用方根据操作阶段记录错误，解析器只返回明确不可读取的事实。
    return null;
  }
}
