import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/memos/presentation/memo_editor_document.dart';

/// 验证编辑器文档的标题换行、格式保留与一次撤销行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// 创建含后续标题的文档，用于检查换行不影响其它段落。
  QuillController controller({int heading = 1}) {
    final result = MemoEditorController(
      document: MemoEditorDocument.fromJson([
        {'insert': '标题文案'},
        {
          'insert': '\n',
          'attributes': {'header': heading},
        },
        {'insert': '已有正文\n另一标题'},
        {
          'insert': '\n',
          'attributes': {'header': 2},
        },
      ]),
      selection: const TextSelection.collapsed(offset: 0),
    );
    addTearDown(result.dispose);
    return result;
  }

  /// 从每一行结尾读取段落样式，忽略具体 Delta 合并形式。
  List<int?> headings(Document document) => [
    for (final operation in document.toDelta().toList())
      if (operation.data is String)
        for (final _ in '\n'.allMatches(operation.data as String))
          operation.attributes?['header'] as int?,
  ];

  for (final heading in [1, 2, 3]) {
    for (final offset in [0, 2, 4]) {
      test('标题 $heading 在位置 $offset 换行后仅前段保留标题，撤销重做恢复整次编辑', () {
        final editor = controller(heading: heading);
        final before = editor.document.toDelta();
        editor.replaceText(
          offset,
          0,
          '\n',
          TextSelection.collapsed(offset: offset + 1),
        );
        expect(
          editor.document.toPlainText(),
          '${'标题文案'.substring(0, offset)}\n'
          '${'标题文案'.substring(offset)}\n已有正文\n另一标题\n',
        );
        expect(headings(editor.document), [heading, null, null, 2]);
        expect(editor.selection.baseOffset, offset + 1);
        final after = editor.document.toDelta();
        expect(editor.document.history.stack.undo, hasLength(1));
        editor.undo();
        expect(editor.document.toDelta(), before);
        editor.redo();
        expect(editor.document.toDelta(), after);
      });
    }
  }

  for (final range in [(1, 2), (2, 4), (0, 8)]) {
    test('选区 ${range.$1}/${range.$2} 换行保留未选中文字并清理新行标题', () {
      final editor = controller();
      final before = editor.document.toDelta();
      final text = editor.document.toPlainText();
      editor.replaceText(
        range.$1,
        range.$2,
        '\n',
        TextSelection.collapsed(offset: range.$1 + 1),
      );
      expect(
        editor.document.toPlainText(),
        '${text.substring(0, range.$1)}\n'
        '${text.substring(range.$1 + range.$2)}',
      );
      expect(headings(editor.document).first, 1);
      expect(headings(editor.document)[1], isNull);
      expect(headings(editor.document).last, 2);
      editor.undo();
      expect(editor.document.toDelta(), before);
    });
  }

  test('多行文本输入只有第一段保留标题，后续输入持续使用正文', () {
    final editor = controller();
    editor.replaceText(
      2,
      0,
      '\n正文\n更多',
      const TextSelection.collapsed(offset: 8),
    );
    expect(headings(editor.document), [1, null, null, null, 2]);
    editor.replaceText(8, 0, '后续', const TextSelection.collapsed(offset: 10));
    expect(editor.document.toPlainText(), '标题\n正文\n更多后续文案\n已有正文\n另一标题\n');
    expect(editor.getSelectionStyle().attributes['header'], isNull);
  });

  test('标题拆分保留文字加粗及无关标题，显式富文本粘贴保留自带标题', () {
    final editor = controller();
    editor.formatText(0, 4, Attribute.bold);
    editor.document.history.clear();
    editor.replaceText(2, 0, '\n', const TextSelection.collapsed(offset: 3));
    expect(
      editor.document.collectStyle(0, 2).attributes['bold']?.value,
      isTrue,
    );
    expect(
      editor.document.collectStyle(3, 2).attributes['bold']?.value,
      isTrue,
    );
    final rich = Delta()
      ..insert('粘贴标题')
      ..insert('\n', {'header': 3});
    editor.replaceText(0, 0, rich, const TextSelection.collapsed(offset: 5));
    expect(headings(editor.document), [3, 1, null, null, 2]);
  });

  test('当前开启加粗时，多行输入的新增文字保留加粗且新段落使用正文', () {
    final editor = controller();
    editor.updateSelection(
      const TextSelection.collapsed(offset: 2),
      ChangeSource.local,
    );
    editor.formatSelection(Attribute.bold);
    editor.replaceText(2, 0, '甲\n乙', const TextSelection.collapsed(offset: 5));
    expect(editor.document.toPlainText(), '标题甲\n乙文案\n已有正文\n另一标题\n');
    expect(headings(editor.document), [1, null, null, 2]);
    for (final offset in [2, 4]) {
      expect(
        editor.document.collectStyle(offset, 1).attributes['bold']?.value,
        isTrue,
      );
    }
  });

  for (final clearBold in [false, true]) {
    test('光标移入已有加粗标题后多行输入继承样式，显式清除优先：$clearBold', () {
      final editor = controller();
      editor.formatText(0, 4, Attribute.bold);
      editor.updateSelection(
        const TextSelection.collapsed(offset: 2),
        ChangeSource.local,
      );
      expect(editor.toggledStyle.isEmpty, isTrue);
      if (clearBold) {
        editor.formatSelection(Attribute.clone(Attribute.bold, null));
      }
      editor.replaceText(
        2,
        0,
        '甲\n乙',
        const TextSelection.collapsed(offset: 5),
      );
      expect(headings(editor.document), [1, null, null, 2]);
      for (final offset in [2, 4]) {
        expect(
          editor.document.collectStyle(offset, 1).attributes['bold']?.value,
          clearBold ? isNull : isTrue,
        );
      }
      expect(
        editor.document.collectStyle(5, 2).attributes['bold']?.value,
        isTrue,
      );
    });
  }

  test('编辑失败显示提示并保留正文、原选区与输入样式', () async {
    var failures = 0;
    final editor = MemoEditorController(
      document: _FailingDocument(),
      selection: const TextSelection(baseOffset: 1, extentOffset: 3),
      onEditError: () => failures++,
    );
    addTearDown(editor.dispose);
    final before = editor.document.toDelta();
    final selection = editor.selection;
    editor.toggledStyle = Style.fromJson({'bold': true});
    editor.replaceText(1, 2, '\n', const TextSelection.collapsed(offset: 2));
    expect(failures, 1);
    expect(editor.document.toDelta(), before);
    expect(editor.selection, selection);
    expect(editor.toggledStyle.attributes['bold']?.value, isTrue);
    await logger.clear();
  });

  test('加载原文以及正文、列表换行保留原有行为', () {
    final original = [
      {
        'insert': '一\n二\n',
        'attributes': {'header': 1},
      },
      {'insert': '正文\n'},
      {'insert': '列表'},
      {
        'insert': '\n',
        'attributes': {'list': 'bullet'},
      },
    ];
    final document = MemoEditorDocument.fromJson(original);
    final baseline = Document.fromJson(original);
    addTearDown(document.close);
    addTearDown(baseline.close);
    expect(document.toDelta(), baseline.toDelta());
    for (final offset in [5, 9]) {
      document.replace(offset, 0, '\n');
      baseline.replace(offset, 0, '\n');
      expect(document.toDelta(), baseline.toDelta());
    }
  });
}

/// 在提交修改前模拟失败，验证控制器不会继续执行光标推进。
class _FailingDocument extends MemoEditorDocument {
  /// 初始化可编辑标题，不修改生产文档的错误处理入口。
  _FailingDocument()
    : super.fromJson([
        {'insert': '标题文案'},
        {
          'insert': '\n',
          'attributes': {'header': 1},
        },
      ]);

  /// 模拟底层文档拒绝本次编辑。
  @override
  Delta replace(int index, int len, Object? data) {
    throw StateError('模拟文档编辑失败');
  }
}
