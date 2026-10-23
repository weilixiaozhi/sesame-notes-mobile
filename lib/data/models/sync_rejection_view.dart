/// 未上传记录的展示快照：只暴露定位、摘要和脱敏原因，不将队列行交给页面。
typedef SyncRejectionView = ({
  String entityId,
  String entityType,
  String label,
  String reason,
});
