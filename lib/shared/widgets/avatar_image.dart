import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../../core/logging/logger_service.dart';

/// 头像以原始长宽比覆盖圆形区域，短边保留足够物理像素，长边沿用同一缩放比例。
class AvatarImage extends ImageProvider<AvatarImageKey> {
  /// 原图仍交给文件或资源提供者读取，解码缩放与原图缓存身份相互独立。
  const AvatarImage(this.source, {required this.pixels}) : assert(pixels > 0);

  final ImageProvider<Object> source;
  final int pixels;

  /// 相同原图与显示像素共享框架图像缓存，不额外保留字节副本。
  @override
  Future<AvatarImageKey> obtainKey(ImageConfiguration configuration) => source
      .obtainKey(configuration)
      .then((key) => AvatarImageKey(key, pixels));

  /// 在框架解码阶段缩小图片，仍保留原提供者的资源释放和读取失败处理。
  @override
  ImageStreamCompleter loadImage(
    AvatarImageKey key,
    ImageDecoderCallback decode,
  ) {
    try {
      final completer = source.loadImage(
        key.source,
        (buffer, {getTargetSize}) => decode(
          buffer,
          getTargetSize: (width, height) {
            final shortest = width < height ? width : height;
            if (shortest <= key.pixels) {
              return ui.TargetImageSize(width: width, height: height);
            }
            final scale = key.pixels / shortest;
            return ui.TargetImageSize(
              width: (width * scale).ceil(),
              height: (height * scale).ceil(),
            );
          },
        ),
      );
      completer.addEphemeralErrorListener((error, stackTrace) {
        logger.error(
          'AvatarImage',
          '头像读取失败，使用默认头像',
          safeErrorSummary(error),
          stackTrace,
        );
        // 读取失败时缓存可能刚开始登记，下一微任务再移除本缩放身份以允许重试。
        scheduleMicrotask(() => PaintingBinding.instance.imageCache.evict(key));
      });
      return completer;
    } catch (error, stackTrace) {
      logger.error(
        'AvatarImage',
        '头像读取失败，使用默认头像',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 相同原图与像素的组件重建继续复用当前图像流。
  @override
  bool operator ==(Object other) =>
      other is AvatarImage && source == other.source && pixels == other.pixels;

  /// 组件提供者身份与解码参数保持一致。
  @override
  int get hashCode => Object.hash(source, pixels);
}

/// 框架缓存键由原图身份和目标像素组成，不持有页面或网络请求。
class AvatarImageKey {
  /// 相同尺寸的头像在多个列表位置复用同一解码结果。
  const AvatarImageKey(this.source, this.pixels);
  final Object source;
  final int pixels;

  /// 原图版本与尺寸均一致时才可共享像素。
  @override
  bool operator ==(Object other) =>
      other is AvatarImageKey &&
      source == other.source &&
      pixels == other.pixels;

  /// 散列与原图和尺寸的相等关系保持一致。
  @override
  int get hashCode => Object.hash(source, pixels);
}
