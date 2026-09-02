import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/category_display.dart';

/// 将 Drift 分类行转换为 UI 可消费的不可变展示模型。
extension CategoryDisplayMapper on Category {
  CategoryDisplay toDisplay() => CategoryDisplay(
    id: id,
    name: name,
    kind: kind,
    level: level,
    sortOrder: sortOrder,
    icon: icon,
    parentId: parentId,
  );
}
