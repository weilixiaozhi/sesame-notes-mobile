import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/models/memo_json.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/settings/application/import_target.dart';
import 'package:sesame_notes/features/settings/application/memo_file_actions.dart';
import 'package:sesame_notes/features/settings/application/transfer_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

/// 备忘录导出与统一导入的往返契约：
/// 导出必须是仓储标准交换格式（自描述本名与本子类型），
/// 统一导入必须能自动落到嵌套明细数组并完成导入。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late SesameDatabase db;
  late MemoRepository repo;
  late WidgetRef ref;
  final now = DateTime.utc(2026, 9, 7, 10);

  setUp(() async {
    temp = createTestTempDirectorySync('memo-roundtrip-');
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = MemoRepository(
      db,
      accountIdGetter: () => null,
      generationGetter: () => 0,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => null),
    );
  });

  tearDown(() async {
    await db.close();
    if (temp.existsSync()) temp.deleteSync(recursive: true);
  });

  /// 建一本本子并写入一条记录，返回本子 id。
  Future<String> seedBook({
    required String id,
    required String name,
    required String type,
    required String entryId,
  }) async {
    await repo.createBook(id: id, name: name, type: type);
    final card = type == 'credentials';
    await repo.saveEntry(
      MemoEntry(
        id: entryId,
        memoBookId: id,
        bookType: type,
        title: card ? '示例卡片' : '示例笔记',
        createdAt: now,
        updatedAt: now,
        bodyJson: card
            ? encodeMemoFields(const [
                MemoField(label: '账号', value: 'user@example.com'),
                MemoField(label: '密码', value: 'secret'),
              ])
            : jsonEncode({
                'ops': [
                  {'insert': '正文内容\n'},
                ],
              }),
      ),
      await repo.target(id),
    );
    return id;
  }

  Future<({String path, String fileName})> exportBook(String id) async {
    late String path;
    await TestAsyncUtils.guard(() async {
      final snapshot = await prepareMemoExport(ref.read, id);
      path = await writeMemoExport(
        ref.read,
        snapshot,
        business: '备忘录',
        outputDirectory: temp,
        typeLabel: snapshot.document.books.single.book.type == 'credentials'
            ? '账号密码本'
            : '普通本',
      );
    });
    return (path: path, fileName: path.split(Platform.pathSeparator).last);
  }

  for (final (type, entryId) in [
    ('credentials', '11111111-1111-4111-8111-111111111112'),
    ('normal', '22222222-2222-4222-8222-222222222223'),
  ]) {
    testWidgets('$type 本导出为交换格式并能被统一导入读回', (tester) async {
      final bookId = type == 'credentials'
          ? '11111111-1111-4111-8111-111111111111'
          : '22222222-2222-4222-8222-222222222222';
      await seedBook(
        id: bookId,
        name: type == 'credentials' ? '账号本' : '笔记',
        type: type,
        entryId: entryId,
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            memoRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            home: Consumer(
              builder: (context, value, _) {
                ref = value;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      late ({String path, String fileName}) exported;
      await tester.runAsync(() async {
        exported = await exportBook(bookId);
      });

      // 文件名自描述业务与本子类型，导出后重新导入时可直接辨认来源。
      expect(exported.fileName, contains('备忘录'));
      expect(
        exported.fileName,
        contains(type == 'credentials' ? '账号密码本' : '普通本'),
      );

      // 文件是仓储标准交换格式：本名与本子类型随文件携带。
      final bytes = File(exported.path).readAsBytesSync();
      final document = MemoJsonDocument.decode(bytes);
      expect(document.books.single.book.type, type);
      expect(
        document.books.single.book.name,
        type == 'credentials' ? '账号本' : '笔记',
      );

      final kind = type == 'credentials'
          ? TransferKind.credentials
          : TransferKind.memo;
      final table = TransferTable.parse(utf8.decode(bytes), kind);
      // 明细在 books[].entries 里：默认路径必须落到明细而不是外层包装对象。
      expect(table.recordPath, 'books.entries');
      expect(table.memoBookType, type);
      final detected = table.detect(kind);
      for (final field in transferFields[kind]!.where((f) => f.required)) {
        expect(
          detected.containsKey(field.key),
          isTrue,
          reason: '必填字段 ${field.key} 必须能自动映射',
        );
      }

      // 真实统一导入管线：预览无错误并成功写入一条记录。
      await tester.runAsync(() async {
        final actions = TransferActions(
          ref.read,
          DataImportTarget(memoTarget: await repo.target(bookId)),
          table,
          kind,
        );
        await actions.prepare();
        actions.map(detected, const {});
        await actions.buildPreview();
        expect(actions.preview.single.error, isNull);
        expect(actions.preview.single.selected, isTrue);
        final outcome = await actions.import((_, _) {}, (_) {});
        expect(outcome.imported, 1);
        expect(outcome.failed, 0);
      });
      await tester.pumpWidget(const SizedBox());
    });
  }
}
