import 'package:flutter/widgets.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/memo_delta.dart';
import 'package:sesame_notes/features/memos/presentation/memo_image_embed.dart';

void main() {
  test('图片作为行内占位参与排版，不再整行块级渲染', () {
    final builder = MemoImageEmbedBuilder(onTap: (_, _, _) async {});
    expect(builder.expanded, isFalse);
    expect(builder.key, 'memo_image');
  });

  test('按行与叶子长度计算图片在文档中的偏移', () {
    final document = Document.fromJson([
      {'insert': '标题\n'},
      {
        'insert': {'memo_image': '9f8e7d6c-5b4a-4392-8171-60514f3e2d1c'},
      },
      {'insert': '\n'},
      {'insert': '正文\n'},
    ]);
    addTearDown(document.close);
    Embed? embed;
    for (final node in document.root.children) {
      for (final child in (node as Line).children) {
        if (child is Embed) embed = child;
      }
    }
    expect(embed, isNotNull);
    expect(memoImageEmbedIndex(document, embed!), '标题\n'.length);
    expect(memoImageRefOf(embed.value.data)?.percent, 100);
  });

  test('替换图片比例时写入嵌入对象而不是原始 Map', () {
    final document = Document.fromJson([
      {'insert': '看图\n'},
      {
        'insert': {'memo_image': '9f8e7d6c-5b4a-4392-8171-60514f3e2d1c'},
      },
      {'insert': '\n'},
    ]);
    addTearDown(document.close);
    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 3),
    );
    addTearDown(controller.dispose);
    controller.replaceText(
      3,
      1,
      BlockEmbed('memo_image', '9f8e7d6c-5b4a-4392-8171-60514f3e2d1c|50'),
      const TextSelection.collapsed(offset: 4),
    );
    final ops = document.toDelta().toJson();
    expect(ops.where((op) => op['insert'] is Map).single['insert'], {
      'memo_image': '9f8e7d6c-5b4a-4392-8171-60514f3e2d1c|50',
    });
  });
}
