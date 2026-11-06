import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/application/serial_draft_writer.dart';

/// 串行保存必须交付最新草稿，存储失败或调用方释放不能丢失已接收内容。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('flush 等待串行队列中的最新草稿保存后才成功', () async {
    final first = Completer<void>();
    final finalWrite = Completer<void>();
    final finalStarted = Completer<void>();
    var persisted = '';
    var completed = false;
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
    try {
      writer.submit('first');
      final flushing = writer.flush().then((success) {
        completed = success;
        return success;
      });
      writer.submit('intermediate');
      writer.submit('final');
      await Future<void>.delayed(Duration.zero);
      expect(finalStarted.isCompleted, isFalse, reason: '前序保存未完成时不能并发写入后续草稿');
      first.complete();
      await finalStarted.future;
      expect(completed, isFalse);
      expect(persisted, isNot('final'));
      finalWrite.complete();
      expect(await flushing, isTrue);
      expect(completed, isTrue);
      expect(persisted, 'final');
    } catch (error, stackTrace) {
      printOnFailure('最新草稿串行保存验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      if (!first.isCompleted) first.complete();
      if (!finalWrite.isCompleted) finalWrite.complete();
      writer.dispose();
    }
  });

  test('失败草稿不覆盖已保存内容，存储恢复后可以重新保存', () async {
    var persisted = 'committed';
    var reject = true;
    final writer = SerialDraftWriter<String>(
      save: (draft) async {
        if (reject) throw StateError('storage unavailable');
        persisted = draft;
        return draft;
      },
      onSaved: (_) {},
      onChanged: () {},
    );
    try {
      writer.submit('failed');
      expect(await writer.flush(), isFalse);
      expect(persisted, 'committed');
      reject = false;
      writer.submit('recovered');
      expect(await writer.flush(), isTrue);
      expect(persisted, 'recovered');
    } catch (error, stackTrace) {
      printOnFailure('保存失败保护与恢复验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      writer.dispose();
    }
  });

  test('释放后仍保存已接收的最新草稿，旧写入失败不丢失新内容', () async {
    final releaseFirst = Completer<void>();
    var persisted = 'committed';
    final writer = SerialDraftWriter<String>(
      save: (draft) async {
        if (draft == 'old') {
          await releaseFirst.future;
          throw StateError('old save failed');
        }
        persisted = draft;
        return draft;
      },
      onSaved: (_) {},
      onChanged: () {},
    );
    try {
      writer.submit('old');
      writer.submit('intermediate');
      writer.submit('final');
      writer.dispose();
      releaseFirst.complete();
      expect(await writer.flush(), isTrue);
      expect(persisted, 'final');
    } catch (error, stackTrace) {
      printOnFailure('释放后最新草稿保存验证失败：$error\n$stackTrace');
      rethrow;
    } finally {
      if (!releaseFirst.isCompleted) releaseFirst.complete();
      writer.dispose();
    }
  });
}
