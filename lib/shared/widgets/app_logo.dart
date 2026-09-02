import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 应用品牌图标组件
///
/// 设计意图：品牌图以矢量 SVG（app_logo.svg）提供，可无损缩放、
/// 多色配色硬编码在图内，不随主题色变化，因此本组件不接受 color 参数。
/// 使用 [SvgPicture.asset] 渲染统一资产路径；当前 SVG 内嵌 base64 位图，
/// 该渲染接口也兼容纯矢量源。
class AppLogo extends StatelessWidget {
  /// Logo 的显示边长。
  final double size;

  /// 创建应用 Logo。
  const AppLogo({super.key, this.size = 256});

  /// 构建指定尺寸的 Logo。
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/app_logo.svg', width: size, height: size);
  }
}
