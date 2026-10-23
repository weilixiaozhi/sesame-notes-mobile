import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'phone_region_sheet.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

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

  /// 输入样式沿用主题，区号变化不会重建手机号控制器。

  @override
  Widget build(BuildContext context) => TextField(
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
  );
}

/// 密码显隐只共享后缀外观，校验、输入限制及状态仍由表单负责。
InputDecoration authPasswordDecoration(
  BuildContext context, {
  required String hint,
  required bool show,
  required VoidCallback? onToggle,
}) => InputDecoration(
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
);
