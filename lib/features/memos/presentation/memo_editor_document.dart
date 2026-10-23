import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 备忘录编辑文档：标题换行时保留前段标题，后段使用正文段落。
class MemoEditorDocument extends Document {
  Style _inputStyle = const Style();

  /// 按原始 Delta 还原文档，仅对后续文本编辑应用标题换行规则。
  MemoEditorDocument.fromJson(super.data) : super.fromJson();

  /// 将标题中的换行、选区替换和段落格式作为一次修改写入撤销历史。
  @override
  Delta replace(int index, int len, Object? data) {
    try {
      // 富文本粘贴携带明确的段落格式，按其原始 Delta 插入。
      if (data is! String || !data.contains('\n')) {
        return super.replace(index, len, data);
      }
      final start = queryChild(index);
      final startLine = start.node;
      if (startLine is! Line) return super.replace(index, len, data);
      final attributes = startLine.toDelta().last.attributes;
      if (attributes?[Attribute.header.key] == null) {
        return super.replace(index, len, data);
      }

      final end = queryChild(index + len);
      final endLine = end.node;
      if (endLine is! Line) {
        throw StateError('MEMO_HEADING_SPLIT_END_LINE');
      }
      final bodyAttributes = Map<String, dynamic>.from(attributes!)
        ..remove(Attribute.header.key);
      // 输入法一次提交多行时仍使用当前行内样式，段落样式只写入换行符。
      final inlineAttributes = {
        for (final attribute in _inputStyle.values)
          if (attribute.isInline && attribute.value != null)
            attribute.key: attribute.value,
      };
      final lines = data.split('\n');
      final change = Delta()..retain(index);
      for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
        if (lines[lineIndex].isNotEmpty) {
          change.insert(lines[lineIndex], inlineAttributes);
        }
        if (lineIndex < lines.length - 1) {
          // 段落样式存储在换行符上，只有第一个换行符保留原标题样式。
          change.insert('\n', lineIndex == 0 ? attributes : bodyAttributes);
        }
      }
      change
        ..delete(len)
        // 选区末尾未删除的文字与新行合并，只清理这一行的标题属性。
        ..retain(endLine.length - end.offset - 1)
        ..retain(1, {Attribute.header.key: null})
        ..trim();
      compose(change, ChangeSource.local);
      return change;
    } catch (_) {
      // 失败交由控制器处理，避免返回空修改后继续推进光标。
      rethrow;
    }
  }
}

/// 在文本编辑入口统一传递输入样式，并隔离编辑失败与光标更新。
class MemoEditorController extends QuillController {
  final void Function()? onEditError;

  /// 创建备忘录控制器，错误提示由持有页面负责展示。
  MemoEditorController({
    required super.document,
    required super.selection,
    super.config,
    super.readOnly,
    this.onEditError,
  });

  /// 只有文档编辑成功才继续更新光标，异常保留编辑前的选区与输入样式。
  @override
  void replaceText(
    int index,
    int len,
    Object? data,
    TextSelection? textSelection, {
    bool ignoreFocus = false,
    bool shouldNotifyListeners = true,
  }) {
    final editingDocument = document;
    try {
      if (index < 0 || len < 0 || index + len >= editingDocument.length) {
        throw RangeError('MEMO_EDIT_RANGE');
      }
      if (editingDocument is MemoEditorDocument) {
        // 从真实插入位置继承行内样式，再应用用户显式开关，空值可清除加粗。
        editingDocument._inputStyle = editingDocument
            .collectStyle(index, 0)
            .mergeAll(toggledStyle);
      }
      super.replaceText(
        index,
        len,
        data,
        textSelection,
        ignoreFocus: ignoreFocus,
        // ignore: experimental_member_use
        shouldNotifyListeners: shouldNotifyListeners,
      );
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '编辑备忘录段落失败（起点 $index，替换长度 $len）',
        safeErrorSummary(error),
        stackTrace,
      );
      onEditError?.call();
    } finally {
      if (editingDocument is MemoEditorDocument) {
        editingDocument._inputStyle = const Style();
      }
    }
  }
}
