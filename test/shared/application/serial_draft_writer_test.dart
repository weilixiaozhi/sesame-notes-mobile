import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/application/serial_draft_writer.dart';

/// 验证连续输入、错误恢复和展示生命周期下的持久化顺序。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('前序写入完成后才处理新输入，只发布最新草稿的回执', () async {
    final first = Completer<String>();
    final second = Completer<String>();
    final started = <String>[];
    final published = <String>[];
    final writer = SerialDraftWriter<String>(
      save: (value) {
        started.add(value);
        return value == 'a' ? first.future : second.future;
      },
      onSaved: published.add,
      onChanged: () {},
    );
    writer.submit('a');
    writer.submit('b');
    await Future<void>.delayed(Duration.zero);
    expect(started, ['a']);
    expect(writer.pending, 2);
    first.complete('saved-a');
    await Future<void>.delayed(Duration.zero);
    expect(started, ['a', 'b']);
    expect(published, isEmpty);
    second.complete('saved-b');
    expect(await writer.flush(), isTrue);
    expect(published, ['saved-b']);
    expect(writer.pending, 0);
    writer.dispose();
  });

  test('离开前只重试最新失败草稿一次，持续失败保留错误状态', () async {
    final saved = <String>[];
    final writer = SerialDraftWriter<String>(
      save: (value) async {
        saved.add(value);
        throw StateError('storage unavailable');
      },
      onSaved: (_) => fail('失败保存不能发布成功回执'),
      onChanged: () {},
    );
    writer.submit('draft');
    expect(await writer.flush(), isFalse);
    expect(saved, ['draft', 'draft']);
    expect(writer.failed, isTrue);
    expect(writer.pending, 0);
    writer.dispose();
  });

  test('旧草稿失败不阻断更新输入，也不会覆盖新输入的成功状态', () async {
    final started = <String>[];
    final published = <String>[];
    final writer = SerialDraftWriter<String>(
      save: (value) async {
        started.add(value);
        if (value == 'old') throw StateError('old save failed');
        return value;
      },
      onSaved: published.add,
      onChanged: () {},
    );
    writer.submit('old');
    writer.submit('new');
    expect(await writer.flush(), isTrue);
    expect(started, ['old', 'new']);
    expect(published, ['new']);
    writer.dispose();
  });

  test('展示者释放后继续完成已提交写入，不再发送界面通知', () async {
    final saved = Completer<String>();
    var notifications = 0;
    final published = <String>[];
    final writer = SerialDraftWriter<String>(
      save: (_) => saved.future,
      onSaved: published.add,
      onChanged: () => notifications++,
    );
    writer.submit('draft');
    final beforeDispose = notifications;
    writer.dispose();
    saved.complete('persisted');
    expect(await writer.flush(), isTrue);
    expect(writer.pending, 0);
    expect(notifications, beforeDispose);
    expect(published, isEmpty);
  });

  test('等待保存期间收到更新输入，业务动作等最新内容落盘后才继续', () async {
    final first = Completer<void>();
    final finalWrite = Completer<void>();
    final finalStarted = Completer<void>();
    var persisted = '';
    var actionStarted = false;
    final writer = SerialDraftWriter<String>(
      save: (draft) async {
        if (draft == 'first') await first.future;
        if (draft == 'final') {
          finalStarted.complete();
          await finalWrite.future;
        }
        persisted = draft;
        return draft;
      },
      onSaved: (_) {},
      onChanged: () {},
    );
    writer.submit('first');
    final leaving = writer.flush().then((ok) {
      actionStarted = ok;
      return ok;
    });
    writer.submit('intermediate');
    writer.submit('final');
    first.complete();
    await finalStarted.future;
    expect(actionStarted, isFalse);
    finalWrite.complete();
    expect(await leaving, isTrue);
    expect(actionStarted, isTrue);
    expect(persisted, 'final');
    writer.dispose();
  });

  test('旧写入失败后已接收的最新草稿仍在页面释放后保存', () async {
    final releaseFirst = Completer<void>();
    var persisted = '';
    final published = <String>[];
    final writer = SerialDraftWriter<String>(
      save: (draft) async {
        if (draft == 'old') {
          await releaseFirst.future;
          throw StateError('old failed');
        }
        persisted = draft;
        return draft;
      },
      onSaved: published.add,
      onChanged: () {},
    );
    writer.submit('old');
    writer.submit('intermediate');
    writer.submit('final');
    writer.dispose();
    releaseFirst.complete();
    expect(await writer.flush(), isTrue);
    expect(persisted, 'final');
    expect(writer.failed, isFalse);
    expect(published, isEmpty);
  });

  for (final source in ['saved', 'changed']) {
    test('$source 回调提交的新草稿也在离开前落盘', () async {
      final finalStarted = Completer<void>();
      final finish = Completer<void>();
      var persisted = '';
      var left = false;
      late final SerialDraftWriter<String> writer;
      writer = SerialDraftWriter<String>(
        save: (draft) async {
          if (draft == 'final') {
            finalStarted.complete();
            await finish.future;
          }
          persisted = draft;
          return draft;
        },
        onSaved: (saved) {
          if (source == 'saved' && saved == 'initial') writer.submit('final');
        },
        onChanged: () {
          if (source == 'changed' &&
              writer.pending == 0 &&
              persisted == 'initial') {
            writer.submit('final');
          }
        },
      );
      writer.submit('initial');
      final leaving = writer.flush().then((ok) {
        left = ok;
        return ok;
      });
      await finalStarted.future;
      expect(left, isFalse);
      finish.complete();
      expect(await leaving, isTrue);
      expect(persisted, 'final');
      writer.dispose();
    });
  }
}
