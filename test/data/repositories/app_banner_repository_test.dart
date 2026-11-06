import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/repositories/app_banner_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 横幅网络入口隔离凭据，配置不能指向外站或穿越资源路径。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  final bytes = Uint8List.fromList([1, 2, 3]);
  final mediaPath = '/api/v1/banners/media/${sha256.convert(bytes)}';

  /// 生成一条启用配置，测试可覆盖单个异常字段。
  Map<String, Object?> entry([Map<String, Object?> overrides = const {}]) => {
    'slot': 'fitness-plan-library',
    'id': '11111111-1111-4111-8111-111111111111',
    'target_id': null,
    'image_path': mediaPath,
    'target': 'fitness-template-library',
    'is_enabled': true,
    'version': 1,
    'updated_at': '2026-10-29T00:00:00Z',
    ...overrides,
  };

  /// 配置响应按实际 JSON 类型交给 Dio 解码。
  ResponseBody configuration(Object body) => ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );

  /// 注入受控响应和图片验证，实际请求选项仍由生产仓储生成。
  AppBannerRepository repository(
    ResponseBody Function(RequestOptions) respond,
  ) => AppBannerRepository(
    dio: Dio(BaseOptions(baseUrl: 'https://banners.example.test'))
      ..httpClientAdapter = _Adapter(respond),
    validateImage: (_) async {},
  );

  test('横幅请求不携带凭据且不跟随重定向', () async {
    try {
      final repo = repository((options) {
        expect(options.followRedirects, isFalse);
        expect(options.headers['Authorization'], isNull);
        expect(options.headers['Cookie'], isNull);
        return options.path == '/api/v1/banners'
            ? configuration({
                'items': [entry()],
              })
            : ResponseBody.fromBytes(bytes, 200);
      });
      expect(await repo.load(), isNotEmpty);
    } catch (error, stackTrace) {
      printOnFailure('安全契约验证失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('横幅拒绝外站图片、路径穿越和外部导航目标', () async {
    try {
      for (final overrides in [
        {'target': 'https://example.test'},
        {'image_path': 'https://example.test/image.png'},
        {'image_path': '/api/v1/banners/media/../secret'},
      ]) {
        final paths = <String>[];
        final repo = repository((options) {
          paths.add(options.path);
          return configuration({
            'items': [entry(overrides)],
          });
        });
        expect(await repo.load(), isEmpty);
        expect(paths, isNotEmpty);
        expect(paths, everyElement('/api/v1/banners'));
      }
    } catch (error, stackTrace) {
      printOnFailure('安全契约验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}

/// 测试适配器只返回注入响应，不连接真实服务器。
class _Adapter implements HttpClientAdapter {
  /// 每次请求交给测试明确指定的响应函数。
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  /// 把测试响应包装为 Dio 的异步传输结果。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  /// 测试适配器没有外部连接需要释放。
  @override
  void close({bool force = false}) {}
}
