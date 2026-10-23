import 'package:sesame_notes/shared/widgets/pin_input_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  const AppLockScreen({super.key});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final _pinInput = PinInputController();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  /// 启动时检查生物识别可用性与开关；可用且开启时自动发起认证。
  Future<void> _checkBiometric() async {
    try {
      final service = ref.read(appLockServiceProvider);
      final canUse = await service.canUseBiometrics();
      final enabled = await service.isBiometricEnabled();
      if (!mounted) return;
      setState(() {
        _biometricAvailable = canUse;
        _biometricEnabled = enabled;
      });
      if (canUse && enabled) {
        _authenticateWithBiometrics();
      }
    } catch (e, st) {
      logger.error('AppLock', '读取生物识别配置失败', e, st);
    }
  }

  /// 发起生物识别认证；成功则解锁。
  Future<void> _authenticateWithBiometrics() async {
    final l10n = AppLocalizations.of(context);
    try {
      final service = ref.read(appLockServiceProvider);
      final success = await service.authenticateWithBiometrics(
        reason: l10n.appLockBiometricReason,
      );
      if (success && mounted) {
        _unlock();
      }
    } catch (e, st) {
      logger.error('AppLock', '生物识别认证失败', e, st);
    }
  }

  /// 输入控制器只返回完整 PIN 快照，页面继续执行各自的认证流程。
  void _onNumberTap(String number) {
    final pin = _pinInput.addDigit(number);
    if (pin != null) _verifyPin(pin);
  }

  /// 页面销毁时清空 PIN 草稿并终止视觉状态通知。
  @override
  void dispose() {
    _pinInput.dispose();
    super.dispose();
  }

  /// 验证 PIN：成功解锁；失败展示错误态并延迟复位。
  ///
  /// 服务调用统一 try-catch：异常时提示友好错误，避免未处理异常冒泡。
  Future<void> _verifyPin(String pin) async {
    final l10n = AppLocalizations.of(context);
    try {
      final service = ref.read(appLockServiceProvider);
      final success = await service.verifyPin(pin);
      if (!mounted) return;
      if (success) {
        _unlock();
      } else {
        await _pinInput.showError();
      }
    } catch (e, st) {
      logger.error('AppLock', 'PIN 验证失败', e, st);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
      }
    } finally {
      _pinInput.finishSubmission();
    }
  }

  /// 解锁：记录解锁时间并清除锁定状态。
  void _unlock() {
    ref.read(appLockServiceProvider).recordUnlock();
    ref.read(isAppLockedProvider.notifier).set(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showBiometric = _biometricAvailable && _biometricEnabled;

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // 品牌图标
            AppLogo(size: AppDimens.authLogoSize),
            SizedBox(height: AppDimens.p20),
            // 标题
            Text(
              l10n.appLockEnterPin,
              style: AppTextTokens.boldTitle(
                context,
              ).copyWith(color: AppTokens.textPrimary(context)),
            ),
            SizedBox(height: AppDimens.p32),
            // PIN 圆点
            ListenableBuilder(
              listenable: _pinInput,
              builder: (context, _) => PinDotIndicator(
                filledCount: _pinInput.length,
                isError: _pinInput.hasError,
              ),
            ),
            const Spacer(flex: 1),
            // 数字键盘
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.p40),
              child: NumberPad(
                onNumberTap: _onNumberTap,
                onDelete: _pinInput.deleteDigit,
                showBiometric: showBiometric,
                onBiometric: showBiometric ? _authenticateWithBiometrics : null,
              ),
            ),
            SizedBox(height: AppDimens.p32),
          ],
        ),
      ),
    );
  }
}
