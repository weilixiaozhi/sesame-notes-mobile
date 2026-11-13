import 'dart:typed_data';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:pdf/pdf.dart';
// 字体子集修复所需类型未由 pdf.dart 导出；锁定版本并用字体轮廓探针验证。
// ignore: implementation_imports
import 'package:pdf/src/pdf/format/array.dart';
// ignore: implementation_imports
import 'package:pdf/src/pdf/format/dict.dart';
// ignore: implementation_imports
import 'package:pdf/src/pdf/format/num.dart';
// ignore: implementation_imports
import 'package:pdf/src/pdf/obj/object_stream.dart';
import 'package:xml/xml.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:sesame_notes/data/models/memo_delta.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'memo_document_style.dart';

/// 导出时使用的图片字节与像素尺寸；抓取阶段统一加载，缺失时按占位处理。
class MemoDocumentMedia {
  final Uint8List bytes;
  final int width;
  final int height;
  final String extension;
  const MemoDocumentMedia({
    required this.bytes,
    required this.width,
    required this.height,
    required this.extension,
  });
}

/// 单篇笔记或多条账号记录共用不可变段落模型，交付前由调用方复核账号和目标。
class MemoDocument {
  final List<MemoParagraph> paragraphs;

  /// 正文引用的图片字节；没有对应项的引用在导出中降级为占位文字。
  final Map<String, MemoDocumentMedia> media;

  /// 将有序账号记录合并为一个文档，各格式使用完全相同的段落集合。
  MemoDocument.fromEntries(
    MemoBook book,
    List<MemoEntry> entries,
    String countLabel, {
    Map<String, MemoDocumentMedia> media = const {},
  }) : media = Map.unmodifiable(media),
       paragraphs = List.unmodifiable([
         MemoParagraph([MemoTextRun(book.name)], header: 1),
         MemoParagraph([MemoTextRun(countLabel)]),
         for (final entry in entries) ...[
           MemoParagraph([const MemoTextRun('────────────────')]),
           ...MemoDocument.fromEntry(book, entry).paragraphs,
         ],
       ]);

  MemoDocument({
    required String bookType,
    required Object body,
    this.media = const {},
  }) : paragraphs = memoParagraphs(body) {
    if (!['normal', 'credentials'].contains(bookType)) {
      throw const FormatException('MEMO_DOCUMENT_BOOK_TYPE');
    }
  }

  /// 账号卡转成带字段名的普通段落，三种阅读格式共用同一份内容。
  factory MemoDocument.fromEntry(
    MemoBook book,
    MemoEntry entry, {
    Map<String, MemoDocumentMedia> media = const {},
  }) => MemoDocument(
    bookType: book.type,
    media: media,
    body: entry.isCard
        ? {
            'ops': [
              if (entry.title.isNotEmpty) ...[
                {'insert': entry.title},
                {
                  'insert': '\n',
                  'attributes': {'header': 1},
                },
              ],
              for (final field in entry.fields)
                {'insert': '${field.label}：${field.value}\n'},
            ],
          }
        : entry.body!,
  );

  /// Markdown 源文保留空白；转义原文标点，格式标记仅由 writer 添加。
  String markdown() {
    String escape(String text) => text.replaceAllMapped(
      RegExp(r'[\\`*_{}\[\]<>()#+\-.!|~&]'),
      (match) => '\\${match[0]}',
    );
    final out = StringBuffer();
    final counters = List.filled(6, 0);
    var previousWasList = false;
    for (final paragraph in paragraphs) {
      if (previousWasList && paragraph.list == null) out.writeln();
      previousWasList = paragraph.list != null;
      var content = paragraph.runs.map((run) {
        // Markdown 单文件无法内嵌图片，保留可读占位；导出前由界面提示不包含图片。
        if (run is MemoImageRun) return '[图片]';
        final textRun = run as MemoTextRun;
        if (!textRun.bold || textRun.text.trim().isEmpty) {
          return escape(textRun.text);
        }
        final match = RegExp(
          r'^(\s*)([\s\S]*?)(\s*)$',
        ).firstMatch(textRun.text)!;
        return '${match[1]}**${escape(match[2]!)}**${match[3]}';
      }).join();
      final prefix = switch (paragraph.list) {
        'ordered' => '${++counters[paragraph.indent]}. ',
        'bullet' => '- ',
        'checked' => '- [x] ',
        'unchecked' => '- [ ] ',
        _ => '',
      };
      if (paragraph.list != 'ordered') counters[paragraph.indent] = 0;
      for (var depth = paragraph.indent + 1; depth < counters.length; depth++) {
        counters[depth] = 0;
      }
      final heading = paragraph.header == null
          ? ''
          : '${'#' * paragraph.header!} ';
      // 空段落用 CommonMark 原生 HTML 换行保留；开头空白避免被解析成代码块。
      if (paragraph.list == null && paragraph.header == null) {
        content = content.replaceFirstMapped(
          RegExp(r'^[ \t]+'),
          (m) => m[0]!.codeUnits.map((c) => '&#$c;').join(),
        );
      }
      if (paragraph.text.isEmpty &&
          paragraph.imageIds.isEmpty &&
          paragraph.list == null) {
        content = '<br>';
      }
      if (paragraph.list == null && paragraph.indent > 0) {
        out.writeln(
          '<div style="margin-left:${paragraph.indent * MemoDocumentStyle.indentEm}em">\n\n$heading$content\n\n</div>\n',
        );
        continue;
      }
      out.writeln(
        '${paragraph.list == null ? '' : '    ' * paragraph.indent}$prefix$heading$content',
      );
      if (paragraph.list == null) out.writeln();
    }
    return out.toString();
  }

  /// 固定 OOXML 容器，文字中的制表符与换行使用 Word 的实际节点。
  Uint8List docx() {
    const ns = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main';
    const drawingNs =
        'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing';
    const mainNs = 'http://schemas.openxmlformats.org/drawingml/2006/main';
    const pictureNs =
        'http://schemas.openxmlformats.org/drawingml/2006/picture';
    const officeRelNs =
        'http://schemas.openxmlformats.org/officeDocument/2006/relationships';
    final xml = XmlBuilder();
    void element(String name, void Function() child) =>
        xml.element('w:$name', nest: child);
    void run(MemoTextRun run) {
      if (run.text.runes.any(
        (c) =>
            (c < 32 && c != 9 && c != 10 && c != 13) ||
            c == 0xfffe ||
            c == 0xffff,
      )) {
        throw const FormatException('MEMO_DOCX_UNREPRESENTABLE_CHARACTER');
      }
      element('r', () {
        if (run.bold) element('rPr', () => xml.element('w:b'));
        final pieces = run.text.split(RegExp(r'(\t|\n|\r)'));
        var offset = 0;
        for (final piece in pieces) {
          if (piece.isNotEmpty) {
            xml.element(
              'w:t',
              attributes: {'xml:space': 'preserve'},
              nest: piece,
            );
          }
          offset += piece.length;
          if (offset < run.text.length) {
            xml.element(run.text[offset] == '\t' ? 'w:tab' : 'w:br');
            offset++;
          }
        }
      });
    }

    // 图片按出现顺序生成固定媒体部件与关系，同一标识复用同一部件。
    final imageParts = <String, ({String path, String relationship})>{};
    var nextImage = 1;
    void imageRun(MemoImageRun image) {
      final media = this.media[image.mediaId];
      // 字节缺失或格式 Word 不支持时保留可读占位，不生成损坏的图片关系。
      if (media == null || !['png', 'jpg'].contains(media.extension)) {
        run(const MemoTextRun('[图片]'));
        return;
      }
      final part = imageParts.putIfAbsent(image.mediaId, () {
        final index = nextImage++;
        return (
          path: 'word/media/image$index.${media.extension}',
          relationship: 'rIdImage$index',
        );
      });
      final naturalWidth = media.width * 9525.0;
      final naturalHeight = media.height * 9525.0;
      final contentWidth =
          (PdfPageFormat.a4.width - MemoDocumentStyle.pageMargin * 2) * 12700;
      final contentHeight =
          (PdfPageFormat.a4.height - MemoDocumentStyle.pageMargin * 2) * 12700;
      final scale = <double>[
        1,
        contentWidth / naturalWidth,
        contentHeight / naturalHeight,
      ].reduce((a, b) => a < b ? a : b);
      final width = (naturalWidth * scale).round();
      final height = (naturalHeight * scale).round();
      final docPrId = nextImage;
      xml.element(
        'w:r',
        nest: () {
          xml.element(
            'w:drawing',
            nest: () {
              xml.element(
                'wp:inline',
                namespaces: {'wp': drawingNs, 'a': mainNs, 'pic': pictureNs},
                nest: () {
                  xml.element(
                    'wp:extent',
                    attributes: {'cx': '$width', 'cy': '$height'},
                  );
                  xml.element(
                    'wp:docPr',
                    attributes: {'id': '$docPrId', 'name': '图片 $docPrId'},
                  );
                  xml.element(
                    'a:graphic',
                    nest: () {
                      xml.element(
                        'a:graphicData',
                        attributes: {
                          'uri':
                              'http://schemas.openxmlformats.org/drawingml/2006/picture',
                        },
                        nest: () {
                          xml.element(
                            'pic:pic',
                            nest: () {
                              xml.element(
                                'pic:nvPicPr',
                                nest: () {
                                  xml.element(
                                    'pic:cNvPr',
                                    attributes: {
                                      'id': '$docPrId',
                                      'name':
                                          'image$docPrId.${media.extension}',
                                    },
                                  );
                                  xml.element('pic:cNvPicPr');
                                },
                              );
                              xml.element(
                                'pic:blipFill',
                                nest: () {
                                  xml.element(
                                    'a:blip',
                                    attributes: {'r:embed': part.relationship},
                                    namespaces: {'r': officeRelNs},
                                  );
                                  xml.element(
                                    'a:stretch',
                                    nest: () {
                                      xml.element('a:fillRect');
                                    },
                                  );
                                },
                              );
                              xml.element(
                                'pic:spPr',
                                nest: () {
                                  xml.element(
                                    'a:xfrm',
                                    nest: () {
                                      xml.element(
                                        'a:off',
                                        attributes: {'x': '0', 'y': '0'},
                                      );
                                      xml.element(
                                        'a:ext',
                                        attributes: {
                                          'cx': '$width',
                                          'cy': '$height',
                                        },
                                      );
                                    },
                                  );
                                  xml.element(
                                    'a:prstGeom',
                                    attributes: {'prst': 'rect'},
                                    nest: () {
                                      xml.element('a:avLst');
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    }

    final orderedIds = List<int?>.filled(6, null);
    final usedOrderedIds = <int>[];
    var nextOrderedId = 3;
    void paragraph(MemoParagraph p) {
      if (p.list == 'ordered' && orderedIds[p.indent] == null) {
        orderedIds[p.indent] = nextOrderedId++;
        usedOrderedIds.add(orderedIds[p.indent]!);
      } else if (p.list != 'ordered') {
        orderedIds[p.indent] = null;
      }
      for (var depth = p.indent + 1; depth < orderedIds.length; depth++) {
        orderedIds[depth] = null;
      }
      element('p', () {
        element('pPr', () {
          if (p.header != null) {
            xml.element(
              'w:pStyle',
              attributes: {'w:val': 'Heading${p.header}'},
            );
          }
          if (p.list != null) {
            element('numPr', () {
              xml.element('w:ilvl', attributes: {'w:val': '${p.indent}'});
              xml.element(
                'w:numId',
                attributes: {
                  'w:val': p.list == 'ordered'
                      ? '${orderedIds[p.indent]}'
                      : '2',
                },
              );
            });
          }
          if (p.list == null && p.indent > 0) {
            xml.element(
              'w:ind',
              attributes: {
                'w:left':
                    '${(p.indent * MemoDocumentStyle.indent * 20).round()}',
              },
            );
          }
        });
        if (p.list == 'checked' || p.list == 'unchecked') {
          run(MemoTextRun(p.list == 'checked' ? '[x] ' : '[ ] '));
        }
        for (final r in p.runs) {
          if (r is MemoTextRun) {
            run(r);
          } else if (r is MemoImageRun) {
            imageRun(r);
          }
        }
      });
    }

    xml.element(
      'w:document',
      namespaces: {
        ns: 'w',
        officeRelNs: 'r',
        drawingNs: 'wp',
        mainNs: 'a',
        pictureNs: 'pic',
      },
      nest: () => element('body', () {
        for (final p in paragraphs) {
          paragraph(p);
        }
        element('sectPr', () {
          xml.element(
            'w:pgSz',
            attributes: {
              'w:w': '${(PdfPageFormat.a4.width * 20).round()}',
              'w:h': '${(PdfPageFormat.a4.height * 20).round()}',
            },
          );
          xml.element(
            'w:pgMar',
            attributes: {
              for (final side in ['top', 'right', 'bottom', 'left'])
                'w:$side': '${(MemoDocumentStyle.pageMargin * 20).round()}',
            },
          );
        });
      }),
    );
    final numbering = XmlBuilder();
    numbering.element(
      'w:numbering',
      namespaces: {ns: 'w'},
      nest: () {
        for (var type = 1; type <= 2; type++) {
          numbering.element(
            'w:abstractNum',
            attributes: {'w:abstractNumId': '$type'},
            nest: () {
              for (var level = 0; level <= 5; level++) {
                numbering.element(
                  'w:lvl',
                  attributes: {'w:ilvl': '$level'},
                  nest: () {
                    numbering.element('w:start', attributes: {'w:val': '1'});
                    numbering.element(
                      'w:numFmt',
                      attributes: {'w:val': type == 1 ? 'decimal' : 'bullet'},
                    );
                    numbering.element(
                      'w:lvlText',
                      attributes: {'w:val': type == 1 ? '%${level + 1}.' : '•'},
                    );
                    numbering.element(
                      'w:pPr',
                      nest: () => numbering.element(
                        'w:ind',
                        attributes: {
                          'w:left':
                              '${((level + 1) * MemoDocumentStyle.indent * 20).round()}',
                          'w:hanging':
                              '${(MemoDocumentStyle.listHanging * 20).round()}',
                        },
                      ),
                    );
                  },
                );
              }
            },
          );
        }
        numbering.element(
          'w:num',
          attributes: {'w:numId': '2'},
          nest: () =>
              numbering.element('w:abstractNumId', attributes: {'w:val': '2'}),
        );
        for (final id in usedOrderedIds) {
          numbering.element(
            'w:num',
            attributes: {'w:numId': '$id'},
            nest: () {
              numbering.element('w:abstractNumId', attributes: {'w:val': '1'});
              for (var level = 0; level <= 5; level++) {
                numbering.element(
                  'w:lvlOverride',
                  attributes: {'w:ilvl': '$level'},
                  nest: () => numbering.element(
                    'w:startOverride',
                    attributes: {'w:val': '1'},
                  ),
                );
              }
            },
          );
        }
      },
    );
    final styles =
        '<w:styles xmlns:w="$ns">'
        '<w:docDefaults><w:rPrDefault><w:rPr>'
        '<w:rFonts w:ascii="${MemoDocumentStyle.fontFamily}" w:hAnsi="${MemoDocumentStyle.fontFamily}" w:eastAsia="${MemoDocumentStyle.fontFamily}"/>'
        '<w:sz w:val="${(MemoDocumentStyle.bodySize * 2).round()}"/>'
        '<w:color w:val="${MemoDocumentStyle.textColor}"/>'
        '</w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>'
        '<w:spacing w:before="0" w:after="${(MemoDocumentStyle.paragraphSpacing * 20).round()}" w:line="${(MemoDocumentStyle.lineHeight * 240).round()}" w:lineRule="auto"/>'
        '</w:pPr></w:pPrDefault></w:docDefaults>'
        '${[1, 2, 3].map((n) => '<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n"/><w:rPr><w:b/><w:sz w:val="${(MemoDocumentStyle.headingSizes[n - 1] * 2).round()}"/></w:rPr></w:style>').join()}'
        '</w:styles>';
    final archive = Archive();
    final parts = <String, String>{
      '[Content_Types].xml':
          '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
          '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
          '<Default Extension="xml" ContentType="application/xml"/>'
          '${['png', if (imageParts.values.any((part) => part.path.endsWith('.jpg'))) 'jpg'].map((ext) => '<Default Extension="$ext" ContentType="image/${ext == 'jpg' ? 'jpeg' : ext}"/>').join()}'
          '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
          '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
          '<Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/>'
          '</Types>',
      '_rels/.rels':
          '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>',
      'word/_rels/document.xml.rels':
          '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
          '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
          '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/>'
          '${imageParts.values.map((part) => '<Relationship Id="${part.relationship}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/${part.path.split('/').last}"/>').join()}'
          '</Relationships>',
      'word/document.xml': xml.buildDocument().toXmlString(),
      'word/styles.xml': styles,
      'word/numbering.xml': numbering.buildDocument().toXmlString(),
    };
    for (final part in parts.entries) {
      // ZIP 长度按 UTF-8 字节计，archive 3 的 string 构造器会截断多字节正文。
      final bytes = utf8.encode(part.value);
      archive.addFile(ArchiveFile(part.key, bytes.length, bytes));
    }
    for (final entry in imageParts.entries) {
      final media = this.media[entry.key]!;
      archive.addFile(
        ArchiveFile(entry.value.path, media.bytes.length, media.bytes),
      );
    }
    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  /// 按字素测量并分页，低层文字操作保留空格，避免大段落重复测量和空白丢失。
  Future<Uint8List> pdf(ByteData normalData, ByteData emojiData) async {
    final document = PdfDocument();
    final normal = _MemoPdfFont(document, normalData);
    final emoji = _MemoPdfFont(document, emojiData);
    final fonts = [normal, emoji];
    // 同一图片在整篇中只嵌入一次，重复引用复用同一对象。
    final images = <String, PdfImage>{};
    final textColor = PdfColor.fromHex(MemoDocumentStyle.textColor);
    var page = PdfPage(document, pageFormat: PdfPageFormat.a4);
    var canvas = page.getGraphics();
    var y = PdfPageFormat.a4.height - MemoDocumentStyle.pageMargin;
    final counters = List.filled(6, 0);
    void draw(MemoParagraph p) {
      final size = p.header == null
          ? MemoDocumentStyle.bodySize
          : MemoDocumentStyle.headingSizes[p.header! - 1];
      final lineHeight = size * MemoDocumentStyle.lineHeight;
      final left =
          MemoDocumentStyle.pageMargin + p.indent * MemoDocumentStyle.indent;
      var x = left;
      void nextLine() {
        y -= lineHeight;
        x = left;
        if (y < MemoDocumentStyle.pageMargin + lineHeight) {
          page = PdfPage(document, pageFormat: PdfPageFormat.a4);
          canvas = page.getGraphics();
          y = PdfPageFormat.a4.height - MemoDocumentStyle.pageMargin;
        }
      }

      final prefix = switch (p.list) {
        'ordered' => '${++counters[p.indent]}. ',
        'bullet' => '• ',
        'checked' => '[x] ',
        'unchecked' => '[ ] ',
        _ => '',
      };
      if (p.list != 'ordered') counters[p.indent] = 0;
      for (var depth = p.indent + 1; depth < counters.length; depth++) {
        counters[depth] = 0;
      }
      for (final run in <MemoRun>[
        MemoTextRun(prefix),
        ...p.runs,
        const MemoTextRun('\n'),
      ]) {
        if (run is MemoImageRun) {
          final media = this.media[run.mediaId];
          // 字节缺失或格式不受支持时按与 DOCX 一致的占位文字绘制。
          if (media == null || !['png', 'jpg'].contains(media.extension)) {
            for (final cluster in '[图片]'.characters) {
              final width = normal.stringMetrics(cluster).advanceWidth * size;
              if (x + width >
                      PdfPageFormat.a4.width - MemoDocumentStyle.pageMargin &&
                  x > left) {
                nextLine();
              }
              canvas.setColor(textColor);
              canvas.drawString(normal, size, cluster, x, y);
              x += width;
            }
            continue;
          }
          final maxWidth =
              PdfPageFormat.a4.width - left - MemoDocumentStyle.pageMargin;
          final sizeScale = media.width * 1.0 > maxWidth
              ? maxWidth / media.width
              : 1.0;
          final width = media.width * sizeScale;
          final height = media.height * sizeScale;
          // 图片整体放不下时先换页，避免跨页裁切。
          if (y - height < MemoDocumentStyle.pageMargin + lineHeight) {
            page = PdfPage(document, pageFormat: PdfPageFormat.a4);
            canvas = page.getGraphics();
            y = PdfPageFormat.a4.height - MemoDocumentStyle.pageMargin;
            x = left;
          }
          try {
            final image = images.putIfAbsent(
              run.mediaId,
              () => PdfImage.file(document, bytes: media.bytes),
            );
            canvas.drawImage(image, x, y - height, width, height);
          } catch (_) {
            // 图片解码失败不阻断整篇导出，正文与占位继续输出。
            for (final cluster in '[图片]'.characters) {
              final width = normal.stringMetrics(cluster).advanceWidth * size;
              canvas.setColor(textColor);
              canvas.drawString(normal, size, cluster, x, y);
              x += width;
            }
          }
          y -= height;
          continue;
        }
        for (final cluster in (run as MemoTextRun).text.characters) {
          final font = fonts.firstWhere(
            (f) => cluster.runes.every(f.font.charToGlyphIndexMap.containsKey),
            orElse: () => normal,
          );
          if (cluster.runes.any(
            (c) => !font.font.charToGlyphIndexMap.containsKey(c),
          )) {
            throw const FormatException('MEMO_PDF_MISSING_GLYPH');
          }
          final width = font.stringMetrics(cluster).advanceWidth * size;
          if (x + width >
                  PdfPageFormat.a4.width - MemoDocumentStyle.pageMargin &&
              x > left) {
            nextLine();
          }
          canvas.setLineWidth(MemoDocumentStyle.boldStroke);
          canvas.setColor(textColor);
          canvas.drawString(
            font,
            size,
            cluster,
            x,
            y,
            mode: run.bold || p.header != null
                ? PdfTextRenderingMode.fillAndStroke
                : PdfTextRenderingMode.fill,
          );
          x += width;
          if (cluster == '\n' || cluster == '\r') nextLine();
        }
      }
      y -= MemoDocumentStyle.paragraphSpacing;
    }

    for (final p in paragraphs) {
      draw(p);
    }
    return document.save();
  }
}

/// 修正 pdf 3.12 的重复字形子集与补充平面映射，不修改包缓存。
class _MemoPdfFont extends PdfTtfFont {
  _MemoPdfFont(super.document, super.data) {
    _glyphMap = PdfObjectStream(pdfDocument, isBinary: true);
    for (final code in [9, 10, 13]) {
      font.charToGlyphIndexMap[code] = font.charToGlyphIndexMap[32]!;
    }
  }
  late final PdfObjectStream _glyphMap;
  @override
  PdfFontMetrics glyphMetrics(int code) =>
      code == 10 || code == 13 ? PdfFontMetrics.zero : super.glyphMetrics(code);
  @override
  void prepare() {
    final codes = List<int>.of(unicodeCMap.cmap);
    final uniqueCodes = <int>[];
    final glyphIds = <int, int>{};
    final mapping = ByteData(codes.length * 2);
    for (var index = 0; index < codes.length; index++) {
      final glyph = font.charToGlyphIndexMap[codes[index]] ?? 0;
      final subset = glyphIds.putIfAbsent(glyph, () {
        uniqueCodes.add(
          glyph == font.charToGlyphIndexMap[32] ? 32 : codes[index],
        );
        return uniqueCodes.length - 1;
      });
      mapping.setUint16(index * 2, subset);
    }
    unicodeCMap.cmap
      ..clear()
      ..addAll(uniqueCodes);
    super.prepare();
    unicodeCMap.cmap
      ..clear()
      ..addAll(codes);
    _glyphMap.buf.putBytes(mapping.buffer.asUint8List());
    final descendant =
        (params['/DescendantFonts'] as PdfArray).values.single as PdfDict;
    descendant['/CIDToGIDMap'] = _glyphMap.ref();
    widthsObject.params.values
      ..clear()
      ..addAll(
        codes.map(
          (code) => PdfNum((glyphMetrics(code).advanceWidth * 1000).toInt()),
        ),
      );
    for (var index = 0; index < unicodeCMap.cmap.length; index++) {
      final code = unicodeCMap.cmap[index];
      if (code > 0xffff && code <= 0x10ffff) {
        final units = String.fromCharCode(code).codeUnits;
        unicodeCMap.cmap[index] = (units[0] << 16) | units[1];
      }
    }
  }
}
