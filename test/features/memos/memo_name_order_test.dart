import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/features/memos/infrastructure/memo_name_order.dart';

/// 名称排序按系统返回的中文自然顺序映射原条目，不发送卡片字段。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.sesame_notes.memo_name_order');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  /// 构造带敏感字段的卡片，以验证排序通道只读取名称。
  MemoEntry entry(String id, String title) => MemoEntry(
    id: id,
    memoBookId: 'book',
    bookType: memoBookTypeCredentials,
    title: title,
    bodyJson: '{"fields":[{"label":"密码","value":"secret"}]}',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('中文数字名称按平台顺序返回，正文保持原样且不进入通道', () async {
    final entries = [entry('c', '账号10'), entry('a', '账号2'), entry('b', '账号02')];
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'sortNames');
      expect(call.arguments, [
        {'id': 'c', 'title': '账号10'},
        {'id': 'a', 'title': '账号2'},
        {'id': 'b', 'title': '账号02'},
      ]);
      return ['a', 'b', 'c'];
    });
    final sorted = await MemoNameOrder().sort(entries);
    expect(sorted.map((entry) => entry.id), ['a', 'b', 'c']);
    expect(identical(sorted.first, entries[1]), isTrue);
  });

  test('重复或未知身份结果必须失败，不能静默改用另一套排序', () async {
    final entries = [entry('a', 'A'), entry('b', 'B')];
    for (final result in [
      ['a', 'a'],
      ['a', 'missing'],
      ['a'],
    ]) {
      messenger.setMockMethodCallHandler(channel, (_) async => result);
      await expectLater(MemoNameOrder().sort(entries), throwsStateError);
    }
  });
}
