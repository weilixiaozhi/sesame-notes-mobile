import 'package:flutter/material.dart';

/// 统一日历在现有业务组件内共享卡片规格，业务字段和操作仍由原组件负责。
class CalendarEntryScope extends InheritedWidget {
  const CalendarEntryScope({super.key, required super.child});

  /// 读取当前明细是否采用日历规格。
  static bool active(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CalendarEntryScope>() != null;

  @override
  bool updateShouldNotify(CalendarEntryScope oldWidget) => false;
}
