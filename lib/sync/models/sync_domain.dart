/// 同步水位与目录按业务域分别维护。
enum SyncDomain { accounting, days, memos, fitness }

/// 健身同步实体集合，范围分派使用同一份协议标识。
const fitnessSyncTypes = {
  'fitness_space',
  'fitness_template',
  'fitness_plan',
  'fitness_workout',
  'fitness_preferences',
};
