import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/sync_service.dart';

/// 延迟装配处理器不能把过期服务重新绑定到第一次调用时的会话。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('请求期间会话变化，迟到的 404 不能解释为原账本已删除', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    var generation = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          generation++;
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(requestOptions: options, statusCode: 404),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );
    final service = SyncService(
      client: SesameApiClient(dio: dio),
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => 'account',
      sessionGenerationGetter: () => generation,
    );
    await expectLater(
      service.fetchLedgerRemoteStatus('11111111-1111-4111-8111-111111111111'),
      throwsStateError,
    );
  });
  test('创建后会话变化，首次调用也在任何网络访问之前失败', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    var generation = 0;
    var requests = 0;
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests++;
          handler.reject(
            DioException(requestOptions: options, error: 'test transport'),
          );
        },
      ),
    );
    final client = SesameApiClient(dio: dio);
    final oldService = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => 'account',
      sessionGenerationGetter: () => generation,
    );
    generation++;
    await expectLater(
      oldService.fetchLedgerRemoteStatus(
        '11111111-1111-4111-8111-111111111111',
      ),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          '登录会话已变化，请重新操作',
        ),
      ),
    );
    expect(requests, 0);
    final currentService = SyncService(
      client: client,
      db: db,
      deviceId: 'device',
      currentAccountIdGetter: () => 'account',
      sessionGenerationGetter: () => generation,
    );
    await expectLater(
      currentService.fetchLedgerRemoteStatus(
        '11111111-1111-4111-8111-111111111111',
      ),
      throwsA(isA<DioException>()),
    );
    expect(requests, 1, reason: '新服务允许进入受控传输，不能永久锁死同步');
  });
}
