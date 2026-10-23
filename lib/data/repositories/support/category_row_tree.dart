import 'package:sesame_notes/data/models/accounting_records.dart';

/// 仓储端口共享的不可变分类快照树。
class CategoryRowTree {
  const CategoryRowTree({required this.topLevel, required this.children});

  final List<CategorySnapshot> topLevel;
  final Map<String, List<CategorySnapshot>> children;
}
