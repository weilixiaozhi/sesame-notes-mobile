import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/auth/application/auth_actions.dart';
import 'package:sesame_notes/features/auth/presentation/phone_region_sheet.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 注册页：区号 + 手机号 + 密码 + 确认密码。
///
/// 设计意图：
/// - 校验顺序：手机号格式 → 密码非空 → 两次密码一致 → 调服务端；
/// - 确认密码不落盘、不写日志、不进请求；
/// - 不提供验证码、协议/隐私政策入口；
/// - 注册成功后本机已有本地账本时显示一次非阻断 Toast。
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
    if (phone.isEmpty) {
      setState(() => errorText = l10n.authInvalidPhone);
      return;
    }
    if (password.isEmpty) {
      setState(() => errorText = l10n.authInvalidPassword);
      return;
    }
    if (password != confirm) {
      setState(() => errorText = l10n.authPasswordMismatch);
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
      // 注册成功提示：本地账本不自动上传（非阻断）
      showToast(context, l10n.authRegisterSuccessToast);
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go(Routes.ledgers);
      }
    } catch (error, stackTrace) {
      logger.error('Auth', '注册失败', error, stackTrace);
      if (mounted) setState(() => errorText = _messageFor(error));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String _messageFor(Object error) {
    final l10n = AppLocalizations.of(context);
    switch (mapApiError(error)) {
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
                  // 注册页与登录页共用品牌 Logo，避免把账号头像当作品牌标识。
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
                          : Text(l10n.authRegister),
                    ),
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
            decoration: InputDecoration(
              hintText: hint,
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
                onPressed: () => onToggle(!show),
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
}
