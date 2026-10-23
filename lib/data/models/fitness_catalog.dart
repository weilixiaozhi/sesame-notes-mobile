import 'fitness_custom_exercise.dart';

/// 公共动作资料不含账号数据；名称与媒体都固定到同一个来源版本。
class FitnessExerciseDefinition {
  final FitnessCustomExercise? custom;
  final String id, nameZh, nameZhHant, nameEn, bodyPart, target, equipment;
  final String gifAsset;
  final String? mediaUrl;
  final bool isEnabled;
  final List<String> secondaryMuscles, instructionsZh, instructionsEn;
  final List<String> instructionsZhHant;

  const FitnessExerciseDefinition({
    this.custom,
    this.mediaUrl,
    this.isEnabled = true,
    required this.id,
    required this.nameZh,
    required this.nameZhHant,
    required this.nameEn,
    required this.bodyPart,
    required this.target,
    required this.equipment,
    required this.gifAsset,
    required this.secondaryMuscles,
    required this.instructionsZh,
    required this.instructionsZhHant,
    required this.instructionsEn,
  });

  factory FitnessExerciseDefinition.fromJson(Map<String, dynamic> json) =>
      FitnessExerciseDefinition(
        id: json['id'] as String,
        nameZh: json['name_zh'] as String,
        nameZhHant: json['name_zh_hant'] as String,
        nameEn: json['name_en'] as String,
        bodyPart: json['body_part'] as String,
        target: json['target'] as String,
        equipment: json['equipment'] as String,
        gifAsset: json['gif_asset'] as String,
        mediaUrl: json['media_url'] as String?,
        isEnabled: json['is_enabled'] as bool? ?? true,
        secondaryMuscles: List<String>.from(json['secondary_muscles'] as List),
        instructionsZh: List<String>.from(json['instructions_zh'] as List),
        instructionsZhHant: List<String>.from(
          json['instructions_zh_hant'] as List,
        ),
        instructionsEn: List<String>.from(json['instructions_en'] as List),
      );

  /// 用正式中英文名称匹配查询词，支持繁体中文与不区分大小写的英文。
  bool matchesSearch(String query) {
    final terms = query.trim().toLowerCase().split(RegExp(r'\s+'));
    final text = [nameZh, nameZhHant, nameEn].join(' ').toLowerCase();
    return terms.every(text.contains);
  }
}

/// 自定义动作到目录展示模型的映射保持单向依赖。
extension CustomExerciseDefinition on FitnessCustomExercise {
  FitnessExerciseDefinition get definition => FitnessExerciseDefinition(
    id: id,
    nameZh: name,
    nameZhHant: name,
    nameEn: name,
    bodyPart: bodyPart,
    target: bodyPart,
    equipment: equipment,
    gifAsset: '',
    secondaryMuscles: const [],
    instructionsZh: const [],
    instructionsZhHant: const [],
    instructionsEn: const [],
    custom: this,
  );
}
