import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/theme/dimens.dart';

import 'memo_editor_styles.dart';

/// 编辑会话只保留正文偏移，不持有任何已卸载编辑器的监听。
class MemoEditorScrollState {
  double offset = 0;
}

/// 将焦点树的卸载通知交给持有输入连接的编辑器实例。
class _MemoEditorFocusNode extends FocusNode {
  /// 输入连接与焦点由同一个模式实例持有。
  _MemoEditorFocusNode(this.closeInput);

  final VoidCallback closeInput;

  /// 持有者根据自身生命周期决定是否需要在焦点脱离前结束输入连接。
  @override
  void unfocus({UnfocusDisposition disposition = UnfocusDisposition.scope}) {
    closeInput();
    super.unfocus(disposition: disposition);
  }
}

/// 每个查看或编辑实例独立管理焦点，正文、选区与滚动位置由页面持有。
class MemoEditorSurface extends StatefulWidget {
  /// 模式切换使用新的 key，确保输入连接和输入法组合区监听完整初始化。
  const MemoEditorSurface({
    super.key,
    required this.controller,
    required this.scrollState,
    required this.readOnly,
    required this.onTapUp,
    required this.contextMenuBuilder,
    required this.onEditError,
  });

  final QuillController controller;
  final MemoEditorScrollState scrollState;
  final bool readOnly;
  final bool Function(TapUpDetails, TextPosition Function(Offset)) onTapUp;
  final Widget Function(BuildContext, QuillRawEditorState) contextMenuBuilder;
  final VoidCallback onEditError;

  /// 焦点节点与实际编辑器状态具有相同生命周期。
  @override
  State<MemoEditorSurface> createState() => _MemoEditorSurfaceState();
}

class _MemoEditorSurfaceState extends State<MemoEditorSurface> {
  late final FocusNode _focus;
  final _editorKey = GlobalKey<EditorState>();
  late final ScrollController _scroll;
  QuillRawEditorState? _rawEditor;
  bool _detaching = false;

  /// 先完成正文和工具栏布局，再创建输入连接并请求系统键盘。
  @override
  void initState() {
    super.initState();
    _focus = _MemoEditorFocusNode(_closeInputForDetach);
    _scroll = ScrollController(
      initialScrollOffset: widget.scrollState.offset,
      keepScrollOffset: false,
    )..addListener(_rememberScrollOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final editor = _editorKey.currentState;
        // 子组件先于当前组件销毁，提前保存观察者身份以便成对注销。
        if (editor is QuillRawEditorState) _rawEditor = editor;
        // 正常失焦先由编辑器处理，随后确认连接已关闭，避免组合区刷新再次抢占焦点。
        _focus.addListener(_focusChanged);
        if (!widget.readOnly && !widget.controller.readOnly) {
          editor?.requestKeyboard();
        }
      } catch (error, stackTrace) {
        logger.error(
          'MemoEditor',
          '打开备忘录输入键盘失败',
          safeErrorSummary(error),
          stackTrace,
        );
        widget.onEditError();
      }
    });
  }

  /// 连续记录实际滚动位置，让滚动尚未停下的模式切换也能恢复当前视口。
  void _rememberScrollOffset() {
    if (_scroll.hasClients) widget.scrollState.offset = _scroll.offset;
  }

  /// 仅记录离树状态，输入连接由子焦点实际脱离时释放。
  @override
  void deactivate() {
    _detaching = true;
    super.deactivate();
  }

  /// 同帧重新挂载时仍沿用现有输入连接与焦点。
  @override
  void activate() {
    super.activate();
    _detaching = false;
  }

  /// 子焦点销毁发生在正文状态卸载之前，此时可以安全清理组合区。
  void _closeInputForDetach() {
    if (_detaching) _closeInputConnection();
  }

  /// 焦点域主动切走焦点时也同步关闭连接，不依赖正文是否已完成绘制。
  void _focusChanged() {
    if (!_focus.hasFocus) _closeInputConnection();
  }

  /// 输入连接先于编辑器释放，清理组合区仅影响输入法状态，不修改正文。
  void _closeInputConnection() {
    try {
      final editor = _rawEditor;
      if (editor != null && editor.mounted) editor.closeConnectionIfNeeded();
    } catch (error, stackTrace) {
      logger.error(
        'MemoEditor',
        '关闭备忘录输入连接失败',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 模式实例释放其完整监听集合，焦点被直接卸载时也注销系统观察者。
  @override
  void dispose() {
    final editor = _rawEditor;
    if (editor != null) {
      // 焦点回调可重复注册同一观察者，释放该实例的全部注册记录。
      while (WidgetsBinding.instance.removeObserver(editor)) {}
    }
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// 复用应用排版令牌，自动聚焦由首帧完成后的统一入口负责。
  @override
  Widget build(BuildContext context) => QuillEditor(
    controller: widget.controller,
    focusNode: _focus,
    scrollController: _scroll,
    config: QuillEditorConfig(
      editorKey: _editorKey,
      padding: const EdgeInsets.all(AppDimens.p16),
      customStyles: memoEditorStyles(context),
      contextMenuBuilder: widget.contextMenuBuilder,
      onTapUp: widget.onTapUp,
    ),
  );
}
