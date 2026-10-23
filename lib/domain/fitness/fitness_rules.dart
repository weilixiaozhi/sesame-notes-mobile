import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:sesame_notes/data/models/fitness_catalog_snapshot.dart';
import 'dart:convert';
import 'package:decimal/decimal.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_official_reference.dart';

class FitnessValidationException implements Exception {
  final String code;
  const FitnessValidationException(this.code);
  @override
  String toString() => code;
}

class FitnessRunningWorkoutException implements Exception {
  final FitnessWorkout existingWorkout;
  const FitnessRunningWorkoutException(this.existingWorkout);
}

void fitnessRequire(bool condition, String code) {
  if (!condition) throw FitnessValidationException(code);
}

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[45][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
void validateFitnessId(String id) =>
    fitnessRequire(_uuid.hasMatch(id), 'FITNESS_ID');

/// 发生身份和内容联合校验，导入/同步同样不能制造无法上传的计划训练。
void validateFitnessIdentity(
  String entityType,
  String id,
  Map<String, dynamic> payload,
) {
  validateFitnessId(id);
  if (entityType == 'fitness_workout' && payload['occurrence_key'] != null) {
    fitnessRequire(
      const Uuid().v5(
            payload['source_plan_id'] as String,
            payload['occurrence_key'] as String,
          ) ==
          id,
      'FITNESS_OCCURRENCE',
    );
  }
}

bool fitnessValidExerciseId(String id) =>
    fitnessOfficialReference(id) ||
    id.startsWith('custom:') && _uuid.hasMatch(id.substring(7));

/// 单侧器械：一次训练左右各持一件，默认按左右分别记录重量。
/// 目录里其余器械（杠铃、器械、绳索、自重等）默认只记录总重量。
const fitnessSideWeightEquipments = {'dumbbell', 'kettlebell'};

/// 未显式设置口径的动作按器械推导默认值；器械未知时按总重量处理。
bool fitnessSideWeightDefault(String? equipment) =>
    equipment != null && fitnessSideWeightEquipments.contains(equipment);

/// 已有组数据的口径：出现左右重量即为分侧，只出现总重量即为总重，没有重量数据返回 null。
bool? fitnessSideWeightFromSets(Iterable<FitnessSet> sets) {
  var sawTotal = false;
  for (final set in sets) {
    if (set.weightLeft != null || set.weightRight != null) return true;
    if (set.weight != null) sawTotal = true;
  }
  return sawTotal ? false : null;
}

/// 同动作各实例共用已有成绩的口径，全部空白时才取用户偏好和器械默认值。
/// 编辑历史记录时按数据本身呈现，其他训练的偏好变化不能隐藏已有重量。
bool fitnessUsesSideWeight(
  FitnessPreferences preferences, {
  required String exerciseId,
  String? equipment,
  bool? dataUsesSideWeight,
}) =>
    dataUsesSideWeight ??
    preferences.exerciseWeightModes[exerciseId] ??
    fitnessSideWeightDefault(equipment);

final _weight = RegExp(r'^(0|[1-9][0-9]{0,17})(\.[0-9]{1,10})?$');
bool fitnessValidWeight(String value) => _weight.hasMatch(value);

/// 次数输入只接受模型范围内的正整数；超范围输入返回 null，不产生成绩值。
int? fitnessPositiveInt(String raw) {
  final number = int.tryParse(raw);
  return number != null && number > 0 && number <= FitnessDefaults.maxInteger
      ? number
      : null;
}

/// 数值弹层的整数校验：去空白后必须是 [minValue, maxValue] 区间内的整数。
bool fitnessValidIntegerInput(
  String value, {
  int minValue = 0,
  int maxValue = FitnessDefaults.maxInteger,
}) {
  final number = int.tryParse(value.trim());
  return number != null && number >= minValue && number <= maxValue;
}

String fitnessDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
DateTime fitnessParseDate(String value) {
  fitnessRequire(
    RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value),
    'FITNESS_DATE',
  );
  final date = DateTime.tryParse(value);
  fitnessRequire(
    date != null && date.year > 0 && fitnessDate(date) == value,
    'FITNESS_DATE',
  );
  return date!;
}

String fitnessAddDays(String value, int days) {
  final date = fitnessParseDate(value);
  return fitnessDate(DateTime(date.year, date.month, date.day + days));
}

int fitnessDaysBetween(String a, String b) {
  final x = fitnessParseDate(a), y = fitnessParseDate(b);
  return DateTime.utc(
    y.year,
    y.month,
    y.day,
  ).difference(DateTime.utc(x.year, x.month, x.day)).inDays;
}

bool fitnessValidName(String name) => isValidName(name);
void _name(String name) =>
    fitnessRequire(fitnessValidName(name), 'FITNESS_NAME');

/// 所有写入共用名称规范化，不修改调用方的快照。
Map<String, dynamic> normalizeFitnessNames(Map<String, dynamic> payload) {
  Object? normalize(Object? value, [String? field]) {
    if (value is String &&
        (field == 'name' || (field?.endsWith('_name') ?? false))) {
      return normalizeName(value);
    }
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key as String: normalize(entry.value, entry.key as String),
      };
    }
    if (value is List) return [for (final child in value) normalize(child)];
    return value;
  }

  try {
    return normalize(payload) as Map<String, dynamic>;
  } on FormatException {
    throw const FitnessValidationException('FITNESS_NAME');
  }
}

void _nonNegative(int n) =>
    fitnessRequire(n >= 0 && n <= FitnessDefaults.maxInteger, 'FITNESS_NUMBER');
void _unique(Iterable<String> ids) =>
    fitnessRequire(ids.toSet().length == ids.length, 'FITNESS_DUPLICATE_ID');

/// 来源标记只接受当前官方目录身份，避免任意来源类型进入同步载荷。
void _validateCatalogOrigin(FitnessCatalogOrigin? origin) {
  if (origin == null) return;
  fitnessRequire(origin.source == 'official', 'FITNESS_CATALOG_ORIGIN');
  validateFitnessId(origin.itemId);
  fitnessRequire(
    origin.revision > 0 && origin.revision <= FitnessDefaults.maxInteger,
    'FITNESS_CATALOG_ORIGIN',
  );
}

/// 重量字段必须是合法小数或留空，且一组不能同时保留总重与左右重量两种口径。
/// 只填单边属于编辑中的草稿，允许保存但不构成完整口径。
bool fitnessValidSetWeight(FitnessSet set) {
  for (final weight in [set.weight, set.weightLeft, set.weightRight]) {
    if (weight != null && !fitnessValidWeight(weight)) return false;
  }
  return set.weight == null ||
      (set.weightLeft == null && set.weightRight == null);
}

/// 重量口径是否完整：左右同时留空（总重或自重）或同时填写；只填单边不完整。
bool fitnessSetWeightComplete(FitnessSet set) =>
    (set.weightLeft == null) == (set.weightRight == null);

/// 完成组必须具备合法重量口径与正整数次数。
bool fitnessSetIsValid(FitnessSet set) =>
    FitnessDefaults.setKinds.contains(set.kind) &&
    fitnessValidSetWeight(set) &&
    fitnessSetWeightComplete(set) &&
    set.reps != null &&
    set.reps! > 0 &&
    set.reps! <= FitnessDefaults.maxInteger;

/// 校验动作身份、组配置及执行状态，处方不能携带已完成组的休息记录。
void validateFitnessExercises(
  List<FitnessExercise> exercises, {
  required bool execution,
}) {
  fitnessRequire(
    exercises.length <= FitnessDefaults.maxItems,
    'FITNESS_EXERCISE_LIMIT',
  );
  _unique(exercises.map((e) => e.id));
  final modes = <String, bool>{};
  for (final e in exercises) {
    validateFitnessId(e.id);
    fitnessRequire(fitnessValidExerciseId(e.exerciseId), 'FITNESS_EXERCISE_ID');
    _nonNegative(e.restSeconds);
    if (e.warmupRestSeconds != null) _nonNegative(e.warmupRestSeconds!);
    fitnessRequire(
      e.sets.length <= FitnessDefaults.maxItems,
      'FITNESS_SET_LIMIT',
    );
    _unique(e.sets.map((s) => s.id));
    for (final s in e.sets) {
      validateFitnessId(s.id);
      fitnessRequire(
        FitnessDefaults.setKinds.contains(s.kind),
        'FITNESS_SET_KIND',
      );
      fitnessRequire(fitnessValidSetWeight(s), 'FITNESS_WEIGHT');
      // 同一目录动作的全部实例共用口径；空白或自重组不参与口径判定。
      final side = s.weightLeft != null || s.weightRight != null;
      if (side || s.weight != null) {
        fitnessRequire(
          !modes.containsKey(e.exerciseId) || modes[e.exerciseId] == side,
          'FITNESS_WEIGHT_MODE',
        );
        modes[e.exerciseId] = side;
      }
      for (final n in [s.reps]) {
        if (n != null) {
          fitnessRequire(
            n > 0 && n <= FitnessDefaults.maxInteger,
            'FITNESS_REPS',
          );
        }
      }
      fitnessRequire(
        s.restDurationsSeconds.length <= FitnessDefaults.maxItems &&
            (s.restDurationsSeconds.isEmpty || execution && s.completed),
        'FITNESS_REST_TIMER',
      );
      for (final seconds in s.restDurationsSeconds) {
        _nonNegative(seconds);
      }
      fitnessRequire(
        !execution || !s.completed || fitnessSetIsValid(s),
        'FITNESS_SET_INCOMPLETE',
      );
    }
  }
}

void validateFitnessSchedule(FitnessSchedule schedule) {
  fitnessRequire(
    schedule.cycleDays > 0 &&
        schedule.cycleDays <= FitnessDefaults.maxCycleDays,
    'FITNESS_CYCLE_DAYS',
  );
  fitnessRequire(
    schedule.days.length == schedule.cycleDays,
    'FITNESS_CYCLE_DAYS_MISSING',
  );
  _unique(schedule.days.map((d) => d.dayIndex.toString()));
  fitnessRequire(
    schedule.days.any((d) => d.slot != null),
    'FITNESS_EMPTY_PLAN',
  );
  _unique(schedule.days.map((d) => d.slot?.id).whereType<String>());
  for (final day in schedule.days) {
    fitnessRequire(
      day.dayIndex >= 0 && day.dayIndex < schedule.cycleDays,
      'FITNESS_PLAN_DAY',
    );
    if (day.slot case final slot?) {
      validateFitnessId(slot.id);
      if (slot.sourceTemplateId != null) {
        validateFitnessId(slot.sourceTemplateId!);
      }
      _name(slot.name);
      fitnessRequire(slot.exercises.isNotEmpty, 'FITNESS_EMPTY_TEMPLATE');
      validateFitnessExercises(slot.exercises, execution: false);
    }
  }
}

/// 计划完整性：周期内每一天都必须显式安排训练或休息，未排布的空白日不算休息日。
/// 返回第一个尚未明确安排的日序号，每一天都明确时返回 null。
int? fitnessPlanUnfilledDay(int cycleDays, Set<int> filledDays) {
  for (var index = 0; index < cycleDays; index++) {
    if (!filledDays.contains(index)) return index;
  }
  return null;
}

void _validateRawFitness(
  Object? value, {
  String key = '',
  required bool execution,
}) {
  if (value is String) {
    fitnessRequire(
      !value.contains('\u0000') && utf8.decode(utf8.encode(value)) == value,
      'FITNESS_TEXT',
    );
    if (key.endsWith('_at')) {
      final time = DateTime.tryParse(value);
      fitnessRequire(
        time != null && time.year > 0 && wireTimestamp(time) == value,
        'FITNESS_TIMESTAMP',
      );
    }
    if (key.endsWith('_date') || key == 'rest_dates') fitnessParseDate(value);
  } else if (value is List) {
    for (final item in value) {
      if (key == 'sets') {
        fitnessRequire(
          item is Map && item.containsKey('completed') == execution,
          'FITNESS_SET_STATE',
        );
        fitnessRequire(
          execution || !(item as Map).containsKey('rest_durations_seconds'),
          'FITNESS_SET_STATE',
        );
      }
      _validateRawFitness(item, key: key, execution: execution);
    }
  } else if (value is Map) {
    for (final item in value.entries) {
      _validateRawFitness(
        item.value,
        key: item.key as String,
        execution: execution,
      );
    }
  }
}

/// 导入、同步及本地写入共用严格字段与业务校验，自定义动作在偏好载荷中校验。
void validateFitnessPayload(String entityType, Map<String, dynamic> payload) {
  fitnessRequire(!payload.containsKey('id'), 'FITNESS_PAYLOAD_SHAPE');
  _validateRawFitness(payload, execution: entityType == 'fitness_workout');
  for (final key in ['created_at', 'updated_at']) {
    fitnessRequire(
      payload[key] is String &&
          DateTime.tryParse(payload[key] as String) != null,
      'FITNESS_TIMESTAMP',
    );
  }
  fitnessRequire(
    (payload['updated_at'] as String).compareTo(
          payload['created_at'] as String,
        ) >=
        0,
    'FITNESS_TIMESTAMP',
  );
  switch (entityType) {
    case 'fitness_template':
      final t = FitnessTemplate.fromJson(payload);
      _validateCatalogOrigin(t.catalogOrigin);
      _name(t.name);
      fitnessRequire(t.exercises.isNotEmpty, 'FITNESS_EMPTY_TEMPLATE');
      validateFitnessExercises(t.exercises, execution: false);
    case 'fitness_plan':
      final p = FitnessPlan.fromJson(payload);
      _validateCatalogOrigin(p.catalogOrigin);
      fitnessRequire(
        ['in_progress', 'closed'].contains(p.status),
        'FITNESS_PLAN_STATUS',
      );
      _name(p.name);
      fitnessRequire(
        p.status != 'in_progress' || p.startDate != null,
        'FITNESS_START_DATE_REQUIRED',
      );
      if (p.startDate != null) fitnessParseDate(p.startDate!);
      validateFitnessSchedule(
        FitnessSchedule(cycleDays: p.cycleDays, days: p.days),
      );
      if (p.pendingSchedule != null) {
        validateFitnessSchedule(p.pendingSchedule!);
      }
      final state = p.generationState;
      _nonNegative(state.nextCycleIndex);
      if (state.nextCycleStartDate != null) {
        fitnessParseDate(state.nextCycleStartDate!);
      }
      _unique(state.generatedCycles.map((c) => c.cycleIndex.toString()));
      fitnessRequire(
        state.generatedCycles.isEmpty || state.nextCycleStartDate != null,
        'FITNESS_GENERATION_STATE',
      );
      for (final c in state.generatedCycles) {
        fitnessRequire(
          c.cycleIndex >= 0 &&
              c.cycleIndex < state.nextCycleIndex &&
              c.cycleDays > 0 &&
              c.cycleDays <= FitnessDefaults.maxCycleDays,
          'FITNESS_GENERATION_STATE',
        );
        _unique(c.restDates);
        fitnessParseDate(c.startDate);
        fitnessParseDate(c.generatedFromDate);
        fitnessRequire(
          c.generatedFromDate.compareTo(c.startDate) >= 0 &&
              c.generatedFromDate.compareTo(
                    fitnessAddDays(c.startDate, c.cycleDays),
                  ) <
                  0,
          'FITNESS_GENERATION_STATE',
        );
        for (final date in c.restDates) {
          fitnessParseDate(date);
          fitnessRequire(
            date.compareTo(c.generatedFromDate) >= 0 &&
                date.compareTo(fitnessAddDays(c.startDate, c.cycleDays)) < 0,
            'FITNESS_REST_DATE',
          );
        }
      }
    case 'fitness_workout':
      final w = FitnessWorkout.fromJson(payload);
      _name(w.name);
      fitnessParseDate(w.scheduledDate);
      fitnessRequire(
        FitnessDefaults.sourceKinds.contains(w.sourceKind),
        'FITNESS_SOURCE',
      );
      for (final id in [w.sourcePlanId, w.sourceTemplateId]) {
        if (id != null) validateFitnessId(id);
      }
      if (w.sourceKind == 'plan') {
        fitnessRequire(
          w.sourcePlanId != null &&
              w.sourcePlanName != null &&
              w.occurrenceKey != null,
          'FITNESS_SOURCE',
        );
      } else {
        fitnessRequire(
          w.sourcePlanId == null &&
              w.sourcePlanName == null &&
              w.occurrenceKey == null,
          'FITNESS_SOURCE',
        );
      }
      if (w.sourcePlanName != null) _name(w.sourcePlanName!);
      if (w.occurrenceKey != null) {
        fitnessRequire(
          w.occurrenceKey!.isNotEmpty &&
              w.occurrenceKey!.length <= FitnessDefaults.maxOccurrenceKeyLength,
          'FITNESS_SOURCE',
        );
        final parts = w.occurrenceKey!.split(':');
        fitnessRequire(
          parts.length == 4 &&
              parts.first == w.sourcePlanId &&
              RegExp(r'^(0|[1-9]\d*)$').hasMatch(parts[1]) &&
              RegExp(r'^(0|[1-9]\d*)$').hasMatch(parts[2]) &&
              _uuid.hasMatch(parts.last),
          'FITNESS_OCCURRENCE',
        );
      }
      fitnessRequire(
        w.sourceKind != 'blank' || w.sourceTemplateId == null,
        'FITNESS_SOURCE',
      );
      fitnessRequire(
        w.sourceKind != 'template' || w.sourceTemplateId != null,
        'FITNESS_SOURCE',
      );
      fitnessRequire(
        FitnessDefaults.workoutStatuses.contains(w.status),
        'FITNESS_STATUS',
      );
      fitnessRequire(
        w.status == 'scheduled'
            ? w.runSegments.isEmpty &&
                  !w.exercises.any((e) => e.sets.any((s) => s.completed))
            : w.runSegments.isNotEmpty,
        'FITNESS_RUN_SEGMENTS',
      );
      DateTime? previousEnd;
      for (var i = 0; i < w.runSegments.length; i++) {
        final s = w.runSegments[i];
        fitnessRequire(
          previousEnd == null || !s.startedAt.isBefore(previousEnd),
          'FITNESS_RUN_SEGMENTS',
        );
        if (s.endedAt == null) {
          fitnessRequire(
            w.status == 'in_progress' && i == w.runSegments.length - 1,
            'FITNESS_RUN_SEGMENTS',
          );
        } else {
          fitnessRequire(
            !s.endedAt!.isBefore(s.startedAt),
            'FITNESS_RUN_SEGMENTS',
          );
        }
        previousEnd = s.endedAt;
      }
      final r = w.restTimer;
      fitnessRequire(
        r == null || w.status == 'in_progress',
        'FITNESS_REST_TIMER',
      );
      if (r != null) {
        _nonNegative(r.remainingSeconds);
        _nonNegative(r.durationSeconds);
        _nonNegative(r.elapsedSeconds);
        fitnessRequire(
          (r.exerciseId == null) == (r.setId == null) &&
              (r.exerciseId == null ||
                  w.exercises.any(
                    (e) =>
                        e.id == r.exerciseId &&
                        e.sets.any((s) => s.id == r.setId && s.completed),
                  )),
          'FITNESS_REST_TIMER',
        );
        fitnessRequire(
          r.status == 'running'
              ? r.endsAt != null
              : r.status == 'paused' && r.endsAt == null,
          'FITNESS_REST_TIMER',
        );
      }
      validateFitnessExercises(w.exercises, execution: true);
    case 'fitness_preferences':
      final p = FitnessPreferences.fromJson(payload);
      _unique(p.customExercises.map((e) => e.id));
      // 图片随偏好同步，整体编码内容限定为 256 KiB。
      fitnessRequire(
        p.customExercises.length <= FitnessDefaults.maxItems &&
            utf8
                    .encode(
                      jsonEncode(
                        p.customExercises.map((e) => e.toJson()).toList(),
                      ),
                    )
                    .length <=
                256 * 1024,
        'FITNESS_CUSTOM_LIMIT',
      );
      for (final e in p.customExercises) {
        fitnessRequire(
          e.id.startsWith('custom:') && fitnessValidExerciseId(e.id),
          'FITNESS_EXERCISE_ID',
        );
        _name(e.name);
        fitnessRequire(
          fitnessValidTaxonomyId(e.bodyPart) &&
              fitnessValidTaxonomyId(e.equipment) &&
              RegExp(r'^[a-zA-Z][a-zA-Z0-9]{0,63}$').hasMatch(e.icon),
          'FITNESS_CUSTOM_FIELDS',
        );
        if (e.image != null) {
          fitnessRequire(
            e.image!.isNotEmpty &&
                e.image!.length <= 65536 &&
                RegExp(
                  r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$',
                ).hasMatch(e.image!) &&
                base64Encode(base64Decode(e.image!)) == e.image,
            'FITNESS_CUSTOM_IMAGE',
          );
        }
      }
      fitnessRequire(
        p.pinnedExerciseIds.every(fitnessValidExerciseId),
        'FITNESS_EXERCISE_ID',
      );
      _nonNegative(p.defaultRestSeconds);
      if (p.defaultWarmupRestSeconds != null) {
        _nonNegative(p.defaultWarmupRestSeconds!);
      }
      for (final entry in p.exerciseRestSettings.entries) {
        fitnessRequire(
          fitnessValidExerciseId(entry.key),
          'FITNESS_EXERCISE_ID',
        );
        _nonNegative(entry.value.restSeconds);
        _nonNegative(entry.value.warmupRestSeconds);
      }
      _unique(p.pinnedExerciseIds);
      fitnessRequire(
        p.pinnedExerciseIds.every(
          (id) =>
              id.isNotEmpty && id.length <= FitnessDefaults.maxReferenceLength,
        ),
        'FITNESS_PREFERENCE_ID',
      );
      fitnessRequire(
        p.exerciseWeightModes.length <= FitnessDefaults.maxItems &&
            p.exerciseWeightModes.keys.every(
              (id) =>
                  fitnessValidExerciseId(id) &&
                  id.length <= FitnessDefaults.maxReferenceLength,
            ),
        'FITNESS_EXERCISE_ID',
      );

    default:
      throw const FitnessValidationException('FITNESS_ENTITY_TYPE');
  }
}

/// 完成组必须满足成绩契约；未完成组与热身组不计训练量，自重完成组合法计零。
Decimal fitnessSetVolume(FitnessSet s) {
  if (!s.completed) return Decimal.zero;
  fitnessRequire(fitnessSetIsValid(s), 'FITNESS_SET_INCOMPLETE');
  if (s.kind == 'warmup') return Decimal.zero;
  final weight = s.weight != null
      ? Decimal.parse(s.weight!)
      : Decimal.parse(s.weightLeft ?? '0') +
            Decimal.parse(s.weightRight ?? '0');
  return weight * Decimal.fromInt(s.reps!);
}

/// 训练归属实际首次开始日；未开始记录使用计划日期，不维护可编辑归档日期。
String fitnessWorkoutDate(FitnessWorkout workout) => workout.runSegments.isEmpty
    ? workout.scheduledDate
    : fitnessDate(workout.runSegments.first.startedAt.toLocal());

Duration fitnessElapsed(FitnessWorkout w, DateTime now) => Duration(
  milliseconds: w.runSegments.fold(
    0,
    (sum, s) =>
        sum +
        ((s.endedAt ?? now)
            .difference(s.startedAt)
            .inMilliseconds
            .clamp(0, 1 << 62)),
  ),
);
int fitnessRestRemaining(FitnessRestTimer? timer, DateTime now) => timer == null
    ? 0
    : timer.status == 'paused'
    ? timer.remainingSeconds
    : ((timer.endsAt!.difference(now).inMilliseconds / 1000).ceil()).clamp(
        0,
        FitnessDefaults.maxInteger,
      );

/// 只累计倒计时实际运行的秒数；暂停、延长目标和到期后的等待不算休息计时。
int fitnessRestElapsed(FitnessRestTimer timer, DateTime now) =>
    (timer.elapsedSeconds +
            (timer.status == 'paused'
                ? 0
                : timer.remainingSeconds -
                      fitnessRestRemaining(
                        timer,
                        now,
                      ).clamp(0, timer.remainingSeconds)))
        .clamp(0, FitnessDefaults.maxInteger);

/// 休息到点：计时运行中且剩余归零才算结束，暂停态即使剩余为零仍然是暂停。
bool fitnessRestCompleted(FitnessRestTimer? timer, DateTime now) =>
    timer?.status == 'running' && fitnessRestRemaining(timer, now) <= 0;

/// 休息到点常驻提示的归属：计时弹窗或训练详情已展开结束态时让位，
/// 同一段休息只由一个入口提示，不叠加第二个弹窗。
bool fitnessRestPromptVisible(
  FitnessRestTimer? timer,
  DateTime now, {
  required bool sheetOpen,
  required bool detailOpen,
}) => !sheetOpen && !detailOpen && fitnessRestCompleted(timer, now);

/// 常驻提示只作用于它呈现的那次计时：计时被更新、结束或训练已结束时旧提示不再生效。
bool fitnessRestPromptStillCurrent(
  FitnessWorkout? workout,
  FitnessRestTimer timer,
) =>
    workout?.status == 'in_progress' &&
    workout?.restTimer?.status == 'running' &&
    workout?.restTimer?.endsAt == timer.endsAt;

/// 关闭计时前把本次时长归入触发它的完成组，同一次计时只结算一次。
FitnessWorkout fitnessSettleRest(FitnessWorkout workout, DateTime now) {
  final timer = workout.restTimer;
  if (timer == null) return workout;
  return workout.copyWith(
    restTimer: null,
    exercises: workout.exercises
        .map(
          (e) => e.id != timer.exerciseId
              ? e
              : e.copyWith(
                  sets: e.sets
                      .map(
                        (s) => s.id != timer.setId || !s.completed
                            ? s
                            : s.copyWith(
                                restDurationsSeconds: [
                                  ...s.restDurationsSeconds,
                                  fitnessRestElapsed(timer, now),
                                ],
                              ),
                      )
                      .toList(),
                ),
        )
        .toList(),
  );
}

/// 列表拖动排序：只改变元素位置，被移动的元素本身原样保留。
List<T> fitnessReorderItems<T>(List<T> items, int from, int to) {
  final next = [...items];
  next.insert(to, next.removeAt(from));
  return next;
}

List<FitnessExercise> fitnessSnapshotExercises(
  List<FitnessExercise> exercises, {
  bool newIds = false,
}) => exercises
    .map(
      (e) => e.copyWith(
        id: newIds ? const Uuid().v4() : e.id,
        sets: e.sets
            .map(
              (s) => s.copyWith(
                id: newIds ? const Uuid().v4() : s.id,
                completed: false,
              ),
            )
            .toList(),
      ),
    )
    .toList();

/// 复制组保留配置，替换动作则清空实际字段和完成状态。
FitnessSet fitnessCopySet(FitnessSet set) =>
    set.copyWith(id: const Uuid().v4(), completed: false);

/// 组编辑：复制保留配置并插到源组之后，删除只移除目标组，
/// 切换训练类型时把该组移动到热身与正式组的交界处。
List<FitnessSet> fitnessEditSets(
  List<FitnessSet> sets,
  int setIndex,
  String action,
) {
  final next = [...sets];
  switch (action) {
    case 'copy':
      next.insert(setIndex + 1, fitnessCopySet(next[setIndex]));
    case 'delete':
      next.removeAt(setIndex);
    case 'toggleKind':
      final current = next.removeAt(setIndex);
      final firstWorking = next.indexWhere((set) => set.kind == 'working');
      // 两种切换都放到热身与正式组的交界处，组号按当前顺序计算。
      next.insert(
        firstWorking < 0 ? next.length : firstWorking,
        current.copyWith(kind: current.kind == 'warmup' ? 'working' : 'warmup'),
      );
  }
  return next;
}

/// 键盘一键改：把当前字段按方向写入同一动作内的组范围，含本行、只改同类型组。
/// 记录左右的动作按行同时写入两侧；不跨动作，也不改动其它字段。
List<FitnessSet> fitnessFillSets(
  FitnessExercise exercise, {
  required int setIndex,
  required String field,
  required String value,
  required String action,
}) {
  final current = exercise.sets[setIndex];
  final weight = value.isEmpty ? null : value;
  // 左右重量是同一行的一对数值，一键改按行同时写入两侧。
  final fillBothSides = field == 'weight_left' || field == 'weight_right';
  FitnessSet changed(FitnessSet set, {bool bothSides = false}) {
    // 每次写入只保留当前字段所属口径：填写重量即清除另一种重量的历史值。
    final next = switch (field) {
      'weight' => set.copyWith(
        weight: weight,
        weightLeft: null,
        weightRight: null,
      ),
      'weight_left' || 'weight_right' => set.copyWith(
        // 一键改把同一行的左右两侧写成同一个值，单字段输入只改自己。
        weightLeft: bothSides || field == 'weight_left'
            ? weight
            : set.weightLeft,
        weightRight: bothSides || field == 'weight_right'
            ? weight
            : set.weightRight,
        weight: null,
      ),
      _ => set.copyWith(reps: fitnessPositiveInt(value)),
    };
    // 改动后不再满足完成条件的组落回未完成，避免留下无效成绩。
    return next.completed && !fitnessSetIsValid(next)
        ? next.copyWith(completed: false)
        : next;
  }

  final sets = [...exercise.sets];
  if (action == 'add') {
    sets[setIndex] = changed(current);
    sets.insert(setIndex + 1, fitnessCopySet(sets[setIndex]));
  } else {
    for (var i = 0; i < sets.length; i++) {
      // 按当前视觉顺序，含本行，只更新同种训练组的当前字段。
      if (sets[i].kind == current.kind &&
          (action == 'above' ? i <= setIndex : i >= setIndex)) {
        sets[i] = changed(sets[i], bothSides: fillBothSides);
      }
    }
  }
  return sets;
}

/// 动作列表排序：置顶动作在所有筛选下排最前，其余先按部位分组顺序、
/// 再按目录原序；[recentOrder] 非空时未置顶动作改按最近使用顺序排列。
List<FitnessExerciseDefinition> fitnessSortExercises(
  Iterable<FitnessExerciseDefinition> exercises, {
  required List<FitnessExerciseDefinition> catalog,
  required List<String> pinnedIds,
  List<String>? recentOrder,
}) {
  final parts = ['custom', ...catalog.map((e) => e.bodyPart).toSet()];
  final catalogOrder = {
    for (var i = 0; i < catalog.length; i++) catalog[i].id: i,
  };
  final sorted = exercises.toList();
  int byPinned(FitnessExerciseDefinition a, FitnessExerciseDefinition b) =>
      (pinnedIds.contains(b.id) ? 1 : 0).compareTo(
        pinnedIds.contains(a.id) ? 1 : 0,
      );
  sorted.sort((a, b) {
    final pin = byPinned(a, b);
    if (pin != 0) return pin;
    final part = parts.indexOf(a.bodyPart).compareTo(parts.indexOf(b.bodyPart));
    return part != 0
        ? part
        : catalogOrder[a.id]!.compareTo(catalogOrder[b.id]!);
  });
  if (recentOrder != null) {
    sorted.sort((a, b) {
      final pin = byPinned(a, b);
      return pin != 0
          ? pin
          : recentOrder.indexOf(a.id).compareTo(recentOrder.indexOf(b.id));
    });
  }
  return sorted;
}

/// 计划与模板统一按最近更新优先排序：没有更新时间的条目回落到创建时间，
/// 两者都缺失的条目排在最后，首页预览因此总是显示最近使用的条目。
List<T> fitnessSortByRecent<T>(
  Iterable<T> items,
  DateTime? Function(T) timestamp,
) {
  final sorted = items.toList();
  sorted.sort((a, b) {
    final left = timestamp(a), right = timestamp(b);
    if (left == null || right == null) {
      return left == right
          ? 0
          : left == null
          ? 1
          : -1;
    }
    return right.compareTo(left);
  });
  return sorted;
}

/// 切换重量口径时迁移该组数值：切到左右时把总重同时填入两侧，切回总重时清空左右。
/// 两种口径的重量含义不同（单侧与两侧合计），不做数值换算。
FitnessSet fitnessMigrateSetWeight(FitnessSet set, {required bool side}) => side
    ? set.copyWith(
        weight: null,
        weightLeft: set.weightLeft ?? set.weight,
        weightRight: set.weightRight ?? set.weight,
      )
    : set.copyWith(weightLeft: null, weightRight: null);

/// 在当前草稿中统一迁移同一目录动作的全部实例，保持顺序、身份和其他组数据。
/// 调用方传入最新列表；返回新列表，不修改原始草稿或其他目录动作。
List<FitnessExercise> fitnessSetExerciseWeightMode(
  List<FitnessExercise> exercises, {
  required String exerciseId,
  required bool sideWeight,
}) => [
  for (final exercise in exercises)
    if (exercise.exerciseId == exerciseId)
      exercise.copyWith(
        sets: [
          for (final set in exercise.sets)
            fitnessMigrateSetWeight(set, side: sideWeight),
        ],
      )
    else
      exercise,
];

FitnessExercise fitnessReplaceExercise(
  FitnessExercise old, {
  required String exerciseId,
}) => old.copyWith(
  exerciseId: exerciseId,
  sets: old.sets.map((s) => FitnessSet(id: s.id, kind: s.kind)).toList(),
);

typedef FitnessGenerationResult = ({
  FitnessPlan plan,
  List<FitnessWorkout> workouts,
});

/// 只推进未生成周期。持久化游标、快照、墓碑和 outbox 由仓储在一个事务内提交。
FitnessGenerationResult fitnessGenerate(
  FitnessPlan input,
  String today, {
  bool restart = false,
  Map<String, FitnessTemplate> templates = const {},
  Map<String, FitnessExerciseRest> restSettings = const {},
}) {
  fitnessParseDate(today);
  if (input.status != 'in_progress') return (plan: input, workouts: []);
  fitnessRequire(input.startDate != null, 'FITNESS_START_DATE_REQUIRED');
  validateFitnessId(input.id);
  validateFitnessSchedule(
    FitnessSchedule(cycleDays: input.cycleDays, days: input.days),
  );
  if (input.pendingSchedule != null) {
    validateFitnessSchedule(input.pendingSchedule!);
  }
  var p = input;
  var state = p.generationState;
  var start = restart ? p.startDate! : state.nextCycleStartDate ?? p.startDate!;
  var index = state.nextCycleIndex;
  final cycles = [...state.generatedCycles], workouts = <FitnessWorkout>[];
  var first = restart || state.nextCycleStartDate == null;
  while (first || start.compareTo(today) <= 0) {
    if (p.pendingSchedule != null) {
      p = p.copyWith(
        cycleDays: p.pendingSchedule!.cycleDays,
        days: p.pendingSchedule!.days,
        pendingSchedule: null,
      );
    }
    final end = fitnessAddDays(start, p.cycleDays);
    final rest = <String>[];
    for (final day in p.days) {
      final date = fitnessAddDays(start, day.dayIndex);
      if (day.slot == null) rest.add(date);
      if (day.slot case final slot?) {
        final template = templates[slot.sourceTemplateId];
        final key = '${p.id}:$index:${day.dayIndex}:${slot.id}';
        workouts.add(
          FitnessWorkout(
            id: const Uuid().v5(p.id, key),
            name: template?.name ?? slot.name,
            scheduledDate: date,
            sourceKind: 'plan',
            sourcePlanId: p.id,
            sourcePlanName: p.name,
            sourceTemplateId: slot.sourceTemplateId,
            occurrenceKey: key,
            exercises:
                fitnessSnapshotExercises(
                  template?.exercises ?? slot.exercises,
                ).map((e) {
                  final rest = restSettings[e.exerciseId];
                  return rest == null
                      ? e
                      : e.copyWith(
                          restSeconds: rest.restSeconds,
                          warmupRestSeconds: rest.warmupRestSeconds,
                        );
                }).toList(),
          ),
        );
      }
    }
    cycles.add(
      FitnessGeneratedCycle(
        cycleIndex: index,
        startDate: start,
        cycleDays: p.cycleDays,
        generatedFromDate: start,
        restDates: rest,
      ),
    );
    index++;
    start = end;
    first = false;
  }
  state = FitnessGenerationState(
    nextCycleStartDate: start,
    nextCycleIndex: index,
    generatedCycles: cycles,
  );
  return (plan: p.copyWith(generationState: state), workouts: workouts);
}
