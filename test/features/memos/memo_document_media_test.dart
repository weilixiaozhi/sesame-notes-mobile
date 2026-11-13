import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/memo_delta.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_document.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_image.dart';

/// 1x1 PNG：DOCX/PDF 内嵌只需要真实可解码的图片。
final _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);
const _id = '9f8e7d6c-5b4a-4392-8171-60514f3e2d1c';

Map<String, Object> _body() => {
  'ops': [
    {'insert': '照片\n'},
    {
      'insert': {'memo_image': _id},
    },
    {'insert': '\n'},
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final media = {
    _id: MemoDocumentMedia(
      bytes: _png,
      width: 320,
      height: 200,
      extension: 'png',
    ),
  };

  test('段落模型把图片引用保留为独立图片段', () {
    final paragraphs = memoParagraphs(_body());
    expect(paragraphs.first.text, '照片');
    expect(paragraphs.expand((p) => p.imageIds), [_id]);
  });

  test('Markdown 以占位保留图片位置，不写入不可解析的图片地址', () {
    final markdown = MemoDocument(
      bookType: 'normal',
      body: _body(),
      media: media,
    ).markdown();
    expect(markdown, contains('照片'));
    expect(markdown, contains('[图片]'));
    expect(markdown, isNot(contains(_id)));
  });

  test('DOCX 内嵌图片部件与关系，缺失字节时降级为文字占位', () {
    final docx = MemoDocument(
      bookType: 'normal',
      body: _body(),
      media: media,
    ).docx();
    final archive = ZipDecoder().decodeBytes(docx);
    final names = archive.files.map((file) => file.name).toSet();
    expect(names, contains('word/media/image1.png'));
    final document = utf8.decode(
      archive.files
              .firstWhere((file) => file.name == 'word/document.xml')
              .content
          as List<int>,
    );
    expect(document, contains('w:drawing'));
    expect(document, contains('r:embed="rIdImage1"'));
    final rels = utf8.decode(
      archive.files
              .firstWhere((file) => file.name == 'word/_rels/document.xml.rels')
              .content
          as List<int>,
    );
    expect(rels, contains('media/image1.png'));

    final missing = MemoDocument(bookType: 'normal', body: _body()).docx();
    final missingNames = ZipDecoder()
        .decodeBytes(missing)
        .files
        .map((file) => file.name);
    expect(missingNames, isNot(contains('word/media/image1.png')));
    final missingDocument = utf8.decode(
      ZipDecoder()
              .decodeBytes(missing)
              .files
              .firstWhere((file) => file.name == 'word/document.xml')
              .content
          as List<int>,
    );
    expect(missingDocument, contains('[图片]'));
  });

  test('PDF 与 PNG 导出包含图片且不中断正文输出', () async {
    final document = MemoDocument(
      bookType: 'normal',
      body: _body(),
      media: media,
    );
    final regular = await rootBundle.load('assets/memos/NotoSansSC.ttf');
    final emoji = await rootBundle.load('assets/memos/NotoEmoji.ttf');
    final pdf = await document.pdf(regular, emoji);
    expect(utf8.decode(pdf.sublist(0, 4), allowMalformed: true), '%PDF');
    expect(pdf.length, greaterThan(1000));
    final png = await MemoImage.render(document);
    expect(png.sublist(0, 8), [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
  });
}
