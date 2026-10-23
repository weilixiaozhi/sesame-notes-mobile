import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'memo_document.dart';
import 'memo_document_style.dart';

/// 单图超出明确的像素预算时终止，不能截断正文或悄悄拆图。
class MemoImageTooLarge implements Exception {
  const MemoImageTooLarge();
}

/// PNG 使用文档字号的双倍像素，固定白底并保留标题、加粗、列表与缩进。
abstract final class MemoImage {
  static const width = 1200;
  static const maxHeight = 16000;
  static const maxPixels = 16000000;
  static const scale = 2.0;
  static Future<void>? _fonts;

  /// 字体注册只进行一次；失败后允许下一次导出重新加载。
  static Future<void> _loadFonts() async {
    try {
      final regular = FontLoader(MemoDocumentStyle.fontFamily)
        ..addFont(rootBundle.load(MemoDocumentStyle.fontAsset));
      final emoji = FontLoader('MemoExportEmoji')
        ..addFont(rootBundle.load(MemoDocumentStyle.emojiAsset));
      await Future.wait([regular.load(), emoji.load()]);
    } catch (_) {
      _fonts = null;
      rethrow;
    }
  }

  /// 先测量整张图再分配位图；所有绘图资源在成功、失败及取消后统一释放。
  static Future<Uint8List> render(MemoDocument document) async {
    final painters = <({TextPainter painter, double x, double y})>[];
    ui.Picture? picture;
    ui.Image? image;
    try {
      await (_fonts ??= _loadFonts());
      const margin = MemoDocumentStyle.pageMargin * scale;
      var y = margin;
      final counters = List.filled(6, 0);
      for (final paragraph in document.paragraphs) {
        final prefix = switch (paragraph.list) {
          'ordered' => '${++counters[paragraph.indent]}. ',
          'bullet' => '• ',
          'checked' => '[x] ',
          'unchecked' => '[ ] ',
          _ => '',
        };
        if (paragraph.list != 'ordered') counters[paragraph.indent] = 0;
        for (var i = paragraph.indent + 1; i < counters.length; i++) {
          counters[i] = 0;
        }
        final x = margin + paragraph.indent * MemoDocumentStyle.indent * scale;
        final painter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            style: TextStyle(
              color: const Color(0xff000000),
              fontFamily: MemoDocumentStyle.fontFamily,
              fontFamilyFallback: const ['MemoExportEmoji'],
              fontSize:
                  scale *
                  (paragraph.header == null
                      ? MemoDocumentStyle.bodySize
                      : MemoDocumentStyle.headingSizes[paragraph.header! - 1]),
              height: MemoDocumentStyle.lineHeight,
              fontWeight: paragraph.header == null
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
            children: [
              TextSpan(text: prefix),
              for (final run in paragraph.runs)
                TextSpan(
                  text: run.text,
                  style: run.bold
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ),
              if (paragraph.runs.isEmpty) const TextSpan(text: ' '),
            ],
          ),
        );
        painters.add((painter: painter, x: x, y: y));
        painter.layout(maxWidth: width - margin - x);
        y += painter.height + MemoDocumentStyle.paragraphSpacing * scale;
        if (y + margin > maxHeight || width * (y + margin) > maxPixels) {
          throw const MemoImageTooLarge();
        }
      }
      final height = (y + margin).ceil();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(const Color(0xffffffff), BlendMode.src);
      for (final row in painters) {
        row.painter.paint(canvas, Offset(row.x, row.y));
      }
      picture = recorder.endRecording();
      image = await picture.toImage(width, height);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('MEMO_PNG_ENCODING_FAILED');
      return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    } finally {
      image?.dispose();
      picture?.dispose();
      for (final row in painters) {
        row.painter.dispose();
      }
    }
  }
}
