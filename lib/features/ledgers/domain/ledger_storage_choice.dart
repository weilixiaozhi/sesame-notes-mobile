/// 新建本的归属同时取决于缓存账号与云本能力，已有本的归属不受影响。
String newLedgerStorageMode({
  required String? accountId,
  bool cloudAvailable = true,
}) => cloudAvailable && accountId != null ? 'cloud' : 'local';
