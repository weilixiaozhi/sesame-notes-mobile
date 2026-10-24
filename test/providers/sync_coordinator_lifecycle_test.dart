import 'dart:async';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart'
    show ApplyInterceptor, QueryExecutor, QueryInterceptor, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_api_client/sesame_api_client.dart' show SesameApiClient;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/cloud_sync_run_feedback_provider.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

/// 仅替代网络同步，编排器、身份 Provider 与数据库查询均使用真实实现。
class _SyncService extends Mock implements SyncService {}

/// 挂起一次真实目录查询的返回，精确控制 finally 内的异步收尾窗口。
class _DirectoryReads extends QueryInterceptor {
  bool holdNext = false;
  final entered = Completer<void>();
  final release = Completer<void>();

  /// SQLite 已执行查询后才等待，确保取消发生在读取与状态发布之间。
  @override
  Future<List<Map<String, Object?>>> runSelect(
    QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    final rows = await executor.runSelect(statement, args);
    if (holdNext && statement.contains('sync_state')) {
      holdNext = false;
      entered.complete();
      await release.future;
    }
    return rows;
  }
}

/// 显式销毁或重建 Provider 作用域的契约，不把普通页面退出等同于全局销毁。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late _SyncService service;
  late _DirectoryReads directoryReads;
  late Completer<void> entered;
  late Completer<void> release;
  Future<Object?>? pending;

  /// 使用独立作用域模拟容器重建，数据库由测试统一释放。
  ProviderContainer createContainer() {
    final result = ProviderContainer(
      overrides: [
        // 云端生命周期依赖服务配置，实际同步请求由内存夹具替代。
        apiConfigProvider.overrideWithValue(
          const ApiConfig(baseUrl: 'https://sync.test'),
        ),
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(SesameApiClient()),
        syncServiceProvider.overrideWithValue(service),
      ],
    );
    result
        .read(authSessionProvider.notifier)
        .signIn(
          const AuthSession(
            accessToken: 'token-a',
            userId: 'account-a',
            deviceId: 'device',
          ),
        );
    return result;
  }

  /// 两种恢复入口保持各自的返回类型和失败语义。
  Future<Object> restore(String operation, SyncCoordinator coordinator) =>
      operation == 'reconnect'
      ? coordinator.reconnect()
      : coordinator.bootstrap();

  /// 只重建编排器时，其他 Provider 继续存活；完整销毁则创建全新作用域。
  void replaceScope({required bool wholeContainer}) {
    if (wholeContainer) {
      container.dispose();
      container = createContainer();
    } else {
      container.invalidate(syncCoordinatorProvider);
      container.read(syncCoordinatorProvider);
    }
  }

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    directoryReads = _DirectoryReads();
    db = SesameDatabase.withExecutor(
      NativeDatabase.memory().interceptWith(directoryReads),
    );
    await db.customSelect('SELECT 1').get();
    entered = Completer<void>();
    release = Completer<void>();
    pending = null;
    service = _SyncService();
    when(() => service.refreshCategoryConflicts()).thenAnswer((_) async {});
    when(() => service.synchronize()).thenAnswer((_) async => 0);
    when(() => service.accountingFull()).thenAnswer((_) async {});
    when(() => service.currentAccountIdGetter).thenReturn(() => 'account-a');
    when(() => service.fitnessEnabled).thenReturn(false);
    container = createContainer();
  });

  tearDown(() async {
    if (!release.isCompleted) release.complete();
    if (!directoryReads.release.isCompleted) directoryReads.release.complete();
    try {
      await pending;
    } catch (_) {
      // 主断言负责核对原始异常，清理仍须等待该请求真正结束。
    } finally {
      container.dispose();
      await db.close();
      await logger.clear();
    }
  });

  test('网络步骤结束但队列仍有原记录时，不报告同步成功', () async {
    try {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: 'subscription',
              accountId: const Value('account-a'),
              action: 'upsert',
              payload: '{"name":"订阅服务"}',
              updatedAt: DateTime.utc(2026, 10, 12),
              mutationId: 'original-category',
            ),
          );
      final result = await container.read(syncCoordinatorProvider).run();
      expect(result.ok, isFalse);
      expect(result.pendingCount, 1);
      expect(result.failure?.code, 'SYNC_PENDING_UPLOAD');
      expect(container.read(syncBusyProvider), isFalse);
      expect(
        container.read(cloudSyncRunFeedbackProvider).failure?.code,
        'SYNC_PENDING_UPLOAD',
      );
      expect(
        (await db.select(db.syncChanges).get()).single.mutationId,
        'original-category',
      );
    } catch (error, stack) {
      logger.error(
        'SyncCoordinatorTest',
        '待上传队列真实完成状态验证失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  });

  test('拒绝重试返回网络失败与具体原因，并释放忙碌状态', () async {
    try {
      when(
        () => service.retryRejectedChange('original'),
      ).thenAnswer((_) async {});
      when(() => service.synchronize()).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          type: DioExceptionType.connectionTimeout,
          error: 'PRIVATE_NETWORK_DETAIL',
        ),
      );
      final result = await container
          .read(syncCoordinatorProvider)
          .retryRejected('original');
      expect(result.ok, isFalse);
      expect(result.failure?.code, 'NETWORK_UNAVAILABLE');
      expect(result.error, isNot(contains('PRIVATE_NETWORK_DETAIL')));
      expect(container.read(syncBusyProvider), isFalse);
      expect(
        container.read(cloudSyncRunFeedbackProvider).failure?.code,
        'NETWORK_UNAVAILABLE',
      );
      verify(() => service.retryRejectedChange('original')).called(1);
      verify(() => service.synchronize()).called(1);
    } catch (error, stack) {
      logger.error(
        'SyncCoordinatorTest',
        '重试错误返回与忙碌释放验证失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  });

  for (final wholeContainer in [false, true]) {
    test(
      'refreshData在${wholeContainer ? '容器' : '编排器'}销毁后保留取消结果，不触发迟到刷新',
      () async {
        when(() => service.synchronize()).thenAnswer((_) async {
          entered.complete();
          await release.future;
          return 0;
        });
        final running = container.read(syncCoordinatorProvider).refreshData();
        pending = running;
        await entered.future;
        replaceScope(wholeContainer: wholeContainer);
        release.complete();
        final result = await running;
        expect(result.error, '同步已取消');
        expect(container.read(manualDataRefreshProvider), 0);
        expect(container.read(syncBusyProvider), isFalse);
        verify(() => service.synchronize()).called(1);
      },
    );
  }

  for (final operation in ['reconnect', 'bootstrap']) {
    for (final wholeContainer in [false, true]) {
      test(
        '$operation的${wholeContainer ? '整个作用域' : '编排器'}销毁后，释放闸门不覆盖原恢复错误',
        () async {
          final failure = StateError('原始全量下载失败');
          when(() => service.accountingFull()).thenAnswer((_) async {
            entered.complete();
            await release.future;
            throw failure;
          });
          final running = restore(
            operation,
            container.read(syncCoordinatorProvider),
          );
          pending = running;
          await entered.future;
          expect(container.read(restoreGateProvider), isTrue);
          replaceScope(wholeContainer: wholeContainer);
          release.complete();
          if (operation == 'reconnect') {
            await expectLater(running, throwsA(same(failure)));
          } else {
            final result = (await running) as SyncRunResult;
            expect(result.error, '恢复云端数据失败，请稍后重试');
          }
          expect(container.read(restoreGateProvider), isFalse);
          verifyNever(() => service.synchronize());
        },
      );
    }

    for (final boundary in [
      'coordinator',
      'container',
      'account',
      'generation',
    ]) {
      test('$operation目录收尾期间$boundary变化，旧任务不发布目录也不触发新身份补跑', () async {
        final coordinator = container.read(syncCoordinatorProvider);
        directoryReads.holdNext = true;
        final running = restore(operation, coordinator);
        pending = running;
        await directoryReads.entered.future;
        expect(container.read(restoreGateProvider), isFalse);
        if (boundary == 'coordinator' || boundary == 'container') {
          replaceScope(wholeContainer: boundary == 'container');
        } else {
          // 完整下载已退出串行队列，真实账号转换可在目录收尾等待期间执行。
          await coordinator.runAccountTransition(() async {
            container
                .read(authSessionProvider.notifier)
                .signIn(
                  AuthSession(
                    accessToken: 'replacement-token',
                    userId: boundary == 'account' ? 'account-b' : 'account-a',
                    deviceId: 'device',
                  ),
                );
          });
        }
        directoryReads.release.complete();
        await expectLater(running, completes);
        await pumpEventQueue();
        verifyNever(() => service.synchronize());
        final expected = boundary == 'coordinator'
            ? BookDirectoryStatus.loading
            : BookDirectoryStatus.unknown;
        expect(container.read(dayDirectoryStatusProvider), expected);
        expect(container.read(memoDirectoryStatusProvider), expected);
        expect(container.read(fitnessDirectoryStatusProvider), expected);
      });
    }
  }

  for (final operation in ['run', 'reconnect', 'bootstrap']) {
    test('$operation主流程失败且目录SQL读取失败，保留原结果和已就绪缓存', () async {
      final failure = DioException(
        requestOptions: RequestOptions(path: '/sync'),
        type: DioExceptionType.connectionError,
      );
      when(() => service.synchronize()).thenThrow(failure);
      when(() => service.accountingFull()).thenThrow(failure);
      container
          .read(memoDirectoryStatusProvider.notifier)
          .setStatus(BookDirectoryStatus.ready);
      // 只破坏内存库中的收尾查询表，使用真实 SQLite 错误验证 finally 异常隔离。
      await db.customStatement('DROP TABLE sync_state');
      final coordinator = container.read(syncCoordinatorProvider);
      if (operation == 'reconnect') {
        final running = coordinator.reconnect();
        pending = running;
        await expectLater(running, throwsA(same(failure)));
      } else {
        final running = operation == 'run'
            ? coordinator.run()
            : coordinator.bootstrap();
        pending = running;
        final result = await running;
        expect(
          result.error,
          operation == 'run' ? '网络连接出现问题，请之后再尝试' : '恢复云端数据失败，请稍后重试',
        );
      }
      // 普通恢复仍按原契约补跑增量，等待队列清空后再检查状态与释放数据库。
      await coordinator.run();
      expect(
        container.read(dayDirectoryStatusProvider),
        BookDirectoryStatus.failed,
      );
      expect(
        container.read(fitnessDirectoryStatusProvider),
        BookDirectoryStatus.failed,
      );
      expect(
        container.read(memoDirectoryStatusProvider),
        BookDirectoryStatus.ready,
      );
      expect(container.read(syncBusyProvider), isFalse);
      expect(logger.logs.any((entry) => entry.message == '读取云端目录状态失败'), isTrue);
    });
  }

  test('同步已经成功时目录SQL异常不翻转主结果，未确认目录仍显示失败', () async {
    await db.customStatement('DROP TABLE sync_state');
    final running = container.read(syncCoordinatorProvider).run();
    pending = running;
    final result = await running;
    expect(result.ok, isTrue);
    expect(
      container.read(dayDirectoryStatusProvider),
      BookDirectoryStatus.failed,
    );
    expect(
      container.read(memoDirectoryStatusProvider),
      BookDirectoryStatus.failed,
    );
    expect(
      container.read(fitnessDirectoryStatusProvider),
      BookDirectoryStatus.failed,
    );
    expect(container.read(syncBusyProvider), isFalse);
  });
}
