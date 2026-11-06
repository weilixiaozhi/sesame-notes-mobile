import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' as d;
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
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 在完整条目读取返回前改变会话，用真实仓储验证读取后的身份复核。
class _EntryReadHook extends d.QueryInterceptor {
  void Function()? afterEntries;

  /// 目标父本查询保持原样，钩子只作用于一次所选条目读取。
  @override
  Future<List<Map<String, Object?>>> runSelect(
    d.QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final rows = await executor.runSelect(statement, args);
      if (statement.contains('FROM "memo_entries"') &&
          !statement.contains('JOIN')) {
        final callback = afterEntries;
        afterEntries = null;
        callback?.call();
      }
      return rows;
    } catch (error, stackTrace) {
      logger.error(
        'MemoExportTest',
        '导出身份边界夹具读取失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }
}

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
  late _EntryReadHook readHook;
  var identityGeneration = 0;

  setUp(() async {
    readHook = _EntryReadHook();
    db = SesameDatabase.withExecutor(
      d.ApplyInterceptor(NativeDatabase.memory()).interceptWith(readHook),
    );
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

  test('读取所选正文期间会话变化时拒绝捕获，不交付旧账号快照', () async {
    try {
      readHook.afterEntries = () => identityGeneration++;
      await expectLater(
        actions.captureCredentials(
          bookId,
          {firstId, secondId},
          MemoDocumentFormat.md,
          countLabel: '2',
        ),
        throwsStateError,
      );
    } catch (error, stackTrace) {
      logger.error('MemoExportTest', '读取期间身份复核验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('所选账号跨查询块后仍按本内顺序完整导出并忽略重复标识', () async {
    try {
      final date = DateTime.utc(2026);
      final ids = [
        for (var i = 0; i < 501; i++)
          'dddddddd-dddd-4ddd-8ddd-${i.toString().padLeft(12, '0')}',
      ];
      await db.batch(
        (batch) => batch.insertAll(db.memoEntries, [
          for (var i = 0; i < ids.length; i++)
            MemoEntriesCompanion.insert(
              id: ids[i],
              memoBookId: bookId,
              bookType: 'credentials',
              title: '所选账号$i',
              bodyFormat: const d.Value('fields_v1'),
              body: d.Value(
                encodeMemoFields([MemoField(label: '账号', value: 'demo-$i')]),
              ),
              orderKey: d.Value(i + 2),
              createdAt: date,
              updatedAt: date,
            ),
        ]),
      );
      final selected = await repo.getEntriesByIds([
        ...ids.reversed,
        firstId,
        ids.first,
        secondId,
      ], await repo.target(bookId));
      expect(selected.map((entry) => entry.id), [firstId, secondId, ...ids]);
      expect(selected.last.fields.single.value, 'demo-500');
      final job = await actions.captureCredentials(
        bookId,
        ids.reversed.toSet(),
        MemoDocumentFormat.md,
        countLabel: '501',
      );
      expect(job.entries.map((entry) => entry.id), ids);
      expect(job.entries.every((entry) => entry.bodyJson != null), isTrue);
    } catch (error, stackTrace) {
      logger.error('MemoExportTest', '批量导出顺序与完整性验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('勾选其他本的条目时拒绝捕获，不把跨本正文混入文档', () async {
    try {
      const other = 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee';
      const foreign = 'ffffffff-ffff-4fff-8fff-ffffffffffff';
      await repo.createBook(id: other, name: '其他账号本', type: 'credentials');
      final date = DateTime.utc(2026);
      await repo.saveEntry(
        MemoEntry(
          id: foreign,
          memoBookId: other,
          bookType: 'credentials',
          title: '另一份账号',
          bodyJson: encodeMemoFields(const [
            MemoField(label: '账号', value: 'foreign'),
          ]),
          createdAt: date,
          updatedAt: date,
        ),
        await repo.target(other),
      );
      final selected = await repo.getEntriesByIds([
        firstId,
        foreign,
      ], await repo.target(bookId));
      expect(selected.map((entry) => entry.id), [firstId]);
      await expectLater(
        actions.captureCredentials(
          bookId,
          {firstId, foreign},
          MemoDocumentFormat.md,
          countLabel: '2',
        ),
        throwsStateError,
      );
    } catch (error, stackTrace) {
      logger.error('MemoExportTest', '跨本导出隔离验证失败', error, stackTrace);
      rethrow;
    }
  });

  for (final mutation in ['body', 'order', 'softDelete']) {
    test('所选记录$mutation变化即使时钟未变也拒绝交付旧文档', () async {
      try {
        final job = await actions.captureCredentials(
          bookId,
          {firstId},
          MemoDocumentFormat.md,
          countLabel: '1',
        );
        switch (mutation) {
          case 'body':
            await db.customStatement(
              'UPDATE memo_entries SET body=? WHERE id=?',
              [
                encodeMemoFields(const [
                  MemoField(label: '账号', value: 'changed'),
                ]),
                firstId,
              ],
            );
          case 'order':
            await db.customStatement(
              'UPDATE memo_entries SET order_key=? WHERE id=?',
              [99, firstId],
            );
          case 'softDelete':
            await db.customStatement(
              'UPDATE memo_entries SET deleted_at=? WHERE id=?',
              [DateTime.utc(2026).millisecondsSinceEpoch, firstId],
            );
        }
        await expectLater(actions.validate(job), throwsStateError);
        if (mutation == 'softDelete') {
          await expectLater(
            actions.captureCredentials(
              bookId,
              {firstId, secondId},
              MemoDocumentFormat.md,
              countLabel: '2',
            ),
            throwsStateError,
          );
        }
      } catch (error, stackTrace) {
        logger.error('MemoExportTest', '导出快照版本保护验证失败', error, stackTrace);
        rethrow;
      }
    });
  }

  testWidgets('PNG生成过程中取消任务会停止交付且不创建临时目录', (tester) async {
    await tester.runAsync(() async {
      final job = await actions.captureCredentials(
        bookId,
        {firstId},
        MemoDocumentFormat.png,
        countLabel: '1',
      );
      final previous = ui.Image.onCreate;
      ui.Image.onCreate = (image) {
        previous?.call(image);
        job.cancelled = true;
      };
      try {
        await expectLater(
          actions.generate(job, untitled: '未命名'),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              '取消原因',
              'MEMO_EXPORT_CANCELLED',
            ),
          ),
        );
        expect(job.directory, isNull);
      } finally {
        ui.Image.onCreate = previous;
        await job.dispose();
      }
    });
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
