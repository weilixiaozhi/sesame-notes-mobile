/// 载荷形状声明：本版本认识的字段，以及字段内部嵌套的形状。
///
/// 集中一处的原因：严格校验（文件导入/备份恢复）与“容忍未知字段”（云同步入站）
/// 两种读法必须共用同一份字段表，否则两边会各自漂移。
/// [fields] 参与严格校验；[allowed] 是本版本已知但不参与字段白名单校验的键
/// （如 preferences 的两个派生键），剥离未知字段时必须保留。
class FitnessPayloadShape {
  const FitnessPayloadShape(
    this.fields, {
    this.allowed = const [],
    this.nested = const {},
    this.nestedList = const {},
  });

  final List<String> fields;
  final List<String> allowed;
  final Map<String, FitnessPayloadShape> nested;
  final Map<String, FitnessPayloadShape> nestedList;
}

/// 组的重量字段同时声明总重与左右单侧重量，由业务规则约束二者互斥且左右成对。
const fitnessSetShape = FitnessPayloadShape([
  'id',
  'kind',
  'weight',
  'weight_left',
  'weight_right',
  'reps',
  'completed',
  'rest_durations_seconds',
]);

const fitnessExerciseShape = FitnessPayloadShape(
  ['id', 'exercise_id', 'rest_seconds', 'warmup_rest_seconds', 'sets'],
  nestedList: {'sets': fitnessSetShape},
);

/// 官方来源仅是副本的只读识别信息，不作为用户实体之间的关系字段。
const fitnessCatalogOriginShape = FitnessPayloadShape([
  'source',
  'item_id',
  'revision',
]);

const fitnessTemplateShape = FitnessPayloadShape(
  ['id', 'name', 'exercises', 'catalog_origin', 'created_at', 'updated_at'],
  nestedList: {'exercises': fitnessExerciseShape},
  nested: {'catalog_origin': fitnessCatalogOriginShape},
);

const fitnessPlanSlotShape = FitnessPayloadShape(
  ['id', 'source_template_id', 'name', 'exercises'],
  nestedList: {'exercises': fitnessExerciseShape},
);

const fitnessPlanDayShape = FitnessPayloadShape(
  ['day_index', 'slot'],
  nested: {'slot': fitnessPlanSlotShape},
);

const fitnessScheduleShape = FitnessPayloadShape(
  ['cycle_days', 'days'],
  nestedList: {'days': fitnessPlanDayShape},
);

const fitnessGeneratedCycleShape = FitnessPayloadShape([
  'cycle_index',
  'start_date',
  'cycle_days',
  'generated_from_date',
  'rest_dates',
]);

const fitnessGenerationStateShape = FitnessPayloadShape(
  ['next_cycle_start_date', 'next_cycle_index', 'generated_cycles'],
  nestedList: {'generated_cycles': fitnessGeneratedCycleShape},
);

const fitnessPlanShape = FitnessPayloadShape(
  [
    'id',
    'name',
    'catalog_origin',
    'start_date',
    'cycle_days',
    'status',
    'days',
    'generation_state',
    'pending_schedule',
    'created_at',
    'updated_at',
  ],
  nestedList: {'days': fitnessPlanDayShape},
  nested: {
    'catalog_origin': fitnessCatalogOriginShape,
    'generation_state': fitnessGenerationStateShape,
    'pending_schedule': fitnessScheduleShape,
  },
);

const fitnessRunSegmentShape = FitnessPayloadShape(['started_at', 'ended_at']);

const fitnessRestTimerShape = FitnessPayloadShape([
  'status',
  'ends_at',
  'remaining_seconds',
  'duration_seconds',
  'elapsed_seconds',
  'exercise_id',
  'set_id',
]);

const fitnessWorkoutShape = FitnessPayloadShape(
  [
    'id',
    'name',
    'scheduled_date',
    'source_kind',
    'source_plan_id',
    'source_plan_name',
    'source_template_id',
    'occurrence_key',
    'exercises',
    'status',
    'run_segments',
    'rest_timer',
    'created_at',
    'updated_at',
  ],
  nestedList: {
    'exercises': fitnessExerciseShape,
    'run_segments': fitnessRunSegmentShape,
  },
  nested: {'rest_timer': fitnessRestTimerShape},
);

const fitnessExerciseRestShape = FitnessPayloadShape([
  'rest_seconds',
  'warmup_rest_seconds',
]);

const fitnessPreferencesShape = FitnessPayloadShape(
  [
    'custom_exercises',
    'id',
    'default_rest_seconds',
    'sound_enabled',
    'vibration_enabled',
    'pinned_exercise_ids',
    'exercise_weight_modes',
    'created_at',
    'updated_at',
  ],
  allowed: ['exercise_rest_settings', 'default_warmup_rest_seconds'],
  nestedList: {'custom_exercises': fitnessCustomExerciseShape},
);

/// 实体类型 → 顶层形状（同步入站按它剥离未知字段）。
const fitnessPayloadShapes = <String, FitnessPayloadShape>{
  'fitness_template': fitnessTemplateShape,
  'fitness_plan': fitnessPlanShape,
  'fitness_workout': fitnessWorkoutShape,
  'fitness_preferences': fitnessPreferencesShape,
};

/// 按形状声明剔除本版本不认识的字段（读端只增不减）。
///
/// 只删键、不动值：已知字段的类型与业务校验仍由 validateFitnessPayload 严格执行，
/// 因此远端传来错误类型依旧会失败，而“更新的客户端多带一个字段”不会让整条同步事件被拒。
Map<String, dynamic> fitnessPayloadIgnoringUnknown(
  String entityType,
  Map<String, dynamic> payload,
) {
  final shape = fitnessPayloadShapes[entityType];
  if (shape == null) return payload;
  return stripFitnessShape(payload, shape);
}

/// 递归剥离：未知键丢弃，嵌套对象/列表按子形状继续处理（非容器值原样透传）。
Map<String, dynamic> stripFitnessShape(
  Map<String, dynamic> value,
  FitnessPayloadShape shape,
) {
  final out = <String, dynamic>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (!shape.fields.contains(key) && !shape.allowed.contains(key)) continue;
    final nested = shape.nested[key];
    if (nested != null && entry.value is Map) {
      out[key] = stripFitnessShape(
        Map<String, dynamic>.from(entry.value as Map),
        nested,
      );
      continue;
    }
    final listShape = shape.nestedList[key];
    if (listShape != null && entry.value is List) {
      out[key] = [
        for (final item in entry.value as List)
          item is Map
              ? stripFitnessShape(Map<String, dynamic>.from(item), listShape)
              : item,
      ];
      continue;
    }
    out[key] = entry.value;
  }
  return out;
}

/// 自定义动作载荷形状（与 fitness.dart 的注册表同源，供嵌套校验与剥离未知字段共用）。
const fitnessCustomExerciseShape = FitnessPayloadShape([
  'id',
  'name',
  'body_part',
  'equipment',
  'icon',
  'image',
  'deleted',
]);
