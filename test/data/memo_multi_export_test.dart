import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/memos/application/memo_document_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_document.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_image.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';

/// 固定快照、完整字段与图片边界覆盖真实仓储及文档生成器。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const bookId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const firstId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  const secondId = 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';
  late SesameDatabase db;
  late MemoRepository repo;
  late ProviderContainer container;
  late MemoDocumentActions actions;
  late MemoBook book;
  var identityGeneration = 0;

  setUp(() async {
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    identityGeneration = 0;
    repo = MemoRepository(db, generationGetter: () => identityGeneration);
    book = await repo.createBook(
      id: bookId,
      name: '示例账号本',
      type: 'credentials',
    );
    container = ProviderContainer(
      overrides: [
        memoRepositoryProvider.overrideWithValue(repo),
        currentCredentialBookIdProvider.overrideWithBuild(
          (ref, notifier) => bookId,
        ),
        currentMemoBookIdProvider.overrideWithBuild(
          (ref, notifier) => 'normal',
        ),
      ],
    );
    await container.read(currentCredentialBookIdProvider.future);
    await container.read(currentMemoBookIdProvider.future);
    actions = container.read(memoDocumentActionsProvider);
    final target = await repo.target(bookId);
    for (final (id, count, title, day) in [
      (firstId, 7, '工作邮箱', 2),
      (secondId, 20, '开发账号', 1),
    ]) {
      final date = DateTime.utc(2026, 9, day);
      await repo.saveEntry(
        MemoEntry(
          id: id,
          memoBookId: bookId,
          bookType: 'credentials',
          title: title,
          createdAt: date,
          updatedAt: date,
          bodyJson: encodeMemoFields([
            for (var i = 1; i <= count; i++)
              MemoField(
                label: '字段$i',
                value: i == count ? '末字段完整保留\n第二行 😀' : '演示内容$i',
              ),
          ]),
        ),
        target,
        preserveTimes: true,
      );
    }
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('按本内顺序合并七字段与二十字段记录，Markdown和Word完整保留末字段', () async {
    final job = await actions.captureCredentials(
      bookId,
      {secondId, firstId},
      MemoDocumentFormat.md,
      countLabel: '共 2 条记录',
    );
    expect(job.entries.map((entry) => entry.id), [firstId, secondId]);
    final document = MemoDocument.fromEntries(
      book,
      job.entries,
      job.countLabel,
    );
    final markdown = document.markdown();
    expect(markdown, contains('字段7：末字段完整保留'));
    expect(markdown, contains('字段20：末字段完整保留'));
    expect(markdown.indexOf('工作邮箱'), lessThan(markdown.indexOf('开发账号')));
    final xml = utf8.decode(
      ZipDecoder()
              .decodeBytes(document.docx())
              .findFile('word/document.xml')!
              .content
          as List<int>,
    );
    expect(xml, contains('字段20：末字段完整保留'));
    expect(xml, contains('第二行 😀'));
    final subset = await actions.captureCredentials(
      bookId,
      {secondId},
      MemoDocumentFormat.md,
      countLabel: '共 1 条记录',
    );
    expect(subset.entries.single.id, secondId);
    await expectLater(
      actions.captureCredentials(
        bookId,
        {},
        MemoDocumentFormat.md,
        countLabel: '',
      ),
      throwsStateError,
    );
    await expectLater(
      actions.captureCredentials(
        bookId,
        {'missing'},
        MemoDocumentFormat.md,
        countLabel: '',
      ),
      throwsStateError,
    );
  });

  test('任意所选记录变化、删除、取消和切本均拒绝旧任务，普通本切换不影响账号任务', () async {
    final job = await actions.captureCredentials(
      bookId,
      {firstId, secondId},
      MemoDocumentFormat.md,
      countLabel: '2',
    );
    actions.selectionGeneration++;
    await actions.validate(job);
    actions.credentialGeneration++;
    await expectLater(actions.validate(job), throwsStateError);
    final fresh = await actions.captureCredentials(
      bookId,
      {firstId, secondId},
      MemoDocumentFormat.md,
      countLabel: '2',
    );
    await db.customStatement('UPDATE memo_entries SET title=? WHERE id=?', [
      '改名',
      secondId,
    ]);
    await expectLater(actions.validate(fresh), throwsStateError);
    final removed = await actions.captureCredentials(
      bookId,
      {firstId},
      MemoDocumentFormat.md,
      countLabel: '1',
    );
    await db.customStatement('DELETE FROM memo_entries WHERE id=?', [firstId]);
    await expectLater(actions.validate(removed), throwsStateError);
    final cancelled = await actions.captureCredentials(
      bookId,
      {secondId},
      MemoDocumentFormat.md,
      countLabel: '1',
    );
    cancelled.cancelled = true;
    await expectLater(actions.validate(cancelled), throwsStateError);
  });

  testWidgets('多账号生成一张可解码长图，普通备忘录也可输出PNG', (tester) async {
    await tester.runAsync(() async {
      final job = await actions.captureCredentials(
        bookId,
        {firstId, secondId},
        MemoDocumentFormat.png,
        countLabel: '共 2 条记录',
      );
      final document = MemoDocument.fromEntries(
        book,
        job.entries,
        job.countLabel,
      );
      final bytes = await MemoImage.render(document);
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      try {
        expect(codec.frameCount, 1);
        expect(frame.image.width, MemoImage.width);
        expect(frame.image.height, greaterThan(1200));
        expect(frame.image.height, lessThanOrEqualTo(MemoImage.maxHeight));
        if (const bool.fromEnvironment('MEMO_IMAGE_PREVIEW')) {
          await Directory('Temp').create();
          await File('Temp/memo-image-preview.png').writeAsBytes(bytes);
        }
      } finally {
        frame.image.dispose();
        codec.dispose();
      }
      final normal = MemoDocument(
        bookType: 'normal',
        body: {
          'ops': [
            {'insert': '普通备忘录'},
            {
              'insert': '\n',
              'attributes': {'header': 1},
            },
            {
              'insert': '加粗内容',
              'attributes': {'bold': true},
            },
            {'insert': '\n'},
            {'insert': '待办'},
            {
              'insert': '\n',
              'attributes': {'list': 'unchecked'},
            },
          ],
        },
      );
      expect((await MemoImage.render(normal)).take(8), [
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
      ]);
    });
  });

  test('身份发生变化后拒绝已经捕获的账号文档', () async {
    final job = await actions.captureCredentials(
      bookId,
      {firstId},
      MemoDocumentFormat.png,
      countLabel: '1',
    );
    identityGeneration++;
    await expectLater(actions.validate(job), throwsStateError);
  });

  testWidgets('超长内容明确失败，不生成截断图或多张图', (tester) async {
    await tester.runAsync(() async {
      final document = MemoDocument(
        bookType: 'normal',
        body: {
          'ops': [
            {'insert': List.filled(1000, '完整保留的长文本\n').join()},
          ],
        },
      );
      await expectLater(
        MemoImage.render(document),
        throwsA(isA<MemoImageTooLarge>()),
      );
    });
  });

  test('导出候选摘要不受一百条分页限制', () async {
    final target = await repo.target(bookId);
    for (var i = 0; i < 101; i++) {
      final date = DateTime.utc(2026);
      await repo.saveEntry(
        MemoEntry(
          id: 'dddddddd-dddd-4ddd-8ddd-${i.toString().padLeft(12, '0')}',
          memoBookId: bookId,
          bookType: 'credentials',
          title: '记录$i',
          createdAt: date,
          updatedAt: date,
          bodyJson: encodeMemoFields(const [
            MemoField(label: '账号', value: 'demo'),
          ]),
        ),
        target,
      );
    }
    final subscription = container.listen(
      memoExportEntriesProvider(bookId),
      (_, _) {},
    );
    addTearDown(subscription.close);
    final rows = await container.read(memoExportEntriesProvider(bookId).future);
    expect(rows.length, 103);
    expect(rows.every((entry) => entry.bodyJson == null), isTrue);
  });
}
