import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import '../../../../core/logging/logger_service.dart';
import '../../application/fitness_media_queries.dart';

/// 在线动画与首帧各自拥有缓存键，失败时读取同一个动作的内置 GIF。
class FitnessOfficialImage extends ImageProvider<FitnessOfficialImage> {
  /// 媒体 URL 为服务端受控相对路径，fallbackAsset 仅来自官方目录。
  const FitnessOfficialImage({
    required this.queries,
    required this.mediaUrl,
    required this.fallbackAsset,
    required this.animated,
  });
  final FitnessMediaQueries queries;
  final String mediaUrl;
  final String fallbackAsset;
  final bool animated;

  /// 图片身份不随组件重绘变化。
  @override
  Future<FitnessOfficialImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  /// 静态列表只解码第一帧，训练详情才使用动画解码器。
  @override
  ImageStreamCompleter loadImage(
    FitnessOfficialImage key,
    ImageDecoderCallback decode,
  ) => animated
      ? MultiFrameImageStreamCompleter(codec: _codec(), scale: 1)
      : OneFrameImageStreamCompleter(_firstFrame());

  /// 网络和缓存失败时回退已打包资源；新动作无资源时交给页面占位与重试。
  Future<ui.Codec> _codec() async {
    final bytes = await queries.load(mediaUrl);
    if (bytes != null) {
      try {
        return await ui.instantiateImageCodec(bytes);
      } catch (error, stackTrace) {
        logger.error(
          'FitnessOfficialImage',
          '在线动作动画解码失败，使用内置素材',
          error,
          stackTrace,
        );
      }
    }
    try {
      if (!RegExp(
        r'^assets/fitness/videos/[0-9]{4}-[A-Za-z0-9_-]+\.gif$',
      ).hasMatch(fallbackAsset)) {
        throw StateError('动作素材暂不可用');
      }
      final asset = await rootBundle.load(fallbackAsset);
      return await ui.instantiateImageCodec(
        asset.buffer.asUint8List(asset.offsetInBytes, asset.lengthInBytes),
      );
    } catch (error, stackTrace) {
      logger.error('FitnessOfficialImage', '动作素材暂不可用，请稍后重试', error, stackTrace);
      rethrow;
    }
  }

  /// 首帧解码结束立即释放编解码器。
  Future<ImageInfo> _firstFrame() async {
    ui.Codec? codec;
    try {
      codec = await _codec();
      return ImageInfo(image: (await codec.getNextFrame()).image);
    } finally {
      codec?.dispose();
    }
  }

  /// URL 和播放模式共同决定框架图像缓存身份。
  @override
  bool operator ==(Object other) =>
      other is FitnessOfficialImage &&
      other.queries == queries &&
      other.mediaUrl == mediaUrl &&
      other.fallbackAsset == fallbackAsset &&
      other.animated == animated;

  /// 与相等判断一致的缓存散列。
  @override
  int get hashCode => Object.hash(queries, mediaUrl, fallbackAsset, animated);
}
