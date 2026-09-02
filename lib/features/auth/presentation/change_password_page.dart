import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 修改密码页：当前/新/确认新密码，保存入口位于页面头部。
///
/// 设计意图：新密码按 8-20 位且同时包含字母和数字校验；当前密码错误返回稳定文案；
/// 改密成功后当前设备保持登录，其他设备的 Refresh Token 由服务端撤销。
class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool busy = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  String? errorText;

  @override
  void dispose() {
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final current = currentCtrl.text;
    final next = newCtrl.text;
    final confirm = confirmCtrl.text;
    if (current.isEmpty) {
      setState(() => errorText = l10n.changePasswordCurrent);
      return;
    }
    if (!_isValidNewPassword(next)) {
      setState(() => errorText = l10n.changePasswordRuleInvalid);
      return;
    }
    if (next != confirm) {
      setState(() => errorText = l10n.changePasswordMismatch);
      return;
    }
    setState(() {
      busy = true;
      errorText = null;
    });
    try {
      await ref
          .read(authActionsProvider)
          .changePassword(currentPassword: current, newPassword: next);
      if (!mounted) return;
      showToast(context, l10n.changePasswordSuccess);
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      logger.error('ChangePassword', '修改密码失败', error, stackTrace);
      if (!mounted) return;
      setState(() {
        errorText = switch (mapApiError(error)) {
          ApiErrorKind.currentPasswordInvalid =>
            l10n.changePasswordCurrentInvalid,
          ApiErrorKind.network => l10n.authErrorNetworkIssue,
          ApiErrorKind.server => l10n.authErrorServer,
          _ => l10n.changePasswordFailed,
        };
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 校验新密码强度，确保界面规则与提交行为一致。
  bool _isValidNewPassword(String password) {
    return password.length >= 8 &&
        password.length <= 20 &&
        RegExp('[A-Za-z]').hasMatch(password) &&
        RegExp('[0-9]').hasMatch(password);
  }

  /// 构建带外置标签和文字显隐按钮的密码输入框。
  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool show,
    required ValueChanged<bool> onToggle,
    int? maxLength,
    TextInputAction? textInputAction,
  }) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
          child: Text(label, style: AppTextTokens.label(context)),
        ),
        const SizedBox(height: AppDimens.p8),
        SizedBox(
          height: 54,
          child: TextField(
            controller: controller,
            obscureText: !show,
            maxLength: maxLength,
            textInputAction: textInputAction,
            onChanged: (_) {
              if (errorText != null) setState(() => errorText = null);
            },
            decoration: InputDecoration(
              hintText: hint,
              fillColor: AppTokens.surfaceInput(context),
              counterText: '',
              suffixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.p16,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: busy ? null : () => onToggle(!show),
                child: Text(
                  show ? l10n.authPasswordHide : l10n.authPasswordShow,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(
            title: l10n.changePasswordTitle,
            showBack: true,
            actions: [
              HeaderTextAction(
                label: l10n.changePasswordSubmit,
                onPressed: busy ? null : _submit,
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p20,
                AppDimens.p20 + AppDimens.p4,
                AppDimens.p20,
                AppDimens.p20,
              ),
              children: [
                _field(
                  controller: currentCtrl,
                  label: l10n.changePasswordCurrent,
                  hint: l10n.changePasswordCurrentHint,
                  show: _showCurrent,
                  onToggle: (value) => setState(() => _showCurrent = value),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimens.p16),
                _field(
                  controller: newCtrl,
                  label: l10n.changePasswordNew,
                  hint: l10n.changePasswordNewHint,
                  show: _showNew,
                  onToggle: (value) => setState(() => _showNew = value),
                  maxLength: 20,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppDimens.p16),
                _field(
                  controller: confirmCtrl,
                  label: l10n.changePasswordConfirm,
                  hint: l10n.changePasswordConfirmHint,
                  show: _showConfirm,
                  onToggle: (value) => setState(() => _showConfirm = value),
                  maxLength: 20,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppDimens.p16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
                  child: Text(
                    l10n.changePasswordHint,
                    style: AppTextTokens.label(
                      context,
                    ).copyWith(color: AppTokens.textTertiary(context)),
                  ),
                ),
                if (errorText != null) ...[
                  const SizedBox(height: AppDimens.p8),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p4,
                    ),
                    child: Text(
                      errorText!,
                      style: TextStyle(color: AppTokens.error(context)),
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
