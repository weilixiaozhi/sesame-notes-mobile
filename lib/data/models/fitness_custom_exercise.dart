import 'fitness_payload_shapes.dart';

/// 自定义动作随健身空间偏好保存；删除仅隐藏，已有训练仍可解析动作名称。
class FitnessCustomExercise {
  static const bodyParts = [
    'back',
    'cardio',
    'chest',
    'lower arms',
    'lower legs',
    'neck',
    'shoulders',
    'upper arms',
    'upper legs',
    'waist',
  ];
  static const equipmentTypes = [
    'assisted',
    'band',
    'barbell',
    'body weight',
    'bosu ball',
    'cable',
    'dumbbell',
    'elliptical machine',
    'ez barbell',
    'hammer',
    'kettlebell',
    'leverage machine',
    'medicine ball',
    'olympic barbell',
    'resistance band',
    'roller',
    'rope',
    'skierg machine',
    'sled machine',
    'smith machine',
    'stability ball',
    'stationary bike',
    'stepmill machine',
    'tire',
    'trap bar',
    'upper body ergometer',
    'weighted',
    'wheel roller',
  ];
  final String id, name, bodyPart, equipment, icon;
  final String? image;
  final bool deleted;
  const FitnessCustomExercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.icon,
    this.image,
    this.deleted = false,
  });

  factory FitnessCustomExercise.fromJson(Map<String, dynamic> json) =>
      _parse(json);

  static FitnessCustomExercise _parse(Map<String, dynamic> json) {
    // 字段表来自共享注册表：严格校验与同步入站剥离未知字段必须同源。
    final fields = fitnessCustomExerciseShape.fields;
    if (json.keys.toSet().difference(fields.toSet()).isNotEmpty ||
        fields.toSet().difference(json.keys.toSet()).isNotEmpty) {
      throw const FormatException('FITNESS_PAYLOAD_SHAPE');
    }
    return FitnessCustomExercise(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyPart: json['body_part'] as String,
      equipment: json['equipment'] as String,
      icon: json['icon'] as String,
      image: json['image'] as String?,
      deleted: json['deleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'body_part': bodyPart,
    'equipment': equipment,
    'icon': icon,
    'image': image,
    'deleted': deleted,
  };
}
