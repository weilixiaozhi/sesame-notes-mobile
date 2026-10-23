import 'dart:ui';

import 'package:uuid/uuid.dart';

import 'fitness.dart';
import 'fitness_official_reference.dart';
import 'private_book.dart';

/// 训练内容库当前支持的唯一结构版本。
const fitnessLibrarySchemaVersion = 1;

/// 简体中文、繁体中文和英文共用的官方内容文本。
class FitnessLibraryText {
  final String zh;
  final String zhHant;
  final String en;

  const FitnessLibraryText({
    required this.zh,
    required this.zhHant,
    required this.en,
  });

  /// 从封闭 JSON 对象解析三种语言文本。
  factory FitnessLibraryText.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {'zh', 'zh_hant', 'en'});
    return FitnessLibraryText(
      zh: _text(json['zh']),
      zhHant: _text(json['zh_hant']),
      en: _text(json['en']),
    );
  }

  /// 根据当前应用语言选择文本，中文地区按繁简体区分。
  String resolve(Locale locale) {
    if (locale.languageCode != 'zh') return en;
    final traditional =
        locale.scriptCode == 'Hant' ||
        const {'TW', 'HK', 'MO'}.contains(locale.countryCode);
    return traditional ? zhHant : zh;
  }
}

/// 官方模板中的紧凑动作处方；导入时才展开为拥有新 UUID 的动作和组。
class OfficialFitnessExercise {
  final String exerciseId;
  final int sets;
  final int reps;
  final String? weightKg;
  final String weightMode;
  final int restSeconds;

  const OfficialFitnessExercise({
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.weightKg,
    required this.weightMode,
    required this.restSeconds,
  });

  /// 解析并校验动作目录引用、重量口径和组次范围。
  factory OfficialFitnessExercise.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {
      'exercise_id',
      'sets',
      'reps',
      'weight_kg',
      'weight_mode',
      'rest_seconds',
    });
    final exerciseId = _text(json['exercise_id']);
    final sets = json['sets'];
    final reps = json['reps'];
    final restSeconds = json['rest_seconds'];
    final weight = json['weight_kg'];
    final mode = json['weight_mode'];
    if (!fitnessOfficialReference(exerciseId) ||
        sets is! int ||
        sets < 1 ||
        sets > FitnessDefaults.maxItems ||
        reps is! int ||
        reps < 1 ||
        reps > FitnessDefaults.maxInteger ||
        restSeconds is! int ||
        restSeconds < 0 ||
        restSeconds > FitnessDefaults.maxInteger ||
        !const {'total', 'per_side', 'body_weight'}.contains(mode) ||
        weight != null && (weight is! String || !_weight.hasMatch(weight)) ||
        (mode == 'body_weight') != (weight == null)) {
      throw const FormatException('FITNESS_LIBRARY_EXERCISE');
    }
    return OfficialFitnessExercise(
      exerciseId: exerciseId,
      sets: sets,
      reps: reps,
      weightKg: weight as String?,
      weightMode: mode as String,
      restSeconds: restSeconds,
    );
  }

  /// 展开成用户模板动作，动作和每一组都生成属于用户的新身份。
  FitnessExercise toFitnessExercise() {
    const uuid = Uuid();
    return FitnessExercise(
      id: uuid.v4(),
      exerciseId: exerciseId,
      restSeconds: restSeconds,
      sets: List.generate(
        sets,
        (_) => FitnessSet(
          id: uuid.v4(),
          reps: reps,
          weight: weightMode == 'total' ? weightKg : null,
          weightLeft: weightMode == 'per_side' ? weightKg : null,
          weightRight: weightMode == 'per_side' ? weightKg : null,
        ),
        growable: false,
      ),
    );
  }
}

/// 模板库中的只读官方模板。
class OfficialFitnessTemplate {
  final String id;
  final int revision;
  final FitnessLibraryText name;
  final FitnessLibraryText description;
  final String difficulty;
  final Map<String, List<String>> goals;
  final int durationMinutes;
  final List<String> equipment;
  final List<OfficialFitnessExercise> exercises;

  const OfficialFitnessTemplate({
    required this.id,
    required this.revision,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.goals,
    required this.durationMinutes,
    required this.equipment,
    required this.exercises,
  });

  /// 从服务端或内置快照解析官方模板。
  factory OfficialFitnessTemplate.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {
      'id',
      'revision',
      'name',
      'description',
      'difficulty',
      'goals',
      'duration_minutes',
      'equipment',
      'exercises',
    });
    final id = _text(json['id']);
    final revision = json['revision'];
    final difficulty = json['difficulty'];
    final duration = json['duration_minutes'];
    final equipment = _stringList(json['equipment']);
    final exercises = _mapList(
      json['exercises'],
      OfficialFitnessExercise.fromJson,
    );
    if (!_uuid.hasMatch(id) ||
        revision is! int ||
        revision < 1 ||
        !const {'beginner', 'intermediate', 'advanced'}.contains(difficulty) ||
        duration is! int ||
        duration < 1 ||
        duration > 1440 ||
        equipment.isEmpty ||
        equipment.toSet().length != equipment.length ||
        exercises.isEmpty) {
      throw const FormatException('FITNESS_LIBRARY_TEMPLATE');
    }
    return OfficialFitnessTemplate(
      id: id,
      revision: revision,
      name: FitnessLibraryText.fromJson(_map(json['name'])),
      description: FitnessLibraryText.fromJson(_map(json['description'])),
      difficulty: difficulty as String,
      goals: _localizedList(json['goals']),
      durationMinutes: duration,
      equipment: equipment,
      exercises: exercises,
    );
  }

  /// 生成待导入的用户模板形状；传入 [id] 时只用于计划编辑阶段的临时引用。
  FitnessTemplate toFitnessTemplate(Locale locale, {String id = ''}) =>
      FitnessTemplate(
        id: id,
        name: name.resolve(locale),
        exercises: exercises
            .map((exercise) => exercise.toFitnessExercise())
            .toList(growable: false),
        catalogOrigin: FitnessCatalogOrigin(
          itemId: this.id,
          revision: revision,
        ),
      );
}

/// 官方计划周期中的模板引用或休息日。
class OfficialFitnessPlanDay {
  final int dayIndex;
  final String? templateId;

  const OfficialFitnessPlanDay({
    required this.dayIndex,
    required this.templateId,
  });

  /// 从封闭 JSON 对象解析周期节点。
  factory OfficialFitnessPlanDay.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {'day_index', 'template_id'});
    final index = json['day_index'];
    final templateId = json['template_id'];
    if (index is! int ||
        index < 0 ||
        templateId != null &&
            (templateId is! String || !_uuid.hasMatch(templateId))) {
      throw const FormatException('FITNESS_LIBRARY_PLAN_DAY');
    }
    return OfficialFitnessPlanDay(
      dayIndex: index,
      templateId: templateId as String?,
    );
  }
}

/// 计划库中的只读官方计划。
class OfficialFitnessPlan {
  final String id;
  final int revision;
  final FitnessLibraryText name;
  final FitnessLibraryText description;
  final String difficulty;
  final Map<String, List<String>> goals;
  final int cycleDays;
  final List<OfficialFitnessPlanDay> days;

  const OfficialFitnessPlan({
    required this.id,
    required this.revision,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.goals,
    required this.cycleDays,
    required this.days,
  });

  /// 从服务端或内置快照解析官方计划。
  factory OfficialFitnessPlan.fromJson(Map<String, dynamic> json) {
    _expectKeys(json, const {
      'id',
      'revision',
      'name',
      'description',
      'difficulty',
      'goals',
      'cycle_days',
      'days',
    });
    final id = _text(json['id']);
    final revision = json['revision'];
    final difficulty = json['difficulty'];
    final cycleDays = json['cycle_days'];
    final days = _mapList(json['days'], OfficialFitnessPlanDay.fromJson);
    if (!_uuid.hasMatch(id) ||
        revision is! int ||
        revision < 1 ||
        !const {'beginner', 'intermediate', 'advanced'}.contains(difficulty) ||
        cycleDays is! int ||
        cycleDays < 1 ||
        cycleDays > FitnessDefaults.maxCycleDays ||
        days.length != cycleDays ||
        days.map((day) => day.dayIndex).toSet().length != cycleDays ||
        days.any((day) => day.dayIndex >= cycleDays) ||
        !days.any((day) => day.templateId != null)) {
      throw const FormatException('FITNESS_LIBRARY_PLAN');
    }
    return OfficialFitnessPlan(
      id: id,
      revision: revision,
      name: FitnessLibraryText.fromJson(_map(json['name'])),
      description: FitnessLibraryText.fromJson(_map(json['description'])),
      difficulty: difficulty as String,
      goals: _localizedList(json['goals']),
      cycleDays: cycleDays,
      days: days,
    );
  }
}

/// 服务端与 App 内置快照共用的完整只读内容库。
class FitnessLibrary {
  final int schemaVersion;
  final int contentVersion;
  final List<OfficialFitnessTemplate> templates;
  final List<OfficialFitnessPlan> plans;

  const FitnessLibrary({
    required this.schemaVersion,
    required this.contentVersion,
    required this.templates,
    required this.plans,
  });

  /// 严格解析并校验内容图，确保计划只引用本快照中的模板。
  factory FitnessLibrary.fromJson(Map<String, dynamic> json) {
    try {
      _expectKeys(json, const {
        'schema_version',
        'content_version',
        'templates',
        'plans',
      });
      final schema = json['schema_version'];
      final version = json['content_version'];
      final templates = _mapList(
        json['templates'],
        OfficialFitnessTemplate.fromJson,
      );
      final plans = _mapList(json['plans'], OfficialFitnessPlan.fromJson);
      final templateIds = templates.map((template) => template.id).toSet();
      if (schema != fitnessLibrarySchemaVersion ||
          version is! int ||
          version < 1 ||
          templateIds.length != templates.length ||
          plans.map((plan) => plan.id).toSet().length != plans.length ||
          plans.any(
            (plan) => plan.days.any(
              (day) =>
                  day.templateId != null &&
                  !templateIds.contains(day.templateId),
            ),
          )) {
        throw const FormatException('FITNESS_LIBRARY_GRAPH');
      }
      return FitnessLibrary(
        schemaVersion: schema as int,
        contentVersion: version,
        templates: List.unmodifiable(templates),
        plans: List.unmodifiable(plans),
      );
    } catch (error) {
      if (error is FormatException && error.message == 'FITNESS_LIBRARY') {
        rethrow;
      }
      throw const FormatException('FITNESS_LIBRARY');
    }
  }

  /// 按稳定官方身份读取模板；内容图已校验，所以缺失属于编程错误。
  OfficialFitnessTemplate template(String id) =>
      templates.firstWhere((template) => template.id == id);

  /// 只读页面容错读取：官方身份可能来自旧草稿，缺失时返回 null。
  OfficialFitnessTemplate? templateOrNull(String id) =>
      templates.where((template) => template.id == id).firstOrNull;
}

/// 从计划库进入只读确认页时携带的临时草稿、官方内容库与模板快照。
class FitnessPlanImportDraft {
  final FitnessPlan plan;
  final FitnessLibrary library;
  final Map<String, FitnessTemplate> officialTemplates;
  final Map<String, String> reusableTemplateIds;
  final PrivateBookTarget? target;

  const FitnessPlanImportDraft({
    required this.plan,
    required this.library,
    required this.officialTemplates,
    this.reusableTemplateIds = const {},
    this.target,
  });
}

/// 把官方计划展开成现有计划编辑页可直接编辑的用户形状。
FitnessPlanImportDraft createFitnessPlanImportDraft({
  required FitnessLibrary library,
  required OfficialFitnessPlan officialPlan,
  required Locale locale,
  required DateTime startDate,
  Map<String, String> reusableTemplateIds = const {},
  Map<String, FitnessTemplate> reusableTemplates = const {},
  PrivateBookTarget? target,
}) {
  const uuid = Uuid();
  final templates = <String, FitnessTemplate>{};
  for (final templateId
      in officialPlan.days.map((day) => day.templateId).whereType<String>()) {
    templates.putIfAbsent(
      templateId,
      () => library
          .template(templateId)
          .toFitnessTemplate(locale, id: templateId),
    );
  }
  return FitnessPlanImportDraft(
    library: library,
    reusableTemplateIds: Map.unmodifiable(reusableTemplateIds),
    target: target,
    officialTemplates: Map.unmodifiable(templates),
    plan: FitnessPlan(
      name: officialPlan.name.resolve(locale),
      startDate:
          '${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      status: 'in_progress',
      cycleDays: officialPlan.cycleDays,
      catalogOrigin: FitnessCatalogOrigin(
        itemId: officialPlan.id,
        revision: officialPlan.revision,
      ),
      days: [
        for (final day in officialPlan.days)
          FitnessPlanDay(
            dayIndex: day.dayIndex,
            slot: day.templateId == null
                ? null
                : FitnessPlanSlot(
                    id: uuid.v4(),
                    sourceTemplateId: day.templateId,
                    name:
                        (reusableTemplates[reusableTemplateIds[day
                                    .templateId]] ??
                                templates[day.templateId]!)
                            .name,
                    exercises: _cloneExercises(
                      (reusableTemplates[reusableTemplateIds[day.templateId]] ??
                              templates[day.templateId]!)
                          .exercises,
                    ),
                  ),
          ),
      ],
    ),
  );
}

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[45][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);
final _weight = RegExp(r'^(0|[1-9][0-9]{0,5})(\.[0-9]{1,3})?$');

/// 读取非空文本，拒绝由弱类型 JSON 混入数字或容器。
String _text(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException('FITNESS_LIBRARY_TEXT');
  }
  return value;
}

/// 读取 JSON 对象并保持字符串键类型。
Map<String, dynamic> _map(Object? value) {
  if (value is! Map) throw const FormatException('FITNESS_LIBRARY_OBJECT');
  return Map<String, dynamic>.from(value);
}

/// 读取只包含非空文本的数组。
List<String> _stringList(Object? value) {
  if (value is! List || value.any((item) => item is! String || item.isEmpty)) {
    throw const FormatException('FITNESS_LIBRARY_STRING_LIST');
  }
  return List<String>.from(value);
}

/// 读取并逐项解析 JSON 对象数组。
List<T> _mapList<T>(Object? value, T Function(Map<String, dynamic>) parse) {
  if (value is! List) throw const FormatException('FITNESS_LIBRARY_LIST');
  return [for (final item in value) parse(_map(item))];
}

/// 校验当前 v1 的封闭字段集合，缺少必需字段或出现未知字段均拒绝。
void _expectKeys(Map<String, dynamic> json, Set<String> fields) {
  if (json.keys.toSet().difference(fields).isNotEmpty ||
      fields.difference(json.keys.toSet()).isNotEmpty) {
    throw const FormatException('FITNESS_LIBRARY_SHAPE');
  }
}

/// 解析三种语言的目标列表并冻结集合。
Map<String, List<String>> _localizedList(Object? value) {
  final json = _map(value);
  _expectKeys(json, const {'zh', 'zh_hant', 'en'});
  final result = {
    for (final key in const ['zh', 'zh_hant', 'en'])
      key: List<String>.unmodifiable(_stringList(json[key])),
  };
  if (result.values.any((items) => items.isEmpty)) {
    throw const FormatException('FITNESS_LIBRARY_GOALS');
  }
  return Map.unmodifiable(result);
}

/// 复制计划节点快照并生成新的动作、组身份。
List<FitnessExercise> _cloneExercises(List<FitnessExercise> exercises) {
  const uuid = Uuid();
  return [
    for (final exercise in exercises)
      exercise.copyWith(
        id: uuid.v4(),
        sets: [for (final set in exercise.sets) set.copyWith(id: uuid.v4())],
      ),
  ];
}
