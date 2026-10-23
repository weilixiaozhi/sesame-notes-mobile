import 'package:flutter/widgets.dart';

/// 弹层打开前收起键盘并等待动画结束，避免键盘影响初始布局。
/// 调用方须在 await 后直接检查 mounted，分析器无法识别封装在扩展内的守卫。
extension OverlayKeyboardGuard on State {
  /// 收起键盘并等待动画；返回后由调用方检查 mounted。
  Future<void> prepareForOverlay() async {
    // 收起当前焦点（输入框）的键盘，避免弹层关闭返回时键盘重新弹起。
    FocusManager.instance.primaryFocus?.unfocus();
    // 等待键盘收起动画，给后续弹层一个干净的布局起点（实测约 100ms 足够）。
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
