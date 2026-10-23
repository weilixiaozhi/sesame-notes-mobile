import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';

/// 静态校验保持跨设备一致；设备今天只约束交互新增和修改出生日期。
DayEventDefinition validateDayEditorDefinition(
  DayEventDefinition value,
  DateOnly today, {
  DayEventDefinition? original,
}) {
  final definition = const DayDateRules().validateAndProject(value);
  if (definition.category == DayCategory.birthday &&
      (original?.category != DayCategory.birthday ||
          original?.event?.solarDate != definition.event?.solarDate) &&
      definition.event!.solarDate!.isAfter(today)) {
    throw const DayDateException('birthday_in_future');
  }
  if (definition.category == DayCategory.stage &&
      definition.end == null &&
      definition.start!.solarDate!.isAfter(today)) {
    throw const DayDateException('stage_end_before_start');
  }
  return definition;
}
