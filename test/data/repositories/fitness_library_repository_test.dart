import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/repositories/fitness_library_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// 测试夹具与正式实现使用相同的来源分区，正文和ETag不会跨服务读取。
  String cacheKey(
    String name, [
    String baseUrl = 'https://fitness.example.test',
  ]) => '${name}_${sha256.convert(utf8.encode(baseUrl))}';

  test('损坏缓存残留 ETag 时重新下载正文，意外 304 也能恢复', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    source['content_version'] = 2;
    SharedPreferences.setMockInitialValues({
      cacheKey('fitness_library_cache_v1'): '{broken',
      cacheKey('fitness_library_etag_v1'): '"fitness-library-1-2"',
    });
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _Adapter((options) {
        expect(options.headers['if-none-match'], isNull);
        if (++requests == 1) return ResponseBody.fromString('', 304);
        return ResponseBody.fromString(
          jsonEncode(source),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
    final repository = FitnessLibraryRepository(
      dio: dio,
      preferences: await SharedPreferences.getInstance(),
    );

    expect(await repository.refresh(), isTrue);
    expect(requests, 2);
    expect((await repository.loadLocal()).contentVersion, 2);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(cacheKey('fitness_library_etag_v1')), isNull);
    // 新正文没有验证令牌，下一次真实条件请求不能沿用旧缓存的 ETag。
    expect(await repository.refresh(), isFalse);
    expect(requests, 3);
  });

  test('本地快照先可用，在线内容变化后写入缓存并命中 ETag', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    source['content_version'] = 2;
    final preferences = await SharedPreferences.getInstance();
    final first = FitnessLibraryRepository(
      dio: Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
        ..httpClientAdapter = _Adapter(
          (_) => ResponseBody.fromString(
            jsonEncode(source),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
              'etag': ['"fitness-library-1-2"'],
            },
          ),
        ),
      preferences: preferences,
    );

    expect((await first.loadLocal()).contentVersion, 1);
    expect(await first.refresh(), isTrue);
    expect((await first.loadLocal()).contentVersion, 2);

    late RequestOptions conditional;
    final second = FitnessLibraryRepository(
      dio: Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
        ..httpClientAdapter = _Adapter((options) {
          conditional = options;
          return ResponseBody.fromString('', 304);
        }),
      preferences: preferences,
    );
    expect(await second.refresh(), isFalse);
    expect(conditional.headers['if-none-match'], '"fitness-library-1-2"');
    expect((await second.loadLocal()).contentVersion, 2);
  });

  test('缓存损坏与网络失败都回退内置快照且不抛错', () async {
    SharedPreferences.setMockInitialValues({
      cacheKey('fitness_library_cache_v1'): '{broken',
    });
    final repository = FitnessLibraryRepository(
      dio: Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
        ..httpClientAdapter = _Adapter(
          (_) => throw DioException(
            requestOptions: RequestOptions(path: '/api/v1/fitness/library'),
            type: DioExceptionType.connectionError,
          ),
        ),
      preferences: await SharedPreferences.getInstance(),
    );

    final local = await repository.loadLocal();
    expect(local.contentVersion, 1);
    expect(local.plans, hasLength(3));
    expect(await repository.refresh(), isFalse);
  });

  test('后台刷新与官方入口同时补齐时共用同一网络请求', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    source['content_version'] = 2;
    final response = Completer<ResponseBody>();
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _AsyncAdapter((_) {
        requests++;
        return response.future;
      });
    addTearDown(() => dio.close(force: true));
    final repository = FitnessLibraryRepository(
      dio: dio,
      preferences: await SharedPreferences.getInstance(),
    );
    final background = repository.refresh();
    final officialEntry = repository.refresh();
    expect(identical(background, officialEntry), isTrue);
    response.complete(
      ResponseBody.fromString(
        jsonEncode(source),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      ),
    );
    expect(await Future.wait([background, officialEntry]), [true, true]);
    expect(requests, 1);
    expect((await repository.loadLocal()).contentVersion, 2);
  });

  test('配置失效后的迟到响应不写正文或ETag', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    source['content_version'] = 7;
    final response = Completer<ResponseBody>();
    final requested = Completer<void>();
    var active = true;
    final dio = Dio(BaseOptions(baseUrl: 'https://fitness.example.test'))
      ..httpClientAdapter = _AsyncAdapter((_) {
        requested.complete();
        return response.future;
      });
    addTearDown(() => dio.close(force: true));
    final preferences = await SharedPreferences.getInstance();
    final repository = FitnessLibraryRepository(
      dio: dio,
      preferences: preferences,
      isCurrent: () => active,
    );
    final refreshing = repository.refresh();
    await requested.future;
    active = false;
    response.complete(
      ResponseBody.fromString(
        jsonEncode(source),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
          'etag': ['"old-source"'],
        },
      ),
    );
    expect(await refreshing, isFalse);
    expect(preferences.getString(cacheKey('fitness_library_cache_v1')), isNull);
    expect(preferences.getString(cacheKey('fitness_library_etag_v1')), isNull);
    expect((await repository.loadLocal()).contentVersion, 1);
  });

  test('各服务正文和ETag分区，未知旧缓存保留且不自动迁入任意来源', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    source['content_version'] = 99;
    final legacy = jsonEncode(source);
    SharedPreferences.setMockInitialValues({
      'fitness_library_cache_v1': legacy,
      'fitness_library_etag_v1': '"unknown-source"',
    });
    final preferences = await SharedPreferences.getInstance();
    final repositories = <FitnessLibraryRepository>[];
    for (var index = 0; index < 2; index++) {
      final baseUrl = 'https://source-$index.example.test';
      final current = Map<String, dynamic>.from(source)
        ..['content_version'] = index + 2;
      final etag = '"source-$index"';
      final dio = Dio(BaseOptions(baseUrl: baseUrl))
        ..httpClientAdapter = _Adapter((options) {
          final condition = options.headers['if-none-match'];
          expect(condition, anyOf(isNull, etag));
          return condition == etag
              ? ResponseBody.fromString('', 304)
              : ResponseBody.fromString(
                  jsonEncode(current),
                  200,
                  headers: {
                    Headers.contentTypeHeader: ['application/json'],
                    'etag': [etag],
                  },
                );
        });
      addTearDown(() => dio.close(force: true));
      final repository = FitnessLibraryRepository(
        dio: dio,
        preferences: preferences,
      );
      repositories.add(repository);
      expect((await repository.loadLocal()).contentVersion, 1);
      expect(await repository.refresh(), isTrue);
      expect(
        preferences.getString(cacheKey('fitness_library_etag_v1', baseUrl)),
        etag,
      );
    }
    expect((await repositories[0].loadLocal()).contentVersion, 2);
    expect((await repositories[1].loadLocal()).contentVersion, 3);
    expect(await repositories[0].refresh(), isFalse);
    expect(await repositories[1].refresh(), isFalse);
    expect(preferences.getString('fitness_library_cache_v1'), legacy);
    expect(
      preferences.getString('fitness_library_etag_v1'),
      '"unknown-source"',
    );
  });
}

/// 为内容库仓库测试提供可编排的 HTTP 响应。
class _Adapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions options) respond;

  _Adapter(this.respond);

  /// 返回测试指定的响应，不访问真实网络。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  /// 测试适配器没有需要释放的资源。
  @override
  void close({bool force = false}) {}
}

/// 受控异步响应覆盖后台与主动查询重叠的真实网络等待窗口。
class _AsyncAdapter implements HttpClientAdapter {
  /// 注入每次请求的受控完成信号。
  _AsyncAdapter(this.respond);
  final Future<ResponseBody> Function(RequestOptions) respond;

  /// 不访问外部服务器，等待测试提供正文。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => respond(options);

  /// 测试适配器没有需要释放的外部连接。
  @override
  void close({bool force = false}) {}
}
