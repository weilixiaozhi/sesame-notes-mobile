/// 新建本的归属由缓存账号与云能力决定，不修改已有本的归属。
String newLedgerStorageMode({
  required String? accountId,
  bool cloudAvailable = true,
}) => cloudAvailable && accountId != null ? 'cloud' : 'local';
