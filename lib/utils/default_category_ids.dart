import 'package:uuid/uuid.dart';

const _namespace = 'b3e7c0de-0000-4000-8000-beec00000001';
const _uuid = Uuid();

/// 与已发布默认分类一致的 UUIDv5 算法；命名空间和种子格式必须保持稳定。
String defaultCategoryId({required int level, required String key}) =>
    _uuid.v5(_namespace, 'cat:expense:$level:$key');
