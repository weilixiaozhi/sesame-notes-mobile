import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

import '../../helpers/fitness_space_fixture.dart';

/// 固定标识让数据库中的实体和每次发布的模型可以直接对应。
String _id(int value) =>
    '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}';

/// 验证宽表通知不会重复解码无关实体，同时守住内容、权限和订阅生命周期。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late FitnessRepository repo;
  late String space;
  String? account;
  final stamp = DateTime.utc(2026, 9, 14, 10);
  final running = FitnessWorkout(
    id: _id(1),
    name: '正在训练',
    scheduledDate: '2026-09-14',
    status: 'in_progress',
    runSegments: [FitnessRunSegment(startedAt: stamp)],
    createdAt: stamp,
    updatedAt: stamp,
  );
  final history = FitnessWorkout(
    id: _id(2),
    name: '历史训练',
    scheduledDate: '2026-09-14',
    status: 'completed',
    runSegments: [
      FitnessRunSegment(
        startedAt: stamp.subtract(const Duration(hours: 1)),
        endedAt: stamp,
      ),
    ],
    createdAt: stamp,
    updatedAt: stamp,
  );

  /// 直接写入生产模型正文，行时钟可保持不变以验证比较确实覆盖正文。
  Future<void> insert(
    String id,
    String type,
    Map<String, dynamic> payload, {
    String? targetSpace,
  }) async {
    try {
      await db
          .into(db.fitnessEntities)
          .insert(
            FitnessEntitiesCompanion.insert(
              id: id,
              fitnessSpaceId: targetSpace ?? space,
              entityType: type,
              payload: jsonEncode(payload),
              createdAt: stamp,
              updatedAt: stamp,
            ),
          );
    } catch (error, stackTrace) {
      logger.error('FitnessWatchTest', '准备训练流数据失败', error, stackTrace);
      rethrow;
    }
  }

  /// 刷新正文不改变行时钟，不能依靠更新时间代替实际内容判断。
  Future<void> replacePayload(String id, Map<String, dynamic> payload) async {
    try {
      await (db.update(
        db.fitnessEntities,
      )..where((row) => row.id.equals(id))).write(
        FitnessEntitiesCompanion(payload: d.Value(jsonEncode(payload))),
      );
    } catch (error, stackTrace) {
      logger.error('FitnessWatchTest', '更新训练流正文失败', error, stackTrace);
      rethrow;
    }
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    account = null;
    space = await seedFitnessTestSpace(db);
    repo = FitnessRepository(
      db,
      spaceId: space,
      accountIdGetter: () => account,
    );
    await insert(running.id, 'fitness_workout', running.toJson());
    await insert(history.id, 'fitness_workout', history.toJson());
    await insert(
      space,
      'fitness_preferences',
      FitnessPreferences(id: space, defaultRestSeconds: 120).toJson(),
    );
    await insert(
      _id(3),
      'fitness_template',
      const FitnessTemplate(name: '模板').toJson(),
    );
  });

  tearDown(() async => db.close());

  test('无关保存不发射，范围只重建正文变化的模型，删除隐藏后释放旧模型', () async {
    final preferences = <FitnessPreferences>[];
    final active = <FitnessWorkout?>[];
    final detail = <FitnessWorkout?>[];
    final templates = <List<FitnessTemplate>>[];
    final ranges = <List<FitnessWorkout>>[];
    final subscriptions = <StreamSubscription<dynamic>>[
      repo.watchPreferences().listen(preferences.add),
      repo.watchRunningWorkout().listen(active.add),
      repo.watchWorkout(running.id).listen(detail.add),
      repo.watchTemplates().listen(templates.add),
      repo
          .watchWorkoutsInRange(DateTime(2026, 9, 14), DateTime(2026, 9, 15))
          .listen(ranges.add),
    ];
    try {
      await pumpEventQueue();
      expect(
        [
          preferences.length,
          active.length,
          detail.length,
          templates.length,
          ranges.length,
        ],
        [1, 1, 1, 1, 1],
      );
      final unchangedHistory = ranges.single.singleWhere(
        (value) => value.id == history.id,
      );

      final otherSpace = await seedFitnessTestSpace(db, id: _id(90));
      await insert(
        _id(91),
        'fitness_workout',
        running.copyWith(id: _id(91)).toJson(),
        targetSpace: otherSpace,
      );
      await insert(_id(92), 'fitness_plan', {'name': '未展示的计划'});
      await (db.update(
        db.fitnessEntities,
      )..where((row) => row.id.equals(running.id))).write(
        FitnessEntitiesCompanion(
          updatedAt: d.Value(stamp.add(const Duration(seconds: 1))),
        ),
      );
      await pumpEventQueue();
      expect(
        [
          preferences.length,
          active.length,
          detail.length,
          templates.length,
          ranges.length,
        ],
        [1, 1, 1, 1, 1],
      );

      await replacePayload(
        running.id,
        running.copyWith(name: '新训练名称').toJson(),
      );
      await pumpEventQueue();
      expect(
        [
          preferences.length,
          active.length,
          detail.length,
          templates.length,
          ranges.length,
        ],
        [1, 2, 2, 1, 2],
      );
      expect(active.last!.name, '新训练名称');
      expect(
        identical(
          ranges.last.singleWhere((value) => value.id == history.id),
          unchangedHistory,
        ),
        isTrue,
        reason: '一条训练变化不能重新解码所有未变历史',
      );

      await (db.update(db.fitnessEntities)
            ..where((row) => row.id.equals(running.id)))
          .write(FitnessEntitiesCompanion(deletedAt: d.Value(stamp)));
      await pumpEventQueue();
      expect(active.last, isNull);
      expect(detail.last, isNull);
      expect(ranges.last.single.id, history.id);

      await (db.update(db.fitnessSpaces)..where((row) => row.id.equals(space)))
          .write(const FitnessSpacesCompanion(isHidden: d.Value(true)));
      await pumpEventQueue();
      expect(ranges.last, isEmpty);
      expect(templates.last, isEmpty);
      expect(preferences.last.defaultRestSeconds, FitnessDefaults.restSeconds);
      await (db.update(db.fitnessSpaces)..where((row) => row.id.equals(space)))
          .write(const FitnessSpacesCompanion(isHidden: d.Value(false)));
      await pumpEventQueue();
      expect(ranges.last.single.id, history.id);
      expect(
        identical(ranges.last.single, unchangedHistory),
        isFalse,
        reason: '离开可见结果的实体不能留在订阅缓存',
      );
      expect(preferences.last.defaultRestSeconds, 120);
    } catch (error, stackTrace) {
      logger.error('FitnessWatchTest', '训练流复用及可见性验证失败', error, stackTrace);
      rethrow;
    } finally {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    }
  });

  test('相同正文的会话变化仍报错，错误恢复会重新发布有效结果', () async {
    final values = <FitnessWorkout?>[];
    final errors = <Object>[];
    final subscription = repo
        .watchWorkout(running.id)
        .listen(values.add, onError: errors.add);
    try {
      await pumpEventQueue();
      final first = values.single;
      account = 'other-account';
      await (db.update(
        db.fitnessEntities,
      )..where((row) => row.id.equals(running.id))).write(
        FitnessEntitiesCompanion(
          updatedAt: d.Value(stamp.add(const Duration(seconds: 1))),
        ),
      );
      await pumpEventQueue();
      expect(errors.single, isA<FitnessValidationException>());
      expect(values, hasLength(1));
      account = null;
      await (db.update(
        db.fitnessEntities,
      )..where((row) => row.id.equals(running.id))).write(
        FitnessEntitiesCompanion(
          updatedAt: d.Value(stamp.add(const Duration(seconds: 2))),
        ),
      );
      await pumpEventQueue();
      expect(values, hasLength(2));
      expect(
        identical(values.last, first),
        isFalse,
        reason: '错误应清理旧会话缓存而不是压住恢复事件',
      );
      await replacePayload(running.id, running.toJson()..['name'] = 123);
      await pumpEventQueue();
      expect(errors.last, isA<TypeError>());
      final beforeRepair = values.last;
      await replacePayload(running.id, running.toJson());
      await pumpEventQueue();
      expect(values, hasLength(3));
      expect(values.last!.name, running.name);
      expect(identical(values.last, beforeRepair), isFalse);
    } catch (error, stackTrace) {
      logger.error('FitnessWatchTest', '会话检查与恢复验证失败', error, stackTrace);
      rethrow;
    } finally {
      await subscription.cancel();
    }
  });

  test('同一流的两个订阅独立复用，取消后重新订阅不保留旧缓存', () async {
    final stream = repo.watchWorkout(running.id);
    final first = <FitnessWorkout?>[];
    final second = <FitnessWorkout?>[];
    final one = stream.listen(first.add);
    final two = stream.listen(second.add);
    try {
      await pumpEventQueue();
      expect(first, hasLength(1));
      expect(second, hasLength(1));
      expect(identical(first.single, second.single), isFalse);
      await one.cancel();
      await replacePayload(running.id, running.copyWith(name: '更新后').toJson());
      await pumpEventQueue();
      expect(first, hasLength(1));
      expect(second.last!.name, '更新后');
      await two.cancel();
      final next = await stream.first;
      expect(next!.name, '更新后');
      expect(identical(next, second.last), isFalse);
    } catch (error, stackTrace) {
      logger.error('FitnessWatchTest', '订阅隔离与释放验证失败', error, stackTrace);
      rethrow;
    } finally {
      await one.cancel();
      await two.cancel();
    }
  });
}
