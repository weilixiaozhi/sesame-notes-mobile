import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 全局单选样式令牌。
///
/// 所有单选场景（选择账本 / 应用语言 / 深色模式 / 币种选择 / 所属分类等）
/// 统一口径：
/// - 指示器放在行右侧：选中 = 圆形内有勾选（主题色），未选中 = 空心圆
///   （iconTertiary），两态同宽避免行间错位；
/// - 文本选中态 = 主题色 + w600，非选中态 = textPrimary + normal。
class AppRadioTokens {
  /// 右侧单选指示器（选中圆勾 / 未选中空心圆）。
  static Widget indicator(BuildContext context, {required bool selected}) {
    return Icon(
      selected ? AppIcons.checkCircle : AppIcons.radioUnchecked,
      size: AppDimens.icon20,
      color: selected
          ? Theme.of(context).colorScheme.primary
          : AppTokens.iconTertiary(context),
    );
  }

  /// 单选行标题样式：选中主题色 + w600，未选中 textPrimary + normal。
  static TextStyle titleStyle(BuildContext context, {required bool selected}) {
    return TextStyle(
      color: selected
          ? Theme.of(context).colorScheme.primary
          : AppTokens.textPrimary(context),
      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
    );
  }
}

/// 统一单选行（ListTile 封装）：标题 + 右侧统一单选指示器。
class AppRadioTile<T> extends StatefulWidget {
  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? subtitle;
  final Widget? bottom;

  /// 紧凑选择列表沿用辅助文字字号，选中样式和交互仍统一维护。
  final bool compact;
  final int? titleMaxLines;
  final T? value;
  final bool _grouped;

  const AppRadioTile({
    super.key,
    required this.title,
    required this.selected,
    this.onTap,
    this.leading,
    this.subtitle,
    this.bottom,
    this.compact = false,
    this.titleMaxLines,
  }) : value = null,
       _grouped = false;

  /// 分组模式复用原生单选焦点导航，视觉仍由统一单选行承载。
  const AppRadioTile.grouped({
    super.key,
    required this.title,
    required T this.value,
    this.leading,
    this.subtitle,
    this.bottom,
    this.compact = false,
    this.titleMaxLines,
  }) : selected = false,
       onTap = null,
       _grouped = true;

  /// 焦点节点归属于单选行，随组件释放。
  @override
  State<AppRadioTile<T>> createState() => _AppRadioTileState<T>();
}

class _AppRadioTileState<T> extends State<AppRadioTile<T>> {
  final _focusNode = FocusNode();

  /// 释放原生单选组使用的焦点资源。
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// 普通点击和分组导航共享同一标题与右侧指示器。
  Widget _tile(
    BuildContext context, {
    required bool selected,
    bool focused = false,
  }) {
    final tile = ListTile(
      leading: widget.leading,
      title: Text(
        widget.title,
        maxLines: widget.titleMaxLines,
        overflow: widget.titleMaxLines == null ? null : TextOverflow.ellipsis,
        style: AppRadioTokens.titleStyle(context, selected: selected).copyWith(
          fontSize: widget.compact
              ? AppTextTokens.label(context).fontSize
              : null,
        ),
      ),
      subtitle: widget.subtitle,
      trailing: AppRadioTokens.indicator(context, selected: selected),
      tileColor: focused ? Theme.of(context).focusColor : null,
      onTap: widget._grouped ? null : widget.onTap,
    );
    if (widget.bottom == null) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.p12,
            0,
            AppDimens.p12,
            AppDimens.p12,
          ),
          child: widget.bottom!,
        ),
      ],
    );
  }

  /// RawRadio 处理方向键、空格和互斥语义，业务只维护组内当前值。
  @override
  Widget build(BuildContext context) {
    if (!widget._grouped) {
      return MergeSemantics(
        child: Semantics(
          checked: widget.selected,
          inMutuallyExclusiveGroup: true,
          child: _tile(context, selected: widget.selected),
        ),
      );
    }
    final registry = RadioGroup.maybeOf<T>(context);
    // 标题与选中状态合并播报，避免辅助功能把同一行拆成两个节点。
    return MergeSemantics(
      child: RawRadio<T>(
        value: widget.value as T,
        groupRegistry: registry,
        enabled: registry != null,
        mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.click),
        toggleable: false,
        autofocus: false,
        focusNode: _focusNode,
        builder: (context, state) => _tile(
          context,
          selected: registry?.groupValue == widget.value,
          focused: state.states.contains(WidgetState.focused),
        ),
      ),
    );
  }
}

/// 表单默认确认后返回；筛选可点选即返回，并限制长列表弹层高度。
Future<T?> showAppRadioSheet<T>(
  BuildContext context, {
  required String title,
  required T selected,
  required Map<T, String> options,
  bool confirmSelection = true,
  double? height,
}) {
  var pending = selected;
  final entries = options.entries.toList();
  return showAppSheet<T>(
    context: context,
    child: StatefulBuilder(
      builder: (context, setState) => SizedBox(
        height: height,
        child: AppSheet(
          title: title,
          footer: confirmSelection
              ? AppPrimaryButton(
                  label: AppLocalizations.of(context).commonConfirm,
                  onPressed: () => Navigator.pop(context, pending),
                )
              : null,
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            separatorBuilder: (context, _) => AppTokens.cardDivider(context),
            itemBuilder: (context, index) {
              final option = entries[index];
              return AppRadioTile(
                title: option.value,
                selected: option.key == pending,
                onTap: () {
                  if (confirmSelection) {
                    setState(() => pending = option.key);
                  } else {
                    Navigator.pop(context, option.key);
                  }
                },
              );
            },
          ),
        ),
      ),
    ),
  );
}
