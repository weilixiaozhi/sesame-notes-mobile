import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 描边入口占满父布局分配的宽度，支持整行或并列的图标加文案按钮。
/// 计划库、模板库、账号密码与分摊统计入口共用同一版式；
/// 组件自身不带外边距，外边距统一由调用方按 p8 给出。
class EntryBarButton extends StatelessWidget {
  /// 业务提供入口内容与跳转动作，外观由按钮主题和统一高度控制。
  const EntryBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// 最小高度保持统一，窄屏长文案按原生按钮布局换行。
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: Icon(icon, size: AppDimens.icon16),
    label: Text(label),
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, AppDimens.p40),
    ),
  );
}
