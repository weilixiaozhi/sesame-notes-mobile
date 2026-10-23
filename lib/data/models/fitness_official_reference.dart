import 'fitness_catalog_registry.dart';

final _officialUuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

/// 官方动作以稳定编号或 UUID 引用；在线目录决定可选内容，服务端校验发布资格。
/// 历史、同步和离线副本保留尚未下载目录的 UUID，避免目录刷新时序损坏用户记录。
bool fitnessOfficialReference(String id) =>
    fitnessCatalogRegistry.contains(id) || _officialUuid.hasMatch(id);
