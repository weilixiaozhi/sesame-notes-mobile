import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import 'package:sesame_notes/shared/providers/refresh_ticks.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 记录队列结果行数和列名，验证状态查询不传输完整正文。
class _StatusReads extends d.QueryInterceptor {
  final queueResults = <List<Map<String, Object?>>>[];

  /// 业务状态读到的内容必须是计数，队列写入和建表不参与统计。
  @override
  Future<List<Map<String, Object?>>> runSelect(
    d.QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final rows = await executor.runSelect(statement, args);
      if (RegExp(
        r'FROM\s+"?sync_changes"?\b',
        caseSensitive: false,
      ).hasMatch(statement)) {
        queueResults.add(rows);
      }
      return rows;
    } catch (error, stackTrace) {
      logger.error('PrivateSyncStatusTest', '队列读取计数失败', error, stackTrace);
      rethrow;
    }
  }
}

/// 验证同步状态按业务隔离失效，计数仍包含拒收和无可见父本的保护记录。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  late _StatusReads reads;
  final stamp = DateTime.utc(2026);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    reads = _StatusReads();
    db = SesameDatabase.withExecutor(
      d.ApplyInterceptor(NativeDatabase.memory()).interceptWith(reads),
    );
    await db
        .into(db.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: 'day',
            name: '日子',
            createdAt: stamp,
            updatedAt: stamp,
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account'),
            serverRevision: const d.Value(0),
          ),
        );
    await db
        .into(db.fitnessSpaces)
        .insert(
          FitnessSpacesCompanion.insert(
            id: 'fitness',
            name: '训练',
            createdAt: stamp,
            updatedAt: stamp,
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value('account'),
            serverRevision: const d.Value(0),
          ),
        );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue('account'),
        currentFitnessSpaceIdProvider.overrideWithBuild(
          (ref, notifier) => 'fitness',
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 大正文用于证明状态读取规模与正文长度无关，拒收及回执采用生产字段。
  Future<void> queue(
    String id, {
    String? day,
    String? fitness,
    String account = 'account',
    bool rejected = false,
    bool pushed = false,
  }) async {
    try {
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: day != null ? 'day_event' : 'fitness_workout',
              entityId: id,
              mutationId: id,
              action: 'upsert',
              payload: 'x' * 8192,
              frozenRequest: d.Value('y' * 8192),
              updatedAt: stamp,
              accountId: d.Value(account),
              dayBookId: d.Value(day),
              fitnessSpaceId: d.Value(fitness),
              rejectionReason: d.Value(rejected ? '字段需要修正' : null),
              pushedAt: d.Value(pushed ? stamp : null),
            ),
          );
    } catch (error, stackTrace) {
      logger.error('PrivateSyncStatusTest', '准备待推计数夹具失败', error, stackTrace);
      rethrow;
    }
  }

  /// 让已提交的表通知及其派生 Future 完成，不依赖任意毫秒阈值。
  Future<void> settle() async {
    for (var turn = 0; turn < 3; turn++) {
      await Future<void>.delayed(Duration.zero);
      await container.pump();
    }
    await container.read(daySyncStatusProvider.future);
    await container.read(fitnessSyncStatusProvider.future);
  }

  test('同步状态按本汇总，正文不进入查询结果且账号与回执过滤有效', () async {
    try {
      await db.transaction(() async {
        for (var index = 0; index < 12; index++) {
          await queue(
            'day-$index',
            day: index < 6 ? 'day' : 'orphan',
            rejected: index % 4 == 0,
          );
          await queue(
            'fitness-$index',
            fitness: 'fitness',
            rejected: index % 4 == 0,
          );
        }
        await queue('day-other-account', day: 'day', account: 'other');
        await queue(
          'fitness-other-account',
          fitness: 'fitness',
          account: 'other',
        );
        await queue('day-pushed', day: 'day', pushed: true);
        await queue('fitness-pushed', fitness: 'fitness', pushed: true);
      });
      container.listen(daySyncStatusProvider, (_, _) {});
      container.listen(fitnessSyncStatusProvider, (_, _) {});
      await settle();

      final days = {
        for (final value in container.read(daySyncStatusProvider).requireValue)
          value.dayBookId: value,
      };
      expect(days['day']!.pendingCount, 6);
      expect(days['day']!.rejectedCount, 2);
      expect(days['orphan']!.pendingCount, 6);
      expect(days['orphan']!.rejectedCount, 1);
      expect(days['orphan']!.book, isNull);
      final fitness = container.read(fitnessSyncStatusProvider).requireValue;
      expect(fitness.pendingCount, 12);
      expect(fitness.rejectedCount, 3);
      expect(reads.queueResults, hasLength(2));
      expect(reads.queueResults.map((rows) => rows.length).toList()..sort(), [
        1,
        2,
      ]);
      expect(
        reads.queueResults
            .expand((rows) => rows)
            .any(
              (row) => row.keys.any(
                (key) =>
                    key.contains('payload') || key.contains('frozen_request'),
              ),
            ),
        isFalse,
      );
    } catch (error, stackTrace) {
      logger.error('PrivateSyncStatusTest', '聚合计数与查询规模验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('笔记与财务保存不重查私有域状态，本域保存和同步回执仍刷新', () async {
    try {
      container.listen(daySyncStatusProvider, (_, _) {});
      container.listen(fitnessSyncStatusProvider, (_, _) {});
      await settle();
      final before = reads.queueResults.length;
      await db.transaction(() async {
        await db
            .into(db.memoBooks)
            .insert(
              MemoBooksCompanion.insert(
                id: 'memo',
                name: '笔记',
                type: 'normal',
                createdAt: stamp,
                updatedAt: stamp,
              ),
            );
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: 'ledger',
                name: '账本',
                updatedAt: stamp,
              ),
            );
      });
      await settle();
      expect(reads.queueResults.length, before);

      await db.transaction(() async {
        await queue('new-day', day: 'day');
        await (db.update(
          db.dayBooks,
        )..where((row) => row.id.equals('day'))).write(
          DayBooksCompanion(
            updatedAt: d.Value(stamp.add(const Duration(days: 1))),
          ),
        );
      });
      await settle();
      expect(
        container.read(daySyncStatusProvider).requireValue.single.pendingCount,
        1,
      );
      expect(reads.queueResults.length, before + 1, reason: '日子提交只重查日子状态');

      await (db.update(db.syncChanges)
            ..where((row) => row.entityId.equals('new-day')))
          .write(SyncChangesCompanion(pushedAt: d.Value(stamp)));
      container.read(syncRunTickProvider.notifier).tick();
      await settle();
      expect(
        container.read(daySyncStatusProvider).requireValue.single.pendingCount,
        0,
      );

      final refreshed = reads.queueResults.length;
      container.read(manualDataRefreshProvider.notifier).tick();
      await settle();
      expect(
        reads.queueResults.length,
        greaterThan(refreshed),
        reason: '手动刷新仍强制重查两个业务状态',
      );
    } catch (error, stackTrace) {
      logger.error('PrivateSyncStatusTest', '跨业务刷新隔离验证失败', error, stackTrace);
      rethrow;
    }
  });
}
