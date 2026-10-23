/// 可直接向用户说明的分类决策失败，不包含服务端或本地载荷。
class CategoryDecisionException implements Exception {
  const CategoryDecisionException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// 比较版本用于确认页面与冻结事务的一致性，不冒充服务端基线。
String categoryDecisionVersion(Map<String, dynamic> remote) {
  final metadata = remote['_category_conflict'];
  if (metadata is! Map || remote['version_token'] is! String) return '';
  return '${metadata['candidate_version']}:${remote['version_token']}';
}

/// 展示只读取分类业务字段；内部候选身份与服务器 token 不进入详情列表。
Map<String, dynamic> categoryConflictDisplay(Map<String, dynamic> payload) => {
  for (final key in const [
    'name',
    'kind',
    'level',
    'sort_order',
    'icon',
    'parent_id',
    'deleted',
    'deleted_at',
  ])
    if (payload.containsKey(key)) key: payload[key],
};
