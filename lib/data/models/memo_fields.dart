import 'dart:convert';

import 'package:sesame_notes/utils/text_validation.dart';

/// 字段数量、名称与取值上限，与服务端 fields_v1 规则逐条对齐。
const memoFieldLimit = 20;
const memoLabelLimit = 64;
const memoValueLimit = 2048;

/// 账号密码卡片的一条字段：名称可自定义、可重复，值允许为空串。
class MemoField {
  final String label, value;
  const MemoField({required this.label, required this.value});
}

/// fields_v1 的纯校验边界；异常不携带字段内容，供本地写入、同步及恢复共用。
void validateMemoFields(Object? value) {
  Never fail() => throw const FormatException('INVALID_MEMO_FIELDS');
  if (value is! Map || value.keys.any((key) => key != 'fields')) fail();
  final fields = value['fields'];
  if (fields is! List || fields.length > memoFieldLimit) fail();
  for (final field in fields) {
    if (field is! Map ||
        field.keys.any((key) => key != 'label' && key != 'value')) {
      fail();
    }
    final label = field['label'], text = field['value'];
    if (label is! String || text is! String) fail();
    // 名称必须可见，取值允许为空串；长度按 UTF-16 码元计数与服务端一致。
    if (!hasVisibleText(label) ||
        label.length > memoLabelLimit ||
        text.length > memoValueLimit ||
        !isWellFormedText(text)) {
      fail();
    }
  }
}

/// 卡片正文的统一解析入口；字段顺序即展示顺序。
List<MemoField> memoFieldsOf(Object? body) {
  validateMemoFields(body);
  return List.unmodifiable([
    for (final field in (body as Map)['fields'] as List)
      MemoField(
        label: (field as Map)['label'] as String,
        value: field['value'] as String,
      ),
  ]);
}

/// 卡片正文的唯一编码入口，模型、同步载荷与交换格式都按同一形状写出。
String encodeMemoFields(List<MemoField> fields) => jsonEncode({
  'fields': [
    for (final field in fields) {'label': field.label, 'value': field.value},
  ],
});
