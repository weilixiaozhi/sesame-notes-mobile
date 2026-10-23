import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';

/// 自定义动作定义随偏好一起交换，引用仍使用同一个动作标识。
List<Map<String, dynamic>> transferCustomExercises(
  Map<String, dynamic> payload,
) => [
  for (final value in payload['custom_exercises'] as List? ?? const [])
    Map<String, dynamic>.from(value as Map),
];

List<FitnessExerciseDefinition> transferCustomCatalog(
  Map<String, dynamic> payload,
) => [
  for (final item in transferCustomExercises(payload))
    FitnessCustomExercise.fromJson(item).definition,
];

/// 只收集动作引用，不能把计时器的组身份或定义本身当作待匹配动作。
Set<String> transferCustomReferences(Object? value, [String? field]) {
  if (value is List) {
    return {for (final item in value) ...transferCustomReferences(item, field)};
  }
  if (value is Map) {
    return {
      // 按动作设置的两张映射表都以动作标识为键，需一并收集自定义动作引用。
      if (field == 'exercise_rest_settings' || field == 'exercise_weight_modes')
        ...value.keys.cast<String>().where((id) => id.startsWith('custom:')),
      for (final entry in value.entries)
        ...transferCustomReferences(entry.value, entry.key as String),
    };
  }
  if (value is String &&
      value.startsWith('custom:') &&
      (field == 'exercise_id' || field == 'pinned_exercise_ids')) {
    return {value};
  }
  return {};
}
