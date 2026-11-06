import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'memo_document.dart';
import 'memo_document_style.dart';

/// 单图超出明确的像素预算时终止，不能截断正文或悄悄拆图。
class MemoImageTooLarge implements Exception {
  const MemoImageTooLarge();
}

/// 取消的导出不再分配后续位图或编码缓冲，已创建的绘图资源仍统一释放。
class MemoImageCancelled implements Exception {
  /// 仅表示当前渲染已取消，不携带文档内容。
  const MemoImageCancelled();
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

  /// 分批测量后再分配整图；取消可以在排版批次和异步绘图边界结束后续工作。
  static Future<Uint8List> render(
    MemoDocument document, {
    bool Function()? isCancelled,
  }) async {
    final painters = <({TextPainter painter, double x, double y})>[];
    ui.PictureRecorder? recorder;
    ui.Picture? picture;
    ui.Image? image;

    /// 只读取操作自身的取消状态，不在渲染过程中借用页面或账号引用。
    void checkCancelled() {
      if (isCancelled?.call() ?? false) throw const MemoImageCancelled();
    }

    try {
      checkCancelled();
      await (_fonts ??= _loadFonts());
      checkCancelled();
      const margin = MemoDocumentStyle.pageMargin * scale;
      var y = margin;
      final counters = List.filled(6, 0);
      final slice = Stopwatch()..start();
      var paragraphsInSlice = 0;
      for (final paragraph in document.paragraphs) {
        checkCancelled();
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
        paragraphsInSlice++;
        if (paragraphsInSlice >= 16 ||
            slice.elapsed >= const Duration(milliseconds: 8)) {
          // 排版仍需使用引擎线程；让出事件循环后，取消点击与页面销毁可及时到达。
          await Future<void>.delayed(Duration.zero);
          checkCancelled();
          paragraphsInSlice = 0;
          slice.reset();
        }
      }
      checkCancelled();
      final height = (y + margin).ceil();
      recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(const Color(0xffffffff), BlendMode.src);
      for (final row in painters) {
        row.painter.paint(canvas, Offset(row.x, row.y));
      }
      picture = recorder.endRecording();
      image = await picture.toImage(width, height);
      checkCancelled();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      checkCancelled();
      if (bytes == null) throw StateError('MEMO_PNG_ENCODING_FAILED');
      return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    } finally {
      image?.dispose();
      picture?.dispose();
      // 绘制中异常时也结束尚未交付的录制，释放已记录的文字与绘图命令。
      if (recorder?.isRecording ?? false) recorder!.endRecording().dispose();
      for (final row in painters) {
        row.painter.dispose();
      }
    }
  }
}
