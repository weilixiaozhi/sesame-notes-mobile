import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_document.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_document_style.dart';
import 'package:sesame_notes/features/memos/application/memo_document_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('账号卡允许捕获导出快照，字段改变或取消后拒绝交付', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MemoRepository(db);
    final book = await repo.createBook(
      id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      name: '账号',
      type: 'credentials',
    );
    final target = await repo.target(book.id);
    final date = DateTime.utc(2026);
    final entry = MemoEntry(
      id: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
      memoBookId: book.id,
      bookType: book.type,
      title: '邮箱',
      createdAt: date,
      updatedAt: date,
      // 卡片正文使用字段列表，值允许为空串。
      bodyJson: encodeMemoFields(const [
        MemoField(label: '账号', value: 'demo'),
        MemoField(label: '密码', value: 'test'),
        MemoField(label: '手机号', value: ''),
        MemoField(label: '邮箱', value: ''),
        MemoField(label: '备注', value: ''),
      ]),
    );
    await repo.saveEntry(entry, target);
    final container = ProviderContainer(
      overrides: [
        memoRepositoryProvider.overrideWithValue(repo),
        currentMemoBookIdProvider.overrideWithBuild((ref, notifier) => book.id),
      ],
    );
    addTearDown(container.dispose);
    await container.read(currentMemoBookIdProvider.future);
    final actions = container.read(memoDocumentActionsProvider);
    final job = await actions.capture(entry.id, MemoDocumentFormat.md);
    await actions.validate(job);
    for (var index = 0; index < entry.fields.length; index++) {
      final snapshot = await actions.capture(entry.id, MemoDocumentFormat.md);
      // 不改时间戳，逐个改动字段取值，验证快照校验也能发现实际字段变化。
      await db.customStatement('UPDATE memo_entries SET body=? WHERE id=?', [
        encodeMemoFields([
          for (var i = 0; i < entry.fields.length; i++)
            MemoField(
              label: entry.fields[i].label,
              value: i == index ? 'changed' : entry.fields[i].value,
            ),
        ]),
        entry.id,
      ]);
      await expectLater(actions.validate(snapshot), throwsStateError);
    }
    final cancelled = await actions.capture(entry.id, MemoDocumentFormat.pdf);
    cancelled.cancelled = true;
    await expectLater(actions.validate(cancelled), throwsStateError);
    await expectLater(
      actions.capture('missing', MemoDocumentFormat.md),
      throwsStateError,
    );
  });
  test('文档文件名跨平台边界：保留有效 Unicode、限制字节、避免设备名与尾点', () {
    expect(memoDocumentFilename('CON'), '_CON');
    expect(memoDocumentFilename('a/b:c*?'), 'a_b_c__');
    expect(memoDocumentFilename('${'a' * 47}.${'b' * 10}'), 'a' * 47);
    expect(
      utf8.encode(memoDocumentFilename('😀' * 100)).length,
      lessThanOrEqualTo(192),
    );
    expect(memoDocumentFilename(' ... '), 'memo');
  });
  MemoDocument build(Object body) =>
      MemoDocument(bookType: 'normal', body: body);
  test('单篇不可变快照与三个格式共用的段落模型', () {
    final body = {
      'ops': [
        {'insert': '第一段\n\n第三段\n'},
      ],
    };
    final document = build(body);
    body['ops']!.clear();
    expect(document.paragraphs.map((p) => p.text), ['第一段', '', '第三段']);
    expect(document.markdown(), '第一段\n\n<br>\n\n第三段\n\n');
    final zip = ZipDecoder().decodeBytes(document.docx());
    for (final part in zip.files) {
      expect(part.size, (part.content as List<int>).length);
    }
    expect(zip.findFile('[Content_Types].xml'), isNotNull);
    expect(zip.findFile('word/_rels/document.xml.rels'), isNotNull);
    final styles = XmlDocument.parse(
      utf8.decode(zip.findFile('word/styles.xml')!.content as List<int>),
    );
    // Word 单位转换后须与 PDF 使用的同一打印规格一致，不能依赖阅读器默认值。
    expect(
      styles.findAllElements('w:sz').map((node) => node.getAttribute('w:val')),
      [
        '${(MemoDocumentStyle.bodySize * 2).round()}',
        for (final size in MemoDocumentStyle.headingSizes)
          '${(size * 2).round()}',
      ],
    );
    expect(
      styles.findAllElements('w:spacing').single.getAttribute('w:line'),
      '${(MemoDocumentStyle.lineHeight * 240).round()}',
    );
    expect(
      styles.findAllElements('w:rFonts').single.getAttribute('w:eastAsia'),
      MemoDocumentStyle.fontFamily,
    );
    final xml = XmlDocument.parse(
      utf8.decode(zip.findFile('word/document.xml')!.content as List<int>),
    );
    final paragraphs = xml.findAllElements('w:p').toList();
    expect(paragraphs, hasLength(3));
    expect(paragraphs[paragraphs.length - 3].innerText, '第一段');
    expect(paragraphs[paragraphs.length - 2].innerText, '');
    expect(paragraphs.last.innerText, '第三段');
  });
  test('Word 制表符、转义、加粗、标题、嵌套编号和任务状态', () {
    final document = build({
      'ops': [
        {
          'insert': '  <>&😀\t文本  ',
          'attributes': {'bold': true},
        },
        {
          'insert': '\n',
          'attributes': {'header': 2},
        },
        {'insert': '项目'},
        {
          'insert': '\n',
          'attributes': {'list': 'ordered', 'indent': 2},
        },
        {'insert': '完成'},
        {
          'insert': '\n',
          'attributes': {'list': 'checked'},
        },
      ],
    });
    final zip = ZipDecoder().decodeBytes(document.docx());
    final xml = XmlDocument.parse(
      utf8.decode(zip.findFile('word/document.xml')!.content as List<int>),
    );
    expect(xml.findAllElements('w:tab').length, 1);
    expect(xml.findAllElements('w:b').length, 1);
    expect(
      xml.findAllElements('w:t').any((t) => t.innerText == '  <>&😀'),
      isTrue,
    );
    expect(xml.findAllElements('w:ilvl').map((n) => n.getAttribute('w:val')), [
      '2',
      '0',
    ]);
    expect(document.markdown(), contains('##   **\\<\\>\\&'));
  });
  test('未知本类型拒绝工具文档输出', () {
    expect(
      () => MemoDocument(
        bookType: 'unknown',
        body: {
          'ops': [
            {'insert': '\n'},
          ],
        },
      ),
      throwsFormatException,
    );
  });
  test('账号密码卡的全部字段复用三种文档格式，保留空白、换行和特殊字符', () async {
    final date = DateTime.utc(2026, 9, 9);
    final book = MemoBook(
      id: 'book',
      name: '账号本',
      type: 'credentials',
      createdAt: date,
      updatedAt: date,
    );
    final entry = MemoEntry(
      id: 'entry',
      memoBookId: book.id,
      bookType: book.type,
      title: '邮箱',
      createdAt: date,
      updatedAt: date,
      bodyJson: encodeMemoFields(const [
        MemoField(label: '账号', value: ' user@example.com '),
        MemoField(label: '密码', value: ' <>&*secret_123 '),
        MemoField(label: '手机号', value: ''),
        MemoField(label: '邮箱', value: 'contact@example.com'),
        MemoField(label: '备注', value: '第一行\n第二行'),
      ]),
    );
    final document = MemoDocument.fromEntry(book, entry);
    expect(document.paragraphs.map((p) => p.text), [
      '邮箱',
      '账号： user@example.com ',
      '密码： <>&*secret_123 ',
      '手机号：',
      '邮箱：contact@example.com',
      '备注：第一行',
      '第二行',
    ]);
    expect(document.markdown(), isNot(contains('账号密码本')));
    expect(document.markdown(), contains(r'密码： \<\>\&\*secret\_123 '));
    final zip = ZipDecoder().decodeBytes(document.docx());
    final xml = XmlDocument.parse(
      utf8.decode(zip.findFile('word/document.xml')!.content as List<int>),
    );
    expect(
      xml.findAllElements('w:p').map((p) => p.innerText),
      document.paragraphs.map((p) => p.text),
    );
    final pdf = await document.pdf(
      ByteData.sublistView(File(MemoDocumentStyle.fontAsset).readAsBytesSync()),
      ByteData.sublistView(
        File(MemoDocumentStyle.emojiAsset).readAsBytesSync(),
      ),
    );
    expect(ascii.decode(pdf.take(5).toList()), '%PDF-');
    // 字段名由正文数据给出，自定义名称同样逐行导出。
    expect(
      MemoDocument.fromEntry(
        book,
        MemoEntry(
          id: 'entry-renamed',
          memoBookId: book.id,
          bookType: book.type,
          title: '邮箱',
          createdAt: date,
          updatedAt: date,
          bodyJson: encodeMemoFields(const [
            MemoField(label: 'Password', value: ' <>&*secret_123 '),
          ]),
        ),
      ).paragraphs.last.text,
      'Password： <>&*secret_123 ',
    );
  });
}
