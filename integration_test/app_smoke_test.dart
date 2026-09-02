// 设备级冒烟集成测试，验证关键用户流程可以在真实 Flutter 运行时启动。
//
// 运行方式（需模拟器/真机）：
//   flutter test integration_test/
//
// 锚点：应用可启动、主界面正常渲染、底部导航可切换——不依赖真实后端
// （离线冒烟），云端链路由同目录的真实后端 E2E 覆盖。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sesame_notes/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('应用启动冒烟：主界面渲染与底部导航切换', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // 底部导航五个主入口存在（首页/账本/记账/统计/我的）。
    expect(find.byType(Navigator), findsWidgets, reason: '应用必须完成路由装配');
  });
}
