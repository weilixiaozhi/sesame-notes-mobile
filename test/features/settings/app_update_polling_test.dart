import 'dart:async';
import 'package:dio/dio.dart' show CancelToken;
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/settings/application/app_update_controller.dart';
import 'package:sesame_notes/features/settings/infrastructure/app_update_service.dart';
import 'package:sesame_notes/features/settings/presentation/app_update_lifecycle_listener.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

import '../../helpers/test_isolation.dart';

/// 构造满足正式安装协议的元数据，测试不访问网络或真实安装器。
AppUpdate _update() => AppUpdate.fromJson({
  'version': '2.0.0',
  'buildNumber': 200,
  'packageName': 'com.sesame.notes',
  'abi': 'arm64-v8a',
  'url': 'https://example.test/app.apk',
  'size': 100,
  'sha256': List.filled(64, 'a').join(),
  'notes': '测试',
});

/// 每次查询创建新对象，验证窗口按内容而非对象身份决定重建。
class _DownloadService extends AppUpdateService {
  int reads = 0;
  int received = 0;

  /// 检查只返回固定元数据，系统任务保持运行状态。
  @override
  Future<AppUpdate?> check(CancelToken token) async => _update();

  /// 运行中的下载进度由测试时钟控制查询次数。
  @override
  Future<UpdateDownload?> currentDownload() async {
    reads++;
    return UpdateDownload(
      id: 1,
      status: 'running',
      received: received,
      update: _update(),
    );
  }
}

/// 使用真实根监听器及平台通道，观察查询、取消和一次性安装行为。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.sesame_notes.update');
  late List<String> calls;
  Map<String, dynamic>? task;
  Future<Object?> Function()? status;
  Future<bool> Function()? consume;

  setUp(() {
    resetGlobalTestState();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls = [];
    task = null;
    status = null;
    consume = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          switch (call.method) {
            case 'isSupported':
            case 'canInstall':
              return true;
            case 'downloadStatus':
              return status == null ? task : await status!();
            case 'enqueueDownload':
              task = {
                'id': 1,
                'status': 'pending',
                'received': 0,
                'manifest': call.arguments,
                'installPending': true,
              };
              return task;
            case 'cancelDownload':
              task = null;
              return null;
            case 'consumeInstall':
              if (consume != null) return await consume!();
              if (task?['installPending'] != true) return false;
              task!['installPending'] = false;
              return true;
            case 'restoreInstallIntent':
              task?['installPending'] = true;
              return null;
            default:
              return null;
          }
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  /// 相同导航器和监听器位置保持生产生命周期，不直接调用私有轮询方法。
  Widget app(GlobalKey<NavigatorState> key, {bool enabled = true}) =>
      MaterialApp(
        navigatorKey: key,
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Stack(
          children: [
            AppUpdateLifecycleListener(enabled: enabled, navigatorKey: key),
          ],
        ),
      );

  testWidgets('空闲不轮询，入队唤醒，后台暂停，恢复后安装且完成即停', (tester) async {
    final key = GlobalKey<NavigatorState>();
    final service = AppUpdateService();
    try {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(app(key));
      await tester.pumpAndSettle();
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(1));
      await tester.pump(const Duration(minutes: 1));
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(1));
      await service.startDownload(_update());
      await tester.pumpAndSettle();
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(2));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(3));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(minutes: 1));
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(3));
      task!['status'] = 'ready';
      task!['received'] = 100;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(calls.where((call) => call == 'install'), hasLength(1));
      final completedReads = calls
          .where((call) => call == 'downloadStatus')
          .length;
      await tester.pump(const Duration(minutes: 1));
      expect(
        calls.where((call) => call == 'downloadStatus'),
        hasLength(completedReads),
      );
    } catch (error, stack) {
      printOnFailure('更新轮询生命周期回归失败：$error\n$stack');
      rethrow;
    } finally {
      service.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    }
  });

  testWidgets('初始空闲查询尚未返回时入队，迟到空结果不吞掉唤醒', (tester) async {
    final key = GlobalKey<NavigatorState>();
    final pending = Completer<Object?>();
    final service = AppUpdateService();
    var reads = 0;
    status = () async => ++reads == 1 ? pending.future : task;
    try {
      await tester.pumpWidget(app(key));
      await tester.pumpAndSettle();
      expect(reads, 1);
      await service.startDownload(_update());
      pending.complete(null);
      await tester.pumpAndSettle();
      expect(reads, 2);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(reads, 3);
    } catch (error, stack) {
      printOnFailure('更新任务唤醒合并回归失败：$error\n$stack');
      rethrow;
    } finally {
      if (!pending.isCompleted) pending.complete(null);
      service.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('领取安装期间锁屏会归还意图，解锁后只安装一次', (tester) async {
    final key = GlobalKey<NavigatorState>();
    final claim = Completer<bool>();
    task = {
      'id': 1,
      'status': 'ready',
      'received': 100,
      'manifest': _update().toJson(),
      'installPending': true,
    };
    consume = () => claim.future;
    try {
      await tester.pumpWidget(app(key));
      await tester.pumpAndSettle();
      expect(calls, contains('consumeInstall'));
      await tester.pumpWidget(app(key, enabled: false));
      claim.complete(true);
      await tester.pumpAndSettle();
      expect(calls, contains('restoreInstallIntent'));
      expect(calls, isNot(contains('install')));
      final before = calls.where((call) => call == 'downloadStatus').length;
      await tester.pump(const Duration(minutes: 1));
      expect(
        calls.where((call) => call == 'downloadStatus'),
        hasLength(before),
      );
      consume = null;
      await tester.pumpWidget(app(key));
      await tester.pumpAndSettle();
      expect(calls.where((call) => call == 'install'), hasLength(1));
    } catch (error, stack) {
      printOnFailure('更新安装门控回归失败：$error\n$stack');
      rethrow;
    } finally {
      if (!claim.isCompleted) claim.complete(true);
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('未知查询失败有界重试，新任务能重新唤醒', (tester) async {
    final key = GlobalKey<NavigatorState>();
    final service = AppUpdateService();
    var fails = true;
    status = () async {
      if (fails) {
        throw PlatformException(code: 'STATUS_TEMPORARILY_UNAVAILABLE');
      }
      return task;
    };
    try {
      await tester.pumpWidget(app(key));
      await tester.pumpAndSettle();
      for (final seconds in [3, 6, 12]) {
        await tester.pump(Duration(seconds: seconds));
        await tester.pumpAndSettle();
      }
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(4));
      await tester.pump(const Duration(minutes: 1));
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(4));
      fails = false;
      await service.startDownload(_update());
      await tester.pumpAndSettle();
      expect(calls.where((call) => call == 'downloadStatus'), hasLength(5));
      await service.cancelDownload();
      await tester.pumpAndSettle();
      final cleared = calls.where((call) => call == 'downloadStatus').length;
      await tester.pump(const Duration(minutes: 1));
      expect(
        calls.where((call) => call == 'downloadStatus'),
        hasLength(cleared),
      );
    } catch (error, stack) {
      printOnFailure('更新查询退避回归失败：$error\n$stack');
      rethrow;
    } finally {
      service.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      debugDefaultTargetPlatformOverride = null;
    }
  });

  test('进度窗口后台停止查询，未变快照不通知界面，恢复后继续', () {
    fakeAsync((time) {
      final service = _DownloadService();
      final controller = AppUpdateController(service: service);
      var notifications = 0;
      controller.addListener(() => notifications++);
      try {
        unawaited(controller.check());
        time.flushMicrotasks();
        expect(service.reads, 1);
        notifications = 0;
        time.elapse(const Duration(seconds: 4));
        expect(service.reads, 3);
        expect(notifications, 0);
        controller.setForeground(false);
        time.elapse(const Duration(minutes: 1));
        expect(service.reads, 3);
        service.received = 50;
        controller.setForeground(true);
        time.flushMicrotasks();
        expect(service.reads, 4);
        expect(controller.progress, .5);
        expect(notifications, 1);
        time.elapse(const Duration(seconds: 2));
        expect(service.reads, 5);
        expect(notifications, 1);
      } catch (error, stack) {
        printOnFailure('更新窗口进度回归失败：$error\n$stack');
        rethrow;
      } finally {
        controller.dispose();
        time.flushMicrotasks();
      }
    });
  });
}
