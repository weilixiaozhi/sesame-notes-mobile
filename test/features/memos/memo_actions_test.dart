import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';

/// 本组不执行删除，用例仍显式接收生命周期能力。
class _Lifecycle extends Mock implements DataLifecycleActions {}

/// 验证编辑快照与原目标绑定，错误目标不会被转交给当前账号。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late MemoRepository repository;
  late MemoActions actions;
  String? account;
  const firstId = '11111111-1111-4111-8111-111111111111';
  const secondId = '22222222-2222-4222-8222-222222222222';

  setUp(() {
    account = null;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = MemoRepository(db, accountIdGetter: () => account);
    actions = MemoActions(repository, _Lifecycle());
  });
  tearDown(() => db.close());

  /// 创建普通笔记的合法正文，测试只改变父本或会话身份。
  MemoEntry entry(String bookId) => MemoEntry(
    id: '33333333-3333-4333-8333-333333333333',
    memoBookId: bookId,
    bookType: 'normal',
    title: '原始笔记',
    bodyJson: jsonEncode({
      'ops': [
        {'insert': '正文\n'},
      ],
    }),
    createdAt: DateTime.utc(2026, 9, 19),
    updatedAt: DateTime.utc(2026, 9, 19),
  );

  test('账号切换后旧编辑快照不能再保存原条目', () async {
    await repository.createBook(id: firstId, name: '原本', type: 'normal');
    final snapshot = await actions.prepareEditor(firstId);
    final value = entry(firstId);
    await actions.saveEntry(value, snapshot.target);
    account = 'another-account';
    await expectLater(
      actions.saveEntry(value, snapshot.target),
      throwsStateError,
    );
    expect((await db.select(db.memoEntries).getSingle()).title, '原始笔记');
  });

  test('一个本子的固定目标不能打开或保存另一个本子的条目', () async {
    await repository.createBook(id: firstId, name: '本子一', type: 'normal');
    await repository.createBook(id: secondId, name: '本子二', type: 'normal');
    final target = await actions.target(firstId);
    await expectLater(
      actions.prepareEditor(secondId, fixedTarget: target),
      throwsStateError,
    );
    await expectLater(
      actions.saveEntry(entry(secondId), target),
      throwsStateError,
    );
    expect(await db.select(db.memoEntries).get(), isEmpty);
  });
}
