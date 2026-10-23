import 'fitness_catalog.dart';
import 'fitness_custom_exercise.dart';

/// 官方动作与分类来自同一缓存快照，防止刷新时动作和标签使用不同版本。
class FitnessCatalogSnapshot {
  /// 对动作列表建立只读副本；空分类对象仍代表服务端提供的权威目录。
  FitnessCatalogSnapshot({
    required Iterable<FitnessExerciseDefinition> exercises,
    this.taxonomies,
  }) : exercises = List.unmodifiable(exercises);

  final List<FitnessExerciseDefinition> exercises;
  final FitnessTaxonomies? taxonomies;
}

/// 分类的稳定标识与多语言名称分离，删除仅影响新选择，不影响历史名称。
class FitnessTaxonomyEntry {
  /// 创建不可变的分类展示资料。
  const FitnessTaxonomyEntry({
    required this.id,
    required this.nameZh,
    required this.nameZhHant,
    required this.nameEn,
    required this.isDeleted,
  });

  final String id, nameZh, nameZhHant, nameEn;
  final bool isDeleted;

  /// 严格校验目录字段，拒绝不完整记录覆盖已缓存的可用标签。
  factory FitnessTaxonomyEntry.fromJson(Object? value) {
    if (value is! Map || value['name'] is! Map) {
      throw const FormatException('FITNESS_TAXONOMY_ENTRY');
    }
    final name = value['name'] as Map;
    final id = value['id'];
    if (!fitnessValidTaxonomyId(id) ||
        value['is_deleted'] is! bool ||
        [
          name['zh'],
          name['zh_hant'],
          name['en'],
        ].any((label) => label is! String || label.trim().isEmpty)) {
      throw const FormatException('FITNESS_TAXONOMY_ENTRY');
    }
    return FitnessTaxonomyEntry(
      id: id as String,
      nameZh: name['zh'] as String,
      nameZhHant: name['zh_hant'] as String,
      nameEn: name['en'] as String,
      isDeleted: value['is_deleted'] as bool,
    );
  }

  /// 使用页面语言选择名称，繁体中文地区与脚本都采用繁体名称。
  String localizedName(String localeName) {
    final locale = localeName.replaceAll('-', '_').toLowerCase();
    if (!locale.startsWith('zh')) return nameEn;
    return locale.contains('hant') ||
            locale.endsWith('_tw') ||
            locale.endsWith('_hk')
        ? nameZhHant
        : nameZh;
  }
}

/// 动态分类快照只通过 Provider 传递，不修改进程级分类字典。
class FitnessTaxonomies {
  /// 保存按服务端顺序排列的只读分类索引。
  FitnessTaxonomies({
    required Iterable<FitnessTaxonomyEntry> bodyParts,
    required Iterable<FitnessTaxonomyEntry> equipment,
  }) : bodyParts = Map.unmodifiable({
         for (final item in bodyParts) item.id: item,
       }),
       equipment = Map.unmodifiable({
         for (final item in equipment) item.id: item,
       });

  final Map<String, FitnessTaxonomyEntry> bodyParts, equipment;

  /// 两类目录必须共同提供，重复标识按损坏响应处理。
  factory FitnessTaxonomies.fromJson(Object? value) {
    if (value is! Map) throw const FormatException('FITNESS_TAXONOMIES');
    return FitnessTaxonomies(
      bodyParts: _entries(value['body_parts']),
      equipment: _entries(value['equipment']),
    );
  }

  /// 校验分类数组内的唯一标识，防止同一标识出现含糊名称。
  static List<FitnessTaxonomyEntry> _entries(Object? value) {
    if (value is! List) throw const FormatException('FITNESS_TAXONOMIES');
    final entries = value.map(FitnessTaxonomyEntry.fromJson).toList();
    if (entries.map((item) => item.id).toSet().length != entries.length) {
      throw const FormatException('FITNESS_TAXONOMY_DUPLICATE');
    }
    return entries;
  }

  /// 已删除分类仍能解析历史标签，未知标识由展示层使用兼容回退。
  String? label(String id, String localeName, {bool isEquipment = false}) =>
      (isEquipment ? equipment : bodyParts)[id]?.localizedName(localeName);
}

/// 分类标识与服务端同步契约一致，历史记录无需依赖当前目录是否仍有该项。
bool fitnessValidTaxonomyId(Object? value) =>
    value is String && value.trim().isNotEmpty && value.runes.length <= 100;

/// 新选择仅提供有效分类；未提供动态目录的服务器和离线包继续使用内置列表。
List<String> fitnessSelectableTaxonomyIds(
  FitnessTaxonomies? taxonomies, {
  bool isEquipment = false,
}) => taxonomies == null
    ? (isEquipment
          ? FitnessCustomExercise.equipmentTypes
          : FitnessCustomExercise.bodyParts)
    : [
        for (final entry
            in (isEquipment ? taxonomies.equipment : taxonomies.bodyParts)
                .values)
          if (!entry.isDeleted) entry.id,
      ];
