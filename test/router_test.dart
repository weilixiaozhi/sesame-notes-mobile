/// 全局路由层（app_router.dart）单元测试。
///
/// 需求锚点：go_router 接管命名路由后——
/// 1. [Routes.all] 中每一条路由都在 GoRoute 表中注册，且 name == path
///    （pushNamed 与路径解析共用同一 name/path，缺一不可）；
/// 2. GoRoute 表不允许出现 [Routes.all] 之外的路径（防漂移）；
/// 3. [createAppRouter] 的 '/' 根路由渲染 homeBuilder 提供的页面；
/// 4. 参数型路由（record/对象经 extra 传递）均已注册。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/router/app_router.dart';
import 'package:sesame_notes/router/route_consts.dart';

void main() {
  group('GoRoute 路由表', () {
    test('Routes.all 全量注册且 name == path', () {
      final routes = buildAppRoutes();
      final byPath = {for (final r in routes) r.path: r};
      final byName = {for (final r in routes) r.name: r};

      for (final constant in Routes.all) {
        final route = byPath[constant];
        expect(route, isNotNull, reason: 'Routes.$constant 必须注册 GoRoute');
        expect(
          route!.name,
          constant,
          reason: 'GoRoute.name 必须与 path 一致，供 pushNamed 解析',
        );
        expect(byName[constant], same(route), reason: 'name 全局唯一可解析');
      }
      expect(routes.length, Routes.all.length, reason: '不允许表外路由漂移');
    });

    test('参数型路由（extra 传参）均已注册', () {
      final paths = buildAppRoutes().map((r) => r.path).toSet();
      for (final p in [
        Routes.aaStatistics,
        Routes.aaEdit,
        Routes.aaMemberDetail,
        Routes.ledgerEdit,
        Routes.categoryEdit,
        Routes.categoryDetail,
        Routes.importConfirm,
        Routes.recurringTransactionEdit,
        Routes.pinSetup,
        Routes.backupRestore,
      ]) {
        expect(paths, contains(p), reason: '参数型路由 $p 必须存在');
      }
    });
  });

  group('createAppRouter 根路由', () {
    testWidgets("'/' 初始位置渲染 homeBuilder 页面", (tester) async {
      final router = createAppRouter(home: () => const _Marker(text: 'root'));
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      expect(find.text('root'), findsOneWidget, reason: "'/' 应渲染 home 页面");
    });

    testWidgets('stubs 可替换指定路由的页面（测试桩）', (tester) async {
      final router = createAppRouter(
        home: () => const _Marker(text: 'root'),
        stubs: {Routes.categoryManage: (_) => const _Marker(text: 'stub')},
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.pushNamed(Routes.categoryManage);
      await tester.pumpAndSettle();

      expect(
        find.text('stub'),
        findsOneWidget,
        reason: 'stubs 命中时应渲染桩页面而非真实页面',
      );
    });
  });
}

/// 路由测试桩页面：无任何依赖，仅用于验证路由解析。
class _Marker extends StatelessWidget {
  const _Marker({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text(text);
}
