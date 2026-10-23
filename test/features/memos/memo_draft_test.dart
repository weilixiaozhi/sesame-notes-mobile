import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/features/memos/application/memo_draft.dart';

void main() {
  MemoEntry entry(String title) => MemoEntry(
    id: 'fixed',
    memoBookId: 'book',
    bookType: 'normal',
    title: title,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
    bodyJson: '{"ops":[{"insert":"\\n"}]}',
  );
  test('连续输入只标记变更，flush 才捕获一次最新完整正文', () async {
    var captures = 0, latest = '';
    final saved = <String>[];
    final draft = MemoDraft(
      automatic: false,
      save: (value) async => saved.add(value.title),
    );
    addTearDown(draft.dispose);
    for (var i = 0; i < 100; i++) {
      latest = '输入$i';
      draft.editLazy(() {
        captures++;
        return entry(latest);
      });
    }
    expect(draft.dirty, isTrue);
    expect(captures, 0);
    await draft.flush();
    expect(captures, 1);
    expect(saved, ['输入99']);
    expect(draft.dirty, isFalse);
  });
  test('提前保护后仍能记录后续输入，不沿用旧快照', () async {
    var latest = '第一版';
    final protected = <String>[];
    final saved = <String>[];
    final draft = MemoDraft(
      automatic: false,
      onSnapshot: (value) => protected.add(value.title),
      save: (value) async => saved.add(value.title),
    );
    addTearDown(draft.dispose);
    draft.editLazy(() => entry(latest));
    expect(draft.value!.title, '第一版');
    latest = '第二版';
    draft.editLazy(() => entry(latest));
    await draft.flush();
    expect(protected, ['第一版', '第二版']);
    expect(saved, ['第二版']);
  });
  test('纯打开不创建；保存中继续编辑串行写最新版本，flush 等待全部完成', () async {
    final first = Completer<void>();
    final writes = <String>[];
    final draft = MemoDraft(
      automatic: false,
      save: (entry) async {
        writes.add(entry.title);
        if (writes.length == 1) await first.future;
      },
    );
    addTearDown(draft.dispose);
    await draft.flush();
    expect(writes, isEmpty);
    draft.edit(entry('旧'));
    final flushed = draft.flush();
    draft.edit(entry('新'));
    expect(draft.dirty, isTrue);
    first.complete();
    await flushed;
    expect(writes, ['旧', '新']);
    expect(draft.state, MemoSaveState.saved);
    expect(draft.dirty, isFalse);
  });
  test('失败保留输入，重试用同一身份最新版本，不误标成功', () async {
    var fail = true;
    final saved = <MemoEntry>[];
    final draft = MemoDraft(
      automatic: false,
      save: (entry) async {
        if (fail) throw StateError('failure');
        saved.add(entry);
      },
    );
    addTearDown(draft.dispose);
    draft.edit(entry('保留'));
    await expectLater(draft.flush(), throwsStateError);
    expect(draft.state, MemoSaveState.failed);
    expect(draft.value!.title, '保留');
    fail = false;
    await draft.flush();
    expect(saved.single.id, 'fixed');
    expect(saved.single.title, '保留');
    expect(draft.dirty, isFalse);
  });

  test('卡片顺序达到上限保留固定错误码和草稿，未知错误仍隐藏底层详情', () async {
    for (final code in ['MEMO_ORDER_CAPACITY', '底层错误包含敏感正文']) {
      final draft = MemoDraft(
        automatic: false,
        save: (_) async => throw StateError(code),
      );
      addTearDown(draft.dispose);
      draft.edit(entry('保留'));
      await expectLater(
        draft.flush(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            '安全错误码',
            code == 'MEMO_ORDER_CAPACITY' ? code : 'MEMO_SAVE_FAILED',
          ),
        ),
      );
      expect(draft.state, MemoSaveState.failed);
      expect(draft.dirty, isTrue);
      expect(draft.value!.title, '保留');
    }
  });
}
