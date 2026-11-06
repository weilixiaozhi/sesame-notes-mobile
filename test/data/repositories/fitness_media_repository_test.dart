import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/fitness_media_repository.dart';
import 'package:sesame_notes/data/repositories/support/fitness_media_cache.dart';
import 'package:sesame_notes/features/fitness/application/fitness_media_queries.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_official_image.dart';

import '../../helpers/test_isolation.dart';

/// 媒体超时必须停止实际传输，容量策略不能删除唯一的离线图片。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  final bytes = Uint8List.fromList([...ascii.encode('GIF89a'), 1, 2]);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await logger.clear();
    root = await createTestTempDirectory('fitness-media-cache-');
  });
  tearDown(() async {
    await logger.clear();
    await root.delete(recursive: true);
  });

  /// 缓存测试只授权显式给出的可替代身份，未知文件默认受保护。
  FitnessMediaCache cache({
    int limit = 16,
    Set<String> replaceable = const {},
  }) => FitnessMediaCache(
    directory: () async => root,
    maxBytes: limit,
    reclaimableKeys: () async => replaceable,
    verifyReclaimable: (key, file) async => replaceable.contains(key),
  );

  /// 生成合法摘要文件身份，避免测试绕过正式的路径边界。
  String key(String value) => sha256.convert(utf8.encode(value)).toString();

  /// 直接读取本次独占缓存夹具，断言磁盘内容没有被回收或覆盖。
  File file(String identity) =>
      File('${root.path}${Platform.pathSeparator}$identity.gif');

  test('达到预算时不落新文件，保留已有唯一离线图片并记录拒写次数', () async {
    final first = key('unique');
    final second = key('new');
    final store = cache(limit: bytes.length);
    expect(await store.write(first, bytes), isTrue);
    expect(await store.write(second, bytes), isFalse);
    expect(await file(first).readAsBytes(), bytes);
    expect(await file(second).exists(), isFalse);
    expect(
      logger.logs.any(
        (entry) =>
            entry.tag == 'FitnessMediaCache' &&
            entry.message.contains('rejected_writes: 1'),
      ),
      isTrue,
    );
  });

  test('跨仓储实例的并发写入共用容量检查，不能同时越过预算', () async {
    final results = await Future.wait([
      cache(limit: bytes.length).write(key('a'), bytes),
      cache(limit: bytes.length).write(key('b'), bytes),
    ]);
    expect(results.where((saved) => saved), hasLength(1));
    final files = await root
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    expect(files, hasLength(1));
    expect(await files.single.length(), bytes.length);
  });

  test('只回收有可靠随包替身的旧副本，读取中的独立字节和唯一媒体保留', () async {
    final safe = key('builtin');
    final unique = key('uploaded');
    final next = key('next');
    final store = cache(replaceable: {safe});
    expect(await store.write(safe, bytes), isTrue);
    expect(await store.write(unique, bytes), isTrue);
    final decodedInput = await store.read(
      safe,
      maxFileBytes: 20,
      valid: (_) => true,
    );
    expect(await store.write(next, bytes), isTrue);
    expect(await file(safe).exists(), isFalse);
    expect(decodedInput, bytes);
    expect(await file(unique).readAsBytes(), bytes);
    expect(await file(next).readAsBytes(), bytes);
  });

  test('旧缓存已超限时保持可读且不继续增长，未知文件和目录不删除', () async {
    final unique = key('legacy');
    await file(unique).writeAsBytes(bytes);
    final unknown = File('${root.path}${Platform.pathSeparator}old-format.bin');
    await unknown.writeAsBytes(bytes);
    final store = cache(limit: 4);
    expect(
      await store.read(unique, maxFileBytes: 20, valid: (_) => true),
      bytes,
    );
    expect(await store.write(key('new'), bytes), isFalse);
    expect(await unknown.readAsBytes(), bytes);
    final unsafe = Directory(file(key('directory')).path);
    await unsafe.create();
    expect(await store.write(key('directory'), bytes), isFalse);
    expect(await unsafe.exists(), isTrue);
  });

  test('媒体逻辑超时取消传输并释放单飞任务，下一次重试可以成功', () async {
    final cancelled = Completer<void>();
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _Adapter((options, cancel) {
        requests++;
        if (requests == 1) {
          cancel?.then((_) {
            if (!cancelled.isCompleted) cancelled.complete();
          });
          return Completer<ResponseBody>().future;
        }
        return Future.value(ResponseBody.fromBytes(bytes, 200));
      });
    addTearDown(() => dio.close(force: true));
    final repository = FitnessMediaRepository(
      dio: dio,
      directory: () async => root,
      requestTimeout: const Duration(milliseconds: 40),
    );
    final path = '/api/v1/fitness/media/${sha256.convert(bytes)}';
    final first = repository.load(path);
    expect(identical(first, repository.load(path)), isTrue);
    expect(await first, isNull);
    await cancelled.future.timeout(const Duration(seconds: 1));
    expect(await repository.load(path), bytes);
    expect(requests, 2);
    expect(await repository.load(path), bytes);
    expect(requests, 2);
  });

  test('不同媒体的并发读取有上限，相同排队媒体共用结果且失败后继续排队任务', () async {
    final admitted = Completer<void>();
    final release = Completer<void>();
    var requests = 0;
    var active = 0;
    var peak = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _Adapter((options, _) async {
        requests++;
        active++;
        if (active > peak) peak = active;
        if (requests == 2) admitted.complete();
        try {
          await release.future;
          if (options.path.endsWith('0000')) {
            throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            );
          }
          return ResponseBody.fromBytes(bytes, 200);
        } finally {
          active--;
        }
      });
    final repository = FitnessMediaRepository(
      dio: dio,
      directory: () async => root,
      maxConcurrentLoads: 2,
    );
    try {
      final loads = [
        for (var index = 0; index < 6; index++)
          repository.load(
            '/api/v1/fitness/media/builtin-${index.toString().padLeft(4, '0')}',
          ),
      ];
      expect(
        identical(
          loads.last,
          repository.load('/api/v1/fitness/media/builtin-0005'),
        ),
        isTrue,
      );
      await admitted.future.timeout(const Duration(seconds: 3));
      expect(requests, 2);
      release.complete();
      final results = await Future.wait(
        loads,
      ).timeout(const Duration(seconds: 3));
      expect(results.first, isNull);
      expect(results.skip(1), everyElement(bytes));
      expect(requests, 6);
      expect(peak, 2);
    } catch (error, stack) {
      stderr.writeln('媒体并发检查失败：$error\n$stack');
      rethrow;
    } finally {
      if (!release.isCompleted) release.complete();
      repository.dispose();
      dio.close(force: true);
    }
  });

  test('媒体所有者释放时取消在途传输并完成排队结果，不再发起后续请求', () async {
    final admitted = Completer<void>();
    final cancelled = Completer<void>();
    var requests = 0;
    var cancellations = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _Adapter((options, cancellation) async {
        if (options.path == '/health') {
          return ResponseBody.fromString('ok', 200);
        }
        requests++;
        if (requests == 2) admitted.complete();
        await cancellation;
        cancellations++;
        if (cancellations == 2) cancelled.complete();
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
        );
      });
    final repository = FitnessMediaRepository(
      dio: dio,
      directory: () async => root,
      maxConcurrentLoads: 2,
    );
    try {
      final loads = [
        for (var index = 0; index < 6; index++)
          repository.load(
            '/api/v1/fitness/media/builtin-${index.toString().padLeft(4, '0')}',
          ),
      ];
      await admitted.future.timeout(const Duration(seconds: 3));
      repository.dispose();
      expect(
        await Future.wait(loads).timeout(const Duration(seconds: 1)),
        everyElement(isNull),
      );
      await cancelled.future.timeout(const Duration(seconds: 1));
      expect(
        await repository.load('/api/v1/fitness/media/builtin-0007'),
        isNull,
      );
      expect(requests, 2);
      expect((await dio.get<String>('/health')).data, 'ok');
    } catch (error, stack) {
      stderr.writeln('媒体资源释放检查失败：$error\n$stack');
      rethrow;
    } finally {
      repository.dispose();
      dio.close(force: true);
    }
  });

  test('媒体落盘完成前继续占用并发额度', () async {
    final writing = Completer<void>();
    final releaseDisk = Completer<void>();
    var directoryReads = 0;
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _Adapter((options, _) async {
        requests++;
        return ResponseBody.fromBytes(bytes, 200);
      });
    final repository = FitnessMediaRepository(
      dio: dio,
      maxConcurrentLoads: 1,
      directory: () async {
        directoryReads++;
        if (directoryReads == 2) {
          writing.complete();
          await releaseDisk.future;
        }
        return root;
      },
    );
    try {
      final first = repository.load('/api/v1/fitness/media/builtin-0000');
      final second = repository.load('/api/v1/fitness/media/builtin-0001');
      await writing.future.timeout(const Duration(seconds: 3));
      expect(requests, 1, reason: '首张图片仍在等待落盘，后续读取不能分配完整图片缓冲');
      releaseDisk.complete();
      expect(await Future.wait([first, second]), everyElement(bytes));
      expect(requests, 2);
    } catch (error, stack) {
      stderr.writeln('媒体落盘额度检查失败：$error\n$stack');
      rethrow;
    } finally {
      if (!releaseDisk.isCompleted) releaseDisk.complete();
      repository.dispose();
      dio.close(force: true);
    }
  });

  test('媒体超时归还额度并启动已排队图片', () async {
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _Adapter((options, cancellation) async {
        requests++;
        if (options.path.endsWith('0000')) {
          await cancellation;
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
          );
        }
        return ResponseBody.fromBytes(bytes, 200);
      });
    final repository = FitnessMediaRepository(
      dio: dio,
      maxConcurrentLoads: 1,
      requestTimeout: const Duration(milliseconds: 40),
      directory: () async => root,
    );
    try {
      final results = await Future.wait([
        repository.load('/api/v1/fitness/media/builtin-0000'),
        repository.load('/api/v1/fitness/media/builtin-0001'),
      ]).timeout(const Duration(seconds: 3));
      expect(results, [null, bytes]);
      expect(requests, 2);
    } catch (error, stack) {
      stderr.writeln('媒体超时额度检查失败：$error\n$stack');
      rethrow;
    } finally {
      repository.dispose();
      dio.close(force: true);
    }
  });

  test('空间已满仍返回新网络图片，原有媒体在离线时继续可读', () async {
    var offline = false;
    final source = 'https://fitness.example.test';
    final dio = Dio(BaseOptions(baseUrl: source))
      ..httpClientAdapter = _Adapter((options, _) async {
        if (offline) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return ResponseBody.fromBytes(bytes, 200);
      });
    addTearDown(() => dio.close(force: true));
    final oldPath = '/api/v1/fitness/media/builtin-0025';
    final folder = Directory(
      '${root.path}${Platform.pathSeparator}fitness-media',
    );
    await folder.create();
    final old = File(
      '${folder.path}${Platform.pathSeparator}${key('$source|$oldPath')}.gif',
    );
    await old.writeAsBytes(bytes);
    final repository = FitnessMediaRepository(
      dio: dio,
      directory: () async => root,
      assetBundle: _BuiltinBundle(false),
      cacheLimitBytes: bytes.length,
    );
    final newPath = '/api/v1/fitness/media/${sha256.convert(bytes)}';
    expect(await repository.load(newPath), bytes);
    expect(await old.exists(), isTrue);
    offline = true;
    expect(await repository.load(oldPath), bytes);
    expect(await repository.load(newPath), isNull);
  });

  test('只有目录身份与实际打包资源同时证明存在时才回收builtin副本', () async {
    const source = 'https://fitness.example.test';
    final dio = Dio(BaseOptions(baseUrl: source))
      ..httpClientAdapter = _Adapter(
        (_, _) async => ResponseBody.fromBytes(bytes, 200),
      );
    addTearDown(() => dio.close(force: true));
    const oldPath = '/api/v1/fitness/media/builtin-0025';
    final folder = Directory(
      '${root.path}${Platform.pathSeparator}fitness-media',
    );
    await folder.create();
    final old = File(
      '${folder.path}${Platform.pathSeparator}${key('$source|$oldPath')}.gif',
    );
    await old.writeAsBytes(bytes);
    final repository = FitnessMediaRepository(
      dio: dio,
      directory: () async => root,
      assetBundle: _BuiltinBundle(true),
      cacheLimitBytes: bytes.length,
    );
    expect(
      await repository.load('/api/v1/fitness/media/${sha256.convert(bytes)}'),
      bytes,
    );
    expect(await old.exists(), isFalse);
    expect(await folder.list().where((entity) => entity is File).length, 1);
  });

  test('builtin缓存与当前随包字节不同也保留，不能用同名素材替代历史图片', () async {
    const source = 'https://fitness.example.test';
    final dio = Dio(BaseOptions(baseUrl: source))
      ..httpClientAdapter = _Adapter(
        (_, _) async => ResponseBody.fromBytes(bytes, 200),
      );
    addTearDown(() => dio.close(force: true));
    const path = '/api/v1/fitness/media/builtin-0025';
    final folder = Directory(
      '${root.path}${Platform.pathSeparator}fitness-media',
    );
    await folder.create();
    final historical = Uint8List.fromList([...ascii.encode('GIF89a'), 9, 9]);
    final old = File(
      '${folder.path}${Platform.pathSeparator}${key('$source|$path')}.gif',
    );
    await old.writeAsBytes(historical);
    final repository = FitnessMediaRepository(
      dio: dio,
      directory: () async => root,
      assetBundle: _BuiltinBundle(true),
      cacheLimitBytes: bytes.length,
    );
    expect(
      await repository.load('/api/v1/fitness/media/${sha256.convert(bytes)}'),
      bytes,
    );
    expect(await old.readAsBytes(), historical);
    expect(await folder.list().where((entity) => entity is File).length, 1);
  });
  test('真实GIF副本回收后断网，正式图片Provider仍从随包素材解码同一图片', () async {
    final gif = base64Decode(
      'R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7',
    );
    const source = 'https://fitness.example.test';
    var offline = false;
    var fallbackLoads = 0;
    final dio = Dio(BaseOptions(baseUrl: source))
      ..httpClientAdapter = _Adapter((options, _) async {
        if (offline) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return ResponseBody.fromBytes(gif, 200);
      });
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final data = message!;
      final path = utf8.decode(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      if (path != _BuiltinBundle.asset) return null;
      fallbackLoads++;
      return ByteData.sublistView(gif);
    });
    FitnessOfficialImage? provider;
    ImageStream? stream;
    ImageStreamListener? listener;
    ImageInfo? decoded;
    try {
      const builtin = '/api/v1/fitness/media/builtin-0025';
      final folder = Directory(
        '${root.path}${Platform.pathSeparator}fitness-media',
      );
      await folder.create();
      final previous = File(
        '${folder.path}${Platform.pathSeparator}${key('$source|$builtin')}.gif',
      );
      await previous.writeAsBytes(gif);
      final repository = FitnessMediaRepository(
        dio: dio,
        directory: () async => root,
        assetBundle: _BuiltinBundle(true, mediaBytes: gif),
        cacheLimitBytes: gif.length,
      );
      expect(
        await repository.load('/api/v1/fitness/media/${sha256.convert(gif)}'),
        gif,
      );
      expect(await previous.exists(), isFalse, reason: '本轮容量回收确实删除了重复缓存');
      offline = true;
      provider = FitnessOfficialImage(
        queries: FitnessMediaQueries(repository),
        mediaUrl: builtin,
        fallbackAsset: _BuiltinBundle.asset,
        animated: false,
      );
      final completed = Completer<ImageInfo>();
      stream = provider.resolve(ImageConfiguration.empty);
      listener = ImageStreamListener(
        (image, _) {
          if (!completed.isCompleted) completed.complete(image.clone());
        },
        onError: (Object error, StackTrace? stack) {
          if (!completed.isCompleted) {
            completed.completeError(error, stack ?? StackTrace.current);
          }
        },
      );
      stream.addListener(listener);
      decoded = await completed.future.timeout(const Duration(seconds: 3));
      expect(decoded.image.width, 1);
      expect(decoded.image.height, 1);
      expect(fallbackLoads, 1);
    } finally {
      if (listener != null) stream?.removeListener(listener);
      decoded?.dispose();
      await provider?.evict();
      messenger.setMockMessageHandler('flutter/assets', null);
      dio.close(force: true);
    }
  });
}

/// 测试网络只消费预设响应并允许观测实际取消信号，不连接外部服务器。
class _Adapter implements HttpClientAdapter {
  /// 为每次请求注入响应及取消观察器。
  _Adapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions, Future<void>?) respond;

  /// 返回测试控制的异步响应，保留Dio真实的令牌取消链。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => respond(options, cancelFuture);

  /// 测试适配器没有系统连接需要释放。
  @override
  void close({bool force = false}) {}
}

/// 目录中声明的builtin图片可独立模拟已打包或缺失，验证回收证明不能只看字符串。
class _BuiltinBundle extends CachingAssetBundle {
  /// 指定目标GIF是否真实存在于构建资源清单。
  _BuiltinBundle(this.available, {this.mediaBytes});
  final bool available;
  final Uint8List? mediaBytes;
  static const asset = 'assets/fitness/videos/0025-example.gif';

  /// 返回受控目录内容，避免访问仓库资源或设备数据。
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      jsonEncode({
        'exercises': [
          {'id': '0025', 'gif_asset': asset},
        ],
      });

  /// 提供Flutter实际使用的二进制资源清单。
  @override
  Future<ByteData> load(String key) async {
    if (key == asset && available) {
      return ByteData.sublistView(
        mediaBytes ?? Uint8List.fromList([...ascii.encode('GIF89a'), 1, 2]),
      );
    }
    return const StandardMessageCodec().encodeMessage(
      available ? {asset: <Object?>[]} : <String, Object?>{},
    )!;
  }
}
