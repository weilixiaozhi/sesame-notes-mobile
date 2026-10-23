import 'package:sesame_notes/shared/widgets/pin_input_controller.dart';
import 'package:sesame_notes/features/auth/domain/pin_setup_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  final PinSetupMode mode;

  const PinSetupPage({super.key, this.mode = PinSetupMode.create});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  // 步骤：0=验证旧PIN（仅change模式）, 1=输入新PIN, 2=确认新PIN
  int _step = 0;
  final _pinInput = PinInputController();
  String _firstPin = '';

  @override
  void initState() {
    super.initState();
    _step = widget.mode == PinSetupMode.change ? 0 : 1;
  }

  String get _title {
    final l10n = AppLocalizations.of(context);
    if (_step == 0) return l10n.appLockVerifyCurrentPin;
    if (_step == 1) return l10n.appLockSetNewPin;
    return l10n.appLockConfirmPin;
  }

  /// 输入控制器只返回完整 PIN 快照，页面继续执行各自的认证流程。
  void _onNumberTap(String number) {
    final pin = _pinInput.addDigit(number);
    if (pin != null) _handlePinComplete(pin);
  }

  /// 页面销毁时清空 PIN 草稿并终止视觉状态通知。
  @override
  void dispose() {
    _pinInput.dispose();
    super.dispose();
  }

  /// 处理一次完整的 4 位 PIN 提交：按步骤验证 / 记录 / 设置新 PIN。
  ///
  /// 服务调用统一 try-catch：失败时提示友好错误并允许重试，避免未处理异常
  /// 以框架错误形式冒泡。
  Future<void> _handlePinComplete(String pin) async {
    final l10n = AppLocalizations.of(context);
    try {
      final service = ref.read(appLockServiceProvider);
      if (_step == 0) {
        // 验证旧 PIN
        final valid = await service.verifyPin(pin);
        if (!mounted) return;
        if (valid) {
          setState(() => _step = 1);
        } else {
          await _showError();
        }
      } else if (_step == 1) {
        // 记录第一次输入，进入确认步骤
        setState(() {
          _firstPin = pin;
          _step = 2;
        });
      } else {
        // 确认 PIN
        if (pin == _firstPin) {
          await ref.read(appLockEnabledProvider.notifier).createPin(pin);
          if (mounted) {
            showToast(context, l10n.appLockPinSetSuccess);
            Navigator.pop(context, true);
          }
        } else {
          await _showError(resetNewPin: true);
        }
      }
    } catch (e, st) {
      logger.error('PinSetup', 'PIN 操作失败', e, st);
      if (mounted) {
        showToast(context, l10n.commonOperationFailed);
        await _showError();
      }
    } finally {
      _pinInput.finishSubmission();
    }
  }

  /// 错误提示期间由提交流程保持输入禁用，复位后才接收新的数字。
  Future<void> _showError({bool resetNewPin = false}) async {
    if (!mounted) return;
    await _pinInput.showError();
    if (!mounted) return;
    setState(() {
      if (resetNewPin) {
        _step = 1;
        _firstPin = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: widget.mode == PinSetupMode.create
                ? AppLocalizations.of(context).appLockSetPin
                : AppLocalizations.of(context).appLockChangePin,
            showBack: true,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // 步骤提示
                  Text(
                    _title,
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
