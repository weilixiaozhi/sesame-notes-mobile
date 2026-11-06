import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/memos/presentation/widgets/memo_history_buttons.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 观察真实文档流的订阅与取消，不替换编辑和撤销实现。
class _TrackedController extends QuillController {
  /// 每个控制器拥有独立空白文档与选区。
  _TrackedController()
    : super(
        document: Document(),
        selection: const TextSelection.collapsed(offset: 0),
      );
  int activeSubscriptions = 0;
  late final Stream<DocChange> _tracked = Stream.multi((events) {
    activeSubscriptions++;
    final subscription = document.changes.listen(
      events.add,
      onError: events.addError,
      onDone: events.close,
    );
    events.onCancel = () async {
      activeSubscriptions--;
      await subscription.cancel();
    };
  }, isBroadcast: true);

  /// 工具栏通过这一个统计出口读取真实修改事件。
  @override
  Stream<DocChange> get changes => _tracked;
}

/// 使用应用和编辑器的真实本地化，保留按钮启用状态与提示文本。
Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: [
    ...AppLocalizations.localizationsDelegates,
    FlutterQuillLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('zh'),
  home: Scaffold(body: child),
);

/// 工具栏反复卸载不能给仍打开的文档累积监听者。
void main() {
  testWidgets('反复查看与编辑只保留当前历史订阅且撤销重做仍可用', (tester) async {
    final controller = _TrackedController();
    try {
      for (var cycle = 0; cycle < 4; cycle++) {
        await tester.pumpWidget(
          _app(MemoHistoryButtons(controller: controller)),
        );
        await tester.pump();
        expect(controller.activeSubscriptions, 1);
        if (cycle == 0) {
          controller.replaceText(
            0,
            0,
            '笔记',
            const TextSelection.collapsed(offset: 2),
          );
          await tester.pumpAndSettle();
          final undoButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, AppIcons.undo),
          );
          expect(
            undoButton.onPressed,
            isNotNull,
            reason: '文档事件经过订阅计数转发后必须启用撤销',
          );
          await tester.tap(find.byIcon(AppIcons.undo));
          await tester.pumpAndSettle();
          expect(controller.document.toPlainText(), '\n');
          final redoButton = tester.widget<IconButton>(
            find.widgetWithIcon(IconButton, AppIcons.redo),
          );
          expect(redoButton.onPressed, isNotNull, reason: '撤销完成后必须启用重做');
          await tester.tap(find.byIcon(AppIcons.redo));
          await tester.pumpAndSettle();
          expect(controller.document.toPlainText(), '笔记\n');
        }
        await tester.pumpWidget(_app(const SizedBox.shrink()));
        await tester.pump();
        expect(controller.activeSubscriptions, 0);
      }
    } catch (error, stack) {
      debugPrint('笔记历史订阅检查失败：$error\n$stack');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      controller.dispose();
    }
  });

  testWidgets('替换控制器后取消旧文档订阅', (tester) async {
    final first = _TrackedController();
    final second = _TrackedController();
    try {
      await tester.pumpWidget(_app(MemoHistoryButtons(controller: first)));
      await tester.pump();
      expect(first.activeSubscriptions, 1);
      await tester.pumpWidget(_app(MemoHistoryButtons(controller: second)));
      await tester.pump();
      expect(first.activeSubscriptions, 0);
      expect(second.activeSubscriptions, 1);
    } catch (error, stack) {
      debugPrint('笔记历史控制器替换检查失败：$error\n$stack');
      rethrow;
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      first.dispose();
      second.dispose();
    }
  });
}
