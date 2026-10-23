import 'package:flutter/material.dart';

/// 阴影令牌
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// 头像预览页 260×260 头像阴影：暗色背景上的柔和浮起。
  static const double avatarBlur = 24;
}
