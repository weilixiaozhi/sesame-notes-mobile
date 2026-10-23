import 'package:sesame_notes/theme/dimens.dart';

/// 数字键盘共享键距与行距；形状由主题的 keyRadius 角色决定。
class KeypadLayout {
  const KeypadLayout._();

  /// 相邻键位水平间距（px）。
  static const double gap = AppDimens.p4;

  /// 键盘相邻两行之间的纵向行距（px）。
  static const double rowGap = AppDimens.p4;
}
