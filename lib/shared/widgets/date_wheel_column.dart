import 'package:flutter/cupertino.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 至今紧邻当前年份；未来年份仍可向上选择，不改变日期支持范围。
List<int?> dateWheelYearChoices(int minYear, int maxYear, int presentYear) => [
  for (var year = maxYear; year >= minYear; year--) ...[
    if (year == presentYear.clamp(minYear, maxYear)) null,
    year,
  ],
];

/// 公历和农历日期共用的滚轮列，统一行高、选中带和日期文字。
class DateWheelColumn extends StatefulWidget {
  /// 外部控制器由日期选择器管理，独立列由自身创建并释放控制器。
  const DateWheelColumn({
    super.key,
    required this.labels,
    required this.onChanged,
    this.controller,
    this.initialItem = 0,
  });

  final List<String> labels;
  final ValueChanged<int> onChanged;
  final FixedExtentScrollController? controller;
  final int initialItem;

  /// 每列独立维护滚动位置，日期范围变化由业务提供新的列身份。
  @override
  State<DateWheelColumn> createState() => _DateWheelColumnState();
}

class _DateWheelColumnState extends State<DateWheelColumn> {
  late final FixedExtentScrollController _controller;

  /// 保留公历现有控制器，农历列按有效选项索引定位。
  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        FixedExtentScrollController(initialItem: widget.initialItem);
  }

  /// 只释放组件自身持有的控制器。
  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  /// 日期滚轮显示五行，选中带和字重沿用公历日期选择器。
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppWheelColumn(
        labels: widget.labels,
        controller: _controller,
        onChanged: widget.onChanged,
      ),
    );
  }
}

/// 通用、时间和日期滚轮共用选中带、行高与单行缩放。
class AppWheelColumn extends StatelessWidget {
  const AppWheelColumn({
    super.key,
    required this.labels,
    required this.controller,
    required this.onChanged,
  });
  final List<String> labels;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AppDimens.p40 * 5,
    child: CupertinoPicker(
      itemExtent: AppDimens.p40,
      scrollController: controller,
      onSelectedItemChanged: onChanged,
      selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(),
      children: [
        for (final label in labels)
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: AppTextTokens.title(context),
              ),
            ),
          ),
      ],
    ),
  );
}
