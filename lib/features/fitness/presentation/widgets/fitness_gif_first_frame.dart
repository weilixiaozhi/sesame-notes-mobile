import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 内置动作 GIF 的首帧缓存，与播放动画的资源缓存独立。
class FitnessGifFirstFrame extends ImageProvider<FitnessGifFirstFrame> {
  /// 使用资源路径和资源包确定首帧缓存身份。
  const FitnessGifFirstFrame(this.asset, {this.bundle});

  final String asset;
  final AssetBundle? bundle;

  /// 使用当前组件的资源包，使测试及应用资源替换遵循相同规则。
  @override
  Future<FitnessGifFirstFrame> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(
        FitnessGifFirstFrame(
          asset,
          bundle: bundle ?? configuration.bundle ?? rootBundle,
        ),
      );

  /// 单帧流只交付首帧，不创建动画调度或解码后续帧。
  @override
  ImageStreamCompleter loadImage(
    FitnessGifFirstFrame key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(key._loadFirstFrame());

  /// 解码后立即释放编解码器，图像生命周期交由框架缓存管理。
  Future<ImageInfo> _loadFirstFrame() async {
    ui.Codec? codec;
    try {
      final bytes = await bundle!.load(asset);
      codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      final frame = await codec.getNextFrame();
      return ImageInfo(image: frame.image);
    } catch (error, stackTrace) {
      logger.error(
        'FitnessGifFirstFrame',
        '动作首帧加载失败：$asset',
        error,
        stackTrace,
      );
      rethrow;
    } finally {
      codec?.dispose();
    }
  }

  /// 同一资源包内的相同动作复用静态帧。
  @override
  bool operator ==(Object other) =>
      other is FitnessGifFirstFrame &&
      other.asset == asset &&
      other.bundle == bundle;

  /// 为框架图像缓存生成与相等性一致的键。
  @override
  int get hashCode => Object.hash(asset, bundle);
}
