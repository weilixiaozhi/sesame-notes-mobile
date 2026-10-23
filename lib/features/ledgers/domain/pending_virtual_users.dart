/// 新建态账本的待提交虚拟成员列表（内存暂存，保存账本后批量落库）。
///
/// 新建态账本尚未落库、没有 ledgerId，虚拟成员无法直接写库，先在内存暂存；
/// 用户保存账本拿到新 ledgerId 后，父组件遍历该列表批量创建。列表操作保持
/// 三条口径：默认名按现有数量递增、空白名称不覆盖已保存名称、按下标增删。
library;

/// 新建态下内存暂存的虚拟用户(保存账本拿到 ledgerId 后批量落库)。
///
/// 仅有 [name] 字段:新建态没有 ledgerId,无法直接写库,故先在内存暂存;
/// 用户点击保存后,父组件遍历此列表调用 createVirtualUser 批量创建。
class PendingVirtualUser {
  PendingVirtualUser({required this.name});

  /// 虚拟用户昵称。
  String name;
}

/// 默认名编号:现有虚拟成员数 + 1,保证连续添加不重名。
int nextVirtualUserIndex(int existingCount) => existingCount + 1;

/// 追加一个待提交虚拟成员。
///
/// [defaultName] 按编号生成显示名(文案来自本地化,不在此层拼装)。
List<PendingVirtualUser> addPendingVirtualUser(
  List<PendingVirtualUser> current,
  String Function(int index) defaultName,
) => [
  ...current,
  PendingVirtualUser(name: defaultName(nextVirtualUserIndex(current.length))),
];

/// 按下标改名。
///
/// 去首尾空白后为空的名称不覆盖已保存名称,越界下标不改动列表:
/// 两者都原样返回入参列表,调用方据此跳过无变化的状态提交。
List<PendingVirtualUser> renamePendingVirtualUser(
  List<PendingVirtualUser> current,
  int index,
  String name,
) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || index < 0 || index >= current.length) return current;
  final updated = [...current];
  updated[index] = PendingVirtualUser(name: trimmed);
  return updated;
}

/// 按下标删除;越界下标原样返回入参列表。
List<PendingVirtualUser> removePendingVirtualUserAt(
  List<PendingVirtualUser> current,
  int index,
) {
  if (index < 0 || index >= current.length) return current;
  final updated = [...current];
  updated.removeAt(index);
  return updated;
}
