import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/theme/dimens.dart';

import 'memo_editor_styles.dart';

/// 模式实例共享当前正文偏移，重建滚动视口时从同一位置开始布局。
class MemoEditorScrollController extends ScrollController {
  /// 滚动位置随编辑会话存活，不读取可能滞后的路由滚动快照。
  MemoEditorScrollController() : super(keepScrollOffset: false);

  double _offset = 0;

  /// 新视口可能先于旧视口卸载，优先取得仍挂载的实际偏移。
  @override
  double get initialScrollOffset =>
      hasClients ? positions.last.pixels : _offset;

  /// 即使滚动尚未结束，也保留卸载时的位置供下一个模式实例使用。
  @override
  void detach(ScrollPosition position) {
    _offset = position.pixels;
    super.detach(position);
  }
}

/// 每个查看或编辑实例独立管理焦点，正文、选区与滚动位置由页面持有。
class MemoEditorSurface extends StatefulWidget {
  /// 模式切换使用新的 key，确保输入连接和输入法组合区监听完整初始化。
  const MemoEditorSurface({
    super.key,
    required this.controller,
    required this.scrollController,
    required this.readOnly,
    required this.onTapUp,
    required this.contextMenuBuilder,
    required this.onEditError,
  });

  final QuillController controller;
  final ScrollController scrollController;
  final bool readOnly;
  final bool Function(TapUpDetails, TextPosition Function(Offset)) onTapUp;
  final Widget Function(BuildContext, QuillRawEditorState) contextMenuBuilder;
  final VoidCallback onEditError;

  /// 焦点节点与实际编辑器状态具有相同生命周期。
  @override
  State<MemoEditorSurface> createState() => _MemoEditorSurfaceState();
}

class _MemoEditorSurfaceState extends State<MemoEditorSurface> {
  final _focus = FocusNode();
  final _editorKey = GlobalKey<EditorState>();

  /// 先完成正文和工具栏布局，再创建输入连接并请求系统键盘。
  @override
  void initState() {
    super.initState();
    if (!widget.readOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.controller.readOnly) return;
        try {
          _editorKey.currentState?.requestKeyboard();
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
  }

  /// 销毁模式实例时一起释放焦点监听，避免重复进入编辑后累积回调。
  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  /// 复用应用排版令牌，自动聚焦由首帧完成后的统一入口负责。
  @override
  Widget build(BuildContext context) => QuillEditor(
    controller: widget.controller,
    focusNode: _focus,
    scrollController: widget.scrollController,
    config: QuillEditorConfig(
      editorKey: _editorKey,
      padding: const EdgeInsets.all(AppDimens.p16),
      customStyles: memoEditorStyles(context),
      contextMenuBuilder: widget.contextMenuBuilder,
      onTapUp: widget.onTapUp,
    ),
  );
}
