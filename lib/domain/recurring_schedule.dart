import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/data/latest_all.dart' as all_timezone_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:sesame_notes/data/models/accounting_records.dart';

/// 周期协议固定版本；普通交易不依赖此协议。
const recurringProtocolVersion = 1;

/// 与跨端协议保持相同的四位年份范围，避免本地生成无法上传的发生。
void validateRecurringDateRange(DateTime start, DateTime? end) {
  if (start.year < 1000 ||
      start.year > 9999 ||
      (end != null && (end.year < 1000 || end.year > 9999))) {
    throw const FormatException('周期日期年份必须在 1000 到 9999 之间。');
  }
  if (end != null &&
      recurringCalendarDate(end).isBefore(recurringCalendarDate(start))) {
    throw const FormatException('结束日期不能早于开始日期。');
  }
}

/// 纯日期以 UTC 零点承载，绝不把设备 UTC 偏移当成日历日期的一部分。
DateTime recurringCalendarDate(DateTime value) =>
    DateTime.utc(value.year, value.month, value.day);

/// 协议日期统一为四位年份的 YYYY-MM-DD。
String recurringDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// 与服务端共享 SHA-256 种子并设置 UUID v4/variant 位，同一规则同一天只有一个身份。
String recurringOccurrenceId(String ledgerId, String ruleId, String date) {
  final bytes = sha256
      .convert(
        utf8.encode(
          'sesame-notes:recurring:v1:${ledgerId.toLowerCase()}:${ruleId.toLowerCase()}:$date',
        ),
      )
      .bytes
      .take(16)
      .toList();
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// 独立初始化数据库但不重置已就绪的通知时区；不接受缩写或临时偏移代替 IANA 名称。
tz.Location recurringLocation(String timeZone) {
  if (tz.timeZoneDatabase.locations.isEmpty) {
    timezone_data.initializeTimeZones();
  }
  if (timeZone == 'UTC') return tz.UTC;
  try {
    return tz.getLocation(timeZone);
  } catch (_) {
    // 完整 IANA link 库兼容服务器规范名，保留通知模块已经选择的设备时区。
    final local = tz.local;
    all_timezone_data.initializeTimeZones();
    tz.setLocalLocation(local);
    try {
      return tz.getLocation(timeZone);
    } catch (_) {
      throw FormatException('周期账单时区无效，请选择有效的 IANA 时区。');
    }
  }
}

/// 将明确的规则日期转换为该时区的日开始瞬时，夏令时由固定规则库处理。
DateTime recurringOccurrenceInstant(DateTime date, String timeZone) {
  final location = recurringLocation(timeZone);
  final target = recurringCalendarDate(date).millisecondsSinceEpoch;
  var low = target - const Duration(hours: 48).inMilliseconds;
  var high = target + const Duration(hours: 48).inMilliseconds;
  // 和服务端相同的日界二分：被夏令时跳过的零点/整天映射到下一存在的瞬时。
  while (low < high) {
    final middle = low + (high - low) ~/ 2;
    final local = tz.TZDateTime.fromMillisecondsSinceEpoch(location, middle);
    if (recurringCalendarDate(local).isBefore(recurringCalendarDate(date))) {
      low = middle + 1;
    } else {
      high = middle;
    }
  }
  return DateTime.fromMillisecondsSinceEpoch(low, isUtc: true);
}

/// 设备当前时间只用于取规则时区的今天，不改变规则的开始日和月末锚点。
DateTime recurringToday(String timeZone, DateTime instant) {
  final local = tz.TZDateTime.from(instant, recurringLocation(timeZone));
  return DateTime.utc(local.year, local.month, local.day);
}

/// 返回连续游标之后的下一发生日期；从开始日补齐，结束日当天仍可生成。
DateTime? nextRecurringDate(RecurringTransactionSnapshot rule, DateTime today) {
  if (rule.protocolVersion != recurringProtocolVersion) {
    throw StateError('周期规则的协议格式无效，原数据未修改。');
  }
  if (!rule.enabled || rule.deletedAt != null) return null;
  validateRecurringDateRange(rule.startDate.toUtc(), rule.endDate?.toUtc());
  if (rule.interval < 1 || rule.interval > 10000) {
    throw FormatException('周期间隔必须为 1 到 10000。');
  }
  final start = recurringCalendarDate(rule.startDate.toUtc());
  final previous = rule.lastGeneratedDate == null
      ? null
      : recurringCalendarDate(rule.lastGeneratedDate!.toUtc());
  final lower = previous != null && !previous.isBefore(start)
      ? previous.add(const Duration(days: 1))
      : start;
  final targetDay = rule.dayOfMonth ?? start.day;
  DateTime monthDate(int year, int month, int day) {
    final firstDay = DateTime.utc(year, month);
    final lastDay = DateTime.utc(firstDay.year, firstDay.month + 1, 0).day;
    return DateTime.utc(
      firstDay.year,
      firstDay.month,
      day > lastDay ? lastDay : day,
    );
  }

  DateTime candidate;
  switch (rule.frequency) {
    case 'daily':
      final periods = (lower.difference(start).inDays / rule.interval).ceil();
      candidate = start.add(Duration(days: periods * rule.interval));
    case 'weekly':
      final weekday = rule.dayOfWeek ?? start.weekday;
      if (weekday < 1 || weekday > 7) throw FormatException('每周日期无效。');
      final first = start.add(
        Duration(days: (weekday - start.weekday + 7) % 7),
      );
      final periods = (lower.difference(first).inDays / (7 * rule.interval))
          .ceil()
          .clamp(0, 100000000);
      candidate = first.add(Duration(days: periods * 7 * rule.interval));
    case 'monthly':
      if (targetDay < 1 || targetDay > 31) throw FormatException('每月日期无效。');
      final delta = (lower.year - start.year) * 12 + lower.month - start.month;
      var periods = delta ~/ rule.interval;
      candidate = monthDate(
        start.year,
        start.month + periods * rule.interval,
        targetDay,
      );
      if (candidate.isBefore(lower)) {
        candidate = monthDate(
          start.year,
          start.month + ++periods * rule.interval,
          targetDay,
        );
      }
    case 'yearly':
      final month = rule.monthOfYear ?? start.month;
      if (month < 1 || month > 12 || targetDay < 1 || targetDay > 31) {
        throw FormatException('每年日期无效。');
      }
      var periods = (lower.year - start.year) ~/ rule.interval;
      candidate = monthDate(
        start.year + periods * rule.interval,
        month,
        targetDay,
      );
      if (candidate.isBefore(lower)) {
        candidate = monthDate(
          start.year + ++periods * rule.interval,
          month,
          targetDay,
        );
      }
    default:
      throw FormatException('未知周期频率。');
  }
  if (candidate.year < 1000 || candidate.year > 9999) return null;
  if (candidate.isAfter(recurringCalendarDate(today)) ||
      (rule.endDate != null &&
          candidate.isAfter(recurringCalendarDate(rule.endDate!.toUtc())))) {
    return null;
  }
  return candidate;
}
