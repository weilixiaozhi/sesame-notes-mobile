// 首页 debug 入口的验收数据弹窗组件测试。
//
// 锁定弹窗展示契约：五个选项齐全、点击返回对应枚举、取消返回 null。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/ledgers/presentation/widgets/acceptance_seed_dialog.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => showAcceptanceSeedDialog(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('弹窗渲染五个验收选项', (tester) async {
    await pumpDialog(tester);

    expect(find.text('验收数据'), findsOneWidget);
    expect(find.text('一键填充账单（近 12 个月）'), findsOneWidget);
    expect(find.text('新建本地账本'), findsOneWidget);
    expect(find.text('新建云账本'), findsOneWidget);
    expect(find.text('新建 AA 分摊账单'), findsOneWidget);
    expect(find.text('新建虚拟用户（3 个）'), findsOneWidget);
  });

  testWidgets('点击选项返回对应枚举', (tester) async {
    AcceptanceSeedOption? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  picked = await showAcceptanceSeedDialog(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建云账本'));
    await tester.pumpAndSettle();

    expect(picked, AcceptanceSeedOption.createCloudLedger);
    expect(find.text('验收数据'), findsNothing);
  });

  testWidgets('取消弹窗返回 null', (tester) async {
    AcceptanceSeedOption? picked = AcceptanceSeedOption.fillBills;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  picked = await showAcceptanceSeedDialog(context);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // 点击遮罩关闭弹窗
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(picked, isNull);
  });
}
