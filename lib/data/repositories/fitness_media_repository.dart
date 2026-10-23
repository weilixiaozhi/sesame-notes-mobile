import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/logging/logger_service.dart';

/// 官方 GIF 的同源持久缓存，文件名只由受控 URL 的摘要产生。
class FitnessMediaRepository {
  /// 缓存目录可注入，测试不读取应用真实文件。
  FitnessMediaRepository({
    required this.dio,
    Future<Directory> Function()? directory,
  }) : directory = directory ?? getApplicationSupportDirectory;
  final Dio dio;
  final Future<Directory> Function() directory;
  final Map<String, Future<Uint8List?>> _inFlight = {};
  static final _path = RegExp(
    r'^/api/v1/fitness/media/(builtin-[0-9]{4}|[0-9a-f]{64})$',
  );
  static const _maxBytes = 20 * 1024 * 1024;

  /// 同一媒体并发请求共用一次下载，失败留给界面使用随包图片。
  Future<Uint8List?> load(String path) {
    // 无内容服务器时立即交给图片组件读取内置素材，不访问网络或缓存目录。
    if (dio.options.baseUrl.isEmpty || !_path.hasMatch(path)) {
      return Future.value(null);
    }
    return _inFlight.putIfAbsent(
      path,
      () => _load(path).whenComplete(() {
        _inFlight.remove(path);
      }),
    );
  }

  /// GIF 头、大小与上传内容摘要同时校验，缓存损坏时重新获取。
  bool _valid(Uint8List bytes, String path) {
    if (bytes.length < 6 || bytes.length > _maxBytes) return false;
    final signature = ascii.decode(bytes.sublist(0, 6), allowInvalid: true);
    if (signature != 'GIF87a' && signature != 'GIF89a') return false;
    final id = path.split('/').last;
    return id.startsWith('builtin-') || sha256.convert(bytes).toString() == id;
  }

  /// 禁止重定向和外部源；完整校验后原子写入，离线优先读取已有 GIF。
  Future<Uint8List?> _load(String path) async {
    File? target;
    Directory? workDirectory;
    try {
      final root = await directory();
      final cache = Directory(
        '${root.path}${Platform.pathSeparator}fitness-media',
      );
      await cache.create(recursive: true);
      final key = sha256.convert(utf8.encode('${dio.options.baseUrl}|$path'));
      target = File('${cache.path}${Platform.pathSeparator}$key.gif');
      if (await target.exists()) {
        final bytes = await target.readAsBytes();
        if (_valid(bytes, path)) return bytes;
      }
      final cancel = CancelToken();
      final response = await dio
          .get<List<int>>(
            path,
            cancelToken: cancel,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              validateStatus: (status) => status == 200,
            ),
            onReceiveProgress: (count, total) {
              if (count > _maxBytes || total > _maxBytes) {
                cancel.cancel('动作媒体超过大小限制');
              }
            },
          )
          .timeout(const Duration(seconds: 20));
      final bytes = Uint8List.fromList(response.data ?? const []);
      if (!_valid(bytes, path)) {
        throw const FormatException('FITNESS_MEDIA_INVALID');
      }
      // 每次落盘独占目录，不同仓储实例也不会共享或删除彼此的半文件。
      workDirectory = await cache.createTemp('download-');
      final temporary = File(
        '${workDirectory.path}${Platform.pathSeparator}media.gif',
      );
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(target.path);
      return bytes;
    } catch (error, stackTrace) {
      logger.error(
        'FitnessMedia',
        '官方动作图片暂不可用，继续使用内置素材',
        error is DioException ? error.type : error,
        stackTrace,
      );
      return null;
    } finally {
      final ownedDirectory = workDirectory;
      if (ownedDirectory != null) {
        try {
          if (await ownedDirectory.exists()) {
            await ownedDirectory.delete(recursive: true);
          }
        } catch (error, stackTrace) {
          logger.error(
            'FitnessMedia',
            '清理本次动作媒体临时文件失败',
            safeErrorSummary(error),
            stackTrace,
          );
        }
      }
    }
  }
}
