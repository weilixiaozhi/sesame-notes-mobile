import 'fitness_space_fixture.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/models/fitness.dart';

import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';

String fitnessId(int n) => n == 3
    ? const Uuid().v5(fitnessId(2), '${fitnessId(2)}:0:0:${fitnessId(30)}')
    : '11111111-1111-4111-8111-${n.toString().padLeft(12, '0')}';
const fitnessTime = '2026-09-11T08:00:00.123Z';
final fitnessFixtureTime = DateTime.parse(fitnessTime);
const fitnessAudit = {'created_at': fitnessTime, 'updated_at': fitnessTime};

Map<String, dynamic> fitnessFixtureSet(
  int id, {
  bool execution = true,
  bool complete = false,
}) => {
  'id': fitnessId(id),
  'kind': complete ? 'working' : 'warmup',
  'weight': complete ? '100.1234567890' : null,
  'weight_left': null,
  'weight_right': null,
  'reps': complete ? 8 : null,
  if (execution) 'completed': complete,
  if (execution && complete) 'rest_durations_seconds': [17, 42],
};

Map<String, dynamic> fitnessFixtureExercise(int id, {bool execution = true}) =>
    {
      'id': fitnessId(id),
      'exercise_id': '0025',
      'rest_seconds': 90,
      'warmup_rest_seconds': 0,
      'sets': [
        fitnessFixtureSet(id + 1, execution: execution),
        fitnessFixtureSet(id + 2, execution: execution, complete: true),
      ],
    };

Map<String, dynamic> fitnessFixtureWorkout({
  String status = 'scheduled',
  bool empty = false,
}) => {
  'name': '训练,"胸部"\n第二行',
  'scheduled_date': '2026-09-11',
  'source_kind': 'plan',
  'source_plan_id': fitnessId(2),
  'source_plan_name': '计划快照',
  'source_template_id': fitnessId(1),
  'occurrence_key': '${fitnessId(2)}:0:0:${fitnessId(30)}',
  'exercises': empty ? [] : [fitnessFixtureExercise(50)],
  'status': status,
  'run_segments': status == 'scheduled'
      ? []
      : [
          {
            'started_at': '2026-09-11T07:00:00.000Z',
            'ended_at': '2026-09-11T07:20:00.000Z',
          },
          {
            'started_at': '2026-09-11T07:40:00.000Z',
            'ended_at': status == 'in_progress'
                ? null
                : '2026-09-11T08:00:00.000Z',
          },
        ],
  'rest_timer': status == 'in_progress'
      ? {
          'status': 'paused',
          'ends_at': null,
          'remaining_seconds': 15,
          'duration_seconds': 90,
          'elapsed_seconds': 10,
          'exercise_id': fitnessId(50),
          'set_id': fitnessId(52),
        }
      : null,
  ...fitnessAudit,
};

/// 独立固定协议夹具：空训练、未完成组、休息日、暂停规则都有真实字段。
List<FitnessTransferRecord> fitnessFixture({
  String scope = '',
  String status = 'in_progress',
}) {
  final records = <FitnessTransferRecord>[
    FitnessTransferRecord(
      id: fitnessId(1),
      entityType: 'fitness_template',
      fitnessSpaceId: scope.isEmpty ? testFitnessSpaceId() : scope,
      payload: {
        'name': '模板,"双引号"\n换行',
        'exercises': [fitnessFixtureExercise(10, execution: false)],
        ...fitnessAudit,
      },
    ),
    FitnessTransferRecord(
      id: fitnessId(2),
      entityType: 'fitness_plan',
      fitnessSpaceId: scope.isEmpty ? testFitnessSpaceId() : scope,
      payload: {
        'name': '两天计划',
        'start_date': '2026-09-11',
        'status': 'closed',
        'cycle_days': 2,
        'days': [
          {
            'day_index': 0,
            'slot': {
              'id': fitnessId(30),
              'source_template_id': fitnessId(1),
              'name': '模板快照',
              'exercises': [fitnessFixtureExercise(40, execution: false)],
            },
          },
          {'day_index': 1, 'slot': null},
        ],
        'generation_state': {
          'next_cycle_start_date': '2026-09-13',
          'next_cycle_index': 1,
          'generated_cycles': [
            {
              'cycle_index': 0,
              'start_date': '2026-09-11',
              'cycle_days': 2,
              'generated_from_date': '2026-09-11',
              'rest_dates': ['2026-09-12'],
            },
          ],
        },
        'pending_schedule': null,
        ...fitnessAudit,
      },
    ),
    FitnessTransferRecord(
      id: fitnessId(3),
      entityType: 'fitness_workout',
      fitnessSpaceId: scope.isEmpty ? testFitnessSpaceId() : scope,
      payload: fitnessFixtureWorkout(status: status),
    ),
    FitnessTransferRecord(
      id: fitnessId(4),
      entityType: 'fitness_workout',
      fitnessSpaceId: scope.isEmpty ? testFitnessSpaceId() : scope,
      payload: {
        ...fitnessFixtureWorkout(status: 'completed', empty: true),
        'source_kind': 'blank',
        'source_plan_id': null,
        'source_plan_name': null,
        'source_template_id': null,
        'occurrence_key': null,
      },
    ),
    FitnessTransferRecord(
      id: fitnessId(7),
      entityType: 'fitness_preferences',
      fitnessSpaceId: scope.isEmpty ? testFitnessSpaceId() : scope,
      payload: {
        ...const FitnessPreferences().toJson(),
        'default_rest_seconds': 120,
        'sound_enabled': false,
        'vibration_enabled': true,
        'custom_exercises': [],
        'pinned_exercise_ids': ['0025'],
        ...fitnessAudit,
      },
    ),
  ];
  return records;
}

Map<String, dynamic> fitnessDeepCopy(Map<String, dynamic> value) =>
    jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
FitnessTransferDocument fitnessDocument({
  List<FitnessTransferRecord>? records,
  int export = 100,
}) => FitnessTransferDocument(
  fitnessId(export),
  fitnessFixtureTime,
  records ?? fitnessFixture(),
  space: fixtureFitnessSpace(
    records?.firstOrNull?.fitnessSpaceId ?? testFitnessSpaceId(),
  ),
);
