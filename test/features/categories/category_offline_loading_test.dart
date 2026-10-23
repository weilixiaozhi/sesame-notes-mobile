import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' as db;
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/categories/application/category_picker_providers.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../../helpers/test_isolation.dart';

class _RemoteSync extends Mock implements SyncService {}

class _PullApi extends Mock implements SyncApi {}

/// 真实 Dio 请求保持在途，测试显式释放；分类操作不得加入任何额外请求。
class _PendingAdapter implements HttpClientAdapter {
  final entered = Completer<void>();
  final response = Completer<ResponseBody>();
  int requests = 0;

  /// 延迟远端响应而不持有本地数据库事务，模拟弱网未完成的一轮后台同步。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    try {
      requests++;
      if (!entered.isCompleted) entered.complete();
      return await response.future;
    } catch (error, stack) {
      logger.error('CategoryOfflineTest', '模拟在途同步失败', error, stack);
      rethrow;
    }
  }

  /// 用例结束时完成同一请求，禁止遗留后台任务污染后续用例。
  void release() {
    if (!response.isCompleted) {
      response.complete(ResponseBody.fromString('{}', 200));
    }
  }

  @override
  void close({bool force = false}) => release();
}

/// 分类查询与本机仓储不依赖后台网络回执；账号及同步协调器使用正式实现。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const account = 'category-account';
  late db.SesameDatabase database;
  late LocalRepository repository;
  late ProviderContainer container;
  late SesameApiClient client;
  late _PendingAdapter adapter;
  late String ledgerId;
  late String categoryId;
  late _RemoteSync remote;
  Future<SyncRunResult>? running;

  setUp(() async {
    resetGlobalTestState();
    running = null;
    database = db.SesameDatabase.withExecutor(NativeDatabase.memory());
    adapter = _PendingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://test.local'));
    dio.httpClientAdapter = adapter;
    client = SesameApiClient(dio: dio);
    remote = _RemoteSync();
    when(() => remote.client).thenReturn(client);
    when(() => remote.fitnessEnabled).thenReturn(false);
    when(() => remote.currentAccountIdGetter).thenReturn(() => account);
    when(() => remote.synchronize()).thenAnswer((_) async {
      await client.dio.get<Object>('/pending-background-sync');
      return 0;
    });
    when(() => remote.refreshCategoryConflicts()).thenAnswer((_) async {});
    repository = LocalRepository(
      database,
      accountIdGetter: () => account,
      changeTracker: ChangeRecorderImpl(
        database,
        accountIdGetter: () => account,
      ),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(database),
        repositoryProvider.overrideWithValue(repository),
        apiClientProvider.overrideWithValue(client),
        syncServiceProvider.overrideWithValue(remote),
        // 测试平台没有移动端网络通道，只替换系统接口事实，保留真实 Dio 请求。
        cloudNetworkEventsProvider.overrideWithValue(
          const Stream<bool>.empty(),
        ),
      ],
    );
    container
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'fixture',
            userId: account,
            deviceId: 'device',
          ),
        );
    ledgerId = await repository.createLedger(
      name: '本机可用账本',
      storageMode: 'cloud',
    );
    categoryId = await repository.createCategory(name: '本机餐饮', kind: 'expense');
    container.read(currentLedgerIdProvider.notifier).set(ledgerId);
  });

  tearDown(() async {
    adapter.release();
    await running;
    client.dio.close(force: true);
    container.dispose();
    await database.close();
  });

  /// 开始正式后台轮次，只有其 Dio 请求被延迟，分类仍读取同一数据库。
  Future<void> beginPendingSync() async {
    try {
      running = container.read(syncCoordinatorProvider).run();
      await adapter.entered.future.timeout(const Duration(seconds: 2));
    } catch (error, stack) {
      logger.error('CategoryOfflineTest', '启动在途同步失败', error, stack);
      rethrow;
    }
  }

  test('离线分类读取、固定账本选择与保存只提交本机，无Dio调用', () async {
    try {
      final actions = container.read(categoryActionsProvider);
      expect((await actions.getById(categoryId))!.name, '本机餐饮');
      final tree = await readProviderFutureFromContainer(
        container,
        categoryPickerTreeForLedgerProvider((
          ledgerId: ledgerId,
          type: 'expense',
        )).future,
      );
      expect(tree.topLevel.map((row) => row.id), contains(categoryId));
      final created = await actions.create(name: '离线新分类', kind: 'expense');
      await actions.update(created, name: '离线已保存分类');
      expect((await actions.getById(created))!.name, '离线已保存分类');
      expect(adapter.requests, 0);
    } catch (error, stack) {
      logger.error('CategoryOfflineTest', '离线分类本机读写验证失败', error, stack);
      rethrow;
    }
  });

  test('后台Dio悬挂时，分类读取、选择与本机保存均无需等待远端回执', () async {
    try {
      await beginPendingSync();
      final actions = container.read(categoryActionsProvider);
      expect((await actions.getById(categoryId))!.name, '本机餐饮');
      expect(
        await actions.isNameDuplicate(name: '新餐饮', kind: 'expense'),
        isFalse,
      );
      final tree = await readProviderFutureFromContainer(
        container,
        categoryPickerTreeForLedgerProvider((
          ledgerId: ledgerId,
          type: 'expense',
        )).future,
      ).timeout(const Duration(seconds: 2));
      expect(tree.topLevel.map((row) => row.id), contains(categoryId));
      await actions
          .update(categoryId, name: '在途同步期间本机保存')
          .timeout(const Duration(seconds: 2));
      expect((await actions.getById(categoryId))!.name, '在途同步期间本机保存');
      expect(adapter.response.isCompleted, isFalse);
      expect(adapter.requests, 1);
    } catch (error, stack) {
      logger.error('CategoryOfflineTest', '在途同步期间分类读写验证失败', error, stack);
      rethrow;
    }
  });

  test('迟到的真实分类增量不得覆盖在途期间本地保存的正文、身份及待上传意图', () async {
    try {
      final pullApi = _PullApi();
      final cloudTime = DateTime.now().toUtc().add(const Duration(hours: 1));
      final delta = standardSerializers.deserializeWith(
        GetSyncPull200Response.serializer,
        {
          'changes': [
            {
              'change_id': '1',
              'entity_type': 'category',
              'entity_id': categoryId,
              'ledger_id': null,
              'action': 'upsert',
              'mutation_id': 'remote-category-change',
              'device_id': 'another-device',
              'updated_at': cloudTime.toIso8601String(),
              'payload': {
                'id': categoryId,
                'owner_id': account,
                'name': '远端仍持有的分类正文',
                'kind': 'expense',
                'level': '1',
                'sort_order': 0,
                'icon': null,
                'parent_id': null,
                'updated_at': cloudTime.toIso8601String(),
                'deleted_at': null,
                'version_token': 'a' * 64,
              },
            },
          ],
          'server_cursor': '1',
          'has_more': false,
        },
      )!;
      when(() => pullApi.getSyncPull(since: any(named: 'since'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/sync/pull'),
          data: delta,
        ),
      );
      final projection = SyncService(
        client: client,
        db: database,
        deviceId: 'device',
        apiOverride: pullApi,
        currentAccountIdGetter: () => account,
      );
      when(() => remote.synchronize()).thenAnswer((_) async {
        await client.dio.get<Object>('/pending-background-sync');
        return projection.pull();
      });
      await beginPendingSync();
      final actions = container.read(categoryActionsProvider);
      await actions
          .update(categoryId, name: '弱网期间已保存的新分类')
          .timeout(const Duration(seconds: 2));
      final localBefore = await repository.categoryStore.getCategoryById(
        categoryId,
      );
      final pendingBefore =
          await (database.select(database.syncChanges)..where(
                (row) =>
                    row.entityType.equals('category') &
                    row.entityId.equals(categoryId) &
                    row.accountId.equals(account) &
                    row.pushedAt.isNull(),
              ))
              .get();
      adapter.release();
      await running!.timeout(const Duration(seconds: 2));
      final localAfter = await repository.categoryStore.getCategoryById(
        categoryId,
      );
      expect(localAfter!.id, categoryId);
      expect(localAfter.name, localBefore!.name);
      expect(localAfter.serverVersionToken, localBefore.serverVersionToken);
      expect(
        await (database.select(database.syncChanges)..where(
              (row) =>
                  row.entityType.equals('category') &
                  row.entityId.equals(categoryId) &
                  row.accountId.equals(account) &
                  row.pushedAt.isNull(),
            ))
            .get(),
        pendingBefore,
      );
      verify(() => pullApi.getSyncPull(since: any(named: 'since'))).called(1);
      expect(adapter.requests, 1);
    } catch (error, stack) {
      logger.error('CategoryOfflineTest', '迟到分类增量保留本地意图验证失败', error, stack);
      rethrow;
    }
  });
}
