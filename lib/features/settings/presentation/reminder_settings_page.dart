import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/settings/presentation/day_reminder_selection_dialog.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'package:sesame_notes/shared/providers/reminder_system_status_provider.dart';
import 'package:sesame_notes/shared/services/notification/notification_android.dart';
import 'package:sesame_notes/shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 本机提醒配置、系统授权状态和设置入口。
class ReminderSettingsPage extends ConsumerStatefulWidget {
  /// 创建通知设置页。
  const ReminderSettingsPage({super.key});

  /// 创建保存配置和观察系统授权的页面状态。
  @override
  ConsumerState<ReminderSettingsPage> createState() =>
      _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends ConsumerState<ReminderSettingsPage>
    with WidgetsBindingObserver {
  bool _actionRunning = false;
  ReminderSettings? _pendingSettings;

  /// 监听系统设置页返回，以便重新读取真实授权。
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// 释放生命周期监听。
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 普通配置保存复用检测结果，回到前台时才刷新系统状态。
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshSystemStatus();
  }

  /// 更新权限、电池和全部提醒渠道的状态。
  void _refreshSystemStatus() {
    if (!mounted) return;
    ref.invalidate(exactReminderPermissionProvider);
    ref.invalidate(reminderBatteryInfoProvider);
    ref.invalidate(reminderChannelInfoProvider);
  }

  /// 阻止操作重入，保持控件样式稳定并统一报告异常。
  Future<void> _runReminderAction(Future<void> Function() action) async {
    if (_actionRunning) return;
    _actionRunning = true;
    try {
      await action();
    } catch (error, stackTrace) {
      logger.error('ReminderSettings', '执行提醒操作失败', error, stackTrace);
      if (mounted) {
        final l = AppLocalizations.of(context);
        showToast(context, switch (error) {
          PlatformException(code: 'notification_permission_denied') =>
            l.reminderPermissionRequired,
          PlatformException(code: 'notification_unsupported') =>
            l.reminderPlatformUnsupported,
          _ => l.commonOperationFailed,
        });
      }
    } finally {
      _actionRunning = false;
    }
  }

  /// 立即显示选择结果，保存失败时恢复已确认配置。
  Future<void> _saveSettings(ReminderSettings settings) async {
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext();
    final previous = ref.read(reminderSettingsProvider);
    setState(() => _pendingSettings = settings);
    try {
      await ref
          .read(reminderSettingsProvider.notifier)
          .updateSettings(settings);
      if (mounted) {
        ref
            .read(productAnalyticsControllerProvider)
            .trackAction(
              pageId: 'settings.reminder',
              action: ProductAction.settingsReminderChanged,
              context: analyticsContext,
            );
      }
      // 开启分类可能创建渠道或申请权限，刷新时沿用旧结果，避免进入加载占位。
      if (mounted &&
          (settings.notificationsEnabled != previous.notificationsEnabled ||
              settings.dailyActive && !previous.dailyActive ||
              settings.daysActive && !previous.daysActive ||
              settings.restActive && !previous.restActive)) {
        _refreshSystemStatus();
      }
    } finally {
      // Provider 仅在保存成功后提交新值，清除预览即可恢复真实状态。
      if (mounted) setState(() => _pendingSettings = null);
    }
  }

  /// 在操作锁内保存，避免连续点击使用旧配置覆盖新值。
  Future<void> _save(ReminderSettings settings) =>
      _runReminderAction(() => _saveSettings(settings));

  /// 开启每日提醒前必须确认至少一条事项；取消弹窗时保持原开关和选择。
  Future<void> _pickDailyDays() => _runReminderAction(() async {
    final accountId = ref.read(currentAccountIdProvider);
    final settings = ref.read(reminderSettingsProvider);
    final selected = await showDialog<Set<String>>(
      context: context,
      builder: (context) => DayReminderSelectionDialog(
        selectedIds: settings.daysDailyEventIds,
        accountId: accountId,
      ),
    );
    if (selected == null || selected.isEmpty || !mounted) return;
    if (ref.read(currentAccountIdProvider) != accountId) {
      showToast(
        context,
        AppLocalizations.of(context).reminderDaysDailyAccountChanged,
      );
      return;
    }
    // 读取当前配置再提交选择，弹窗等待期间其它设置的更新不会被旧快照覆盖。
    await _saveSettings(
      ref
          .read(reminderSettingsProvider)
          .copyWith(daysDailyEnabled: true, daysDailyEventIds: selected),
    );
  });

  /// 选择分类提醒时间，取消选择时保持原配置。
  Future<void> _pickTime({bool days = false}) => _runReminderAction(() async {
    final settings = ref.read(reminderSettingsProvider);
    final selected = await showWheelTimePicker(
      context,
      initial: TimeOfDay(
        hour: days ? settings.daysHour : settings.hour,
        minute: days ? settings.daysMinute : settings.minute,
      ),
    );
    if (selected == null || !mounted) return;
    final current = ref.read(reminderSettingsProvider);
    await _saveSettings(
      days
          ? current.copyWith(
              daysHour: selected.hour,
              daysMinute: selected.minute,
            )
          : current.copyWith(hour: selected.hour, minute: selected.minute),
    );
  });

  /// 优先进入可访问的自启动页，受厂商限制时给出手动路径。
  Future<void> _openAutoStartSettings() => _runReminderAction(() async {
    final util = NotificationFactory.getInstance();
    if (util is! AndroidNotificationUtil) return;
    if (await util.openAutoStartSettings() || !mounted) return;
    final l = AppLocalizations.of(context);
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AppContentDialog(
        title: l.reminderAutoStartSettings,
        content: Text(l.reminderAutoStartAdvice),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.commonSettings),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.commonConfirm),
          ),
        ],
      ),
    );
    if (openSettings == true && mounted) await util.openAppSettings();
  });

  /// 设置分组复用全局卡片皮肤，内容行自行提供内部留白。
  Widget _card(List<Widget> children, {Key? key}) => SectionCard(
    key: key,
    margin: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
    padding: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  /// 四个入口均分一行，窄屏缩放文字并保留完整辅助功能语义。
  Widget _settingsButton(String label, VoidCallback onPressed) => Expanded(
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
        minimumSize: const Size(0, AppDimens.p36),
        textStyle: AppTextTokens.label(context),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
    ),
  );

  /// 通知总开关关闭时仍可直接进入系统设置。
  Widget _systemButtons(AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.p12),
    child: Row(
      key: const ValueKey('notification-system-actions'),
      children: [
        _settingsButton(
          l.reminderOpenAppSettings,
          () => _runReminderAction(() async {
            final util = NotificationFactory.getInstance();
            if (util is AndroidNotificationUtil) await util.openAppSettings();
          }),
        ),
        const SizedBox(width: AppDimens.p4),
        _settingsButton(l.reminderAutoStartSettings, _openAutoStartSettings),
        const SizedBox(width: AppDimens.p4),
        _settingsButton(
          l.reminderCheckChannel,
          () => _runReminderAction(() async {
            final util = NotificationFactory.getInstance();
            if (util is AndroidNotificationUtil) {
              await util.openAppNotificationSettings();
            }
          }),
        ),
        const SizedBox(width: AppDimens.p4),
        _settingsButton(
          l.reminderCheckBattery,
          () => _runReminderAction(() async {
            final util = NotificationFactory.getInstance();
            if (util is AndroidNotificationUtil) await util.openAppSettings();
          }),
        ),
      ],
    ),
  );

  /// 检测失败在原位置显示，用户可重试而无需关闭弹窗。
  Widget _statusError(AppLocalizations l) => Row(
    children: [
      Expanded(child: _statusLine(l.reminderStatusUnavailable, enabled: false)),
      TextButton(onPressed: _refreshSystemStatus, child: Text(l.commonRetry)),
    ],
  );

  /// 以项目语义颜色区分开启、关闭和中性信息，状态含义同时保留在文字中。
  Widget _statusLine(String text, {bool? enabled, Key? key}) => Text(
    text,
    key: key,
    style: AppTextTokens.label(context).copyWith(
      color: enabled == null
          ? AppTokens.textSecondary(context)
          : enabled
          ? AppTokens.success(context)
          : AppTokens.warning(context),
    ),
  );

  /// 状态区与卡片操作共用左右留白，并与相邻设置行保持间隔。
  Widget _statusSection({required Widget child, Key? key}) => Padding(
    key: key,
    padding:
        (ListTileTheme.of(context).contentPadding ??
                const EdgeInsets.symmetric(horizontal: AppDimens.p12))
            .add(
              const EdgeInsets.only(top: AppDimens.p8, bottom: AppDimens.p16),
            ),
    child: child,
  );

  /// 耗电管理的标签和豁免状态合并为一条状态文字。
  Widget _batteryStatus(AppLocalizations l) => _statusSection(
    child: ref
        .watch(reminderBatteryInfoProvider)
        .when(
          data: (info) => info == null
              ? _statusLine(l.reminderStatusUnavailable, enabled: false)
              : _statusLine(
                  info['isIgnoring'] == true
                      ? l.reminderBatteryIgnored
                      : l.reminderBatteryNotIgnored,
                  enabled: info['isIgnoring'] == true,
                ),
          loading: () => _statusLine(l.reminderStatusLoading),
          error: (error, stack) => _statusError(l),
        ),
  );

  /// 时间值使用明确的选择按钮，数字右边缘与开关保持对齐。
  Widget _timeSetting({
    required String id,
    required String title,
    required String value,
    required EdgeInsetsGeometry padding,
    required VoidCallback? onTap,
  }) => Padding(
    padding: padding,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppDimens.actionButtonMinHeight,
      ),
      child: AppListTile(
        key: ValueKey(id),
        title: title,
        enabled: onTap != null,
        onTap: onTap,
        trailing: Tooltip(
          message: AppLocalizations.of(context).commonSelectTime,
          child: TextButton(
            key: ValueKey('$id-button'),
            onPressed: onTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, AppDimens.p40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppTokens.primary(context),
              textStyle: AppTextTokens.body(context).copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppTokens.primary(context),
              ),
            ),
            child: Text(
              value,
              key: ValueKey('$id-value'),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ),
    ),
  );

  /// 每类通知在自身卡片中展示系统渠道状态，所有卡片复用同一份检测结果。
  Widget _channelStatus(String channelId, AppLocalizations l) => _statusSection(
    key: ValueKey('notification-status-$channelId'),
    child: ref
        .watch(reminderChannelInfoProvider)
        .when(
          data: (channels) {
            final info = channels[channelId];
            return info == null
                ? _statusLine(l.reminderChannelNotCreated, enabled: false)
                : _channelTable(channelId, info, l);
          },
          loading: () => _statusLine(l.reminderStatusLoading),
          error: (error, stack) => _statusError(l),
        ),
  );

  /// 三态开关保留未知值，系统未返回的字段不显示为关闭。
  String _booleanStatus(Object? value, AppLocalizations l) => switch (value) {
    true => l.reminderStatusOn,
    false => l.reminderStatusOff,
    _ => l.reminderImportanceUnknown,
  };

  /// 五列状态共用紧凑表格，字段和值上下对齐并用细竖线分隔。
  Widget _channelTable(
    String channelId,
    Map<String, dynamic> info,
    AppLocalizations l,
  ) {
    final fields =
        <({String field, String label, String value, bool? enabled})>[
          (
            field: 'notification',
            label: l.reminderStatusNotificationLabel,
            value: _booleanStatus(info['isEnabled'], l),
            enabled: info['isEnabled'] is bool
                ? info['isEnabled'] as bool
                : null,
          ),
          (
            field: 'importance',
            label: l.reminderStatusImportanceLabel,
            value: switch (info['importance']) {
              'high' || 'max' => l.reminderImportanceHigh,
              'default' => l.reminderImportanceDefault,
              'low' => l.reminderImportanceLow,
              'min' => l.reminderImportanceMin,
              'none' => l.reminderImportanceNone,
              _ => l.reminderImportanceUnknown,
            },
            enabled: switch (info['importance']) {
              'high' || 'max' => true,
              'none' || 'min' || 'low' => false,
              _ => null,
            },
          ),
          (
            field: 'sound',
            label: l.reminderStatusSoundLabel,
            value: _booleanStatus(info['sound'], l),
            enabled: info['sound'] is bool ? info['sound'] as bool : null,
          ),
          (
            field: 'vibration',
            label: l.reminderStatusVibrationLabel,
            value: _booleanStatus(info['vibration'], l),
            enabled: info['vibration'] is bool
                ? info['vibration'] as bool
                : null,
          ),
          (
            field: 'dnd', label: l.reminderStatusDndLabel,
            value: switch (info['bypassDnd']) {
              true => l.reminderStatusDndBypass,
              false => l.reminderStatusDndFollow,
              _ => l.reminderImportanceUnknown,
            },
            // 遵循勿扰是系统提示偏好，不等同于通知被禁止。
            enabled: info['bypassDnd'] == true ? true : null,
          ),
        ];
    return IntrinsicHeight(
      child: Row(
        key: ValueKey('notification-status-table-$channelId'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            if (index > 0)
              VerticalDivider(
                width: AppDimens.p8,
                indent: AppDimens.p4,
                endIndent: AppDimens.p4,
                color: AppTokens.divider(context),
              ),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  key: ValueKey(
                    'notification-status-$channelId-${fields[index].field}',
                  ),
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        fields[index].label,
                        style: AppTextTokens.label(context),
                      ),
                    ),
                    const SizedBox(height: AppDimens.p8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _statusLine(
                        fields[index].value,
                        key: ValueKey(
                          'notification-status-$channelId-${fields[index].field}-value',
                        ),
                        enabled: fields[index].enabled,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 四个提前提醒选项保持同行，选中状态不改变选项宽度。
  Widget _offsets(
    ReminderSettings settings,
    AppLocalizations l, {
    required bool editable,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppDimens.p12),
    child: Row(
      key: const ValueKey('notification-day-offsets'),
      children: [
        for (final day in ReminderSettings.allowedDayOffsets) ...[
          if (day != 0) const SizedBox(width: AppDimens.p4),
          Expanded(
            child: FilterChip(
              key: ValueKey('notification-offset-$day'),
              side: BorderSide.none,
              showCheckmark: false,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p4,
              ),
              label: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(switch (day) {
                    0 => l.reminderDaySame,
                    1 => l.reminderDayBefore,
                    3 => l.reminderThreeDaysBefore,
                    _ => l.reminderWeekBefore,
                  }),
                ),
              ),
              selected: settings.selectedDayOffsets.contains(day),
              onSelected: !editable
                  ? null
                  : (selected) {
                      final offsets = settings.daysOffsets ^ (1 << day);
                      if (offsets == 0) {
                        showToast(context, l.reminderChooseOneDay);
                        return;
                      }
                      _save(settings.copyWith(daysOffsets: offsets));
                    },
            ),
          ),
        ],
      ],
    ),
  );

  /// 按开启通知、分类提醒、常驻说明的顺序展示页面。
  @override
  Widget build(BuildContext context) {
    final confirmed = ref.watch(reminderSettingsProvider);
    final settings = _pendingSettings ?? confirmed;
    final l = AppLocalizations.of(context);
    final supported = ref.watch(reminderSupportedProvider);
    final editable = supported && settings.isLoaded;
    final android =
        supported && defaultTargetPlatform == TargetPlatform.android;
    final exact = android ? ref.watch(exactReminderPermissionProvider) : null;
    final switchPadding =
        ListTileTheme.of(context).contentPadding ??
        const EdgeInsets.symmetric(horizontal: AppDimens.p12);

    /// 开关与时间行共用主题留白，仅业务不可用时禁用。
    Widget toggle(
      String key,
      String title,
      bool value,
      ValueChanged<bool>? onChanged,
    ) => Padding(
      padding: switchPadding,
      child: AppSwitchTile(
        key: ValueKey(key),
        compact: true,
        title: title,
        value: value,
        onChanged: onChanged,
      ),
    );

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l.mineReminderSettings, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.p16),
              children: [
                if (!supported)
                  Padding(
                    padding: switchPadding.add(
                      const EdgeInsets.only(bottom: AppDimens.p16),
                    ),
                    child: Text(
                      l.reminderPlatformUnsupported,
                      key: const ValueKey('notification-platform-unsupported'),
                      style: AppTextTokens.body(context),
                    ),
                  ),
                _card([
                  toggle(
                    'notifications-master',
                    l.reminderGlobalTitle,
                    settings.notificationsEnabled,
                    editable
                        ? (value) => _save(
                            settings.copyWith(notificationsEnabled: value),
                          )
                        : null,
                  ),
                  if (android) ...[
                    if (exact?.value == false)
                      Padding(
                        padding: switchPadding,
                        child: AppListTile(
                          title: l.reminderExactPermissionTitle,
                          titleMaxLines: null,
                          subtitleMaxLines: null,
                          trailing: TextButton(
                            onPressed: () => _runReminderAction(() async {
                              final util = NotificationFactory.getInstance();
                              if (util is AndroidNotificationUtil) {
                                await util.requestExactReminderPermission();
                                _refreshSystemStatus();
                              }
                            }),
                            child: Text(l.commonSettings),
                          ),
                        ),
                      ),
                    if (exact?.hasError == true)
                      Padding(padding: switchPadding, child: _statusError(l)),
                    _systemButtons(l),
                    _batteryStatus(l),
                  ],
                ], key: const ValueKey('notification-master-card')),
                const SizedBox(height: AppDimens.p16),
                _card([
                  toggle(
                    'notifications-daily',
                    l.reminderDailyTitle,
                    settings.isEnabled,
                    editable && settings.notificationsEnabled
                        ? (value) => _save(settings.copyWith(isEnabled: value))
                        : null,
                  ),
                  _timeSetting(
                    id: 'notification-daily-time',
                    padding: switchPadding,
                    title: l.reminderTimeTitle,
                    value: settings.timeString,
                    onTap: editable ? () => _pickTime() : null,
                  ),
                  if (android) _channelStatus('accounting_reminder', l),
                ], key: const ValueKey('notification-daily-card')),
                const SizedBox(height: AppDimens.p16),
                _card([
                  toggle(
                    'notifications-days',
                    l.reminderDaysTitle,
                    settings.daysEnabled,
                    editable && settings.notificationsEnabled
                        ? (value) =>
                              _save(settings.copyWith(daysEnabled: value))
                        : null,
                  ),
                  _offsets(settings, l, editable: editable),
                  CheckboxListTile(
                    key: const ValueKey('notifications-days-daily'),
                    contentPadding: switchPadding,
                    title: Text(l.reminderDaysDailyTitle),
                    subtitle: Text(l.reminderDaysDailyHint),
                    value: settings.daysDailyEnabled,
                    onChanged: !editable
                        ? null
                        : (value) => value == true
                              ? _pickDailyDays()
                              : _save(
                                  settings.copyWith(daysDailyEnabled: false),
                                ),
                  ),
                  if (settings.daysDailyEnabled)
                    Padding(
                      padding: switchPadding,
                      child: AppListTile(
                        key: const ValueKey(
                          'notification-days-daily-selection',
                        ),
                        title: l.reminderDaysDailySelect,
                        titleMaxLines: null,
                        onTap: editable ? _pickDailyDays : null,
                      ),
                    ),
                  _timeSetting(
                    id: 'notification-days-time',
                    padding: switchPadding,
                    title: l.reminderDaysTimeTitle,
                    value:
                        '${settings.daysHour.toString().padLeft(2, '0')}:${settings.daysMinute.toString().padLeft(2, '0')}',
                    onTap: editable ? () => _pickTime(days: true) : null,
                  ),
                  if (android) _channelStatus('days_reminder', l),
                ], key: const ValueKey('notification-days-card')),
                const SizedBox(height: AppDimens.p16),
                _card([
                  toggle(
                    'notifications-rest',
                    l.reminderRestTitle,
                    settings.restEnabled,
                    editable && settings.notificationsEnabled
                        ? (value) =>
                              _save(settings.copyWith(restEnabled: value))
                        : null,
                  ),
                  if (android) _channelStatus('fitness_rest_alarm_v2', l),
                ], key: const ValueKey('notification-rest-card')),
                const SizedBox(height: AppDimens.p20),
                _card([
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.reminderSystemSettings,
                          style: AppTextTokens.body(context),
                        ),
                        const SizedBox(height: AppDimens.p12),
                        Text(
                          l.reminderDescription,
                          style: AppTextTokens.label(context),
                        ),
                        if (android) ...[
                          const SizedBox(height: AppDimens.p12),
                          Text(
                            l.reminderAndroidInstructions,
                            style: AppTextTokens.label(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: AppDimens.p16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
