import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/logging/logger_service.dart';
import '../models/app_banner.dart';

/// 匿名内容仅从当前服务器读取，网络或素材故障返回空覆盖以使用内置入口。
class AppBannerRepository {
  /// 图片解码可注入，方便独立验证网络协议与失败回退。
  AppBannerRepository({
    required this.dio,
    Future<void> Function(Uint8List)? validateImage,
  }) : validateImage = validateImage ?? validateBannerImage;

  final Dio dio;
  final Future<void> Function(Uint8List) validateImage;
  static const _maxImageBytes = 8 * 1024 * 1024;
  static const _maxConfigBytes = 128 * 1024;
  static const _timeout = Duration(seconds: 8);
  static final _imagePath = RegExp(r'^/api/v1/banners/media/[0-9a-f]{64}$');

  /// 配置和所有有效图片一起返回，单个位置失败不会影响另一个入口。
  Future<Map<AppBannerSlot, List<ResolvedAppBanner>>> load() async {
    final result = <AppBannerSlot, List<ResolvedAppBanner>>{};
    try {
      final origin = Uri.tryParse(dio.options.baseUrl);
      if (origin == null ||
          !origin.hasAuthority ||
          origin.host.isEmpty ||
          origin.userInfo.isNotEmpty ||
          !['http', 'https'].contains(origin.scheme)) {
        return result;
      }
      final response = await _get<Object?>(
        '/api/v1/banners',
        ResponseType.json,
        _maxConfigBytes,
        queryParameters: const {'format': 'carousel'},
      );
      final body = response.data;
      if (body is! Map || body['items'] is! List) {
        throw const FormatException('BANNER_RESPONSE_INVALID');
      }
      final items = body['items'] as List;
      if (items.length > 100) {
        throw const FormatException('BANNER_RESPONSE_TOO_MANY_ITEMS');
      }
      final grouped = <AppBannerSlot, List<Map>>{};
      for (final item in items) {
        if (item is! Map) continue;
        final slot = AppBannerSlot.parse(item['slot']);
        if (slot != null) (grouped[slot] ??= []).add(item);
      }
      // 每个位置按服务端顺序逐张校验，坏图片不挤占轮播位置或产生曝光。
      await Future.wait(
        grouped.entries.map((entry) async {
          final banners = <ResolvedAppBanner>[];
          for (final item in entry.value) {
            if (entry.value
                    .where((other) => other['id'] == item['id'])
                    .length !=
                1) {
              continue;
            }
            final banner = await _resolve(entry.key, item);
            if (banner != null) banners.add(banner);
          }
          if (banners.isNotEmpty) {
            result[entry.key] = List.unmodifiable(banners);
          }
        }),
      );
    } catch (error, stackTrace) {
      logger.error(
        'AppBanner',
        '横幅配置暂不可用，继续使用内置入口',
        safeErrorSummary(error),
        stackTrace,
      );
    }
    return result;
  }

  /// 只请求固定协议路径，禁用重定向并限制接收大小与完整等待时间。
  Future<Response<T>> _get<T>(
    String path,
    ResponseType type,
    int maxBytes, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final cancel = CancelToken();
    try {
      return await dio
          .get<T>(
            path,
            cancelToken: cancel,
            queryParameters: queryParameters,
            options: Options(
              responseType: type,
              followRedirects: false,
              validateStatus: (status) => status == 200,
            ),
            onReceiveProgress: (count, total) {
              if (count > maxBytes || total > maxBytes) {
                cancel.cancel('横幅响应超过大小限制');
              }
            },
          )
          .timeout(
            _timeout,
            onTimeout: () {
              cancel.cancel('横幅请求超时');
              throw TimeoutException('BANNER_REQUEST_TIMEOUT', _timeout);
            },
          );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// 图片摘要、协议字段与完整解码全部通过后才启用对应跳转。
  Future<ResolvedAppBanner?> _resolve(AppBannerSlot slot, Map item) async {
    try {
      if (item['is_enabled'] == false) return null;
      final path = item['image_path'];
      final target = AppBannerTarget.parse(item['target']);
      final version = item['version'];
      final id = item['id'];
      final targetId = item['target_id'];
      final detail =
          target == AppBannerTarget.officialPlan ||
          target == AppBannerTarget.officialTemplate;
      if (path is! String ||
          !_imagePath.hasMatch(path) ||
          target == null ||
          version is! int ||
          version < 1 ||
          version > 2147483647 ||
          id is! String ||
          !Uuid.isValidUUID(fromString: id) ||
          (detail
              ? targetId is! String || !Uuid.isValidUUID(fromString: targetId)
              : targetId != null)) {
        throw const FormatException('BANNER_ENTRY_INVALID');
      }
      final response = await _get<List<int>>(
        path,
        ResponseType.bytes,
        _maxImageBytes,
      );
      final bytes = Uint8List.fromList(response.data ?? const []);
      if (bytes.isEmpty ||
          bytes.length > _maxImageBytes ||
          sha256.convert(bytes).toString() != path.split('/').last) {
        throw const FormatException('BANNER_IMAGE_INTEGRITY');
      }
      await validateImage(bytes);
      return ResolvedAppBanner(
        id: id,
        targetId: targetId as String?,
        bytes: bytes,
        target: target,
        version: version,
      );
    } catch (error, stackTrace) {
      logger.error(
        'AppBanner',
        '${slot.id} 横幅暂不可用，继续使用内置入口',
        safeErrorSummary(error),
        stackTrace,
      );
      return null;
    }
  }
}

/// 解码前限制像素容量，解码后立即释放资源，损坏或动画图片不能进入展示状态。
Future<void> validateBannerImage(Uint8List bytes) async {
  ui.ImmutableBuffer? buffer;
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  try {
    buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    if (descriptor.width < 1 ||
        descriptor.height < 1 ||
        descriptor.width > 8192 ||
        descriptor.height > 8192 ||
        descriptor.width * descriptor.height > 16 * 1024 * 1024) {
      throw const FormatException('BANNER_IMAGE_DIMENSIONS');
    }
    codec = await descriptor.instantiateCodec();
    if (codec.frameCount != 1) {
      throw const FormatException('BANNER_IMAGE_ANIMATED');
    }
    final frame = await codec.getNextFrame();
    frame.image.dispose();
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(error, stackTrace);
  } finally {
    codec?.dispose();
    descriptor?.dispose();
    buffer?.dispose();
  }
}
