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
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 验证待推与拒收数量按账号和本子隔离，已确认记录不计入待推。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  final stamp = DateTime.utc(2026);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
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

  /// 构造不同账号、本子、拒收及确认状态的同步队列记录。
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
              payload: '{}',
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

  test('同步状态按本汇总，账号与回执过滤有效', () async {
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
    } catch (error, stackTrace) {
      logger.error(
        'PrivateSyncStatusTest',
        '同步状态计数与账号过滤验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('队列提交与同步确认后待推数量更新', () async {
    try {
      container.listen(daySyncStatusProvider, (_, _) {});
      container.listen(fitnessSyncStatusProvider, (_, _) {});
      await settle();
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

      await (db.update(db.syncChanges)
            ..where((row) => row.entityId.equals('new-day')))
          .write(SyncChangesCompanion(pushedAt: d.Value(stamp)));
      container.read(syncRunTickProvider.notifier).tick();
      await settle();
      expect(
        container.read(daySyncStatusProvider).requireValue.single.pendingCount,
        0,
      );
    } catch (error, stackTrace) {
      logger.error('PrivateSyncStatusTest', '同步确认后待推数量验证失败', error, stackTrace);
      rethrow;
    }
  });
}
