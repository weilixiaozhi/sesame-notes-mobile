import 'memo.dart';

/// 卡片默认按同步顺序排列，名称和最近编辑只改变当前列表视图。
enum CredentialSort { manual, updated, title }

/// 手动顺序同值时使用稳定身份，避免各设备因查询顺序不同而跳动。
int compareCredentialOrder(MemoEntry left, MemoEntry right) {
  final order = left.orderKey!.compareTo(right.orderKey!);
  return order == 0 ? left.id.compareTo(right.id) : order;
}

/// 搜索及分页只替换可见卡片的原有位置，隐藏卡片的相对顺序保持完整。
List<String> mergeCredentialOrder(
  List<MemoEntry> entries,
  List<String> visibleIds,
  List<String> reorderedIds,
) {
  final fullIds = entries.map((entry) => entry.id).toSet();
  final visible = visibleIds.toSet();
  if (fullIds.length != entries.length ||
      visible.length != visibleIds.length ||
      reorderedIds.length != visibleIds.length ||
      reorderedIds.toSet().length != reorderedIds.length ||
      visibleIds.any((id) => !fullIds.contains(id)) ||
      reorderedIds.any((id) => !visible.contains(id))) {
    throw StateError('MEMO_ORDER_CHANGED');
  }
  var index = 0;
  return [
    for (final entry in entries)
      visible.contains(entry.id) ? reorderedIds[index++] : entry.id,
  ];
}
