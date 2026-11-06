import 'package:flutter/material.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 搜索输入共用搜索图标和清除入口，查询策略由业务页面持有。
class AppSearchField extends StatelessWidget {
  /// 控制器由页面创建和释放，输入及清除回调保留各自的筛选规则。
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool enabled;

  /// 清除入口随当前草稿更新，不等待业务查询的防抖计时器触发。
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(AppIcons.search),
            hintText: hintText,
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(AppIcons.close, size: AppDimens.icon20),
                    onPressed: enabled ? onClear : null,
                  ),
          ),
        ),
      );
}
