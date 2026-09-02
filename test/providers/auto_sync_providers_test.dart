/// 自动推送编排（post_processor 核对结论的落地）测试。
///
/// 需求锚点：
/// - 本地写库登记 sync_changes 变更后，自动触发一轮同步（push→pull），
///   无需用户手动刷新——「记账后自动上传到云端」；
/// - 防抖：短时间批量写库只触发一次同步（2s 窗口）；
/// - 未登录不触发（无云端会话，push 无意义）；
/// - 登录态启动时主动执行一轮，消费离线/冷启动前已经存在的 pending；
/// - pull 应用业务表不登记 sync_changes → 天然无循环（由实现保证）。
library;

import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/shared/providers/auto_sync_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StreamController<Set<TableUpdate>> controller;
  late List<int> syncCalls;

  setUp(() {
    controller = StreamController<Set<TableUpdate>>();
    syncCalls = [];
  });

  tearDown(() => controller.close());

  AutoSyncCoordinator buildCoordinator({
    bool loggedIn = true,
    Duration debounce = const Duration(seconds: 2),
  }) {
    return AutoSyncCoordinator(
      changes: controller.stream.map((s) => s),
      isLoggedIn: () => loggedIn,
      sync: () async => syncCalls.add(syncCalls.length + 1),
      debounce: debounce,
    );
  }

  test('变更登记后防抖触发一次同步（登录态）', () async {
    final coordinator = buildCoordinator();
    coordinator.start();
    addTearDown(coordinator.dispose);

    controller.add({TableUpdate('sync_changes')});
    expect(syncCalls, isEmpty, reason: '防抖窗口内不得立即同步');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(syncCalls, isEmpty);
    // 防抖窗口 + 缓冲：Timer 与断言等待存在调度竞争，留出余量。
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    expect(syncCalls, hasLength(1), reason: '防抖窗口结束触发一次同步');
  });

  test('登录态启动时主动调度一轮同步，已有 pending 无需等待下一次编辑', () async {
    final coordinator = buildCoordinator(
      debounce: const Duration(milliseconds: 10),
    );
    coordinator.start(syncOnStart: true);
    addTearDown(coordinator.dispose);

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(syncCalls, hasLength(1), reason: '冷启动或重新登录后必须主动消费已有队列');
  });

  test('防抖合并：窗口内多次变更只触发一次', () async {
    final coordinator = buildCoordinator();
    coordinator.start();
    addTearDown(coordinator.dispose);

    controller.add({TableUpdate('sync_changes')});
    await Future<void>.delayed(const Duration(milliseconds: 500));
    controller.add({TableUpdate('sync_changes')});
    await Future<void>.delayed(const Duration(milliseconds: 500));
    controller.add({TableUpdate('sync_changes')});
    await Future<void>.delayed(const Duration(seconds: 3));

    expect(syncCalls, hasLength(1), reason: '2s 窗口内 3 次变更合并为一次同步');
  });

  test('未登录不触发同步', () async {
    final coordinator = buildCoordinator(loggedIn: false);
    coordinator.start();
    addTearDown(coordinator.dispose);

    controller.add({TableUpdate('sync_changes')});
    await Future<void>.delayed(const Duration(seconds: 3));
    expect(syncCalls, isEmpty, reason: '未登录时变更只入队不推送');
  });

  test('同步执行期间的新变更在完成后重新排队', () async {
    // 慢同步：首次执行挂起，期间新变更应被防抖重新调度。
    final gate = Completer<void>();
    var calls = 0;
    final coordinator = AutoSyncCoordinator(
      changes: controller.stream.map((s) => s),
      isLoggedIn: () => true,
      sync: () async {
        calls++;
        if (calls == 1) await gate.future; // 第一次挂起
      },
      debounce: const Duration(seconds: 2),
    );
    coordinator.start();
    addTearDown(coordinator.dispose);

    controller.add({TableUpdate('sync_changes')});
    // 防抖窗口 + 缓冲：Timer 与断言等待存在调度竞争，留出余量。
    await Future<void>.delayed(const Duration(milliseconds: 2200));
    expect(calls, 1, reason: '首次同步已启动');
    // 执行期间新变更 → 防抖调度；完成后触发第二次。
    controller.add({TableUpdate('sync_changes')});
    gate.complete();
    await Future<void>.delayed(const Duration(milliseconds: 3300));
    expect(calls, greaterThanOrEqualTo(2), reason: '执行期变更在完成后重新触发');
  });
}
