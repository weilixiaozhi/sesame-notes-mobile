import 'post_login_migration.dart';
import 'auth_fields.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/presentation/phone_region_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/shared/widgets/app_logo.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 登录页：手机号 + 密码，区号选择器对齐 UI 稿。
///
/// 设计意图：
/// - 登录成功由协调器提交候选凭证（不自行写安全存储）；
/// - reconnect 失败不构成登录失败（保持已登录并提示稍后同步）；
/// - 页面以 push(bool) 返回认证结果，云功能门禁据此返回来源页。
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  PhoneRegion _region = PhoneRegion.defaultRegion;
  final phoneCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  String? errorText;
  bool busy = false;
  bool _showPwd = false;

  @override
  void dispose() {
    phoneCtrl.dispose();
    pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final phone = phoneCtrl.text.trim();
    final password = pwdCtrl.text;
    // 手机号非空 → 密码非空，任一不满足都不发起认证请求
    final invalid = switch (validateCredentialsForm(
      phone: phone,
      password: password,
    )) {
      AuthFormError.phoneRequired => l10n.authInvalidPhone,
      AuthFormError.passwordRequired => l10n.authInvalidPassword,
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
          .login(countryCode: _region.code, phone: phone, password: password);
      if (!mounted) return;
      if (!ok) {
        setState(() => errorText = l10n.authErrorOther);
        return;
      }
      // 登录成功后返回来源页（云功能门禁/我的页）
      await finishAuthenticationNavigation(context);
    } catch (error, stackTrace) {
      logger.error('Auth', '登录失败', error, stackTrace);
      if (mounted) {
        setState(() => errorText = _messageFor(error));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  /// 统一错误文案映射：网络/限流/凭据错误各有稳定文案，不展示服务端堆栈。
  String _messageFor(Object error) {
    final l10n = AppLocalizations.of(context);
    switch (mapApiError(error)) {
      case ApiErrorKind.serverNotConfigured:
        return l10n.authErrorServerNotConfigured;
      case ApiErrorKind.invalidCredentials:
        return l10n.authErrorInvalidCredentials;
      case ApiErrorKind.phoneAlreadyRegistered:
        return l10n.authErrorPhoneAlreadyRegistered;
      case ApiErrorKind.rateLimited:
        return l10n.authErrorRateLimit;
      case ApiErrorKind.network:
        return l10n.authErrorNetworkIssue;
      case ApiErrorKind.server:
        return l10n.authErrorServer;
      case ApiErrorKind.invalidRefreshToken:
      case ApiErrorKind.alreadyLedgerOwner:
      case ApiErrorKind.currentPasswordInvalid:
      case ApiErrorKind.phoneInvalid:
      case ApiErrorKind.passwordInvalid:
      case ApiErrorKind.displayNameInvalid:
      case ApiErrorKind.genderInvalid:
      case ApiErrorKind.other:
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
                  // 登录页使用品牌 Logo 资源，避免与账号头像或通用登录图标混淆。
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
                  const SizedBox(height: AppDimens.p20),
                  Text(
                    l10n.authWelcomeBack,
                    textAlign: TextAlign.center,
                    style: AppTextTokens.display1(context),
                  ),
                  const SizedBox(height: AppDimens.p4),
                  Text(
                    l10n.authWelcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextTokens.body(
                      context,
                    ).copyWith(color: AppTokens.textTertiary(context)),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p4,
                    ),
                    child: Text(
                      l10n.authPassword,
                      style: AppTextTokens.label(context),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p8),
                  SizedBox(
                    height: AppDimens.authFieldHeight,
                    child: TextField(
                      controller: pwdCtrl,
                      obscureText: !_showPwd,
                      decoration: authPasswordDecoration(
                        context,
                        hint: l10n.authPasswordHint,
                        show: _showPwd,
                        onToggle: () => setState(() => _showPwd = !_showPwd),
                      ),
                    ),
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
                    label: l10n.authLogin,
                  ),
                  const SizedBox(height: AppDimens.p12),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final ok = await context.push<bool>(
                              Routes.authRegister,
                            );
                            if (ok == true && context.mounted) {
                              await finishAuthenticationNavigation(context);
                            }
                          },
                    child: Text(l10n.authNoAccount),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
