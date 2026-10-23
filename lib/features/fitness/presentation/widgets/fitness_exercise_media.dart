import 'dart:convert';
import 'fitness_gif_first_frame.dart';
import 'fitness_official_image.dart';
import '../../application/fitness_media_queries.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/category_icon.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/colors.dart';

String fitnessExerciseName(
  BuildContext context,
  FitnessExerciseDefinition def,
) {
  final locale = Localizations.localeOf(context);
  if (locale.languageCode != 'zh') return def.nameEn;
  return locale.countryCode == 'TW' || locale.scriptCode == 'Hant'
      ? def.nameZhHant
      : def.nameZh;
}

/// 静态列表和离线教学动画共用占位、失败重试；暂停保留当前帧。
class FitnessExerciseMedia extends StatefulWidget {
  const FitnessExerciseMedia({
    super.key,
    required this.definition,
    this.animated = false,
  });
  final FitnessExerciseDefinition definition;
  final bool animated;
  @override
  State<FitnessExerciseMedia> createState() => _FitnessExerciseMediaState();
}

class _FitnessExerciseMediaState extends State<FitnessExerciseMedia> {
  bool _playing = true;
  int _retry = 0;
  MemoryImage? _customImage;

  /// 图片字节由当前组件持有，重绘复用同一图片缓存键。
  @override
  void initState() {
    super.initState();
    _updateCustomImage();
  }

  /// 内容变化时替换图片；非法编码使用占位图并记录错误，不中断页面构建。
  void _updateCustomImage() {
    _customImage = null;
    final encoded = widget.definition.custom?.image;
    if (encoded == null) return;
    try {
      _customImage = MemoryImage(base64Decode(encoded));
    } catch (error, stackTrace) {
      logger.error(
        'FitnessExerciseMedia',
        '自定义动作图片解码失败：${widget.definition.id}',
        error,
        stackTrace,
      );
    }
  }

  /// 同一图片保持缓存身份，动作或播放模式切换时重置播放状态。
  @override
  void didUpdateWidget(FitnessExerciseMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.definition.custom?.image != widget.definition.custom?.image) {
      _updateCustomImage();
    }
    if (oldWidget.definition.id != widget.definition.id ||
        oldWidget.animated != widget.animated) {
      _playing = true;
      _retry = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final custom = widget.definition.custom;
    if (custom != null) {
      return Semantics(
        label: custom.name,
        child: AspectRatio(
          aspectRatio: 1,
          child: custom.image == null
              ? CategoryIconWidget(
                  iconName: custom.icon,
                  size: AppDimens.icon40,
                  color: AppTokens.primary(context),
                )
              : _customImage == null
              ? const Icon(AppIcons.fitness)
              : Image(
                  image: _customImage!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(AppIcons.fitness),
                ),
        ),
      );
    }
    final l = AppLocalizations.of(context);
    final ImageProvider provider = widget.definition.mediaUrl != null
        ? FitnessOfficialImage(
            queries: ProviderScope.containerOf(
              context,
              listen: false,
            ).read(fitnessMediaQueriesProvider),
            mediaUrl: widget.definition.mediaUrl!,
            fallbackAsset: widget.definition.gifAsset,
            animated: widget.animated,
          )
        : widget.animated
        ? AssetImage(widget.definition.gifAsset)
        : FitnessGifFirstFrame(widget.definition.gifAsset);
    Widget placeholder({bool retry = false}) => Center(
      child: retry
          ? IconButton(
              tooltip: l.commonRetry,
              icon: const Icon(AppIcons.refresh),
              onPressed: () async {
                try {
                  await provider.evict(
                    configuration: createLocalImageConfiguration(context),
                  );
                  if (mounted) setState(() => _retry++);
                } catch (error, stackTrace) {
                  logger.error(
                    'FitnessExerciseMedia',
                    '动作媒体重试失败：${widget.definition.gifAsset}',
                    error,
                    stackTrace,
                  );
                }
              },
            )
          : Icon(
              AppIcons.fitness,
              size: AppDimens.icon40,
              color: AppTokens.iconTertiary(context),
            ),
    );
    return Semantics(
      label: fitnessExerciseName(context, widget.definition),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 使用框架预解码与屏幕帧调度；TickerMode 暂停后保留当前帧。
            TickerMode(
              enabled: _playing,
              child: RepaintBoundary(
                child: Image(
                  image: provider,
                  key: ValueKey(
                    '${widget.definition.id}:${widget.animated}:$_retry',
                  ),
                  fit: BoxFit.contain,
                  frameBuilder: (context, child, frame, _) => Stack(
                    fit: StackFit.expand,
                    children: [
                      frame == null ? placeholder() : child,
                      if (widget.animated && frame != null)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton.filledTonal(
                            tooltip: _playing
                                ? l.fitnessPauseMedia
                                : l.fitnessPlay,
                            icon: Icon(
                              _playing ? AppIcons.pause : AppIcons.play,
                            ),
                            onPressed: () =>
                                setState(() => _playing = !_playing),
                          ),
                        ),
                    ],
                  ),
                  errorBuilder: (_, _, _) => placeholder(retry: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
