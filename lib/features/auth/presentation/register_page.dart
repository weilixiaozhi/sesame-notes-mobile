import 'post_login_migration.dart';
import 'auth_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/presentation/phone_region_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 注册页：区号 + 手机号 + 密码 + 确认密码。
///
/// 设计意图：
/// - 校验顺序：手机号非空 → 密码非空 → 两次密码一致 → 调服务端；
/// - 确认密码不落盘、不写日志、不进请求；
/// - 不提供验证码、协议/隐私政策入口；
/// - 注册成功返回目标页面后统一询问是否迁移本机本子。
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  PhoneRegion _region = PhoneRegion.defaultRegion;
  final phoneCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  String? errorText;
  bool busy = false;
  bool _showPwd = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    pwdCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final phone = phoneCtrl.text.trim();
    final password = pwdCtrl.text;
    final confirm = confirmCtrl.text;
    // 校验顺序：手机号 → 密码非空 → 两次一致 → 调服务端
    final invalid = switch (validateCredentialsForm(
      phone: phone,
      password: password,
      confirmPassword: confirm,
    )) {
      AuthFormError.phoneRequired => l10n.authInvalidPhone,
      AuthFormError.passwordRequired => l10n.authInvalidPassword,
      AuthFormError.passwordMismatch => l10n.authPasswordMismatch,
      _ => null,
    };
    if (invalid != null) {
      setState(() => errorText = invalid);
      return;
    }
    setState(() {
      busy = true;
      errorText = null;
    });
    try {
      final ok = await ref
          .read(authActionsProvider)
          .register(
            countryCode: _region.code,
            phone: phone,
            password: password,
          );
      if (!mounted) return;
      if (!ok) {
        setState(() => errorText = l10n.authErrorOther);
        return;
      }
      // 登录成功导航完成后，由目标页面统一询问本机迁移。
      await finishAuthenticationNavigation(context);
    } catch (error, stackTrace) {
      logger.error('Auth', '注册失败', error, stackTrace);
      if (mounted) setState(() => errorText = _messageFor(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 配置缺失、断网和账号错误分别展示稳定文案。
  String _messageFor(Object error) {
    final l10n = AppLocalizations.of(context);
    switch (mapApiError(error)) {
      case ApiErrorKind.serverNotConfigured:
        return l10n.authErrorServerNotConfigured;
      case ApiErrorKind.phoneAlreadyRegistered:
        return l10n.authErrorPhoneAlreadyRegistered;
      case ApiErrorKind.phoneInvalid:
        return l10n.authInvalidPhone;
      case ApiErrorKind.rateLimited:
        return l10n.authErrorRateLimit;
      case ApiErrorKind.network:
        return l10n.authErrorNetworkIssue;
      case ApiErrorKind.server:
        return l10n.authErrorServer;
      default:
        return l10n.authErrorOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.p20,
            AppDimens.p40,
            AppDimens.p20,
            AppDimens.p20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.authFormMaxWidth,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 注册页与登录页共用品牌 Logo，避免把账号头像当作品牌标识。
                  Center(
                    child: Container(
                      width: AppDimens.authLogoSize,
                      height: AppDimens.authLogoSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimens.radius16),
                        boxShadow: AppTokens.isDark(context)
                            ? null
                            : AppShadows.card,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const AppLogo(size: AppDimens.authLogoSize),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p32),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p4,
                    ),
                    child: Text(
                      l10n.authPhone,
                      style: AppTextTokens.label(context),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  AuthPhoneField(
                    controller: phoneCtrl,
                    region: _region,
                    onRegionChanged: (region) =>
                        setState(() => _region = region),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  _passwordField(
                    controller: pwdCtrl,
                    label: l10n.authPassword,
                    hint: l10n.authRegisterPasswordHint,
                    show: _showPwd,
                    onToggle: (v) => setState(() => _showPwd = v),
                  ),
                  const SizedBox(height: AppDimens.p16),
                  _passwordField(
                    controller: confirmCtrl,
                    label: l10n.authConfirmPassword,
                    hint: l10n.authConfirmPasswordHint,
                    show: _showConfirm,
                    onToggle: (v) => setState(() => _showConfirm = v),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: AppDimens.p12),
                    Text(
                      errorText!,
                      style: AppTextTokens.body(
                        context,
                      ).copyWith(color: AppTokens.error(context)),
                    ),
                  ],
                  const SizedBox(height: AppDimens.p32),
                  AppPrimaryButton(
                    onPressed: _submit,
                    busy: busy,
                    label: l10n.authRegister,
                  ),
                  const SizedBox(height: AppDimens.p12),
                  TextButton(
                    onPressed: busy ? null : () => context.pop(false),
                    child: Text(l10n.authAlreadyHaveAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 构建带外置标签的密码输入框，使标签和占位文案职责清晰。
  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool show,
    required ValueChanged<bool> onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
          child: Text(label, style: AppTextTokens.label(context)),
        ),
        const SizedBox(height: AppDimens.p8),
        SizedBox(
          height: AppDimens.authFieldHeight,
          child: TextField(
            controller: controller,
            obscureText: !show,
            decoration: authPasswordDecoration(
              context,
              hint: hint,
              show: show,
              onToggle: () => onToggle(!show),
            ),
          ),
        ),
      ],
    );
  }
}
