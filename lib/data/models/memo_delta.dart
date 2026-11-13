import 'package:sesame_notes/utils/text_validation.dart';

/// 单篇笔记允许的内联图片数量，与服务端上限一致。
const memoImageLimit = 20;

/// 图片引用的媒体标识只接受 UUID 形状，不接受地址或字节。
final _memoImageId = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// delta_v1 的纯校验边界；异常不携带正文，供本地写入、同步及恢复共用。
void validateMemoDelta(Object? value) {
  Never fail() => throw const FormatException('INVALID_MEMO_DELTA');
  if (value is! Map || value.keys.any((key) => key != 'ops')) fail();
  final ops = value['ops'];
  if (ops is! List || ops.isEmpty) fail();
  var images = 0;
  for (final op in ops) {
    if (op is! Map ||
        op.keys.any((key) => key != 'insert' && key != 'attributes')) {
      fail();
    }
    final insert = op['insert'];
    if (insert is Map) {
      // 图片引用只保存媒体标识：不承载字节、地址或额外排版信息。
      if (insert.length != 1 ||
          insert['memo_image'] is! String ||
          !_memoImageId.hasMatch(insert['memo_image'] as String) ||
          op.containsKey('attributes')) {
        fail();
      }
      images++;
      if (images > memoImageLimit) fail();
      continue;
    }
    if (insert is! String || insert.isEmpty || !isWellFormedText(insert)) {
      fail();
    }
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
        !RegExp(r'^\n+$').hasMatch(insert)) {
      fail();
    }
    if (attributes.containsKey('header') && attributes.containsKey('list')) {
      fail();
    }
  }
  // 正文始终以文字换行结束，图片引用不能成为最后一段。
  final last = ops.last as Map;
  final tail = last['insert'];
  if (tail is! String || !tail.endsWith('\n')) fail();
}

/// 读取图片 op 引用的媒体标识；非图片 op 返回 null。
String? memoImageIdOf(Object? op) {
  if (op is! Map) return null;
  final insert = op['insert'];
  if (insert is! Map) return null;
  final id = insert['memo_image'];
  return id is String ? id : null;
}

/// 三种文档输出共用文字段和段落语义，终止换行不额外产生空段落。
sealed class MemoRun {
  const MemoRun();
}

class MemoTextRun extends MemoRun {
  final String text;
  final bool bold;
  const MemoTextRun(this.text, {this.bold = false});
}

/// 正文中的一次图片引用；导出时按可承载的格式内嵌或降级为占位。
class MemoImageRun extends MemoRun {
  final String mediaId;
  const MemoImageRun(this.mediaId);
}

class MemoParagraph {
  final List<MemoRun> runs;
  final int? header;
  final String? list;
  final int indent;
  MemoParagraph(
    Iterable<MemoRun> runs, {
    this.header,
    this.list,
    this.indent = 0,
  }) : runs = List.unmodifiable(runs);
  String get text =>
      runs.whereType<MemoTextRun>().map((run) => run.text).join();

  /// 段落是否只包含图片引用：导出时整段按图片处理。
  Iterable<String> get imageIds =>
      runs.whereType<MemoImageRun>().map((run) => run.mediaId);
}

List<MemoParagraph> memoParagraphs(Object? body) {
  validateMemoDelta(body);
  final paragraphs = <MemoParagraph>[];
  var runs = <MemoRun>[];
  for (final op in (body as Map)['ops'] as List) {
    final imageId = memoImageIdOf(op);
    if (imageId != null) {
      runs.add(MemoImageRun(imageId));
      continue;
    }
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
