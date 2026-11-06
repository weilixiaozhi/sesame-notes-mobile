import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/app_logo.dart';
import 'phone_region_sheet.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/shadows.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 登录与注册共用品牌、表单宽度、安全区和键盘弹出后的滚动布局。
class AuthFormScaffold extends StatelessWidget {
  /// 表单只提供字段、提示和操作，页面外框由认证模块统一维护。
  const AuthFormScaffold({super.key, required this.children});

  final List<Widget> children;

  /// 宽屏限制表单宽度，内容超出键盘上方空间时可继续滚动操作。
  @override
  Widget build(BuildContext context) => Scaffold(
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
                ...children,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// 登录与注册共用区号入口；背景、边框和文字由输入主题提供。
class AuthPhoneField extends StatefulWidget {
  /// 由表单拥有手机号和区号值，控件统一处理选择弹层的生命周期。
  const AuthPhoneField({
    super.key,
    required this.controller,
    required this.region,
    required this.onRegionChanged,
  });
  final TextEditingController controller;
  final PhoneRegion region;
  final ValueChanged<PhoneRegion> onRegionChanged;

  /// 区号选择状态仅属于当前输入控件。
  @override
  State<AuthPhoneField> createState() => _AuthPhoneFieldState();
}

class _AuthPhoneFieldState extends State<AuthPhoneField> {
  bool _picking = false;

  /// 一次只打开一个选择弹层，控件退出后忽略结果，异常记录并提示用户。
  Future<void> _pickRegion() async {
    if (_picking) return;
    _picking = true;
    try {
      final picked = await showPhoneRegionSheet(
        context,
        selected: widget.region,
      );
      if (mounted && picked != null) widget.onRegionChanged(picked);
    } catch (error, stackTrace) {
      logger.error('AuthPhoneField', '选择手机号地区失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      _picking = false;
    }
  }

  /// 外置标签与区号入口共同属于手机号字段，重建时保留输入控制器。
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
        child: Text(
          AppLocalizations.of(context).authPhone,
          style: AppTextTokens.label(context),
        ),
      ),
      const SizedBox(height: AppDimens.p8),
      TextField(
        controller: widget.controller,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).authPhoneHint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: AppDimens.p8),
            child: TextButton(
              onPressed: _pickRegion,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.region.code),
                  const SizedBox(width: AppDimens.p4),
                  const Icon(AppIcons.chevronDown, size: AppDimens.icon16),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// 认证表单共用密码标签、输入高度和显隐入口，业务负责校验与状态。
class AuthPasswordField extends StatelessWidget {
  /// 输入限制和键盘动作直接交给原生输入框，控制器归属于表单。
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.show,
    required this.onToggle,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool show;
  final VoidCallback? onToggle;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  /// 显隐只改变遮挡状态，输入内容和焦点由同一个输入框保留。
  @override
  Widget build(BuildContext context) => Column(
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
          maxLength: maxLength,
          textInputAction: textInputAction,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            suffixIcon: TextButton(
              onPressed: onToggle,
              child: Text(
                show
                    ? AppLocalizations.of(context).authPasswordHide
                    : AppLocalizations.of(context).authPasswordShow,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
