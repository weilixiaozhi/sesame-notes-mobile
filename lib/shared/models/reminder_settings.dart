/// 本机全局及分类提醒设置
class ReminderSettings {
  // 每日记账分类开关受通知总开关控制。
  final bool isEnabled;
  final bool isLoaded;
  final bool notificationsEnabled;
  final bool restEnabled;
  final bool daysEnabled;
  final int daysHour;
  final int daysMinute;
  final int daysOffsets;
  final bool daysDailyEnabled;
  final Set<String> daysDailyEventIds;
  static const allowedDayOffsets = [0, 1, 3, 7];
  List<int> get selectedDayOffsets => [
    for (final day in allowedDayOffsets)
      if (daysOffsets & (1 << day) != 0) day,
  ];
  bool get dailyActive => isLoaded && notificationsEnabled && isEnabled;
  bool get daysActive => isLoaded && notificationsEnabled && daysEnabled;
  bool get restActive => isLoaded && notificationsEnabled && restEnabled;
  final int hour; // 0-23
  final int minute; // 0-59

  /// 保存设备提醒配置；每日纪念日提醒仅作用于选中的记录。
  const ReminderSettings({
    required this.isEnabled,
    required this.hour,
    required this.minute,
    this.isLoaded = true,
    this.notificationsEnabled = false,
    this.restEnabled = true,
    this.daysEnabled = false,
    this.daysHour = 9,
    this.daysMinute = 0,
    this.daysOffsets = 3,
    this.daysDailyEnabled = false,
    this.daysDailyEventIds = const {},
  });

  /// 加载完成前保持全部通知关闭，避免用默认配置覆盖已有排期。
  factory ReminderSettings.defaultSettings() {
    return const ReminderSettings(
      isEnabled: false,
      isLoaded: false,
      hour: 21, // 默认晚上9点
      minute: 0,
    );
  }

  /// 合并变更并固定选中集合，后续编辑选项不会改变已发布的设置。
  ReminderSettings copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    bool? notificationsEnabled,
    bool? restEnabled,
    bool? daysEnabled,
    int? daysHour,
    int? daysMinute,
    int? daysOffsets,
    bool? daysDailyEnabled,
    Set<String>? daysDailyEventIds,
  }) {
    return ReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoaded: isLoaded,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      restEnabled: restEnabled ?? this.restEnabled,
      daysEnabled: daysEnabled ?? this.daysEnabled,
      daysHour: daysHour ?? this.daysHour,
      daysMinute: daysMinute ?? this.daysMinute,
      daysOffsets: daysOffsets ?? this.daysOffsets,
      daysDailyEnabled: daysDailyEnabled ?? this.daysDailyEnabled,
      daysDailyEventIds: Set.unmodifiable(
        daysDailyEventIds ?? this.daysDailyEventIds,
      ),
    );
  }

  String get timeString {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// 多选顺序不影响配置是否相同，集合内容变化仍会触发重新排期。
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderSettings &&
          runtimeType == other.runtimeType &&
          isLoaded == other.isLoaded &&
          isEnabled == other.isEnabled &&
          hour == other.hour &&
          minute == other.minute &&
          notificationsEnabled == other.notificationsEnabled &&
          restEnabled == other.restEnabled &&
          daysEnabled == other.daysEnabled &&
          daysHour == other.daysHour &&
          daysMinute == other.daysMinute &&
          daysOffsets == other.daysOffsets &&
          daysDailyEnabled == other.daysDailyEnabled &&
          daysDailyEventIds.length == other.daysDailyEventIds.length &&
          daysDailyEventIds.containsAll(other.daysDailyEventIds);

  /// 与配置和无序多选集合的相等语义保持一致。
  @override
  int get hashCode => Object.hash(
    isLoaded,
    isEnabled,
    hour,
    minute,
    notificationsEnabled,
    restEnabled,
    daysEnabled,
    daysHour,
    daysMinute,
    daysOffsets,
    daysDailyEnabled,
    Object.hashAllUnordered(daysDailyEventIds),
  );
}
