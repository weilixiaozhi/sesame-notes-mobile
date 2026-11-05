/// 同步水位与目录按业务域分别维护。
enum SyncDomain { accounting, days, memos, fitness }

/// 父本确认策略集中声明，清理范围和幂等删除检查使用同一实体集合。
class SyncParentPolicy {
  /// 重放删除是否还需读取当前权威快照，由领域协议决定。
  const SyncParentPolicy({required this.confirmIgnoredDeletion});

  final bool confirmIgnoredDeletion;
}

/// 健身空间墓碑由版本比较阻止重新激活，同一删除的幂等回执可直接确认。
/// 其他父本通过权威整本读取确认删除，网络失败时保留冻结请求供重试。
const syncParentPolicies = <String, SyncParentPolicy>{
  'ledger': SyncParentPolicy(confirmIgnoredDeletion: true),
  'day_book': SyncParentPolicy(confirmIgnoredDeletion: true),
  'memo_book': SyncParentPolicy(confirmIgnoredDeletion: true),
  'fitness_space': SyncParentPolicy(confirmIgnoredDeletion: false),
};

/// 健身同步实体集合，范围分派使用同一份协议标识。
const fitnessSyncTypes = {
  'fitness_space',
  'fitness_template',
  'fitness_plan',
  'fitness_workout',
  'fitness_preferences',
};
