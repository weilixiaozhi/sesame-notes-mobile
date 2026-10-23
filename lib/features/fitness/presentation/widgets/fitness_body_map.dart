import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/chart_tokens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'fitness_body_anatomy.dart';
import 'fitness_widgets.dart';

/// 已训练肌群按所属部位训练量着色；选中只放大并浮起，填充色保持不变。
class FitnessBodyMap extends StatelessWidget {
  const FitnessBodyMap({
    super.key,
    required this.onSelected,
    required this.trainedMuscles,
    required this.bodyPartVolumeKg,
    this.selectedPart,
  });
  final Set<String> trainedMuscles;
  final Map<String, double> bodyPartVolumeKg;
  final String? selectedPart;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final neutral = AppChartTokens.bodyNeutral(context);
    final trained = AppTokens.primary(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final back in [false, true]) ...[
          if (back) const SizedBox(width: AppDimens.p8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 170 / 250,
              child: LayoutBuilder(
                builder: (context, constraints) => GestureDetector(
                  onTapUp: (details) {
                    final point = Offset(
                      details.localPosition.dx * 170 / constraints.maxWidth -
                          35,
                      details.localPosition.dy * 250 / constraints.maxHeight,
                    );
                    final part = fitnessBodyPartAt(
                      point,
                      back: back,
                      selectedPart: selectedPart,
                    );
                    if (part != null) onSelected(part);
                  },
                  child: CustomPaint(
                    key: ValueKey(
                      back ? 'fitness-body-back' : 'fitness-body-front',
                    ),
                    painter: _BodyPainter(
                      back: back,
                      trainedMuscles: trainedMuscles,
                      bodyPartVolumeKg: bodyPartVolumeKg,
                      shadow: AppTokens.textPrimary(context),
                      selectedPart: selectedPart,
                      neutral: neutral,
                      trained: trained,
                      outline: AppChartTokens.bodyOutline(context),
                      surface: AppTokens.surface(context),
                      textStyle: AppTextTokens.caption(context).copyWith(
                        fontSize:
                            AppTextTokens.caption(context).fontSize! *
                            (170 / constraints.maxWidth).clamp(1, 1.5),
                      ),
                      muscleLabel: (muscle) => switch (muscle) {
                        'pectorals' => l.fitnessBodyChestRegions,
                        'delts' =>
                          back
                              ? l.fitnessBodyBackShoulderRegions
                              : l.fitnessBodyFrontShoulderRegions,
                        _ => fitnessBodyPartLabel(l, muscle),
                      },
                      viewLabel: back ? l.fitnessBodyBack : l.fitnessBodyFront,
                      label: (muscle) =>
                          '${back ? l.fitnessBodyBack : l.fitnessBodyFront} · ${fitnessBodyPartLabel(l, muscle)}',
                      onSelected: onSelected,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

final _front = fitnessMusclePaths(false), _back = fitnessMusclePaths(true);
Map<String, List<Path>> _regions(bool back) => back ? _back : _front;

/// 人体图的可点击部位集合，统计卡片按实际记录筛选展示。
final fitnessAnatomyBodyParts = {
  for (final muscle in {..._front.keys, ..._back.keys})
    fitnessMuscleBodyPart(muscle),
};

// 绘制、命中和读屏共用变换后的路径，放大边缘仍可点击。
Path _displayPath(Path path, bool selected) {
  if (!selected) return path;
  const scale = AppChartTokens.bodySelectionScale;
  final center = path.getBounds().center;
  return path.transform(
    Float64List.fromList([
      scale,
      0,
      0,
      0,
      0,
      scale,
      0,
      0,
      0,
      0,
      1,
      0,
      center.dx * (1 - scale),
      center.dy * (1 - scale),
      0,
      1,
    ]),
  );
}

@visibleForTesting
String? fitnessBodyPartAt(
  Offset point, {
  required bool back,
  String? selectedPart,
}) {
  // 浮起的选中区域优先命中，避免相邻部位抢走放大边缘的点击。
  for (final selected in [true, false]) {
    for (final region in _regions(back).entries) {
      final part = fitnessMuscleBodyPart(region.key);
      if ((part == selectedPart) != selected) continue;
      if (region.value.any(
        (path) => _displayPath(path, selected).contains(point),
      )) {
        return part;
      }
    }
  }
  return null;
}

// 标签锚点与折线均为插画坐标；左右交错避免小屏文字跨越人体。
const _frontLabels = [
  ('pectorals', Offset(39, 48), Offset(-33, 32)),
  ('serratus anterior', Offset(35, 70), Offset(-33, 64)),
  ('biceps', Offset(22, 65), Offset(-33, 92)),
  ('abs', Offset(45, 99), Offset(-33, 136)),
  ('quads', Offset(37, 152), Offset(-33, 194)),
  ('delts', Offset(76, 44), Offset(109, 22)),
  ('forearms', Offset(84, 98), Offset(109, 76)),
  ('calves', Offset(63, 193), Offset(109, 176)),
];
const _backLabels = [
  ('delts', Offset(25, 44), Offset(-33, 22)),
  ('triceps', Offset(22, 66), Offset(-33, 70)),
  ('hamstrings', Offset(37, 146), Offset(-33, 187)),
  ('traps', Offset(59, 36), Offset(107, 33)),
  ('lats', Offset(63, 64), Offset(107, 88)),
  ('glutes', Offset(60, 114), Offset(107, 143)),
  ('calves', Offset(64, 194), Offset(107, 208)),
];

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.back,
    required this.trainedMuscles,
    required this.bodyPartVolumeKg,
    required this.shadow,
    required this.selectedPart,
    required this.neutral,
    required this.trained,
    required this.outline,
    required this.surface,
    required this.textStyle,
    required this.muscleLabel,
    required this.viewLabel,
    required this.label,
    required this.onSelected,
  });
  final bool back;
  final Set<String> trainedMuscles;
  final Map<String, double> bodyPartVolumeKg;
  final String? selectedPart;
  final Color neutral, trained, shadow, outline, surface;
  final TextStyle textStyle;
  final String Function(String) label, muscleLabel;
  final String viewLabel;
  final ValueChanged<String> onSelected;

  /// 绘制解剖轮廓与训练量标签，临时文字布局在每次绘制后立即释放。
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 170, size.height / 250);
    canvas.translate(35, 0);
    void draw(Path path, Color fill, Color border, double width) {
      canvas.drawPath(path, Paint()..color = fill);
      canvas.drawPath(
        path,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeJoin = StrokeJoin.round,
      );
    }

    draw(fitnessBodyOutline, surface, outline, .65);
    for (final ear in fitnessEars) {
      draw(ear, surface, outline, .5);
    }
    draw(fitnessHead, back ? outline : surface, outline, .5);
    draw(fitnessHair, outline, outline, .4);
    final maximum = bodyPartVolumeKg.values.fold<double>(
      0,
      (a, b) => a > b ? a : b,
    );
    for (final selected in [false, true]) {
      for (final region in _regions(back).entries) {
        final part = fitnessMuscleBodyPart(region.key);
        if ((part == selectedPart) != selected) continue;
        final fill = AppChartTokens.bodyVolumeColor(
          trainedMuscles.contains(region.key) ? bodyPartVolumeKg[part] ?? 0 : 0,
          maximum,
          neutral,
          trained,
        );
        for (final path in region.value) {
          final displayed = _displayPath(path, selected);
          if (selected) canvas.drawShadow(displayed, shadow, 2, false);
          draw(
            displayed,
            fill,
            selected ? outline : surface,
            selected ? .8 : .7,
          );
        }
      }
    }
    // 肌腱和肌纤维不承载训练量，用细线保留自然走向与关节结构。
    for (final side in [-1, 1]) {
      canvas.save();
      canvas.translate(50, 0);
      canvas.scale(side.toDouble(), 1);
      final tendon = Path()
        ..moveTo(11, 207)
        ..cubicTo(12, 213, 10, 220, 10, 224)
        ..moveTo(9, 171)
        ..quadraticBezierTo(11, 176, 14, 171)
        ..moveTo(29, 88)
        ..quadraticBezierTo(35, 104, 42, 114)
        ..moveTo(36, 122)
        ..quadraticBezierTo(38, 127, 42, 126);
      canvas.drawPath(
        tendon,
        Paint()
          ..color = neutral
          ..style = PaintingStyle.stroke
          ..strokeWidth = .75,
      );
      canvas.restore();
    }
    for (final item in back ? _backLabels : _frontLabels) {
      final (muscle, anchor, end) = item;
      final active = trainedMuscles.contains(muscle);
      final color = active ? trained : outline;
      final left = end.dx < 0;
      final line = Path()
        ..moveTo(anchor.dx, anchor.dy)
        ..lineTo(left ? end.dx + 27 : end.dx - 9, end.dy + 10)
        ..lineTo(left ? end.dx : end.dx + 27, end.dy + 10);
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = .55,
      );
      canvas.drawCircle(anchor, .95, Paint()..color = color);
      final text = TextPainter(
        text: TextSpan(
          text: muscleLabel(muscle),
          style: textStyle.copyWith(color: color),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: 44);
      try {
        text.paint(
          canvas,
          Offset(left ? end.dx : 134 - text.width, end.dy - text.height + 8),
        );
      } finally {
        // 绘制器按帧创建文字布局，绘制完成后释放原生段落资源。
        text.dispose();
      }
    }
    final caption = TextPainter(
      text: TextSpan(
        text: viewLabel,
        style: textStyle.copyWith(color: outline),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    try {
      caption.paint(canvas, Offset(50 - caption.width / 2, 240));
    } finally {
      caption.dispose();
    }
    canvas.restore();
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
    final nodes = <CustomPainterSemantics>[];
    for (final region in _regions(back).entries) {
      final part = fitnessMuscleBodyPart(region.key);
      final selected = part == selectedPart;
      for (final path in region.value) {
        final bounds = _displayPath(path, selected).getBounds();
        nodes.add(
          CustomPainterSemantics(
            rect: Rect.fromLTRB(
              (bounds.left + 35) * size.width / 170,
              bounds.top * size.height / 250,
              (bounds.right + 35) * size.width / 170,
              bounds.bottom * size.height / 250,
            ),
            properties: SemanticsProperties(
              label: label(region.key),
              textDirection: TextDirection.ltr,
              button: true,
              selected: selected,
              onTap: () => onSelected(part),
            ),
          ),
        );
      }
    }
    return nodes;
  };

  @override
  bool shouldRepaint(covariant _BodyPainter old) =>
      old.back != back ||
      !setEquals(old.trainedMuscles, trainedMuscles) ||
      old.shadow != shadow ||
      !mapEquals(old.bodyPartVolumeKg, bodyPartVolumeKg) ||
      old.selectedPart != selectedPart ||
      old.neutral != neutral ||
      old.trained != trained ||
      old.outline != outline ||
      old.surface != surface ||
      old.textStyle != textStyle ||
      old.viewLabel != viewLabel;
  @override
  bool shouldRebuildSemantics(covariant _BodyPainter old) => true;
}
