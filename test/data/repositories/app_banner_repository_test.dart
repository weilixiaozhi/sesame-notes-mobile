import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/app_banner.dart';
import 'package:sesame_notes/data/repositories/app_banner_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 横幅配置、图片校验和断网回退的协议边界回归。
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

  /// 真实 HTTP 请求由可编排适配器替代，默认图片验证不依赖图形引擎。
  AppBannerRepository repository(
    ResponseBody Function(RequestOptions) respond, {
    String baseUrl = 'https://banners.example.test',
    Future<void> Function(Uint8List)? validate,
  }) => AppBannerRepository(
    dio: Dio(BaseOptions(baseUrl: baseUrl))
      ..httpClientAdapter = _Adapter(respond),
    validateImage: validate ?? (_) async {},
  );

  test('未配置或非法服务器时直接保留本地入口，不请求网络', () async {
    for (final address in ['', 'https://user:secret@example.test']) {
      var requests = 0;
      final repo = repository((_) {
        requests++;
        throw StateError('不应请求');
      }, baseUrl: address);
      expect(await repo.load(), isEmpty);
      expect(requests, 0);
    }
  });

  test('有效图片与目标一起发布，所有请求禁止重定向且不含凭据', () async {
    final calls = <String>[];
    var validated = false;
    final repo = repository(
      (options) {
        calls.add(options.path);
        if (options.path == '/api/v1/banners') {
          expect(options.queryParameters, {'format': 'carousel'});
        }
        expect(options.followRedirects, isFalse);
        expect(options.headers['Authorization'], isNull);
        expect(options.headers['Cookie'], isNull);
        return options.path == '/api/v1/banners'
            ? configuration({
                'items': [entry()],
              })
            : ResponseBody.fromBytes(bytes, 200);
      },
      validate: (value) async {
        expect(value, bytes);
        validated = true;
      },
    );
    final result = await repo.load();
    expect(validated, isTrue);
    expect(calls, ['/api/v1/banners', mediaPath]);
    expect(result[AppBannerSlot.fitnessPlanLibrary]!.single.bytes, bytes);
    expect(
      result[AppBannerSlot.fitnessPlanLibrary]!.single.target,
      AppBannerTarget.fitnessTemplateLibrary,
    );
  });

  test('同位置多张按返回顺序保留，坏图跳过，具体官方目标保留身份', () async {
    const secondId = '22222222-2222-4222-8222-222222222222';
    const thirdId = '33333333-3333-4333-8333-333333333333';
    const officialId = '44444444-4444-4444-8444-444444444444';
    final repo = repository(
      (options) => options.path == '/api/v1/banners'
          ? configuration({
              'items': [
                entry(),
                entry({'id': secondId, 'image_path': null}),
                entry({
                  'id': thirdId,
                  'target': 'official-plan',
                  'target_id': officialId,
                }),
              ],
            })
          : ResponseBody.fromBytes(bytes, 200),
    );
    final rows = (await repo.load())[AppBannerSlot.fitnessPlanLibrary]!;
    expect(rows.map((value) => value.id), [
      '11111111-1111-4111-8111-111111111111',
      thirdId,
    ]);
    expect(rows.last.target, AppBannerTarget.officialPlan);
    expect(rows.last.targetId, officialId);
  });

  test('禁用、未知目标、外站图片与缺失图片均不启用覆盖', () async {
    for (final overrides in [
      {'is_enabled': false},
      {'target': '/auth/login'},
      {'target': 'https://example.test'},
      {'image_path': 'https://example.test/image.png'},
      {'image_path': '/api/v1/banners/media/../secret'},
      {'image_path': null},
      {'version': 0},
    ]) {
      var requests = 0;
      final repo = repository((_) {
        requests++;
        return configuration({
          'items': [entry(overrides)],
        });
      });
      expect(await repo.load(), isEmpty);
      expect(requests, 1);
    }
  });

  test('图片不存在或哈希错误时同时放弃自定义目标', () async {
    for (final response in [
      ResponseBody.fromString('', 404),
      ResponseBody.fromBytes([9, 8, 7], 200),
    ]) {
      final repo = repository(
        (options) => options.path == '/api/v1/banners'
            ? configuration({
                'items': [entry()],
              })
            : response,
      );
      expect(await repo.load(), isEmpty);
    }
  });

  test('解码失败只回退对应位置，不影响另一张有效横幅', () async {
    final corrupt = Uint8List.fromList([6, 7, 8]);
    final corruptPath = '/api/v1/banners/media/${sha256.convert(corrupt)}';
    final repo = repository(
      (options) {
        if (options.path == '/api/v1/banners') {
          return configuration({
            'items': [
              entry({'image_path': corruptPath}),
              entry({
                'slot': 'fitness-template-library',
                'target': 'fitness-exercises',
              }),
            ],
          });
        }
        return ResponseBody.fromBytes(
          options.path == corruptPath ? corrupt : bytes,
          200,
        );
      },
      validate: (value) async {
        if (value.first == 6) throw const FormatException('损坏图片');
      },
    );
    final result = await repo.load();
    expect(result.containsKey(AppBannerSlot.fitnessPlanLibrary), isFalse);
    expect(
      result[AppBannerSlot.fitnessTemplateLibrary]!.single.target,
      AppBannerTarget.fitnessExercises,
    );
  });

  test('空配置、重复位置、损坏正文与离线都恢复内置入口', () async {
    for (final body in [
      {'items': []},
      {
        'items': [entry(), entry()],
      },
      {'items': 'invalid'},
      ['invalid'],
    ]) {
      expect(await repository((_) => configuration(body)).load(), isEmpty);
    }
    expect(
      await repository(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      ).load(),
      isEmpty,
    );
  });

  test('真实图片可以完整解码，损坏字节被拒绝', () async {
    final source = await File(
      'assets/fitness/plan-library-banner.png',
    ).readAsBytes();
    await validateBannerImage(source);
    await expectLater(validateBannerImage(bytes), throwsA(anything));
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
