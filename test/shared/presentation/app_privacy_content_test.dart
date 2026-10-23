import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/shared/widgets/app_content_shield.dart';

const _draftText = '尚未保存的私人生日草稿';

void main() {
  group('遮蔽谓词', () {
    test('应用锁或后台隐私屏任一成立都必须隐藏业务内容', () {
      expect(
        shouldHideAppContent(locked: false, privacyScreen: false),
        isFalse,
      );
      expect(shouldHideAppContent(locked: true, privacyScreen: false), isTrue);
      expect(shouldHideAppContent(locked: false, privacyScreen: true), isTrue);
      expect(shouldHideAppContent(locked: true, privacyScreen: true), isTrue);
    });
  });

  group('业务内容隔离', () {
    testWidgets('隐藏时敏感内容同时退出辅助语义与点击目标，草稿状态保留', (tester) async {
      Future<void> pump({required bool hidden}) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppContentShield(hidden: hidden, child: const _DraftField()),
          ),
        ),
      );

      // 隐藏：读屏遍历与命中测试都拿不到敏感内容。
      await pump(hidden: true);
      expect(accessibleText(tester), isNot(contains(_draftText)));
      expect(find.byType(TextField).hitTestable(), findsNothing);
      final draftState = tester.state<_DraftFieldState>(
        find.byType(_DraftField),
      );

      // 隐藏不销毁业务子树，解锁后草稿内容与状态原样恢复。
      await pump(hidden: false);
      expect(
        tester.state<_DraftFieldState>(find.byType(_DraftField)),
        same(draftState),
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        _draftText,
      );
      expect(accessibleText(tester), contains(_draftText));
      expect(find.byType(TextField).hitTestable(), findsOneWidget);
    });
  });
}

/// 收集实际辅助功能遍历可见的名称和值，不把 Widget 树可见性当作读屏隐私。
String accessibleText(WidgetTester tester) => tester.semantics
    .simulatedAccessibilityTraversal()
    .map((node) {
      final data = node.getSemanticsData();
      return '${data.label}\n${data.value}\n${data.tooltip}';
    })
    .join('\n');

/// 模拟编辑器草稿：隐藏期间必须保留自身状态与输入内容。
class _DraftField extends StatefulWidget {
  const _DraftField();

  @override
  State<_DraftField> createState() => _DraftFieldState();
}

class _DraftFieldState extends State<_DraftField> {
  final _controller = TextEditingController(text: _draftText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
