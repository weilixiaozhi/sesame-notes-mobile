import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../../data/models/fitness.dart';
import '../../../data/models/fitness_catalog.dart';
import '../../../data/models/fitness_official_reference.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'transfer_table.dart';

String fitnessTransferType(Object? value) => switch (value?.toString().trim()) {
  '计划' || 'plan' || 'fitness_plan' => 'fitness_plan',
  '模板' || 'template' || 'fitness_template' => 'fitness_template',
  '训练' || '记录' || 'workout' || 'fitness_workout' => 'fitness_workout',
  '偏好' || 'preferences' || 'fitness_preferences' => 'fitness_preferences',
  _ => throw const FormatException('数据类型：应为计划、模板、训练或偏好'),
};

/// 表格按业务父项分组，JSON 中已经嵌套的记录仍作为一个可选择的完整条目。
String fitnessTransferGroup(Map<String, Object?> row, int index) {
  if (row['days'] != null ||
      row['exercises'] != null ||
      row['preferences'] != null) {
    return 'record:$index';
  }
  return jsonEncode([row['entity_type'], row['name'], row['scheduled_date']]);
}

class FitnessTableConverter {
  final List<FitnessExerciseDefinition> catalog;
  final Map<String, String?> exerciseMapping;
  final DateTime now;
  final String spaceId;
  FitnessTableConverter(
    this.catalog,
    this.exerciseMapping,
    this.now,
    this.spaceId,
  );

  String reference(Object value) {
    final raw = value.toString();
    return FitnessTransferFormat.uuid.hasMatch(raw)
        ? raw
        : transferId(['fitness-reference', raw]);
  }

  /// 通过动作标识或正式中英文名称识别导入动作，歧义名称交由用户选择。
  String? detectExercise(String raw) {
    if (fitnessOfficialReference(raw)) return raw;
    final normalized = normalizeTransferHeader(raw);
    final found = catalog
        .where(
          (e) => [
            e.id,
            e.nameZh,
            e.nameZhHant,
            e.nameEn,
          ].any((s) => normalizeTransferHeader(s) == normalized),
        )
        .toList();
    return found.length == 1 ? found.single.id : null;
  }

  String exerciseId(Object? value) {
    final raw = value?.toString() ?? '';
    final id = exerciseMapping.containsKey(raw)
        ? exerciseMapping[raw]
        : detectExercise(raw);
    if (id == null) throw const FormatException('动作：未匹配，请选择对应动作');
    return id;
  }

  int integer(
    Object? value,
    String field, {
    int? fallback,
    int min = 0,
    int max = FitnessDefaults.maxInteger,
  }) {
    final number = value == null || value == ''
        ? fallback
        : int.tryParse(value.toString());
    if (number == null || number < min || number > max) {
      throw FormatException('$field：数值无效');
    }
    return number;
  }

  Object? structured(Object? value) =>
      value is String && value.isNotEmpty ? jsonDecode(value) : value;

  List<FitnessExercise> exercises(Object? value, String seed, bool execution) {
    final list = structured(value);
    if (list is! List) throw const FormatException('动作与组：应为数组');
    return [
      for (var i = 0; i < list.length; i++)
        exercise(
          Map<String, Object?>.from(list[i] as Map),
          '$seed:$i',
          execution,
        ),
    ];
  }

  FitnessExercise exercise(
    Map<String, Object?> row,
    String seed,
    bool execution,
  ) {
    final rawSets = structured(row['sets']);
    final sets = rawSets == null
        ? List.generate(
            integer(
              row['set_count'],
              '组数',
              fallback: 1,
              min: 1,
              max: FitnessDefaults.maxItems,
            ),
            (_) => row,
          )
        : rawSets is List
        ? rawSets.map((s) => Map<String, Object?>.from(s as Map)).toList()
        : throw const FormatException('组：应为数组');
    // 表格里的空单元格表示未填写重量，空串不进入重量契约。
    String? weight(Object? value) {
      final raw = value?.toString().trim() ?? '';
      return raw.isEmpty ? null : raw;
    }

    return FitnessExercise(
      id: row['id'] == null
          ? transferId([seed, 'exercise'])
          : reference(row['id']!),
      exerciseId: exerciseId(row['exercise'] ?? row['exercise_id']),
      restSeconds: integer(
        row['rest_seconds'],
        '休息秒数',
        fallback: FitnessDefaults.restSeconds,
      ),
      warmupRestSeconds: row['warmup_rest_seconds'] == null
          ? null
          : integer(row['warmup_rest_seconds'], '热身休息秒数'),
      sets: [
        for (var i = 0; i < sets.length; i++)
          FitnessSet(
            id: sets[i]['id'] == null
                ? transferId([seed, 'set', i])
                : reference(sets[i]['id']!),
            kind: switch (sets[i]['kind']?.toString()) {
              '热身' => 'warmup',
              '正式' => 'working',
              null || '' => 'working',
              final s => s,
            },
            weight: weight(sets[i]['weight']),
            weightLeft: weight(sets[i]['weight_left']),
            weightRight: weight(sets[i]['weight_right']),
            reps: sets[i]['reps'] == null
                ? null
                : integer(sets[i]['reps'], '次数', min: 1),
            completed: execution && transferBool(sets[i]['completed'], '完成'),
            restDurationsSeconds: sets[i]['rest_durations_seconds'] == null
                ? const []
                : List<int>.from(sets[i]['rest_durations_seconds'] as List),
          ),
      ],
    );
  }

  FitnessTransferRecord convert(List<Map<String, Object?>> rows, String id) {
    final row = rows.first;
    for (final field in ['cycle_days', 'start_date', 'status']) {
      if (rows.map((r) => r[field]).toSet().length > 1) {
        throw FormatException('$field：同一计划／训练的值不一致');
      }
    }
    final type = fitnessTransferType(row['entity_type']);
    final created = transferTimestamp(row['created_at'], now, '创建时间');
    final updated = transferTimestamp(row['updated_at'], created, '修改时间');
    final name = transferText(row, 'name');
    final execution = type == 'fitness_workout';
    // 官方来源是独立副本的识别信息，导入导出原样保留但不参与身份重映射。
    final originValue = structured(row['catalog_origin']);
    final catalogOrigin = originValue == null
        ? null
        : FitnessCatalogOrigin.fromJson(
            Map<String, dynamic>.from(originValue as Map),
          );
    // 同一动作的连续组归入同一个动作，避免每一组都变成一个动作条目。
    List<FitnessExercise> groupedExercises(
      List<Map<String, Object?>> source,
      String seed,
    ) {
      final groups = <String, List<Map<String, Object?>>>{};
      for (final r in source) {
        groups.putIfAbsent(exerciseId(r['exercise']), () => []).add(r);
      }
      return [
        for (final entry in groups.entries)
          FitnessExercise(
            id: transferId([seed, entry.key]),
            exerciseId: entry.key,
            restSeconds: integer(
              entry.value.first['rest_seconds'],
              '休息秒数',
              fallback: FitnessDefaults.restSeconds,
            ),
            sets: [
              for (var i = 0; i < entry.value.length; i++)
                ...exercise(
                  entry.value[i],
                  '$seed:${entry.key}:$i',
                  execution,
                ).sets,
            ],
          ),
      ];
    }

    List<FitnessPlanDay> planDays() {
      final raw = structured(row['days']);
      if (raw != null) {
        if (raw is! List) throw const FormatException('训练日安排：应为数组');
        return [
          for (var i = 0; i < raw.length; i++)
            () {
              final day = Map<String, Object?>.from(raw[i] as Map);
              final slot = day['slot'] == null
                  ? null
                  : Map<String, Object?>.from(day['slot'] as Map);
              return FitnessPlanDay(
                dayIndex: day['day'] != null
                    ? integer(day['day'], '训练日', min: 1) - 1
                    : integer(day['day_index'], '训练日', fallback: i),
                slot: slot == null
                    ? null
                    : FitnessPlanSlot(
                        id: slot['id'] == null
                            ? transferId([id, 'day', i])
                            : reference(slot['id']!),
                        name: slot['name']?.toString() ?? name,
                        sourceTemplateId: slot['source_template_id'] == null
                            ? null
                            : reference(slot['source_template_id']!),
                        exercises: exercises(
                          slot['exercises'],
                          '$id:day:$i',
                          false,
                        ),
                      ),
              );
            }(),
        ];
      }
      final grouped = <int, List<Map<String, Object?>>>{};
      for (final r in rows) {
        final day = integer(
          r['day'],
          '训练日',
          fallback: 1,
          min: 1,
          max: FitnessDefaults.maxCycleDays,
        );
        grouped.putIfAbsent(day - 1, () => []).add(r);
      }
      final cycle = integer(
        row['cycle_days'],
        '循环天数',
        fallback: grouped.keys.reduce((a, b) => a > b ? a : b) + 1,
        min: 1,
        max: FitnessDefaults.maxCycleDays,
      );
      if (grouped.keys.any((day) => day >= cycle)) {
        throw const FormatException('训练日：超出循环天数');
      }
      return List.generate(
        cycle,
        (i) => FitnessPlanDay(
          dayIndex: i,
          slot: grouped[i] == null
              ? null
              : FitnessPlanSlot(
                  id: transferId([id, 'day', i]),
                  name: name,
                  exercises: groupedExercises(grouped[i]!, '$id:day:$i'),
                ),
        ),
      );
    }

    Map<String, dynamic> payload;
    switch (type) {
      case 'fitness_plan':
        final days = planDays();
        final start = row['start_date'] == null
            ? null
            : fitnessDate(transferTimestamp(row['start_date'], now, '计划开始日期'));
        payload = FitnessPlan(
          name: name,
          catalogOrigin: catalogOrigin,
          startDate: start,
          status: row['status'] as String?,
          cycleDays: integer(
            row['cycle_days'],
            '循环天数',
            fallback: days.length,
            min: 1,
            max: FitnessDefaults.maxCycleDays,
          ),
          days: days,
          generationState: row['generation_state'] == null
              ? const FitnessGenerationState()
              : FitnessGenerationState.fromJson(
                  Map<String, dynamic>.from(
                    structured(row['generation_state']) as Map,
                  ),
                ),
          pendingSchedule: row['pending_schedule'] == null
              ? null
              : FitnessSchedule.fromJson(
                  Map<String, dynamic>.from(
                    structured(row['pending_schedule']) as Map,
                  ),
                ),
          createdAt: created,
          updatedAt: updated,
        ).toJson();
      case 'fitness_template':
        payload = FitnessTemplate(
          name: name,
          catalogOrigin: catalogOrigin,
          exercises: row['exercises'] == null
              ? groupedExercises(rows, id)
              : exercises(row['exercises'], id, false),
          createdAt: created,
          updatedAt: updated,
        ).toJson();
      case 'fitness_workout':
        if (row['scheduled_date'] == null) {
          throw const FormatException('训练日期：必填');
        }
        payload = FitnessWorkout(
          name: name,
          scheduledDate: fitnessDate(
            transferTimestamp(row['scheduled_date'], now, '训练日期'),
          ),
          exercises: row['exercises'] == null
              ? groupedExercises(rows, id)
              : exercises(row['exercises'], id, true),
          status: row['status'] as String? ?? 'scheduled',
          sourceKind: row['source_kind'] as String? ?? 'blank',
          sourcePlanId: row['source_plan_id'] as String?,
          sourcePlanName: row['source_plan_name'] as String?,
          sourceTemplateId: row['source_template_id'] as String?,
          occurrenceKey: row['occurrence_key'] as String?,
          runSegments: row['run_segments'] == null
              ? const []
              : (structured(row['run_segments']) as List)
                    .map(
                      (r) => FitnessRunSegment.fromJson(
                        Map<String, dynamic>.from(r as Map),
                      ),
                    )
                    .toList(),
          restTimer: row['rest_timer'] == null
              ? null
              : FitnessRestTimer.fromJson(
                  Map<String, dynamic>.from(
                    structured(row['rest_timer']) as Map,
                  ),
                ),
          createdAt: created,
          updatedAt: updated,
        ).toJson();
      case 'fitness_preferences':
        final preferences = row['preferences'] == null
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(structured(row['preferences']) as Map);
        payload = {
          ...const FitnessPreferences().toJson(),
          ...preferences,
          'created_at': preferences['created_at'] ?? wireTimestamp(created),
          'updated_at': preferences['updated_at'] ?? wireTimestamp(updated),
        };
      default:
        throw const FormatException('数据类型无效');
    }
    final sourceId = row['id']?.toString();
    var recordId = sourceId == null || sourceId.isEmpty ? id : sourceId;
    // 关联名称可以由用户自定义，内部身份由导入器生成；完整文件中的合法关系原样保留后统一重映射。
    recordId = reference(recordId);
    for (final key in ['source_plan_id', 'source_template_id']) {
      if (payload[key] != null) payload[key] = reference(payload[key]!);
    }
    if (payload['occurrence_key'] case final String occurrence) {
      final parts = occurrence.split(':');
      if (parts.length == 4) {
        payload['occurrence_key'] = [
          reference(parts[0]),
          parts[1],
          parts[2],
          reference(parts[3]),
        ].join(':');
      }
    }
    if (payload['rest_timer'] case final Map timer) {
      for (final key in ['exercise_id', 'set_id']) {
        if (timer[key] != null) timer[key] = reference(timer[key]);
      }
    }
    if (payload['source_plan_id'] != null &&
        payload['occurrence_key'] != null) {
      recordId = const Uuid().v5(
        payload['source_plan_id'] as String,
        payload['occurrence_key'] as String,
      );
    }
    validateFitnessPayload(type, payload);
    validateFitnessIdentity(type, recordId, payload);
    return FitnessTransferRecord(
      id: recordId,
      entityType: type,
      payload: payload,
      fitnessSpaceId: spaceId,
    );
  }
}
