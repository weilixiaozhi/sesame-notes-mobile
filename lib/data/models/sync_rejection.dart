/// 拒收结果仅按稳定错误码归类，缺失或格式异常时保留可安全展示的未知失败。
String syncRejectionCode(String? code) {
  if (code != null && RegExp(r'^[A-Z][A-Z0-9_]{0,79}$').hasMatch(code)) {
    return code;
  }
  return 'UNKNOWN_VALIDATION';
}

/// 用户提示只采用本机固定文案，未知服务端文本不会暴露用户内容或凭证。
String syncRejectionReason(String code) => switch (code) {
  'CATEGORY_NAME_CONFLICT' => '同一所属分类下已存在同名分类，请使用已有分类或修改名称后保存。原记录会继续保留。',
  'INVALID_CATEGORY' => '这条记录的分类在云端不可用。请先处理分类的同步问题，分类恢复后会自动重试这条记录。',
  'CATEGORY_PARENT_UNAVAILABLE' => '所属分类在云端不可用。请先处理所属分类的同步问题，恢复后会自动重试这个子分类。',
  'INVALID_CATEGORY_PARENT' => '所属分类的身份无效，请重新选择有效的一级分类后保存。',
  'CATEGORY_PARENT_REQUIRED' => '二级分类缺少所属分类，请选择一个一级分类后保存。',
  'CATEGORY_PARENT_FORBIDDEN' => '一级分类不能设置所属分类，请检查分类结构后保存。',
  'INVALID_CATEGORY_LEVEL' => '分类层级未被云端接受，请重试；若仍失败，请检查客户端与服务端版本。',
  'CATEGORY_CYCLE' => '分类不能选择自身作为所属分类，请重新选择后保存。',
  'CATEGORY_HAS_CHILDREN' => '这个分类仍有子分类，请先调整子分类，再修改或删除当前分类。',
  'CATEGORY_HAS_TRANSACTIONS' => '云端仍有记账记录使用这个分类，请先完成关联记录的迁移或删除，再重试分类删除。',
  'INVALID_CATEGORY_SORT_ORDER' => '分类的排序值超出允许范围，请重新调整排序后重试。',
  'INVALID_CATEGORY_ICON' => '分类图标格式无效，请重新选择图标后保存。',
  'INVALID_CATEGORY_KIND' => '分类类型未被云端接受，请检查客户端与服务端版本后重试。',
  'INVALID_CATEGORY_SCOPE' ||
  'INVALID_CATEGORY_PAYLOAD' => '分类的上传数据格式未被云端接受，请重试；若仍失败，请反馈此问题。',
  'INVALID_RECURRING' => '关联的周期账单在云端不可用，请先处理周期账单的同步问题。',
  'INVALID_NATIVE_AMOUNT' => '本位币记录的折算金额与原金额不一致，请检查金额和币种后保存。',
  'MEMBER_IN_USE' => '成员仍被记账记录引用，请先调整相关记录，再删除成员。',
  'INVALID_RECURRING_OCCURRENCE' => '周期记账的发生身份、日期或排期无效，请检查关联的周期账单后重试。',
  'INVALID_OCCURRENCE_DATE' => '周期记账的发生日期无效，请检查日期后重试。',
  'INVALID_TRANSACTION_PAYLOAD' => '这条记账记录的分摊成员或金额格式无效，请检查后保存。',
  'INVALID_RECURRING_DATE_RANGE' => '周期账单的结束日期早于开始日期，请调整后保存。',
  'INVALID_RECURRING_TIME_ZONE' => '周期账单的时区无效，请重新选择时区后保存。',
  'RECURRING_TIME_ZONE_IMMUTABLE' => '这个周期账单已生成过记录，不能修改时区；请新建周期账单。',
  'INVALID_RECURRING_PROTOCOL' => '周期账单的同步协议未被云端接受，请检查客户端与服务端版本后重试。',
  _ => '云端未提供可识别的失败原因，请先重试；若仍失败，请反馈此问题。',
};
