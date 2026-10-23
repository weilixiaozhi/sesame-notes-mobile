import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';
import 'dart:convert';
import 'dart:io';

import 'package:built_value/serializer.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_payload_shapes.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';

const id = '11111111-1111-4111-8111-111111111111';
const setId = '22222222-2222-4222-8222-222222222222';
const secondId = '33333333-3333-4333-8333-333333333333';
final time = DateTime.utc(2026, 9, 10, 12);
FitnessExercise exercise({List<FitnessSet>? sets}) => FitnessExercise(
  id: id,
  exerciseId: '0025',

  sets:
      sets ??
      [const FitnessSet(id: setId, weight: '20', reps: 10, completed: true)],
);
FitnessWorkout workout({
  String workoutId = id,
  List<FitnessExercise>? exercises,
  DateTime? start,
  DateTime? end,
  String date = '2026-09-10',
}) => FitnessWorkout(
  id: workoutId,
  name: '训练',
  scheduledDate: date,

  status: 'completed',
  exercises: exercises ?? [exercise()],
  runSegments: [
    FitnessRunSegment(
      startedAt: start ?? DateTime.parse('${date}T12:00:00.000Z'),
      endedAt:
          end ??
          (start ?? DateTime.parse('${date}T12:00:00.000Z')).add(
            const Duration(minutes: 10),
          ),
    ),
  ],
  createdAt: time,
  updatedAt: time,
);

void main() {
  test('同动作所有实例共用重量口径，空白组和不同动作独立校验', () {
    final total = exercise();
    final side = exercise(
      sets: [
        const FitnessSet(
          id: setId,
          weightLeft: '10',
          weightRight: '10',
          reps: 8,
        ),
      ],
    ).copyWith(id: secondId);
    expect(
      () => validateFitnessExercises([total, side], execution: true),
      throwsA(
        isA<FitnessValidationException>().having(
          (error) => error.code,
          'code',
          'FITNESS_WEIGHT_MODE',
        ),
      ),
    );
    expect(
      () => validateFitnessExercises([
        total.copyWith(
          sets: [
            ...total.sets,
            side.sets.single.copyWith(id: secondId),
          ],
        ),
      ], execution: true),
      throwsA(
        isA<FitnessValidationException>().having(
          (error) => error.code,
          'code',
          'FITNESS_WEIGHT_MODE',
        ),
      ),
    );
    expect(
      () => validateFitnessExercises([
        total,
        side.copyWith(exerciseId: '0001'),
      ], execution: true),
      returnsNormally,
    );
    expect(
      () => validateFitnessExercises([
        total.copyWith(sets: [const FitnessSet(id: setId)]),
        side,
      ], execution: true),
      returnsNormally,
    );
  });
  test('自定义动作字段、必填值、图片和标识严格校验', () {
    const custom = FitnessCustomExercise(
      id: 'custom:$id',
      name: '自定义深蹲',
      bodyPart: 'upper legs',
      equipment: 'body weight',
      icon: 'dumbbell',
    );
    final payload = FitnessPreferences(
      customExercises: [custom],
      createdAt: time,
      updatedAt: time,
    ).toJson();
    expect(
      () => validateFitnessPayload('fitness_preferences', payload),
      returnsNormally,
    );
    expect(
      FitnessPreferences.fromJson(payload).customExercises.single.toJson(),
      custom.toJson(),
    );
    for (final invalid in [
      {...custom.toJson(), 'name': ' '},
      {...custom.toJson(), 'id': 'custom:invalid'},
      {...custom.toJson(), 'body_part': ''},
      {...custom.toJson(), 'equipment': ' '},
      {...custom.toJson(), 'equipment': 'x' * 101},
      {...custom.toJson(), 'icon': ''},
      {...custom.toJson(), 'image': '!!!!'},
      {...custom.toJson(), 'image': 'A' * 65540},
      {...custom.toJson(), 'unexpected': true},
    ]) {
      expect(
        () => validateFitnessPayload('fitness_preferences', {
          ...payload,
          'custom_exercises': [invalid],
        }),
        throwsA(anything),
      );
    }
    expect(
      () => validateFitnessPayload(
        'fitness_preferences',
        {...payload}..remove('custom_exercises'),
      ),
      throwsA(anything),
    );
    expect(
      () => validateFitnessPayload('fitness_preferences', {
        ...payload,
        'custom_exercises': [custom.toJson(), custom.toJson()],
      }),
      throwsA(anything),
    );
    expect(
      () => validateFitnessExercises([
        exercise().copyWith(exerciseId: custom.id),
      ], execution: true),
      returnsNormally,
    );
  });

  test('计划日以单个安排往返，替换和清空不会保留旧安排', () {
    final slot = FitnessPlanSlot(id: id, name: '力量', exercises: [exercise()]);
    final day = FitnessPlanDay(dayIndex: 0, slot: slot);
    expect(FitnessPlanDay.fromJson(day.toJson()).slot!.name, '力量');
    expect(day.copyWith(slot: slot.copyWith(name: '跑步')).slot!.name, '跑步');
    expect(day.copyWith(dayIndex: 1).slot, same(slot));
    expect(day.copyWith(slot: null).toJson()['slot'], isNull);
    expect(
      FitnessPlanDay.fromJson({'day_index': 0, 'slot': null}).slot,
      isNull,
    );
    for (final json in [
      {
        'day_index': 0,
        'slots': [slot.toJson(), slot.toJson()],
      },
      {
        'day_index': 0,
        'slot': [slot.toJson()],
      },
      {'day_index': 0},
    ]) {
      expect(() => FitnessPlanDay.fromJson(json), throwsA(anything));
    }
  });

  test('统一 kg 与次数，空重量和零重量有效且不产生训练量', () {
    for (final weight in [null, '0', '20.125']) {
      final set = FitnessSet(
        id: setId,
        weight: weight,
        reps: 8,
        completed: true,
      );
      expect(fitnessSetIsValid(set), isTrue);
      expect(
        fitnessSetVolume(set),
        Decimal.parse(weight ?? '0') * Decimal.fromInt(8),
      );
      expect(fitnessSetVolume(set.copyWith(kind: 'warmup')), Decimal.zero);
      expect(fitnessSetVolume(set.copyWith(completed: false)), Decimal.zero);
      expect(fitnessSetIsValid(set.copyWith(reps: null)), isFalse);
      expect(fitnessSetIsValid(set.copyWith(reps: 0)), isFalse);
      expect(fitnessSetIsValid(set.copyWith(weight: '-1')), isFalse);
    }
    expect(
      () => FitnessWorkout.fromJson({
        ...workout().toJson(),
        'archive_date': null,
      }),
      throwsFormatException,
    );
  });

  test('左右重量必须成对且与总重互斥，训练量按两侧相加计算', () {
    for (final (left, right) in [
      ('5', '5'),
      ('0', '12.5'),
      ('10.0000000001', '9'),
    ]) {
      final set = FitnessSet(
        id: setId,
        weightLeft: left,
        weightRight: right,
        reps: 8,
        completed: true,
      );
      expect(fitnessSetIsValid(set), isTrue);
      expect(
        fitnessSetVolume(set),
        (Decimal.parse(left) + Decimal.parse(right)) * Decimal.fromInt(8),
      );
      // 单边缺失、与总重并存、非法小数都不构成有效组
      expect(fitnessSetIsValid(set.copyWith(weightRight: null)), isFalse);
      expect(fitnessSetIsValid(set.copyWith(weightLeft: null)), isFalse);
      expect(fitnessSetIsValid(set.copyWith(weight: '5')), isFalse);
      expect(fitnessSetIsValid(set.copyWith(weightLeft: '-1')), isFalse);
      expect(fitnessSetIsValid(set.copyWith(weightRight: '5.')), isFalse);
    }
    // 编辑中的草稿允许只填单边，完成组必须成对
    const halfSet = FitnessSet(
      id: setId,
      weightLeft: '5',
      reps: 8,
      completed: false,
    );
    final draft =
        workout(
          exercises: [
            exercise(sets: [halfSet]),
          ],
        ).copyWith(
          status: 'in_progress',
          runSegments: [FitnessRunSegment(startedAt: time, endedAt: null)],
        );
    expect(
      () => validateFitnessPayload('fitness_workout', draft.toJson()),
      returnsNormally,
    );
    expect(fitnessSetIsValid(halfSet), isFalse);
    expect(
      () => validateFitnessPayload(
        'fitness_workout',
        workout(
          exercises: [
            exercise(sets: [halfSet.copyWith(completed: true)]),
          ],
        ).toJson(),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
    final total = FitnessSet(id: setId, weight: '20', reps: 8);
    expect(fitnessSetIsValid(total), isTrue);
    // 未填写任何重量的空组仍然有效
    const empty = FitnessSet(id: setId, reps: 8);
    expect(fitnessSetIsValid(empty), isTrue);
    // 切换口径迁移数值，避免两种重量并存
    final side = fitnessMigrateSetWeight(total, side: true);
    expect(
      [side.weight, side.weightLeft, side.weightRight],
      [null, '20', '20'],
    );
    final back = fitnessMigrateSetWeight(side, side: false);
    expect(
      [back.weight, back.weightLeft, back.weightRight],
      [null, null, null],
    );
    // 契约字段必须存在：缺失左右重量无法解析
    expect(
      () => FitnessSet.fromJson({
        'id': setId,
        'kind': 'working',
        'weight': null,
        'reps': 8,
        'completed': false,
        'rest_durations_seconds': <int>[],
      }),
      throwsFormatException,
    );
    // 生成客户端的推送模型同步认识左右重量字段
    final payload = workout(
      exercises: [
        exercise(
          sets: [
            const FitnessSet(
              id: setId,
              weightLeft: '5',
              weightRight: '6.25',
              reps: 8,
              completed: true,
            ),
          ],
        ),
      ],
    ).toJson();
    final model = api.standardSerializers.deserializeWith(
      api.PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload.serializer,
      payload,
    );
    expect(
      api.standardSerializers.serializeWith(
        api.PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload.serializer,
        model,
      ),
      payload,
    );
  });

  test('动作级重量口径优先已有成绩，空白动作采用偏好和器械默认值', () {
    const preferences = FitnessPreferences();
    // 哑铃、壶铃这类单侧器械默认按左右记录，其余器械默认总重量
    expect(
      fitnessUsesSideWeight(
        preferences,
        exerciseId: '0289',
        equipment: 'dumbbell',
      ),
      isTrue,
    );
    expect(
      fitnessUsesSideWeight(
        preferences,
        exerciseId: '0662',
        equipment: 'kettlebell',
      ),
      isTrue,
    );
    expect(
      fitnessUsesSideWeight(
        preferences,
        exerciseId: '0025',
        equipment: 'barbell',
      ),
      isFalse,
    );
    expect(
      fitnessUsesSideWeight(preferences, exerciseId: '0025', equipment: null),
      isFalse,
    );
    // 显式关闭单侧器械、显式开启双侧器械都以用户设置为准
    expect(
      fitnessUsesSideWeight(
        preferences.copyWith(exerciseWeightModes: const {'0289': false}),
        exerciseId: '0289',
        equipment: 'dumbbell',
      ),
      isFalse,
    );
    expect(
      fitnessUsesSideWeight(
        preferences.copyWith(exerciseWeightModes: const {'0025': true}),
        exerciseId: '0025',
        equipment: 'barbell',
      ),
      isTrue,
    );
    // 已有数据优先于器械默认：导入的总重量不会被哑铃默认口径改写
    expect(
      fitnessUsesSideWeight(
        preferences,
        exerciseId: '0289',
        equipment: 'dumbbell',
        dataUsesSideWeight: false,
      ),
      isFalse,
    );
    expect(
      fitnessUsesSideWeight(
        preferences,
        exerciseId: '0025',
        equipment: 'barbell',
        dataUsesSideWeight: true,
      ),
      isTrue,
    );
    // 其他训练改变空间偏好后，历史记录仍按自身成绩的口径呈现。
    expect(
      fitnessUsesSideWeight(
        preferences.copyWith(exerciseWeightModes: const {'0289': false}),
        exerciseId: '0289',
        equipment: 'dumbbell',
        dataUsesSideWeight: true,
      ),
      isTrue,
    );
    expect(
      fitnessUsesSideWeight(
        preferences.copyWith(exerciseWeightModes: const {'0025': true}),
        exerciseId: '0025',
        equipment: 'barbell',
        dataUsesSideWeight: false,
      ),
      isFalse,
    );
  });

  test('已有组数据的口径推导：分侧优先，只有总重即总重，无重量为 null', () {
    expect(fitnessSideWeightFromSets(const []), isNull);
    expect(
      fitnessSideWeightFromSets(const [FitnessSet(id: setId, reps: 8)]),
      isNull,
    );
    expect(
      fitnessSideWeightFromSets(const [
        FitnessSet(id: setId, weight: '20', reps: 8),
      ]),
      isFalse,
    );
    expect(
      fitnessSideWeightFromSets(const [
        FitnessSet(id: setId, weightLeft: '5', weightRight: '5', reps: 8),
      ]),
      isTrue,
    );
    expect(
      fitnessSideWeightFromSets(const [
        FitnessSet(id: setId, weight: '20', reps: 8),
        FitnessSet(id: secondId, weightLeft: '5', weightRight: '5', reps: 8),
      ]),
      isTrue,
    );
  });

  test('动作级重量口径映射的键必须合法且条目数受限', () {
    for (final modes in [
      <String, bool>{},
      {'0025': true},
      {'custom:$id': false},
      {'0025': true, 'custom:$id': false},
    ]) {
      expect(
        () => validateFitnessPayload(
          'fitness_preferences',
          FitnessPreferences(
            exerciseWeightModes: modes,
            createdAt: time,
            updatedAt: time,
          ).toJson(),
        ),
        returnsNormally,
      );
    }
    for (final modes in [
      {'unknown': true},
      {'': true},
      {'x' * 129: true},
    ]) {
      expect(
        () => validateFitnessPayload(
          'fitness_preferences',
          FitnessPreferences(
            exerciseWeightModes: modes,
            createdAt: time,
            updatedAt: time,
          ).toJson(),
        ),
        throwsA(isA<FitnessValidationException>()),
      );
    }
  });

  test('模板和偏好拒绝未定义的排序与收藏字段', () {
    final template = FitnessTemplate(name: '单次训练', exercises: [exercise()]);
    final preferences = const FitnessPreferences();
    expect(template.toJson().containsKey('sort_order'), isFalse);
    expect(preferences.toJson().containsKey('favorite_plan_ids'), isFalse);
    expect(
      () => FitnessTemplate.fromJson({...template.toJson(), 'sort_order': 0}),
      throwsFormatException,
    );
    expect(
      () => FitnessPreferences.fromJson({
        ...preferences.toJson(),
        'favorite_plan_ids': [],
      }),
      throwsFormatException,
    );
  });
  test('模板、计划、训练和偏好载荷经过真实生成客户端往返，null与毫秒精度不丢失', () {
    void roundTrip<T>(Serializer<T> serializer, Map<String, dynamic> payload) {
      final model = api.standardSerializers.deserializeWith(
        serializer,
        payload,
      );
      expect(api.standardSerializers.serializeWith(serializer, model), payload);
    }

    final template = FitnessTemplate(
      id: id,
      name: '模板',
      exercises: [exercise()],
      createdAt: time,
      updatedAt: time,
    );
    final plan = FitnessPlan(
      id: secondId,
      name: '计划',
      startDate: '2026-09-10',
      cycleDays: 2,
      days: [
        FitnessPlanDay(
          dayIndex: 0,
          slot: FitnessPlanSlot(
            id: setId,
            sourceTemplateId: id,
            name: '模板',
            exercises: fitnessSnapshotExercises(template.exercises),
          ),
        ),
        const FitnessPlanDay(dayIndex: 1),
      ],
      createdAt: time,
      updatedAt: time,
    );
    roundTrip(
      api.PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload.serializer,
      template.toJson(),
    );
    roundTrip(
      api.PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload.serializer,
      fitnessGenerate(plan, '2026-09-10').plan.toJson(),
    );
    roundTrip(
      api.PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload.serializer,
      workout().toJson(),
    );
    roundTrip(
      api.PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload.serializer,
      FitnessPreferences(
        createdAt: time,
        updatedAt: time,
        customExercises: const [
          FitnessCustomExercise(
            id: 'custom:$id',
            name: '自定义深蹲',
            bodyPart: 'upper legs',
            equipment: 'body weight',
            icon: 'dumbbell',
            image: 'aGVsbG8=',
          ),
        ],
      ).toJson(),
    );
  });

  test('严格日期、JSON必填与未知字段，默认仅用于新建', () {
    expect(
      () => fitnessParseDate('2026-02-30'),
      throwsA(isA<FitnessValidationException>()),
    );
    expect(
      () => FitnessPreferences.fromJson({'weight_unit': 'kg'}),
      throwsFormatException,
    );
    final payload = workout().toJson();
    payload['notes'] = '不能存在';
    expect(
      () => validateFitnessPayload('fitness_workout', payload),
      throwsFormatException,
    );
    final valid = workout().toJson();
    validateFitnessPayload('fitness_workout', valid);
    ((valid['exercises'] as List).single as Map).remove('warmup_rest_seconds');
    expect(
      () => validateFitnessPayload('fitness_workout', valid),
      throwsFormatException,
    );
    expect(
      const FitnessPreferences().defaultRestSeconds,
      FitnessDefaults.restSeconds,
    );
  });

  test('同步入站剥离未知字段，用户文件与备份路径仍严格', () {
    final payload = workout().toJson();
    payload['future_field'] = 'v2';
    (payload['exercises'] as List).first['future_metric'] = 42;

    expect(
      () => validateFitnessPayload('fitness_workout', payload),
      throwsFormatException,
      reason: '文件/备份路径保持严格：形状不符必须 fail-loud',
    );

    final sanitized = fitnessPayloadIgnoringUnknown('fitness_workout', payload);
    validateFitnessPayload('fitness_workout', sanitized);
    expect(sanitized.containsKey('future_field'), isFalse);
    expect(
      ((sanitized['exercises'] as List).first as Map).containsKey(
        'future_metric',
      ),
      isFalse,
    );
    expect(FitnessWorkout.fromJson(sanitized).name, workout().name);
  });

  test('同步入站保留 preferences 的已知派生键，不误删字段', () {
    const custom = FitnessCustomExercise(
      id: 'custom:$id',
      name: '自定义深蹲',
      bodyPart: 'upper legs',
      equipment: 'body weight',
      icon: 'dumbbell',
    );
    final payload = <String, dynamic>{
      ...FitnessPreferences(
        customExercises: [custom],
        createdAt: time,
        updatedAt: time,
      ).toJson(),
      'exercise_rest_settings': {
        'custom:$id': const {'rest_seconds': 60, 'warmup_rest_seconds': 30},
      },
      'default_warmup_rest_seconds': 30,
      'future_field': 7,
    };

    final sanitized = fitnessPayloadIgnoringUnknown(
      'fitness_preferences',
      payload,
    );

    expect(
      sanitized.keys,
      containsAll([
        'exercise_rest_settings',
        'default_warmup_rest_seconds',
        'custom_exercises',
      ]),
      reason: '派生键必须随载荷一起保留，否则同步会静默丢每个动作的休息设置',
    );
    expect(sanitized.containsKey('future_field'), isFalse);
    validateFitnessPayload('fitness_preferences', sanitized);
  });

  test('损坏日期、非法来源、无效动作标识与错位记录字段均拒绝', () {
    for (final mutate in <void Function(Map<String, dynamic>)>[
      (p) => p['created_at'] = '2026-09-10T12:00:00Z',
      (p) => p['updated_at'] = '2026-02-30T12:00:00.000Z',
      (p) => p['created_at'] = '0000-01-01T00:00:00.000Z',
      (p) => p['name'] = '\u0000',
      (p) => p['source_plan_id'] = id,
      (p) => p['source_kind'] = 'template',
      (p) => (p['exercises'] as List).single['exercise_id'] = 'custom-squat',
      (p) => (p['exercises'] as List).single['weight_mode'] = 'per_hand',
      (p) => (p['exercises'] as List).single['sets'][0].remove('completed'),
      (p) => (p['exercises'] as List).single['sets'][0]['completed'] = null,
      (p) => (p['exercises'] as List).single['sets'][0]['weight'] = 'NaN',
      (p) => (p['exercises'] as List).single['sets'][0]['weight'] = '-1',
      (p) => (p['exercises'] as List).single['sets'][0]['reps_min'] = 8,
      (p) =>
          (p['exercises'] as List).single['sets'][0]['duration_seconds'] = 10,
    ]) {
      final payload = workout().toJson();
      mutate(payload);
      expect(
        () => validateFitnessPayload('fitness_workout', payload),
        throwsA(anything),
      );
    }
  });

  test('发生UUID固定黄金向量，计划身份和键不可错配', () {
    const planId = '22222222-2222-4222-8222-222222222222';
    const slotId = '66666666-6666-4666-8666-666666666666';
    final p = FitnessPlan(
      id: planId,
      name: '黄金',
      startDate: '2026-09-11',
      cycleDays: 1,
      days: [
        FitnessPlanDay(
          dayIndex: 0,
          slot: FitnessPlanSlot(
            id: slotId,
            name: '动作',
            exercises: [exercise()],
          ),
        ),
      ],
    );
    final w = fitnessGenerate(p, '2026-09-11').workouts.single;
    expect(w.occurrenceKey, '$planId:0:0:$slotId');
    expect(w.id, '842be7db-6cec-593a-97b0-3ae8fb35e0ee');
    validateFitnessIdentity('fitness_workout', w.id, w.toJson());
    expect(
      () => validateFitnessIdentity('fitness_workout', id, w.toJson()),
      throwsA(isA<FitnessValidationException>()),
    );
  });

  test('空记录展示汇总归零', () {
    final assisted = exercise();
    final lower = assisted.sets.single.copyWith(weight: '10');
    final w = workout(
      exercises: [
        assisted.copyWith(
          sets: [
            assisted.sets.single,
            lower.copyWith(id: secondId),
            lower.copyWith(id: id, kind: 'warmup', weight: '0'),
          ],
        ),
      ],
    );
    var stats = fitnessStatistics(
      [w],
      startDate: '2026-09-10',
      endDate: '2026-09-10',
    );
    expect(stats.trainingDays, 1);
    stats = fitnessStatistics(
      [],
      startDate: '2026-09-10',
      endDate: '2026-09-10',
    );
    expect(stats.trainingDays, 0);
    expect(stats.volumeKg, Decimal.zero);
  });

  test('已训练肌群只取范围内有效正式组，缺失目录和无记录不误染色', () {
    final data =
        jsonDecode(File('assets/fitness/exercises.json').readAsStringSync())
            as Map;
    final catalog = {
      for (final row in data['exercises'] as List)
        (row as Map<String, dynamic>)['id'] as String:
            FitnessExerciseDefinition.fromJson(row),
    };
    final valid = exercise().sets.single;
    final w = workout(
      exercises: [
        exercise(
          sets: [
            valid,
            valid.copyWith(id: 'warmup', kind: 'warmup'),
            valid.copyWith(id: 'unfinished', completed: false),
            valid.copyWith(id: 'draft', reps: null, completed: false),
          ],
        ),
      ],
    );
    FitnessStatistics stats(
      List<FitnessWorkout> input, {
      bool withCatalog = true,
    }) => fitnessStatistics(
      input,
      startDate: '2026-09-10',
      endDate: '2026-09-10',
      catalog: withCatalog ? catalog : const {},
    );
    expect(stats([w, w]).trainedMuscles, {'pectorals'});
    expect(stats([w, w]).bodyPartVolumeKg, {'chest': Decimal.fromInt(200)});
    final repeated = w.copyWith(
      exercises: [
        exercise(
          sets: [
            valid,
            valid.copyWith(id: 'another'),
          ],
        ),
      ],
    );
    expect(stats([repeated]).trainedMuscles, {'pectorals'});
    expect(stats([repeated]).bodyPartVolumeKg['chest'], Decimal.fromInt(400));
    final missing = stats([w], withCatalog: false);
    expect(missing.bodyPartVolumeKg, isEmpty);
    expect(missing.volumeKg, Decimal.fromInt(200));
    final cardioDefinition = catalog.values.firstWhere(
      (e) => e.bodyPart == 'cardio',
    );
    final cardio = w.copyWith(
      exercises: [
        FitnessExercise(
          id: id,
          exerciseId: cardioDefinition.id,

          sets: const [FitnessSet(id: setId, reps: 60, completed: true)],
        ),
      ],
    );
    expect(stats([cardio]).bodyPartVolumeKg, isEmpty);
    expect(stats([cardio]).trainedMuscles, isEmpty);
    expect(stats([cardio]).trainingDays, 1);
    expect(stats([cardio]).totalDuration, const Duration(minutes: 10));

    expect(stats([w]).trainedMuscles.contains('triceps'), isFalse);
    expect(stats([w], withCatalog: false).trainedMuscles, isEmpty);
    expect(stats([]).trainedMuscles, isEmpty);
    expect(stats([workout(date: '2026-09-09')]).trainedMuscles, isEmpty);
    expect(stats([w.copyWith(status: 'in_progress')]).trainedMuscles, isEmpty);
  });

  test('自然周月年区间', () {
    expect(fitnessDateRange(DateTime(2026, 9, 13), 'week'), (
      startDate: '2026-09-07',
      endDate: '2026-09-13',
    ));
    expect(fitnessDateRange(DateTime(2024, 2, 20), 'month'), (
      startDate: '2024-02-01',
      endDate: '2024-02-29',
    ));
  });

  test('首页按选中日查询，跨日计时、归档日与空态边界一致', () {
    final running = FitnessWorkout(
      id: 'running',
      name: '跨日训练',
      scheduledDate: '2026-09-10',
      status: 'in_progress',
      runSegments: [
        FitnessRunSegment(startedAt: DateTime(2026, 9, 10, 23, 50)),
      ],
    );
    final now = DateTime(2026, 9, 11, 0, 10);
    expect(fitnessWorkoutsOnDate([running], '2026-09-11', now: now), [running]);
    expect(fitnessWorkoutsOnDate([running], '2026-09-12', now: now), isEmpty);
    final ended = running.copyWith(
      status: 'completed',

      runSegments: [
        FitnessRunSegment(
          startedAt: DateTime(2026, 9, 10, 23, 50),
          endedAt: now,
        ),
      ],
    );
    expect(fitnessWorkoutsOnDate([ended], '2026-09-11', now: now), [ended]);
    expect(fitnessWorkoutsOnDate([ended], '2026-09-09', now: now), isEmpty);
  });

  test('首页选中日去重并优先运行，其他日期训练不混入', () {
    final ended = workout();
    final running = ended.copyWith(
      id: secondId,
      status: 'in_progress',
      scheduledDate: '2026-09-09',
      runSegments: [FitnessRunSegment(startedAt: time)],
    );
    final pending = const FitnessWorkout(
      id: setId,
      name: '逾期',
      scheduledDate: '2026-09-01',
    );
    const restartedId = '44444444-4444-4444-8444-444444444444';
    final restarted = workout(workoutId: restartedId, date: '2026-09-09')
        .copyWith(
          runSegments: [
            FitnessRunSegment(
              startedAt: time.subtract(const Duration(days: 1)),
              endedAt: time.subtract(const Duration(hours: 23)),
            ),
            FitnessRunSegment(
              startedAt: time,
              endedAt: time.add(const Duration(minutes: 10)),
            ),
          ],
        );
    final home = fitnessWorkoutsOnDate([
      ended,
      running,
      pending,
      restarted,
    ], '2026-09-10');
    expect(home.first.id, secondId);
    expect(home.map((w) => w.id).toSet(), {secondId, id, restartedId});
    expect(home.where((w) => w.id == restartedId).length, 1);
    expect(
      fitnessWorkoutDate(home.singleWhere((w) => w.id == restartedId)),
      '2026-09-09',
    );
    expect(home.any((w) => w.id == setId), isFalse);
    expect(fitnessWorkoutsOnDate([pending], '2026-09-01').single.id, setId);
    expect(fitnessWorkoutsOnDate([pending], '2026-09-02'), isEmpty);
  });

  test('计划与模板按最近更新排序，缺失时间回落到创建时间并排在最后', () {
    final older = time.subtract(const Duration(days: 2));
    final middle = time.subtract(const Duration(days: 1));
    FitnessTemplate item(
      String id,
      DateTime? updatedAt, {
      DateTime? createdAt,
    }) => FitnessTemplate(
      id: id,
      name: id,
      exercises: const [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
    final sorted = fitnessSortByRecent([
      item('no-time', null),
      item('older', older),
      item('newest', time),
      item('created-only', null, createdAt: middle),
    ], (t) => t.updatedAt ?? t.createdAt);
    expect(sorted.map((t) => t.id), [
      'newest',
      'created-only',
      'older',
      'no-time',
    ]);
    // 不改写调用方传入的列表
    final source = [item('a', older), item('b', time)];
    expect(fitnessSortByRecent(source, (t) => t.updatedAt).first.id, 'b');
    expect(source.first.id, 'a');
    expect(
      fitnessSortByRecent(<FitnessTemplate>[], (t) => t.updatedAt),
      isEmpty,
    );
  });

  test('组编辑：复制插到源组之后并清空成绩，删除只移除目标组，切换类型落到热身交界', () {
    const warmup = FitnessSet(
      id: 'warmup',
      kind: 'warmup',
      weight: '10',
      reps: 8,
    );
    const first = FitnessSet(id: 'first', weight: '20', reps: 6);
    const second = FitnessSet(
      id: 'second',
      weight: '30.5',
      reps: 4,
      completed: true,
      restDurationsSeconds: [60],
    );
    const sets = [warmup, first, second];

    // 复制：新身份、保留重量与次数、清空完成状态和休息记录，插在源组之后
    final copied = fitnessEditSets(sets, 2, 'copy');
    expect(copied.map((s) => s.id), [
      'warmup',
      'first',
      'second',
      copied.last.id,
    ]);
    expect(copied.last.id, isNot('second'));
    expect(copied.last.weight, '30.5');
    expect(copied.last.reps, 4);
    expect(copied.last.kind, 'working');
    expect(copied.last.completed, isFalse);
    expect(copied.last.restDurationsSeconds, isEmpty);
    // 复制不改写调用方列表
    expect(sets.map((s) => s.id), ['warmup', 'first', 'second']);

    // 删除：只移除目标组，其余组顺序和成绩不变
    final deleted = fitnessEditSets(copied, 2, 'delete');
    expect(deleted.map((s) => s.id), ['warmup', 'first', copied.last.id]);
    expect(deleted.first.weight, '10');

    // 切换类型：插到热身与正式组交界处，组数据不带走
    final toWarmup = fitnessEditSets(deleted, 2, 'toggleKind');
    expect(toWarmup.map((s) => s.id), ['warmup', copied.last.id, 'first']);
    expect(toWarmup[1].kind, 'warmup');
    expect(toWarmup[1].weight, '30.5');
    final toWorking = fitnessEditSets(toWarmup, 0, 'toggleKind');
    expect(toWorking.map((s) => s.id), [copied.last.id, 'warmup', 'first']);
    expect(toWorking[1].kind, 'working');
    // 没有正式组时切换排到末尾，不丢组
    final onlyWarmup = fitnessEditSets(const [warmup], 0, 'toggleKind');
    expect(onlyWarmup.single.id, 'warmup');
    expect(onlyWarmup.single.kind, 'working');
  });

  test('拖动排序只改顺序，组重量、次数与完成状态原样保留', () {
    const first = FitnessExercise(
      id: 'first',
      exerciseId: '0025',
      sets: [
        FitnessSet(id: 'first-set', weight: '20.125', reps: 8, completed: true),
      ],
    );
    const second = FitnessExercise(
      id: 'second',
      exerciseId: '0025',
      sets: [FitnessSet(id: 'second-set', weight: '30', reps: 6)],
    );
    final moved = fitnessReorderItems(const [first, second], 0, 1);
    expect(moved.map((e) => e.id), ['second', 'first']);
    expect(moved.last.sets.single.id, 'first-set');
    expect(moved.last.sets.single.weight, '20.125');
    expect(moved.last.sets.single.reps, 8);
    expect(moved.last.sets.single.completed, isTrue);
    // 首尾互拖保持顺序与数据一致
    expect(fitnessReorderItems(moved, 1, 0).map((e) => e.id), [
      'first',
      'second',
    ]);
    expect(fitnessReorderItems(moved, 0, 1).map((e) => e.id), [
      'first',
      'second',
    ]);
    // 排序不改写调用方列表
    final source = [first, second];
    fitnessReorderItems(source, 0, 1);
    expect(source.map((e) => e.id), ['first', 'second']);
  });

  test('次数与秒数输入只接受模型范围内的整数，超范围输入不产生值', () {
    expect(fitnessPositiveInt('8'), 8);
    expect(
      fitnessPositiveInt('${FitnessDefaults.maxInteger}'),
      FitnessDefaults.maxInteger,
    );
    for (final invalid in [
      '${FitnessDefaults.maxInteger + 1}',
      '0',
      '-1',
      '',
      '8.5',
      'x',
    ]) {
      expect(fitnessPositiveInt(invalid), isNull, reason: invalid);
    }
    // 休息秒数弹层：默认上限即模型整数上限，纠正后可提交
    expect(fitnessValidIntegerInput('90'), isTrue);
    expect(fitnessValidIntegerInput(' 90 '), isTrue);
    expect(fitnessValidIntegerInput('0'), isTrue);
    expect(fitnessValidIntegerInput('${FitnessDefaults.maxInteger}'), isTrue);
    for (final invalid in [
      '${FitnessDefaults.maxInteger + 1}',
      '-1',
      '',
      '9.5',
      'x',
    ]) {
      expect(fitnessValidIntegerInput(invalid), isFalse, reason: invalid);
    }
    // 周期天数等自定区间沿用同一条边界
    expect(fitnessValidIntegerInput('1', minValue: 1, maxValue: 36500), isTrue);
    expect(
      fitnessValidIntegerInput('0', minValue: 1, maxValue: 36500),
      isFalse,
    );
    expect(
      fitnessValidIntegerInput('36501', minValue: 1, maxValue: 36500),
      isFalse,
    );
    // 落库侧的上限与输入侧一致
    expect(
      () => validateFitnessExercises([
        FitnessExercise(
          id: id,
          exerciseId: '0025',
          restSeconds: FitnessDefaults.maxInteger,
        ),
      ], execution: false),
      returnsNormally,
    );
    expect(
      () => validateFitnessExercises([
        FitnessExercise(
          id: id,
          exerciseId: '0025',
          restSeconds: FitnessDefaults.maxInteger + 1,
        ),
      ], execution: false),
      throwsA(isA<FitnessValidationException>()),
    );
  });

  test('计划完整性：周期内每一天都必须显式安排训练或休息', () {
    // 只有一天显式安排时，未安排的空白日不算休息日
    expect(fitnessPlanUnfilledDay(7, {1}), 0);
    expect(fitnessPlanUnfilledDay(7, {0, 2, 3, 4, 5, 6}), 1);
    expect(fitnessPlanUnfilledDay(7, const {}), 0);
    expect(fitnessPlanUnfilledDay(1, {0}), isNull);
    // 显式设为休息的天数同样计入已安排
    expect(fitnessPlanUnfilledDay(7, {0, 1, 2, 3, 4, 5, 6}), isNull);
    // 整份计划都是休息日时，完整性之外还要至少有一天训练
    expect(
      () => validateFitnessSchedule(
        FitnessSchedule(
          cycleDays: 2,
          days: const [
            FitnessPlanDay(dayIndex: 0),
            FitnessPlanDay(dayIndex: 1),
          ],
        ),
      ),
      throwsA(isA<FitnessValidationException>()),
    );
  });
}
