import 'package:flutter/material.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 设置单选页：统一返回头部、列表留白与选中态。
class SettingsSelection<T> extends StatelessWidget {
  final String title;
  final Map<T, String> options;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  /// 头部右侧操作；需要显式保存的设置页把自己的保存入口放进来。
  final List<Widget>? actions;

  /// 选项下方的说明内容，承载隐私提示等次要文案。
  final Widget? footer;

  /// 按选项顺序展示列表，点击后交由调用方更新设置。
  const SettingsSelection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.actions,
    this.footer,
  });

  /// 使用项目头部、单选行和间距令牌构建二级页。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: title, showBack: true, actions: actions),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.p16),
              children: [
                for (final option in options.entries) ...[
                  AppRadioTile(
                    title: option.value,
                    selected: option.key == selectedValue,
                    onTap: () => onChanged(option.key),
                  ),
                  const SizedBox(height: AppDimens.p8),
                ],
                ?footer,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
