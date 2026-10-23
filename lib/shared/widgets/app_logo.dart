import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 应用品牌图标组件
///
/// 设计意图：品牌图以矢量 SVG（app_logo.svg）提供，可无损缩放、
/// 多色配色硬编码在图内，不随主题色变化，因此本组件不接受 color 参数。
/// 使用 [SvgPicture.asset] 渲染统一的纯矢量资产。
class AppLogo extends StatelessWidget {
  /// Logo 的显示边长。
  final double size;

  const AppLogo({super.key, this.size = 256});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/app_logo.svg', width: size, height: size);
  }
}
