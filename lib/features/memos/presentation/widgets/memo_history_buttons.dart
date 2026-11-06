import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/logging/logger_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/toast.dart';
import '../../../../theme/dimens.dart';
import '../../../../theme/icons/app_icons.dart';

/// 撤销与重做共用文档订阅，工具栏退出或控制器替换时由框架对称释放。
class MemoHistoryButtons extends StatelessWidget {
  /// 操作始终作用于当前编辑器的同一份撤销历史。
  const MemoHistoryButtons({super.key, required this.controller});

  final QuillController controller;

  /// 只有可执行的历史操作才提交，失败记录诊断并保持正文原样。
  void _apply(BuildContext context, {required bool undo}) {
    try {
      if (undo && controller.hasUndo) {
        controller.undo();
      } else if (!undo && controller.hasRedo) {
        controller.redo();
      }
    } catch (error, stackTrace) {
      logger.error('MemoHistory', '笔记历史操作失败', error, stackTrace);
      showToast(context, AppLocalizations.of(context).commonOperationFailed);
    }
  }

  /// 使用编辑器已有本地化与应用图标尺寸，文档通知只重建两枚历史按钮。
  @override
  Widget build(BuildContext context) => StreamBuilder<DocChange>(
    stream: controller.changes,
    builder: (context, snapshot) {
      final l = FlutterQuillLocalizations.of(context)!;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l.undo,
            icon: const Icon(AppIcons.undo, size: AppDimens.icon20),
            onPressed: controller.hasUndo
                ? () => _apply(context, undo: true)
                : null,
          ),
          IconButton(
            tooltip: l.redo,
            icon: const Icon(AppIcons.redo, size: AppDimens.icon20),
            onPressed: controller.hasRedo
                ? () => _apply(context, undo: false)
                : null,
          ),
        ],
      );
    },
  );
}
