import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/presentation/phone_region_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/app_logo.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
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
    if (phone.isEmpty) {
      setState(() => errorText = l10n.authInvalidPhone);
      return;
    }
    if (password.isEmpty) {
      setState(() => errorText = l10n.authInvalidPassword);
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
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(Routes.ledgers);
      }
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
      case ApiErrorKind.currentPasswordInvalid:
      case ApiErrorKind.phoneInvalid:
      case ApiErrorKind.passwordInvalid:
      case ApiErrorKind.displayNameInvalid:
      case ApiErrorKind.genderInvalid:
      case ApiErrorKind.other:
        return l10n.authErrorOther;
    }
  }

  Future<void> _pickRegion() async {
    final picked = await showPhoneRegionSheet(context, selected: _region);
    if (picked != null) setState(() => _region = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final radius = BorderRadius.circular(AppDimens.radius12);

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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 登录页使用品牌 Logo 资源，避免与账号头像或通用登录图标混淆。
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimens.radius16),
                        boxShadow: AppTokens.isDark(context)
                            ? null
                            : AppShadows.card,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const AppLogo(size: 64),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p20),
                  Text(
                    l10n.authWelcomeBack,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
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
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.p16,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.surfaceInput(context),
                      borderRadius: radius,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _pickRegion,
                          borderRadius: radius,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _region.code,
                                style: AppTextTokens.title(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: AppDimens.p4),
                              Icon(
                                AppIcons.chevronDown,
                                size: AppDimens.icon16,
                                color: AppTokens.iconTertiary(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: AppDimens.p20,
                          child: VerticalDivider(
                            width: AppDimens.p20,
                            thickness: 1,
                            color: AppTokens.divider(context),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: l10n.authPhoneHint,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    height: 54,
                    child: TextField(
                      controller: pwdCtrl,
                      obscureText: !_showPwd,
                      decoration: InputDecoration(
                        hintText: l10n.authPasswordHint,
                        fillColor: AppTokens.surfaceInput(context),
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
                          onPressed: () => setState(() => _showPwd = !_showPwd),
                          child: Text(
                            _showPwd
                                ? l10n.authPasswordHide
                                : l10n.authPasswordShow,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: AppDimens.p12),
                    Text(
                      errorText!,
                      style: TextStyle(color: AppTokens.error(context)),
                    ),
                  ],
                  const SizedBox(height: AppDimens.p32),
                  SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: busy ? null : _submit,
                      child: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.authLogin),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p12),
                  TextButton(
                    onPressed: busy
                        ? null
                        : () async {
                            final ok = await context.push<bool>(
                              Routes.authRegister,
                            );
                            if (ok == true &&
                                context.mounted &&
                                context.canPop()) {
                              context.pop(true);
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
