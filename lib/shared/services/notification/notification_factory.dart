import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'notification_util.dart';
import 'notification_android.dart';
import 'notification_android_rest.dart';
import 'notification_navigation.dart';

/// 通知工厂类 - 根据平台创建对应的通知实现
class NotificationFactory {
  static NotificationUtil? _instance;
  static NotificationUtil? _daysInstance;
  static NotificationUtil? _fitnessTestInstance;

  /// 只有已实现的原生平台或显式注入的通知后端可以提交提醒配置。
  static bool get supportsReminders => Platform.isAndroid || _instance != null;

  static NotificationUtil getDaysInstance() {
    if (_daysInstance != null) return _daysInstance!;
    if (!Platform.isAndroid) {
      throw UnsupportedError('不支持的平台: ${Platform.operatingSystem}');
    }
    return _daysInstance = AndroidNotificationUtil(
      _plugin,
      channel: const AndroidNotificationChannel(
        'days_reminder',
        '纪念日提醒',
        importance: Importance.high,
      ),
      visibility: NotificationVisibility.private,
      destination: NotificationDestination.days,
      prepareSchedule: ensureTimeZone,
    );
  }

  @visibleForTesting
  static void setDaysInstanceForTesting(NotificationUtil instance) {
    _daysInstance = instance;
  }

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static final _fitnessInstances = <String, NotificationUtil>{};

  /// 休息结束使用系统闹钟铃声与闹钟音量，默认以两段振动提示。
  @visibleForTesting
  static AndroidNotificationChannel buildFitnessRestChannel({
    required String channelName,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) => AndroidNotificationChannel(
    'fitness_rest_alarm_v2',
    channelName,
    importance: Importance.high,
    playSound: soundEnabled,
    sound: const UriAndroidNotificationSound(
      'content://settings/system/alarm_alert',
    ),
    audioAttributesUsage: AudioAttributesUsage.alarm,
    enableVibration: vibrationEnabled,
    vibrationPattern: Int64List.fromList([0, 1000, 300, 1000]),
    showBadge: false,
  );

  /// 休息提醒使用唯一渠道；声音与振动偏好只用于首次创建，已有渠道沿用系统设置。
  static NotificationUtil getFitnessRestInstance({
    required String channelName,
    required bool soundEnabled,
    required bool vibrationEnabled,
  }) {
    if (_fitnessTestInstance != null) return _fitnessTestInstance!;
    if (!Platform.isAndroid) {
      throw UnsupportedError('不支持的平台: ${Platform.operatingSystem}');
    }
    return _fitnessInstances.putIfAbsent(
      '$channelName:$soundEnabled:$vibrationEnabled',
      () => AndroidRestNotificationUtil(
        _plugin,
        channel: buildFitnessRestChannel(
          channelName: channelName,
          soundEnabled: soundEnabled,
          vibrationEnabled: vibrationEnabled,
        ),
        prepareChannel: () async {
          await const MethodChannel(
            'notification_channel',
          ).invokeMethod('prepareFitnessRestChannel', {
            'channelName': channelName,
            'soundEnabled': soundEnabled,
            'vibrationEnabled': vibrationEnabled,
          });
        },
      ),
    );
  }

  /// 非 Android 宿主注入休息通知替身，验证真实生命周期的登记和取消行为。
  @visibleForTesting
  static void setFitnessRestInstanceForTesting(NotificationUtil instance) {
    _fitnessTestInstance = instance;
  }

  static NotificationUtil getInstance() {
    if (_instance != null) return _instance!;

    if (Platform.isAndroid) {
      _instance = AndroidNotificationUtil(
        _plugin,
        prepareSchedule: ensureTimeZone,
      );
    } else {
      throw UnsupportedError('不支持的平台: ${Platform.operatingSystem}');
    }

    return _instance!;
  }

  /// 测试注入点：非 Android 测试宿主（如 Windows/CI）无法创建平台通知实现，
  /// 允许测试注入内存假实现来验证业务编排，不影响生产路径。
  @visibleForTesting
  static void setInstanceForTesting(NotificationUtil? instance) {
    _instance = instance;
  }

  /// 初始化时区（必须在使用通知服务之前调用）
  static Future<void>? _timeZoneReady;

  /// 每次调度等待同一个时区初始化，避免首帧中的多个提醒抢先使用 UTC。
  static Future<void> ensureTimeZone() =>
      _timeZoneReady ?? initializeTimeZone();

  /// 串行重读设备时区，调度等待最新一轮刷新，避免较早请求晚返回后覆盖当前规则。
  static Future<void> initializeTimeZone() {
    final previous = _timeZoneReady;
    late final Future<void> refresh;
    refresh = _refreshTimeZone(previous).then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        // 失败的就绪状态不能缓存，之后的主动恢复必须重新访问系统。
        if (identical(_timeZoneReady, refresh)) _timeZoneReady = null;
        Error.throwWithStackTrace(error, stack);
      },
    );
    return _timeZoneReady = refresh;
  }

  /// 排队刷新只等待前一次读取收尾；前一次失败后仍须执行本轮明确请求。
  static Future<void> _refreshTimeZone(Future<void>? previous) async {
    try {
      await previous;
    } catch (_) {
      // 这里只释放读取顺序，原始错误仍由前一次调用方接收，不作为时区就绪结果。
    }
    await _loadTimeZone();
  }

  /// 从系统恢复冷启动通知，实际导航交给应用就绪与解锁闸门。
  static Future<void> restoreLaunchNotification() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp == true &&
          details?.notificationResponse != null) {
        NotificationNavigation.receive(details!.notificationResponse!);
      }
    } catch (error, stack) {
      logger.error('NotificationFactory', '读取通知启动信息失败', error, stack);
    }
  }

  /// 接受设备声明的 IANA 或明确固定偏移规则，读取失败保留已有规则并交调用方处理。
  static Future<void> _loadTimeZone() async {
    // 使用系统 IANA 标识，让每日重复通知沿用当地的夏令时规则。
    final zoneName = await const MethodChannel(
      'notification_channel',
    ).invokeMethod<String>('getTimeZone');
    if (zoneName == null) throw StateError('系统未返回时区标识');
    final location = _deviceTimeZone(zoneName);
    tz.setLocalLocation(location);
    logger.info('NotificationFactory', '[Timezone] 设置为: $zoneName');
  }

  /// Java 的自定义时区 ID 使用规范 GMT±HH:mm；该明确规则没有夏令时，不能按 IANA 查库。
  static tz.Location _deviceTimeZone(String zoneName) {
    final fixed = RegExp(
      r'^GMT([+-])([01]\d|2[0-3]):([0-5]\d)$',
    ).firstMatch(zoneName);
    if (fixed != null) {
      final minutes =
          int.parse(fixed.group(2)!) * 60 + int.parse(fixed.group(3)!);
      final offset = Duration(
        minutes: fixed.group(1) == '-' ? -minutes : minutes,
      );
      return tz.Location(zoneName, [], [], [
        tz.TimeZone(offset, isDst: false, abbreviation: zoneName),
      ]);
    }
    // 完整解析成功后才切换当地时区；失败不猜测偏移，也不重置已有的当地选择。
    if (tz.timeZoneDatabase.locations.isEmpty) tz.initializeTimeZones();
    return tz.getLocation(zoneName);
  }

  /// 重置实例（用于测试）
  static void reset() {
    _instance = null;
    _daysInstance = null;
    _fitnessTestInstance = null;
    _fitnessInstances.clear();
    _timeZoneReady = null;
    NotificationNavigation.pending.value = null;
  }
}
