import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_reminder.dart';
import 'package:sesame_notes/shared/services/notification/notification_android.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/services/notification/notification_navigation.dart';
import 'package:sesame_notes/shared/services/notification/notification_util.dart';
import 'package:sesame_notes/shared/services/notification/reminder_constants.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

const _packageName = 'com.sesame.notes.test.probe';
const _logPrefix = 'NOTIFICATION_PROBE_JSON:';
const _storageKey = 'notification_delivery_probe_jobs';
const _exactId = 19001;
const _alarmClockId = 19002;

/// 独立通知验收入口，仅允许测试探针包调用真实 Android 通知服务。
///
/// 通过按钮登记后，可分别验证前台、上滑、一键清理及 am kill。
/// 启动和恢复只读取状态，不重排或清理，保留进程被结束后的系统证据。
/// 入口不加载产品主应用、账号、数据库，也不连接服务端。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AppEnvironment.validate();
    final package = await PackageInfo.fromPlatform();
    if (!Platform.isAndroid ||
        AppEnvironment.name != 'test' ||
        package.packageName != _packageName) {
      throw StateError('通知探针仅允许 Android test 环境的 $_packageName 独立包');
    }
    _emit('startup', {'package': package.packageName});
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const _NotificationProbe(),
      ),
    );
  } catch (error, stack) {
    _reportError('startup', error, stack);
    runApp(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: const Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimens.p20),
              child: Text('通知探针无法启动。请使用独立 test.probe 测试包，并保留日志检查构建配置。'),
            ),
          ),
        ),
      ),
    );
  }
}

/// 结构化日志在 profile 模式同样输出，便于 adb logcat 保留绝对时刻及任务标识。
void _emit(String event, Map<String, Object?> data) {
  try {
    stdout.writeln(
      '$_logPrefix${jsonEncode({'event': event, 'at': DateTime.now().toIso8601String(), 'epoch_ms': DateTime.now().millisecondsSinceEpoch, ...data})}',
    );
  } catch (error, stack) {
    logger.error('NotificationProbe', '输出通知探针日志失败', error, stack);
  }
}

/// 错误同时保留产品日志和完整探针堆栈，界面只展示可操作的友好提示。
void _reportError(String action, Object error, StackTrace stack) {
  logger.error('NotificationProbe', '通知验收操作失败：$action', error, stack);
  _emit('error', {
    'action': action,
    'error': error.toString(),
    'stack': stack.toString(),
  });
}

/// 提供显式登记、精确定时对照及清理入口，所有任务只作用于独立测试包。
class _NotificationProbe extends StatefulWidget {
  const _NotificationProbe();

  /// 建立界面状态，通知服务仅在包名验证通过后才创建。
  @override
  State<_NotificationProbe> createState() => _NotificationProbeState();
}

class _NotificationProbeState extends State<_NotificationProbe>
    with WidgetsBindingObserver {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _accounting = NotificationFactory.getInstance();
  final _days = NotificationFactory.getDaysInstance();
  final _fitness = NotificationFactory.getFitnessRestInstance(
    channelName: '休息提醒',
    soundEnabled: true,
    vibrationEnabled: true,
  );
  final _jobs = <Map<String, Object?>>[];
  Timer? _ticker;
  bool _busy = false;
  String _status = '正在读取测试任务';
  String _snapshot = '尚未读取';
  int _lastCountdown = -1;

  /// 恢复本探针登记记录；计时器只刷新显示，不承担任何通知投递任务。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      final remaining = _remainingSeconds;
      if (remaining != _lastCountdown && remaining % 10 == 0) {
        _lastCountdown = remaining;
        _emit('countdown', {'remaining_seconds': remaining});
      }
    });
    unawaited(
      _run('读取任务', () async {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(_storageKey);
        if (saved != null) {
          final parsed = jsonDecode(saved) as List<dynamic>;
          _jobs.addAll(
            parsed.map((item) => Map<String, Object?>.from(item as Map)),
          );
        }
        await _refreshSnapshot();
      }),
    );
  }

  /// 恢复前台只记录生命周期，不自动登记、取消或替换系统任务。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _emit('lifecycle', {'state': state.name, 'jobs': _jobs});
  }

  /// 销毁界面时只释放显示计时器，已登记通知仍由 Android 执行。
  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 依据绝对到期时间显示倒计时，后台暂停不影响计划时刻。
  int get _remainingSeconds {
    final now = DateTime.now().millisecondsSinceEpoch;
    final future = _jobs
        .map((job) => job['due_epoch_ms'] as int)
        .where((due) => due > now)
        .toList();
    if (future.isEmpty) return 0;
    future.sort();
    return ((future.first - now) / 1000).ceil();
  }

  /// 串行执行按钮操作，失败保留已成功登记部分并明确报告，供后续检查和清理。
  Future<void> _run(String action, Future<void> Function() work) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = '$action…';
    });
    try {
      await work();
      if (mounted) setState(() => _status = '$action完成');
      _emit('completed', {'action': action, 'jobs': _jobs});
    } catch (error, stack) {
      _reportError(action, error, stack);
      if (mounted) {
        setState(() {
          _status = '$action失败。请检查通知和精确闹钟权限；已登记部分可查看日志后清理。';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 用户点击调度后申请所需权限，权限页返回后才确定统一的六十秒到期时刻。
  Future<void> _prepare(List<NotificationUtil> services) async {
    await NotificationFactory.initializeTimeZone();
    for (final service in services) {
      if (!await service.requestPermissions()) {
        throw StateError('请允许通知，并开启对应通知渠道');
      }
    }
  }

  /// 持久化本探针任务记录，重启后仍能查看原始登记时刻和清理原标识。
  Future<void> _record(int id, String label, DateTime due, String mode) async {
    final job = <String, Object?>{
      'id': id,
      'label': label,
      'mode': mode,
      'registered_at': DateTime.now().toIso8601String(),
      'due_at': due.toIso8601String(),
      'due_epoch_ms': due.millisecondsSinceEpoch,
    };
    _jobs.removeWhere((existing) => existing['id'] == id);
    _jobs.add(job);
    _emit('registered', job);
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(_storageKey, jsonEncode(_jobs))) {
      throw StateError('系统已登记提醒，但探针任务记录保存失败');
    }
  }

  /// 使用产品通知服务在同一时刻登记四条通知，验证跨业务及两条纪念日不覆盖。
  ///
  /// 记账沿用产品渠道和单次调度入口以支持秒级验收；本步骤不验证每日重复。
  /// 两条纪念日分别采用今天、明天的真实日期标识，但统一压缩为六十秒后投递。
  Future<void> _scheduleBusiness() async {
    await _prepare([_accounting, _days, _fitness]);
    final due = DateTime.now().add(const Duration(seconds: 60));
    final today = DateTime(due.year, due.month, due.day);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final dayIds = [
      for (final day in [today, tomorrow])
        dayReminderIdStart + DateOnly.fromDateTime(day).dayNumber % 400,
    ];
    final requests = [
      (service: _accounting, id: ReminderPrefs.mainNotificationId, label: '记账'),
      (service: _days, id: dayIds[0], label: '纪念日 A（当日 ID）'),
      (service: _days, id: dayIds[1], label: '纪念日 B（次日 ID）'),
      (service: _fitness, id: fitnessRestNotificationId, label: '健身休息'),
    ];
    for (final request in requests) {
      await request.service.scheduleOnceReminder(
        id: request.id,
        title: 'QA/${request.label}',
        body: 'QA id=${request.id} 到期=${due.toIso8601String()}',
        scheduledDate: due,
      );
      await _record(request.id, request.label, due, 'product');
    }
    await _refreshSnapshot();
  }

  /// 独立验证每日重复入口，首次目标为下一个整分钟，后续每天在相同当地时间执行。
  Future<void> _scheduleDaily() async {
    await _prepare([_accounting]);
    final now = DateTime.now();
    final due = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );
    await _accounting.scheduleDailyReminder(
      id: ReminderPrefs.mainNotificationId,
      title: 'QA/每日记账重复',
      body:
          'QA id=${ReminderPrefs.mainNotificationId} 首次=${due.toIso8601String()}',
      hour: due.hour,
      minute: due.minute,
    );
    await _record(ReminderPrefs.mainNotificationId, '每日记账重复', due, 'daily');
    await _refreshSnapshot();
  }

  /// 精确待机与闹钟模式分别使用独立标识和同一渠道，保持对照时的展示条件一致。
  Future<void> _scheduleComparison(AndroidScheduleMode mode) async {
    await _prepare([_days]);
    final android = _days as AndroidNotificationUtil;
    if (!await android.canScheduleExactReminders()) {
      throw StateError('对照实验需要精确闹钟权限，请在系统设置中允许后重试');
    }
    final due = DateTime.now().add(const Duration(seconds: 60));
    final id = mode == AndroidScheduleMode.alarmClock
        ? _alarmClockId
        : _exactId;
    await _plugin.zonedSchedule(
      id: id,
      title: 'QA/${mode.name}',
      body: 'QA id=$id 到期=${due.toIso8601String()}',
      scheduledDate: convertToTZDateTime(due),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'days_reminder',
          '纪念日提醒',
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.max,
          visibility: NotificationVisibility.private,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
      androidScheduleMode: mode,
      payload: NotificationDestination.settings.path,
    );
    await _record(id, mode.name, due, mode.name);
    await _refreshSnapshot();
  }

  /// 只清理固定测试标识及本探针记录的纪念日标识，同时停止原生健身声振。
  Future<void> _clear() async {
    final ids = <int>{
      ReminderPrefs.mainNotificationId,
      fitnessRestNotificationId,
      _exactId,
      _alarmClockId,
      for (final job in _jobs) job['id'] as int,
    };
    for (final id in ids) {
      if (id == fitnessRestNotificationId) {
        await _fitness.cancelNotification(id);
      } else {
        await _accounting.cancelNotification(id);
      }
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(_storageKey)) throw StateError('清理探针任务记录失败');
    _jobs.clear();
    _emit('cleared', {'ids': ids.toList()});
    await _refreshSnapshot();
  }

  /// 分开读取插件排队缓存与已显示通知，排队缓存不能作为系统闹钟仍存在的证明。
  Future<void> _refreshSnapshot() async {
    await _accounting.initialize();
    final pending = await _fitness.getPendingNotifications();
    final active = await _plugin.getActiveNotifications();
    final pendingIds = pending.map((item) => item.id).toList()..sort();
    final activeIds = active.map((item) => item.id).whereType<int>().toList()
      ..sort();
    _snapshot = '登记缓存：$pendingIds\n通知中心当前 ID：$activeIds';
    _emit('snapshot', {
      'pending_cache_ids': pendingIds,
      'active_notifications': [
        for (final item in active)
          {'id': item.id, 'channel': item.channelId, 'title': item.title},
      ],
      'jobs': _jobs,
    });
  }

  /// 所有状态均为可访问文本，adb uiautomator 可读取登记时刻和倒计时。
  @override
  Widget build(BuildContext context) {
    final remaining = _remainingSeconds;
    return Scaffold(
      appBar: AppBar(title: const Text('通知送达探针')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.p16),
          children: [
            Text(_packageName, style: AppTextTokens.label(context)),
            const SizedBox(height: AppDimens.p12),
            Text(_status, style: AppTextTokens.strongTitle(context)),
            const SizedBox(height: AppDimens.p12),
            Text(
              remaining > 0 ? '距离下一条计划时间：$remaining 秒' : '当前无未来倒计时；送达状态请读取通知中心',
              style: AppTextTokens.title(context),
            ),
            const SizedBox(height: AppDimens.p12),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () => _run('登记四条业务通知', _scheduleBusiness),
              child: const Text('四条业务通知 · 60 秒后'),
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _run('登记每日重复记账', _scheduleDaily),
              child: const Text('每日记账重复 · 下一分钟'),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(
                      '登记精确待机对照',
                      () => _scheduleComparison(
                        AndroidScheduleMode.exactAllowWhileIdle,
                      ),
                    ),
              child: const Text('exactAllowWhileIdle · 60 秒后'),
            ),
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(
                      '登记闹钟模式对照',
                      () => _scheduleComparison(AndroidScheduleMode.alarmClock),
                    ),
              child: const Text('alarmClock · 60 秒后'),
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _run('读取系统快照', _refreshSnapshot),
              child: const Text('读取通知中心和缓存'),
            ),
            TextButton(
              onPressed: _busy ? null : () => _run('清理探针通知', _clear),
              child: const Text('清理本探针 ID'),
            ),
            const SizedBox(height: AppDimens.p12),
            Text(_snapshot, style: AppTextTokens.body(context)),
            const SizedBox(height: AppDimens.p8),
            Text(
              '插件缓存不代表 AlarmManager 闹钟仍存在。启动和恢复不自动重排。'
              '四条业务按钮的记账采用单次入口；两条纪念日压缩到同秒以检查内容互不覆盖。'
              '每日重复按钮复用 ID 1001，会替换单次记账计划，验收后请清理。',
              style: AppTextTokens.label(context),
            ),
            for (final job in _jobs)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.p12),
                child: Text(
                  '${job['label']} · ID ${job['id']}\n'
                  '登记：${job['registered_at']}\n到期：${job['due_at']}\n'
                  'epoch_ms：${job['due_epoch_ms']}',
                  style: AppTextTokens.body(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
