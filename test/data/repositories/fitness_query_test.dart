import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import '../../helpers/fitness_space_fixture.dart';

String id(int n) => '00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
void main() {
  late SesameDatabase db;
  late FitnessRepository repo;
  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = await createFitnessTestRepository(db);
  });
  tearDown(() => db.close());
  Future<void> insert(FitnessWorkout workout, {String? space}) => db
      .into(db.fitnessEntities)
      .insert(
        FitnessEntitiesCompanion.insert(
          id: workout.id,
          fitnessSpaceId: space ?? repo.spaceId,
          entityType: 'fitness_workout',
          payload: jsonEncode(workout.toJson()..remove('id')),
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      )
      .then((_) {});
  test('单条和进行中查询不解析无关历史，保持空间隔离与跨午夜范围', () async {
    final before = DateTime(2026, 9, 13, 23, 30).toUtc(),
        after = DateTime(2026, 9, 14, 0, 15).toUtc();
    final paused = FitnessWorkout(
      id: id(1),
      name: '跨日',
      scheduledDate: '2026-08-01',
      status: 'paused',
      runSegments: [FitnessRunSegment(startedAt: before, endedAt: after)],
      createdAt: before,
      updatedAt: after,
    );
    final running = FitnessWorkout(
      id: id(2),
      name: '当前',
      scheduledDate: '2026-09-14',
      status: 'in_progress',
      runSegments: [
        FitnessRunSegment(startedAt: DateTime(2026, 9, 14, 12).toUtc()),
      ],
      createdAt: before,
      updatedAt: after,
    );
    await insert(paused);
    await insert(running);
    final other = await seedFitnessTestSpace(db, id: id(90));
    await insert(running.copyWith(id: id(3)), space: other);
    final invalid = paused.toJson()
      ..['id'] = id(4)
      ..['name'] = 123
      ..['scheduled_date'] = '2020-01-01'
      ..['run_segments'] = [
        {
          'started_at': DateTime(2020, 1, 1).toUtc().toIso8601String(),
          'ended_at': DateTime(2020, 1, 1, 1).toUtc().toIso8601String(),
        },
      ];
    invalid.remove('id');
    await db
        .into(db.fitnessEntities)
        .insert(
          FitnessEntitiesCompanion.insert(
            id: id(4),
            fitnessSpaceId: repo.spaceId,
            entityType: 'fitness_workout',
            payload: jsonEncode(invalid),
            createdAt: before,
            updatedAt: after,
          ),
        );
    expect((await repo.watchRunningWorkout().first)!.id, running.id);
    expect((await repo.watchWorkout(paused.id).first)!.name, '跨日');
    expect(await repo.watchWorkout(id(3)).first, isNull);
    final calendar = await repo
        .watchWorkoutsInRange(
          DateTime(2026, 9, 14),
          DateTime(2026, 9, 15),
          calendar: true,
        )
        .first;
    expect(calendar.map((w) => w.id).toSet(), {paused.id, running.id});
    final archive = await repo
        .watchWorkoutsInRange(DateTime(2026, 9, 14), DateTime(2026, 9, 15))
        .first;
    expect(archive.map((w) => w.id), [running.id]);
  });
  test('动作历史按需分页，最近动作与统计边界只读取需要的范围', () async {
    final day = DateTime(2026, 9, 10);
    for (var n = 1; n <= 60; n++) {
      final start = day.add(Duration(minutes: n)).toUtc();
      await insert(
        FitnessWorkout(
          id: id(n),
          name: '训练$n',
          scheduledDate: '2026-09-10',
          status: 'completed',
          runSegments: [
            FitnessRunSegment(
              startedAt: start,
              endedAt: start.add(const Duration(minutes: 1)),
            ),
          ],
          exercises: [
            FitnessExercise(
              id: id(1000 + n),
              exerciseId: '0025',
              sets: [
                FitnessSet(
                  id: id(2000 + n),
                  weight: '20',
                  reps: 10,
                  completed: true,
                ),
              ],
            ),
          ],
          createdAt: start,
          updatedAt: start,
        ),
      );
    }
    final first = await repo.watchExerciseHistory('0025').first;
    expect(first, hasLength(50));
    expect(first.first.id, id(60));
    expect(
      await repo.watchExerciseHistory('0025', limit: 100).first,
      hasLength(60),
    );
    expect(await repo.watchRecentExerciseIds().first, ['0025']);
    final bounds = await repo.watchWorkoutBounds().first;
    expect(bounds.earliest, day.add(const Duration(minutes: 1)));
    expect(bounds.latest, day.add(const Duration(minutes: 60)));
  });
}
