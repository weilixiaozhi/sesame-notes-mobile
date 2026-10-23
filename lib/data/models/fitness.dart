import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'fitness_custom_exercise.dart';
import 'fitness_payload_shapes.dart';

abstract final class FitnessDefaults {
  static const restSeconds = 90;
  static const maxItems = 1000;
  static const maxCycleDays = 36500;
  static const maxInteger = 2147483647;
  static const maxReferenceLength = 128;
  static const maxOccurrenceKeyLength = 255;
  static const workoutStatuses = ['scheduled', 'in_progress', 'completed'];
  static const setKinds = ['warmup', 'working'];
  static const sourceKinds = ['blank', 'template', 'plan'];
}

Map<String, dynamic> _fitnessJson(
  Map<String, dynamic> json,
  List<String> fields, {
  bool set = false,
  bool entity = false,
  List<String> optional = const [],
}) {
  final required = fields.where(
    (k) =>
        !(set && (k == 'completed' || k == 'rest_durations_seconds')) &&
        !optional.contains(k) &&
        !(entity && k == 'id'),
  );
  // 模型使用封闭形状：校验必需字段与字段类型，拒绝未声明的键。
  // 同步入站在构造模型前按共享字段表筛选内容，文件导入直接接受严格校验。
  if (required.any((k) => !json.containsKey(k)) ||
      json.keys.any((k) => !fields.contains(k)) ||
      set && json.containsKey('completed') && json['completed'] is! bool ||
      json.containsKey('rest_durations_seconds') &&
          json['rest_durations_seconds'] is! List ||
      json.containsKey('elapsed_seconds') && json['elapsed_seconds'] is! int) {
    throw const FormatException('FITNESS_PAYLOAD_SHAPE');
  }
  return json;
}

/// 读取可选的官方来源标记：缺省表示用户自建内容，显式 null 与服务端封闭契约不符。
FitnessCatalogOrigin? _fitnessCatalogOrigin(Map<String, dynamic> json) {
  if (!json.containsKey('catalog_origin')) return null;
  final value = json['catalog_origin'];
  if (value is! Map) throw const FormatException('FITNESS_CATALOG_ORIGIN');
  return FitnessCatalogOrigin.fromJson(Map<String, dynamic>.from(value));
}

// 个人健身展示与业务模型；字段映射遵循生成客户端所用的同一 wire 契约。
const _unsetFitness = Object();

/// 一组训练的重量只有两种口径：总重 [weight]，或左右成对的 [weightLeft] / [weightRight]。
/// 三者同为 null 表示未填写重量，写入规则由 fitness_rules 统一约束。
class FitnessSet {
  final String id;
  final String kind;
  final String? weight;
  final String? weightLeft;
  final String? weightRight;
  final int? reps;
  final bool completed;
  final List<int> restDurationsSeconds;
  const FitnessSet({
    required this.id,
    this.kind = 'working',
    this.weight,
    this.weightLeft,
    this.weightRight,
    this.reps,
    this.completed = false,
    this.restDurationsSeconds = const [],
  });
  factory FitnessSet.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessSetShape.fields, set: true, entity: false);
    return FitnessSet(
      id: json['id'] as String,
      kind: json['kind'] as String,
      weight: json['weight'] as String?,
      weightLeft: json['weight_left'] as String?,
      weightRight: json['weight_right'] as String?,
      reps: json['reps'] as int?,
      completed: (json['completed'] as bool?) ?? false,
      restDurationsSeconds: List<int>.from(
        json['rest_durations_seconds'] as List? ?? const [],
      ),
    );
  }
  Map<String, dynamic> toJson({bool execution = true}) => {
    'id': id,
    'kind': kind,
    'weight': weight,
    'weight_left': weightLeft,
    'weight_right': weightRight,
    'reps': reps,
    if (execution) 'completed': completed,
    if (execution) 'rest_durations_seconds': restDurationsSeconds,
  };
  FitnessSet copyWith({
    String? id,
    String? kind,
    Object? weight = _unsetFitness,
    Object? weightLeft = _unsetFitness,
    Object? weightRight = _unsetFitness,
    Object? reps = _unsetFitness,
    bool? completed,
    List<int>? restDurationsSeconds,
  }) => FitnessSet(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    weight: identical(weight, _unsetFitness) ? this.weight : weight as String?,
    weightLeft: identical(weightLeft, _unsetFitness)
        ? this.weightLeft
        : weightLeft as String?,
    weightRight: identical(weightRight, _unsetFitness)
        ? this.weightRight
        : weightRight as String?,
    reps: identical(reps, _unsetFitness) ? this.reps : reps as int?,
    completed: completed ?? this.completed,
    restDurationsSeconds: completed == false
        ? const []
        : restDurationsSeconds ?? this.restDurationsSeconds,
  );
}

class FitnessExercise {
  final String id;
  final String exerciseId;
  final int restSeconds;
  final int? warmupRestSeconds;
  final List<FitnessSet> sets;
  const FitnessExercise({
    required this.id,
    required this.exerciseId,
    this.restSeconds = FitnessDefaults.restSeconds,
    this.warmupRestSeconds,
    this.sets = const [],
  });
  factory FitnessExercise.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessExerciseShape.fields, set: false, entity: false);
    return FitnessExercise(
      id: json['id'] as String,
      exerciseId: json['exercise_id'] as String,
      restSeconds: json['rest_seconds'] as int,
      warmupRestSeconds: json['warmup_rest_seconds'] as int?,
      sets: (json['sets'] as List)
          .map((v) => FitnessSet.fromJson(Map<String, dynamic>.from(v as Map)))
          .toList(growable: false),
    );
  }
  Map<String, dynamic> toJson({bool execution = true}) => {
    'id': id,
    'exercise_id': exerciseId,
    'rest_seconds': restSeconds,
    'warmup_rest_seconds': warmupRestSeconds,
    'sets': sets.map((v) => v.toJson(execution: execution)).toList(),
  };
  FitnessExercise copyWith({
    String? id,
    String? exerciseId,
    int? restSeconds,
    Object? warmupRestSeconds = _unsetFitness,
    List<FitnessSet>? sets,
  }) => FitnessExercise(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    restSeconds: restSeconds ?? this.restSeconds,
    warmupRestSeconds: identical(warmupRestSeconds, _unsetFitness)
        ? this.warmupRestSeconds
        : warmupRestSeconds as int?,
    sets: sets ?? this.sets,
  );
}

/// 官方内容复制到用户空间时保留的只读来源标记。
///
/// 它不参与官方内容读取，也不是外键；用户副本在创建后始终独立演进。
class FitnessCatalogOrigin {
  final String source;
  final String itemId;
  final int revision;

  const FitnessCatalogOrigin({
    this.source = 'official',
    required this.itemId,
    required this.revision,
  });

  /// 从严格 wire 结构解析来源标记。
  factory FitnessCatalogOrigin.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      json,
      fitnessCatalogOriginShape.fields,
      set: false,
      entity: false,
    );
    if (json['source'] != 'official') {
      throw const FormatException('FITNESS_CATALOG_ORIGIN_KIND');
    }
    return FitnessCatalogOrigin(
      source: json['source'] as String,
      itemId: json['item_id'] as String,
      revision: json['revision'] as int,
    );
  }

  /// 编码为同步、备份和表格导出共用的 wire 结构。
  Map<String, dynamic> toJson() => {
    'source': source,
    'item_id': itemId,
    'revision': revision,
  };
}

class FitnessTemplate {
  final String id;
  final String name;
  final List<FitnessExercise> exercises;
  final FitnessCatalogOrigin? catalogOrigin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const FitnessTemplate({
    this.id = '',
    required this.name,
    this.exercises = const [],
    this.catalogOrigin,
    this.createdAt,
    this.updatedAt,
  });
  factory FitnessTemplate.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      json,
      fitnessTemplateShape.fields,
      set: false,
      entity: true,
      optional: const ['catalog_origin'],
    );
    return FitnessTemplate(
      id: (json['id'] as String?) ?? '',
      name: json['name'] as String,
      exercises: (json['exercises'] as List)
          .map(
            (v) =>
                FitnessExercise.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(growable: false),
      catalogOrigin: _fitnessCatalogOrigin(json),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 模板处方只保存配置，完成状态与休息记录由实际训练持有。
  Map<String, dynamic> toJson() => {
    'name': name,
    'exercises': exercises.map((v) => v.toJson(execution: false)).toList(),
    if (catalogOrigin != null) 'catalog_origin': catalogOrigin!.toJson(),
    'created_at': createdAt == null ? null : wireTimestamp(createdAt!),
    'updated_at': updatedAt == null ? null : wireTimestamp(updatedAt!),
  };
  FitnessTemplate copyWith({
    String? id,
    String? name,
    List<FitnessExercise>? exercises,
    Object? catalogOrigin = _unsetFitness,
    Object? createdAt = _unsetFitness,
    Object? updatedAt = _unsetFitness,
  }) => FitnessTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
    catalogOrigin: identical(catalogOrigin, _unsetFitness)
        ? this.catalogOrigin
        : catalogOrigin as FitnessCatalogOrigin?,
    createdAt: identical(createdAt, _unsetFitness)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unsetFitness)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

class FitnessPlanSlot {
  final String id;
  final String? sourceTemplateId;
  final String name;
  final List<FitnessExercise> exercises;
  const FitnessPlanSlot({
    required this.id,
    this.sourceTemplateId,
    required this.name,
    this.exercises = const [],
  });
  factory FitnessPlanSlot.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessPlanSlotShape.fields, set: false, entity: false);
    return FitnessPlanSlot(
      id: json['id'] as String,
      sourceTemplateId: json['source_template_id'] as String?,
      name: json['name'] as String,
      exercises: (json['exercises'] as List)
          .map(
            (v) =>
                FitnessExercise.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(growable: false),
    );
  }

  /// 计划安排保存动作处方及来源，不携带组执行状态。
  Map<String, dynamic> toJson() => {
    'id': id,
    'source_template_id': sourceTemplateId,
    'name': name,
    'exercises': exercises.map((v) => v.toJson(execution: false)).toList(),
  };
  FitnessPlanSlot copyWith({
    String? id,
    Object? sourceTemplateId = _unsetFitness,
    String? name,
    List<FitnessExercise>? exercises,
  }) => FitnessPlanSlot(
    id: id ?? this.id,
    sourceTemplateId: identical(sourceTemplateId, _unsetFitness)
        ? this.sourceTemplateId
        : sourceTemplateId as String?,
    name: name ?? this.name,
    exercises: exercises ?? this.exercises,
  );
}

class FitnessPlanDay {
  final int dayIndex;
  final FitnessPlanSlot? slot;
  const FitnessPlanDay({required this.dayIndex, this.slot});
  factory FitnessPlanDay.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessPlanDayShape.fields, set: false, entity: false);
    return FitnessPlanDay(
      dayIndex: json['day_index'] as int,
      slot: json['slot'] == null
          ? null
          : FitnessPlanSlot.fromJson(
              Map<String, dynamic>.from(json['slot'] as Map),
            ),
    );
  }

  /// 编码周期节点及可选训练安排。
  Map<String, dynamic> toJson() => {
    'day_index': dayIndex,
    'slot': slot?.toJson(),
  };
  FitnessPlanDay copyWith({int? dayIndex, Object? slot = _unsetFitness}) =>
      FitnessPlanDay(
        dayIndex: dayIndex ?? this.dayIndex,
        slot: identical(slot, _unsetFitness)
            ? this.slot
            : slot as FitnessPlanSlot?,
      );
}

class FitnessSchedule {
  final int cycleDays;
  final List<FitnessPlanDay> days;
  const FitnessSchedule({required this.cycleDays, required this.days});
  factory FitnessSchedule.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessScheduleShape.fields, set: false, entity: false);
    return FitnessSchedule(
      cycleDays: json['cycle_days'] as int,
      days: (json['days'] as List)
          .map(
            (v) => FitnessPlanDay.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(growable: false),
    );
  }

  /// 编码周期长度和按日排列的计划节点。
  Map<String, dynamic> toJson() => {
    'cycle_days': cycleDays,
    'days': days.map((v) => v.toJson()).toList(),
  };
  FitnessSchedule copyWith({int? cycleDays, List<FitnessPlanDay>? days}) =>
      FitnessSchedule(
        cycleDays: cycleDays ?? this.cycleDays,
        days: days ?? this.days,
      );
}

class FitnessGeneratedCycle {
  final int cycleIndex;
  final String startDate;
  final int cycleDays;
  final String generatedFromDate;
  final List<String> restDates;
  const FitnessGeneratedCycle({
    required this.cycleIndex,
    required this.startDate,
    required this.cycleDays,
    required this.generatedFromDate,
    this.restDates = const [],
  });
  factory FitnessGeneratedCycle.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      json,
      fitnessGeneratedCycleShape.fields,
      set: false,
      entity: false,
    );
    return FitnessGeneratedCycle(
      cycleIndex: json['cycle_index'] as int,
      startDate: json['start_date'] as String,
      cycleDays: json['cycle_days'] as int,
      generatedFromDate: json['generated_from_date'] as String,
      restDates: (json['rest_dates'] as List)
          .map((v) => v as String)
          .toList(growable: false),
    );
  }
  Map<String, dynamic> toJson() => {
    'cycle_index': cycleIndex,
    'start_date': startDate,
    'cycle_days': cycleDays,
    'generated_from_date': generatedFromDate,
    'rest_dates': restDates,
  };
  FitnessGeneratedCycle copyWith({
    int? cycleIndex,
    String? startDate,
    int? cycleDays,
    String? generatedFromDate,
    List<String>? restDates,
  }) => FitnessGeneratedCycle(
    cycleIndex: cycleIndex ?? this.cycleIndex,
    startDate: startDate ?? this.startDate,
    cycleDays: cycleDays ?? this.cycleDays,
    generatedFromDate: generatedFromDate ?? this.generatedFromDate,
    restDates: restDates ?? this.restDates,
  );
}

class FitnessGenerationState {
  final String? nextCycleStartDate;
  final int nextCycleIndex;
  final List<FitnessGeneratedCycle> generatedCycles;
  const FitnessGenerationState({
    this.nextCycleStartDate,
    this.nextCycleIndex = 0,
    this.generatedCycles = const [],
  });
  factory FitnessGenerationState.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      json,
      fitnessGenerationStateShape.fields,
      set: false,
      entity: false,
    );
    return FitnessGenerationState(
      nextCycleStartDate: json['next_cycle_start_date'] as String?,
      nextCycleIndex: json['next_cycle_index'] as int,
      generatedCycles: (json['generated_cycles'] as List)
          .map(
            (v) => FitnessGeneratedCycle.fromJson(
              Map<String, dynamic>.from(v as Map),
            ),
          )
          .toList(growable: false),
    );
  }
  Map<String, dynamic> toJson() => {
    'next_cycle_start_date': nextCycleStartDate,
    'next_cycle_index': nextCycleIndex,
    'generated_cycles': generatedCycles.map((v) => v.toJson()).toList(),
  };
  FitnessGenerationState copyWith({
    Object? nextCycleStartDate = _unsetFitness,
    int? nextCycleIndex,
    List<FitnessGeneratedCycle>? generatedCycles,
  }) => FitnessGenerationState(
    nextCycleStartDate: identical(nextCycleStartDate, _unsetFitness)
        ? this.nextCycleStartDate
        : nextCycleStartDate as String?,
    nextCycleIndex: nextCycleIndex ?? this.nextCycleIndex,
    generatedCycles: generatedCycles ?? this.generatedCycles,
  );
}

class FitnessPlan {
  final String id;
  final String name;
  final FitnessCatalogOrigin? catalogOrigin;
  final String? startDate;
  final int cycleDays;
  final String status;
  final List<FitnessPlanDay> days;
  final FitnessGenerationState generationState;
  final FitnessSchedule? pendingSchedule;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const FitnessPlan({
    this.id = '',
    required this.name,
    this.catalogOrigin,
    this.startDate,
    required this.cycleDays,
    String? status,
    this.days = const [],
    this.generationState = const FitnessGenerationState(),
    this.pendingSchedule,
    this.createdAt,
    this.updatedAt,
  }) : status = status ?? (startDate == null ? 'closed' : 'in_progress');
  factory FitnessPlan.fromJson(Map<String, dynamic> json) {
    if (json['status'] != 'in_progress' && json['status'] != 'closed') {
      throw const FormatException('FITNESS_PLAN_STATUS');
    }
    _fitnessJson(
      json,
      fitnessPlanShape.fields,
      set: false,
      entity: true,
      optional: const ['catalog_origin'],
    );
    return FitnessPlan(
      id: (json['id'] as String?) ?? '',
      name: json['name'] as String,
      catalogOrigin: _fitnessCatalogOrigin(json),
      startDate: json['start_date'] as String?,
      cycleDays: json['cycle_days'] as int,
      status: json['status'] as String,
      days: (json['days'] as List)
          .map(
            (v) => FitnessPlanDay.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(growable: false),
      generationState: FitnessGenerationState.fromJson(
        Map<String, dynamic>.from(json['generation_state'] as Map),
      ),
      pendingSchedule: json['pending_schedule'] == null
          ? null
          : FitnessSchedule.fromJson(
              Map<String, dynamic>.from(json['pending_schedule'] as Map),
            ),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 编码计划配置与生成进度，节点只包含训练处方。
  Map<String, dynamic> toJson() => {
    'name': name,
    if (catalogOrigin != null) 'catalog_origin': catalogOrigin!.toJson(),
    'start_date': startDate,
    'cycle_days': cycleDays,
    'status': status,
    'days': days.map((v) => v.toJson()).toList(),
    'generation_state': generationState.toJson(),
    'pending_schedule': pendingSchedule?.toJson(),
    'created_at': createdAt == null ? null : wireTimestamp(createdAt!),
    'updated_at': updatedAt == null ? null : wireTimestamp(updatedAt!),
  };
  FitnessPlan copyWith({
    String? id,
    String? name,
    Object? catalogOrigin = _unsetFitness,
    Object? startDate = _unsetFitness,
    int? cycleDays,
    String? status,
    List<FitnessPlanDay>? days,
    FitnessGenerationState? generationState,
    Object? pendingSchedule = _unsetFitness,
    Object? createdAt = _unsetFitness,
    Object? updatedAt = _unsetFitness,
  }) => FitnessPlan(
    id: id ?? this.id,
    name: name ?? this.name,
    catalogOrigin: identical(catalogOrigin, _unsetFitness)
        ? this.catalogOrigin
        : catalogOrigin as FitnessCatalogOrigin?,
    startDate: identical(startDate, _unsetFitness)
        ? this.startDate
        : startDate as String?,
    cycleDays: cycleDays ?? this.cycleDays,
    status: status ?? this.status,
    days: days ?? this.days,
    generationState: generationState ?? this.generationState,
    pendingSchedule: identical(pendingSchedule, _unsetFitness)
        ? this.pendingSchedule
        : pendingSchedule as FitnessSchedule?,
    createdAt: identical(createdAt, _unsetFitness)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unsetFitness)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

class FitnessRunSegment {
  final DateTime startedAt;
  final DateTime? endedAt;
  const FitnessRunSegment({required this.startedAt, this.endedAt});
  factory FitnessRunSegment.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      json,
      fitnessRunSegmentShape.fields,
      set: false,
      entity: false,
    );
    return FitnessRunSegment(
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
    );
  }
  Map<String, dynamic> toJson() => {
    'started_at': wireTimestamp(startedAt),
    'ended_at': endedAt == null ? null : wireTimestamp(endedAt!),
  };
  FitnessRunSegment copyWith({
    DateTime? startedAt,
    Object? endedAt = _unsetFitness,
  }) => FitnessRunSegment(
    startedAt: startedAt ?? this.startedAt,
    endedAt: identical(endedAt, _unsetFitness)
        ? this.endedAt
        : endedAt as DateTime?,
  );
}

class FitnessRestTimer {
  final String status;
  final DateTime? endsAt;
  final int remainingSeconds;
  final int durationSeconds;
  final int elapsedSeconds;
  final String? exerciseId, setId;
  const FitnessRestTimer({
    this.status = 'running',
    this.endsAt,
    this.remainingSeconds = 0,
    this.durationSeconds = FitnessDefaults.restSeconds,
    this.elapsedSeconds = 0,
    this.exerciseId,
    this.setId,
  });
  factory FitnessRestTimer.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      json,
      fitnessRestTimerShape.fields,
      optional: ['elapsed_seconds', 'exercise_id', 'set_id'],
      set: false,
      entity: false,
    );
    return FitnessRestTimer(
      status: json['status'] as String,
      endsAt: json['ends_at'] == null
          ? null
          : DateTime.parse(json['ends_at'] as String),
      remainingSeconds: json['remaining_seconds'] as int,
      durationSeconds: json['duration_seconds'] as int,
      elapsedSeconds: (json['elapsed_seconds'] as int?) ?? 0,
      exerciseId: json['exercise_id'] as String?,
      setId: json['set_id'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'status': status,
    'ends_at': endsAt == null ? null : wireTimestamp(endsAt!),
    'remaining_seconds': remainingSeconds,
    'duration_seconds': durationSeconds,
    'elapsed_seconds': elapsedSeconds,
    'exercise_id': exerciseId,
    'set_id': setId,
  };
  FitnessRestTimer copyWith({
    String? status,
    Object? endsAt = _unsetFitness,
    int? remainingSeconds,
    int? durationSeconds,
    int? elapsedSeconds,
    Object? exerciseId = _unsetFitness,
    Object? setId = _unsetFitness,
  }) => FitnessRestTimer(
    status: status ?? this.status,
    endsAt: identical(endsAt, _unsetFitness)
        ? this.endsAt
        : endsAt as DateTime?,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    exerciseId: identical(exerciseId, _unsetFitness)
        ? this.exerciseId
        : exerciseId as String?,
    setId: identical(setId, _unsetFitness) ? this.setId : setId as String?,
  );
}

class FitnessWorkout {
  final String id;
  final String name;
  final String scheduledDate;
  final String sourceKind;
  final String? sourcePlanId;
  final String? sourcePlanName;
  final String? sourceTemplateId;
  final String? occurrenceKey;
  final List<FitnessExercise> exercises;
  final String status;
  final List<FitnessRunSegment> runSegments;
  final FitnessRestTimer? restTimer;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const FitnessWorkout({
    this.id = '',
    required this.name,
    required this.scheduledDate,
    this.sourceKind = 'blank',
    this.sourcePlanId,
    this.sourcePlanName,
    this.sourceTemplateId,
    this.occurrenceKey,
    this.exercises = const [],
    this.status = 'scheduled',
    this.runSegments = const [],
    this.restTimer,
    this.createdAt,
    this.updatedAt,
  });
  factory FitnessWorkout.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessWorkoutShape.fields, set: false, entity: true);
    return FitnessWorkout(
      id: (json['id'] as String?) ?? '',
      name: json['name'] as String,
      scheduledDate: json['scheduled_date'] as String,
      sourceKind: json['source_kind'] as String,
      sourcePlanId: json['source_plan_id'] as String?,
      sourcePlanName: json['source_plan_name'] as String?,
      sourceTemplateId: json['source_template_id'] as String?,
      occurrenceKey: json['occurrence_key'] as String?,
      exercises: (json['exercises'] as List)
          .map(
            (v) =>
                FitnessExercise.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(growable: false),
      status: json['status'] as String,
      runSegments: (json['run_segments'] as List)
          .map(
            (v) =>
                FitnessRunSegment.fromJson(Map<String, dynamic>.from(v as Map)),
          )
          .toList(growable: false),
      restTimer: json['rest_timer'] == null
          ? null
          : FitnessRestTimer.fromJson(
              Map<String, dynamic>.from(json['rest_timer'] as Map),
            ),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'scheduled_date': scheduledDate,
    'source_kind': sourceKind,
    'source_plan_id': sourcePlanId,
    'source_plan_name': sourcePlanName,
    'source_template_id': sourceTemplateId,
    'occurrence_key': occurrenceKey,
    'exercises': exercises.map((v) => v.toJson(execution: true)).toList(),
    'status': status,
    'run_segments': runSegments.map((v) => v.toJson()).toList(),
    'rest_timer': restTimer?.toJson(),
    'created_at': createdAt == null ? null : wireTimestamp(createdAt!),
    'updated_at': updatedAt == null ? null : wireTimestamp(updatedAt!),
  };
  FitnessWorkout copyWith({
    String? id,
    String? name,
    String? scheduledDate,
    String? sourceKind,
    Object? sourcePlanId = _unsetFitness,
    Object? sourcePlanName = _unsetFitness,
    Object? sourceTemplateId = _unsetFitness,
    Object? occurrenceKey = _unsetFitness,
    List<FitnessExercise>? exercises,
    String? status,
    List<FitnessRunSegment>? runSegments,
    Object? restTimer = _unsetFitness,
    Object? createdAt = _unsetFitness,
    Object? updatedAt = _unsetFitness,
  }) => FitnessWorkout(
    id: id ?? this.id,
    name: name ?? this.name,
    scheduledDate: scheduledDate ?? this.scheduledDate,
    sourceKind: sourceKind ?? this.sourceKind,
    sourcePlanId: identical(sourcePlanId, _unsetFitness)
        ? this.sourcePlanId
        : sourcePlanId as String?,
    sourcePlanName: identical(sourcePlanName, _unsetFitness)
        ? this.sourcePlanName
        : sourcePlanName as String?,
    sourceTemplateId: identical(sourceTemplateId, _unsetFitness)
        ? this.sourceTemplateId
        : sourceTemplateId as String?,
    occurrenceKey: identical(occurrenceKey, _unsetFitness)
        ? this.occurrenceKey
        : occurrenceKey as String?,
    exercises: exercises ?? this.exercises,
    status: status ?? this.status,
    runSegments: runSegments ?? this.runSegments,
    restTimer: identical(restTimer, _unsetFitness)
        ? this.restTimer
        : restTimer as FitnessRestTimer?,
    createdAt: identical(createdAt, _unsetFitness)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unsetFitness)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}

/// 同一目录动作在所有训练共用的休息设置，批量和单项编辑写入同一入口。
class FitnessExerciseRest {
  final int restSeconds, warmupRestSeconds;
  const FitnessExerciseRest({
    required this.restSeconds,
    required this.warmupRestSeconds,
  });
  factory FitnessExerciseRest.fromJson(Map<String, dynamic> json) {
    _fitnessJson(json, fitnessExerciseRestShape.fields);
    return FitnessExerciseRest(
      restSeconds: json['rest_seconds'] as int,
      warmupRestSeconds: json['warmup_rest_seconds'] as int,
    );
  }
  Map<String, dynamic> toJson() => {
    'rest_seconds': restSeconds,
    'warmup_rest_seconds': warmupRestSeconds,
  };
}

class FitnessPreferences {
  final List<FitnessCustomExercise> customExercises;
  final String id;
  final int defaultRestSeconds;
  final int? defaultWarmupRestSeconds;
  final Map<String, FitnessExerciseRest> exerciseRestSettings;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final List<String> pinnedExerciseIds;

  /// 动作级重量口径：true 记录左右重量，false 只记录总重量；
  /// 未列出的动作按器械推导默认值，显式设置优先。
  final Map<String, bool> exerciseWeightModes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const FitnessPreferences({
    this.customExercises = const [],
    this.id = '',
    this.defaultRestSeconds = FitnessDefaults.restSeconds,
    this.defaultWarmupRestSeconds,
    this.exerciseRestSettings = const {},
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.pinnedExerciseIds = const [],
    this.exerciseWeightModes = const {},
    this.createdAt,
    this.updatedAt,
  });
  factory FitnessPreferences.fromJson(Map<String, dynamic> json) {
    _fitnessJson(
      {...json}
        ..remove('exercise_rest_settings')
        ..remove('default_warmup_rest_seconds'),
      fitnessPreferencesShape.fields,
      set: false,
      entity: true,
    );
    return FitnessPreferences(
      customExercises: (json['custom_exercises'] as List)
          .map(
            (e) => FitnessCustomExercise.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
      id: (json['id'] as String?) ?? '',
      defaultRestSeconds: json['default_rest_seconds'] as int,
      defaultWarmupRestSeconds: json['default_warmup_rest_seconds'] as int?,
      exerciseRestSettings: {
        for (final entry
            in (json.containsKey('exercise_rest_settings')
                    ? json['exercise_rest_settings'] as Map
                    : const {})
                .entries)
          entry.key as String: FitnessExerciseRest.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          ),
      },
      soundEnabled: json['sound_enabled'] as bool,
      vibrationEnabled: json['vibration_enabled'] as bool,
      pinnedExerciseIds: (json['pinned_exercise_ids'] as List)
          .map((v) => v as String)
          .toList(growable: false),
      exerciseWeightModes: {
        for (final entry in (json['exercise_weight_modes'] as Map).entries)
          entry.key as String: entry.value as bool,
      },
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }
  Map<String, dynamic> toJson() => {
    'custom_exercises': customExercises.map((e) => e.toJson()).toList(),
    'default_rest_seconds': defaultRestSeconds,
    if (defaultWarmupRestSeconds != null)
      'default_warmup_rest_seconds': defaultWarmupRestSeconds,
    'exercise_rest_settings': exerciseRestSettings.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'sound_enabled': soundEnabled,
    'vibration_enabled': vibrationEnabled,
    'pinned_exercise_ids': pinnedExerciseIds,
    'exercise_weight_modes': exerciseWeightModes,
    'created_at': createdAt == null ? null : wireTimestamp(createdAt!),
    'updated_at': updatedAt == null ? null : wireTimestamp(updatedAt!),
  };
  FitnessPreferences copyWith({
    List<FitnessCustomExercise>? customExercises,
    String? id,
    int? defaultRestSeconds,
    int? defaultWarmupRestSeconds,
    Map<String, FitnessExerciseRest>? exerciseRestSettings,
    bool? soundEnabled,
    bool? vibrationEnabled,
    List<String>? pinnedExerciseIds,
    Map<String, bool>? exerciseWeightModes,
    Object? createdAt = _unsetFitness,
    Object? updatedAt = _unsetFitness,
  }) => FitnessPreferences(
    customExercises: customExercises ?? this.customExercises,
    id: id ?? this.id,
    defaultRestSeconds: defaultRestSeconds ?? this.defaultRestSeconds,
    defaultWarmupRestSeconds:
        defaultWarmupRestSeconds ?? this.defaultWarmupRestSeconds,
    exerciseRestSettings: exerciseRestSettings ?? this.exerciseRestSettings,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    pinnedExerciseIds: pinnedExerciseIds ?? this.pinnedExerciseIds,
    exerciseWeightModes: exerciseWeightModes ?? this.exerciseWeightModes,
    createdAt: identical(createdAt, _unsetFitness)
        ? this.createdAt
        : createdAt as DateTime?,
    updatedAt: identical(updatedAt, _unsetFitness)
        ? this.updatedAt
        : updatedAt as DateTime?,
  );
}
