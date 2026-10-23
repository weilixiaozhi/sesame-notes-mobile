import 'package:uuid/uuid.dart';
import 'default_category_keys.dart';

/// 官方分类身份不依赖语言；父子结构来自模板键集合，不能通过名称猜测来源。
typedef DefaultCategoryIdentity = ({
  String id,
  String key,
  int level,
  String? parentId,
});

const _namespace = 'b3e7c0de-0000-4000-8000-beec00000001';
const _uuid = Uuid();

/// 与已发布默认分类一致的 UUIDv5 算法；命名空间和种子格式必须保持稳定。
String defaultCategoryId({required int level, required String key}) =>
    _uuid.v5(_namespace, 'cat:expense:$level:$key');

/// 所有一级与分层模板的 159 个固定身份；随机用户分类不会被纳入此表。
final Map<String, DefaultCategoryIdentity> officialCategoryIdentities =
    _buildIdentities();

Map<String, DefaultCategoryIdentity> _buildIdentities() {
  final result = <String, DefaultCategoryIdentity>{};
  void add(int level, String key, String? parentKey) {
    final id = defaultCategoryId(level: level, key: key);
    final identity = (
      id: id,
      key: key,
      level: level,
      parentId: parentKey == null
          ? null
          : defaultCategoryId(level: 1, key: parentKey),
    );
    final previous = result[id];
    if (previous != null && previous != identity) {
      throw StateError('官方分类固定身份冲突: $id');
    }
    result[id] = identity;
  }

  for (final key in {
    ...kFlatExpenseCategoryKeys,
    ...kHierarchicalExpenseCategories.keys,
  }) {
    add(1, key, null);
  }
  for (final entry in kHierarchicalExpenseCategories.entries) {
    for (final key in entry.value) {
      add(2, key, entry.key);
    }
  }
  return Map.unmodifiable(result);
}
