import 'package:sesame_notes/shared/widgets/pin_input_controller.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/features/auth/domain/pin_setup_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class AppLockSettingsPage extends ConsumerStatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  ConsumerState<AppLockSettingsPage> createState() =>
      _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends ConsumerState<AppLockSettingsPage> {
  bool _canUseBiometrics = false;
  bool _changing = false;

  /// 系统认证或设置页返回前保持互斥，取消和失败都恢复设置入口。
  Future<void> _changeSetting(Future<void> Function() action) async {
    if (_changing) return;
    setState(() => _changing = true);
    try {
      await action();
    } catch (error, stackTrace) {
      logger.error('AppLock', '更新应用锁设置失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      final canUse = await ref.read(appLockServiceProvider).canUseBiometrics();
      if (mounted) {
        setState(() => _canUseBiometrics = canUse);
      }
    } catch (e, st) {
      logger.warning('AppLock', '检测生物识别支持失败,按不支持处理', '$e\n$st');
    }
  }

  Future<void> _toggleAppLock(bool enable) async {
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext();
    final l10n = AppLocalizations.of(context);

    if (enable) {
      // 开启：跳转设置 PIN（创建模式经 extra 传枚举）
      final result = await context.pushNamed<bool>(
        Routes.pinSetup,
        extra: PinSetupMode.create,
      );
      // 如果用户取消设置，开关回弹
      if (result != true) return;
    } else {
      // 关闭：需要验证当前 PIN
      final verified = await _verifyCurrentPin();
      if (!verified || !mounted) return;

      // 先持久化成功再更新内存状态:失败时保持现状并提示,避免状态与磁盘不一致。
      try {
        await ref.read(appLockEnabledProvider.notifier).clearPin();
      } catch (e, st) {
        logger.error('AppLock', '关闭应用锁失败(清除 PIN)', e, st);
        if (mounted) {
          showToast(context, l10n.commonOperationFailed);
        }
        return;
      }
      if (mounted) {
        showToast(context, l10n.appLockDisabled);
      }
    }
    if (mounted) {
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: 'settings.app_lock',
            action: ProductAction.settingsAppLockChanged,
            context: analyticsContext,
          );
    }
  }

  Future<bool> _verifyCurrentPin() async {
    final result = await Navigator.push<bool>(
      context,
      appPageRoute(builder: (_) => const _PinVerifyPage()),
    );
    return result == true;
  }

  Future<void> _changePin() async {
    // 修改模式经 extra 传枚举。
    await context.pushNamed(Routes.pinSetup, extra: PinSetupMode.change);
  }

  Future<void> _toggleBiometric(bool enable) async {
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext();
    final l10n = AppLocalizations.of(context);
    if (enable) {
      // 先验证生物识别可用
      final success = await ref
          .read(appLockServiceProvider)
          .authenticateWithBiometrics(reason: l10n.appLockBiometricReason);
      if (!success || !mounted) return;
    }
    await ref.read(appLockBiometricEnabledProvider.notifier).set(enable);
    if (mounted) {
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: 'settings.app_lock',
            action: ProductAction.settingsAppLockChanged,
            context: analyticsContext,
          );
    }
  }

  void _showTimeoutPicker() {
    final l10n = AppLocalizations.of(context);
    final currentTimeout = ref.read(appLockTimeoutProvider);

    final options = [
      (0, l10n.appLockTimeoutImmediate),
      (60, l10n.appLockTimeout1Min),
      (300, l10n.appLockTimeout5Min),
      (900, l10n.appLockTimeout15Min),
    ];

    showAppSheet<void>(
      context: context,
      child: StatefulBuilder(
        builder: (sheetContext, update) => AppSheet(
          title: l10n.appLockTimeout,
          contentPadding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...options.map((opt) {
                final isSelected = opt.$1 == currentTimeout;
                return AppRadioTile(
                  title: opt.$2,
                  selected: isSelected,
                  onTap: _changing
                      ? null
                      : () =>
                            _changeSetting(() async {
                              update(() {});
                              // 持久化完成后发布状态，失败由公共设置边界提示并保留弹层。
                              final analyticsContext = ref
                                  .read(productAnalyticsControllerProvider)
                                  .captureContext();
                              await ref
                                  .read(appLockTimeoutProvider.notifier)
                                  .set(opt.$1);
                              if (mounted) {
                                ref
                                    .read(productAnalyticsControllerProvider)
                                    .trackAction(
                                      pageId: 'settings.app_lock',
                                      action:
                                          ProductAction.settingsAppLockChanged,
                                      context: analyticsContext,
                                    );
                              }
                              if (sheetContext.mounted &&
                                  ModalRoute.of(sheetContext)?.isCurrent ==
                                      true) {
                                Navigator.pop(sheetContext);
                              }
                            }).whenComplete(() {
                              if (sheetContext.mounted) update(() {});
                            }),
                );
              }),
              const SizedBox(height: AppDimens.p8),
            ],
          ),
        ),
      ),
    );
  }

  String _timeoutLabel(int seconds) {
    final l10n = AppLocalizations.of(context);
    switch (seconds) {
      case 0:
        return l10n.appLockTimeoutImmediate;
      case 60:
        return l10n.appLockTimeout1Min;
      case 300:
        return l10n.appLockTimeout5Min;
      case 900:
        return l10n.appLockTimeout15Min;
      default:
        return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(appLockEnabledProvider);
    final biometricEnabled = ref.watch(appLockBiometricEnabledProvider);
    final timeout = ref.watch(appLockTimeoutProvider);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.appLockTitle, showBack: true),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                top: AppDimens.p8,
                bottom: AppDimens.p16,
              ),
              children: [
                // 应用锁开关
                SectionCard(
                  child: Column(
                    children: [
                      AppSwitchTile(
                        leading: AppIcons.lock,
                        title: l10n.appLockEnable,
                        subtitle: l10n.appLockEnableDesc,
                        value: enabled,
                        onChanged: _changing
                            ? null
                            : (value) =>
                                  _changeSetting(() => _toggleAppLock(value)),
                      ),
                    ],
                  ),
                ),
                if (enabled) ...[
                  SizedBox(height: AppDimens.p8),
                  // PIN 管理
                  SectionCard(
                    child: Column(
                      children: [
                        AppListTile(
                          leading: AppIcons.dialpad,
                          title: l10n.appLockChangePin,
                          trailing: Icon(
                            AppIcons.chevronRight,
                            color: AppTokens.iconTertiary(context),
                            size: AppDimens.icon20,
                          ),
                          onTap: _changing
                              ? null
                              : () => _changeSetting(_changePin),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimens.p8),
                  // 生物识别 + 超时
                  SectionCard(
                    child: Column(
                      children: [
                        if (_canUseBiometrics) ...[
                          AppSwitchTile(
                            leading: AppIcons.fingerprint,
                            title: l10n.appLockBiometric,
                            subtitle: l10n.appLockBiometricDesc,
                            value: biometricEnabled,
                            onChanged: _changing
                                ? null
                                : (value) => _changeSetting(
                                    () => _toggleBiometric(value),
                                  ),
                          ),
                          AppTokens.cardDivider(context),
                        ],
                        AppListTile(
                          leading: AppIcons.timer,
                          title: l10n.appLockTimeout,
                          subtitle: _timeoutLabel(timeout),
                          trailing: Icon(
                            AppIcons.chevronRight,
                            color: AppTokens.iconTertiary(context),
                            size: AppDimens.icon20,
                          ),
                          onTap: _changing ? null : _showTimeoutPicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 验证当前 PIN 页面（用于关闭应用锁时验证）
class _PinVerifyPage extends ConsumerStatefulWidget {
  const _PinVerifyPage();

  @override
  ConsumerState<_PinVerifyPage> createState() => _PinVerifyPageState();
}

class _PinVerifyPageState extends ConsumerState<_PinVerifyPage> {
  final _pinInput = PinInputController();

  /// 输入控制器只返回完整 PIN 快照，页面继续执行各自的认证流程。
  void _onNumberTap(String number) {
    final pin = _pinInput.addDigit(number);
    if (pin != null) _verify(pin);
  }

  /// 页面销毁时清空 PIN 草稿并终止视觉状态通知。
  @override
  void dispose() {
    _pinInput.dispose();
    super.dispose();
  }

  /// 服务结果仅应用于仍在显示的页面，失败复位完成后再接收新的 PIN。
  Future<void> _verify(String pin) async {
    try {
      final success = await ref.read(appLockServiceProvider).verifyPin(pin);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context, true);
      } else {
        await _pinInput.showError();
      }
    } catch (error, stackTrace) {
      logger.error('AppLock', 'PIN 验证失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
        await _pinInput.showError();
      }
    } finally {
      _pinInput.finishSubmission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.appLockVerifyPin, showBack: true),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    l10n.appLockVerifyCurrentPin,
                    style: AppTextTokens.boldTitle(
                      context,
                    ).copyWith(color: AppTokens.textPrimary(context)),
                  ),
                  SizedBox(height: AppDimens.p32),
                  ListenableBuilder(
                    listenable: _pinInput,
                    builder: (context, _) => PinDotIndicator(
                      filledCount: _pinInput.length,
                      isError: _pinInput.hasError,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppDimens.p40),
                    child: NumberPad(
                      onNumberTap: _onNumberTap,
                      onDelete: _pinInput.deleteDigit,
                    ),
                  ),
                  SizedBox(height: AppDimens.p32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
