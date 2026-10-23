import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/repositories/fitness_library_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('损坏缓存残留 ETag 时重新下载正文，意外 304 也能恢复', () async {
    final source =
        jsonDecode(await File('assets/fitness/library.json').readAsString())
            as Map<String, dynamic>;
    source['content_version'] = 2;
    SharedPreferences.setMockInitialValues({
      'fitness_library_cache_v1': '{broken',
      'fitness_library_etag_v1': '"fitness-library-1-2"',
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
    expect(preferences.getString('fitness_library_etag_v1'), isNull);
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
      'fitness_library_cache_v1': '{broken',
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
