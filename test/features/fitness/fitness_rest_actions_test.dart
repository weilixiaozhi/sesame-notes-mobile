import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

import '../../helpers/fitness_running_fixture.dart';
import '../../helpers/fitness_space_fixture.dart';

const exerciseInstance = '11111111-1111-4111-8111-111111111111';
const setId = '22222222-2222-4222-8222-222222222222';

void main() {
  late SesameDatabase db;
  late FitnessRepository repo;
  var now = DateTime(2026, 9, 14, 12);
  setUp(() async {
    now = DateTime(2026, 9, 14, 12);
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = await createFitnessTestRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('休息计时开始/暂停/加减/继续/跳过均落盘，声音与震动偏好同步保存', () async {
    final workout = await runningWorkoutFixture(repo);
    expect((await repo.getWorkout(workout.id))!.restTimer, isNull);
    // 弹层里的声音与震动开关直接落库。
    var preferences = await repo.savePreferences(
      (await repo.getPreferences()).copyWith(
        soundEnabled: false,
        vibrationEnabled: false,
      ),
    );
    expect(preferences.soundEnabled, isFalse);
    expect(preferences.vibrationEnabled, isFalse);
    expect((await repo.getPreferences()).soundEnabled, isFalse);
    expect((await repo.getPreferences()).vibrationEnabled, isFalse);
    final defaultSeconds = preferences.defaultRestSeconds;

    var stored = await repo.startRest(workout.id, seconds: defaultSeconds);
    expect(stored.restTimer!.status, 'running');
    expect(fitnessRestRemaining(stored.restTimer, now), defaultSeconds);

    stored = await repo.pauseRest(workout.id);
    expect(stored.restTimer!.status, 'paused');
    final paused = stored.restTimer!;
    // 暂停态加减时长只改剩余秒数，不产生新的截止时间。
    stored = await repo.adjustRest(workout.id, 10);
    expect(stored.restTimer!.status, 'paused');
    expect(stored.restTimer!.remainingSeconds, paused.remainingSeconds + 10);
    expect(stored.restTimer!.endsAt, isNull);
    stored = await repo.adjustRest(workout.id, -10);
    expect(stored.restTimer!.remainingSeconds, paused.remainingSeconds);
    // 加减时长不改动默认休息设置。
    expect((await repo.getPreferences()).defaultRestSeconds, defaultSeconds);

    stored = await repo.resumeRest(workout.id);
    expect(stored.restTimer!.status, 'running');
    expect(
      stored.restTimer!.endsAt,
      now.toUtc().add(Duration(seconds: paused.remainingSeconds)),
    );

    stored = await repo.skipRest(workout.id);
    expect(stored.restTimer, isNull);
    expect((await repo.getWorkout(workout.id))!.restTimer, isNull);
  });

  test('休息到期可重复同一时长，结束休息即清空计时', () async {
    final workout = await runningWorkoutFixture(repo);
    await repo.startRest(workout.id, seconds: 10);
    now = now.add(const Duration(seconds: 11));
    var stored = (await repo.getWorkout(workout.id))!;
    expect(fitnessRestCompleted(stored.restTimer, now), isTrue);

    // 重复休息使用上一次的时长重新开始，提示随之消失。
    stored = await repo.startRest(
      workout.id,
      seconds: stored.restTimer!.durationSeconds,
    );
    expect(stored.restTimer!.durationSeconds, 10);
    expect(
      stored.restTimer!.endsAt,
      now.toUtc().add(const Duration(seconds: 10)),
    );
    expect(fitnessRestCompleted(stored.restTimer, now), isFalse);
    now = now.add(const Duration(seconds: 11));
    expect(fitnessRestCompleted(stored.restTimer, now), isTrue);

    stored = await repo.skipRest(workout.id);
    expect(stored.restTimer, isNull);
    expect((await repo.getWorkout(workout.id))!.restTimer, isNull);
  });

  test('休息结束把实际运行秒数结算给触发组，同一次计时只结算一次', () async {
    final template = await repo.saveTemplate(
      const FitnessTemplate(
        name: '休息',
        exercises: [
          FitnessExercise(
            id: exerciseInstance,
            exerciseId: '0025',
            restSeconds: 30,
            sets: [FitnessSet(id: setId, weight: '20', reps: 8)],
          ),
        ],
      ),
    );
    var workout = await repo.startFromTemplate(template.id);
    workout = await repo.setGroupCompleted(
      workout.id,
      exerciseInstance,
      setId,
      true,
    );
    expect(workout.restTimer!.durationSeconds, 30);
    now = now.add(const Duration(seconds: 7));
    final settled = await repo.skipRest(workout.id);
    expect(settled.restTimer, isNull);
    // 按已运行的 7 秒结算，不冒充预设的 30 秒。
    expect(settled.exercises.single.sets.single.restDurationsSeconds, [7]);
    final again = await repo.skipRest(workout.id);
    expect(again.exercises.single.sets.single.restDurationsSeconds, [7]);
  });

  test('默认热身与正式休息分别持久化，非法值不落库且 JSON 往返一致', () async {
    await repo.savePreferences(
      const FitnessPreferences(defaultRestSeconds: 80),
    );
    // 旧数据只有通用默认值：热身默认留空，由上层回退到通用默认。
    expect((await repo.getPreferences()).defaultWarmupRestSeconds, isNull);
    expect((await repo.getPreferences()).defaultRestSeconds, 80);
    // 非法值不落库。
    await expectLater(
      repo.savePreferences(
        (await repo.getPreferences()).copyWith(defaultRestSeconds: -1),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    await expectLater(
      repo.savePreferences(
        (await repo.getPreferences()).copyWith(
          defaultWarmupRestSeconds: FitnessDefaults.maxInteger + 1,
        ),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    expect((await repo.getPreferences()).defaultRestSeconds, 80);
    expect((await repo.getPreferences()).defaultWarmupRestSeconds, isNull);

    // 热身与正式组休息分别持久化，并能从 JSON 还原。
    final saved = await repo.savePreferences(
      (await repo.getPreferences()).copyWith(
        defaultWarmupRestSeconds: 30,
        defaultRestSeconds: 90,
      ),
    );
    expect(saved.defaultWarmupRestSeconds, 30);
    expect(saved.defaultRestSeconds, 90);
    expect((await repo.getPreferences()).defaultWarmupRestSeconds, 30);
    expect((await repo.getPreferences()).defaultRestSeconds, 90);
    final restored = FitnessPreferences.fromJson(saved.toJson());
    expect(restored.defaultWarmupRestSeconds, 30);
    expect(restored.defaultRestSeconds, 90);
  });
}
