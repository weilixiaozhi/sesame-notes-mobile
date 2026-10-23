import 'package:sesame_notes/utils/text_validation.dart';

/// delta_v1 的纯校验边界；异常不携带正文，供本地写入、同步及恢复共用。
void validateMemoDelta(Object? value) {
  Never fail() => throw const FormatException('INVALID_MEMO_DELTA');
  if (value is! Map || value.keys.any((key) => key != 'ops')) fail();
  final ops = value['ops'];
  if (ops is! List || ops.isEmpty) fail();
  for (final op in ops) {
    if (op is! Map ||
        op.keys.any((key) => key != 'insert' && key != 'attributes')) {
      fail();
    }
    final text = op['insert'];
    if (text is! String || text.isEmpty || !isWellFormedText(text)) fail();
    if (!op.containsKey('attributes')) continue;
    final attributes = op['attributes'];
    if (attributes is! Map) fail();
    for (final key in attributes.keys) {
      final attribute = attributes[key];
      switch (key) {
        case 'bold':
          if (attribute is! bool) fail();
        case 'header':
          if (attribute is! num || ![1, 2, 3].contains(attribute)) fail();
        case 'list':
          if (![
            'ordered',
            'bullet',
            'checked',
            'unchecked',
          ].contains(attribute)) {
            fail();
          }
        case 'indent':
          if (attribute is! num ||
              !attribute.isFinite ||
              attribute != attribute.truncateToDouble() ||
              attribute < 0 ||
              attribute > 5) {
            fail();
          }
        default:
          fail();
      }
    }
    // 与服务端一致，段落格式只作用于换行，不能混合标题和列表。
    if (['header', 'list', 'indent'].any(attributes.containsKey) &&
        !RegExp(r'^\n+$').hasMatch(text)) {
      fail();
    }
    if (attributes.containsKey('header') && attributes.containsKey('list')) {
      fail();
    }
  }
  if (!((ops.last as Map)['insert'] as String).endsWith('\n')) fail();
}

/// 三种文档输出共用文字段和段落语义，终止换行不额外产生空段落。
class MemoTextRun {
  final String text;
  final bool bold;
  const MemoTextRun(this.text, {this.bold = false});
}

class MemoParagraph {
  final List<MemoTextRun> runs;
  final int? header;
  final String? list;
  final int indent;
  MemoParagraph(
    Iterable<MemoTextRun> runs, {
    this.header,
    this.list,
    this.indent = 0,
  }) : runs = List.unmodifiable(runs);
  String get text => runs.map((run) => run.text).join();
}

List<MemoParagraph> memoParagraphs(Object? body) {
  validateMemoDelta(body);
  final paragraphs = <MemoParagraph>[];
  var runs = <MemoTextRun>[];
  for (final op in (body as Map)['ops'] as List) {
    final attributes = (op['attributes'] as Map?) ?? const {};
    final pieces = (op['insert'] as String).split('\n');
    for (var index = 0; index < pieces.length; index++) {
      if (pieces[index].isNotEmpty) {
        runs.add(MemoTextRun(pieces[index], bold: attributes['bold'] == true));
      }
      if (index < pieces.length - 1) {
        paragraphs.add(
          MemoParagraph(
            runs,
            header: (attributes['header'] as num?)?.toInt(),
            list: attributes['list'] as String?,
            indent: (attributes['indent'] as num?)?.toInt() ?? 0,
          ),
        );
        runs = [];
      }
    }
  }
  return List.unmodifiable(paragraphs);
}
