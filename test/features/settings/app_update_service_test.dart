import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sesame_notes/features/settings/infrastructure/app_update_service.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);
  @override
  void close({bool force = false}) {}
}

/// 平台通道承担下载，Dart 层只校验元数据并转交任务和安装身份。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.sesame_notes.update');
  late Map<String, dynamic> manifest;
  Map<String, dynamic>? task;
  late List<MethodCall> calls;
  late Dio dio;
  late AppUpdateService service;
  setUp(() {
    task = null;
    calls = [];
    manifest = {
      'version': '1.1.0',
      'buildNumber': 14,
      'packageName': 'com.sesame.notes',
      'abi': 'arm64-v8a',
      'url': 'https://example.com/update.apk',
      'size': 100,
      'sha256': List.filled(64, 'a').join(),
      'notes': '更新',
    };
    PackageInfo.setMockInitialValues(
      appName: 'Sesame',
      packageName: 'com.sesame.notes',
      version: '1.0.12',
      buildNumber: '13',
      buildSignature: '',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          switch (call.method) {
            case 'isSupported':
            case 'canInstall':
              return true;
            case 'downloadStatus':
              return task;
            case 'enqueueDownload':
              task ??= {
                'id': 42,
                'status': 'pending',
                'received': 0,
                'total': 100,
                'manifest': call.arguments,
                'installPending': true,
              };
              return task;
            case 'cancelDownload':
              task = null;
              return null;
            case 'consumeInstall':
              return true;
            default:
              return null;
          }
        });
    dio = Dio()
      ..httpClientAdapter = _Adapter((options) {
        expect(options.uri.path, '/update.json', reason: 'HTTP 客户端不再下载 APK');
        expect(options.headers.containsKey('Authorization'), isFalse);
        return ResponseBody.fromString(
          jsonEncode(manifest),
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });
    service = AppUpdateService(
      dio: dio,
      source: 'https://example.com/update.json',
    );
  });
  tearDown(() {
    service.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('同版本重构建可更新，相同或较低构建号不可更新', () async {
    expect((await service.check(CancelToken()))!.buildNumber, 14);
    expect(service.installedVersion, '1.0.12 (13)');
    manifest['buildNumber'] = 13;
    expect(await service.check(CancelToken()), isNull);
    expect(AppUpdate.fromJson(manifest).isNewerThan(14), isFalse);
  });

  test('元数据拒绝非 HTTPS、错误包名、ABI、大小和摘要', () {
    for (final invalid in <Map<String, dynamic>>[
      {'url': 'http://example.com/update.apk'},
      {'url': 'https://user:password@example.com/update.apk'},
      {'packageName': 'com.other.app'},
      {'abi': 'x86'},
      {'buildNumber': '14'},
      {'buildNumber': 0},
      {'size': 0},
      {'sha256': 'abc'},
      {'version': '1.2'},
      {'notes': null},
    ]) {
      expect(
        () => AppUpdate.fromJson({...manifest, ...invalid}),
        throwsFormatException,
      );
    }
  });

  test('未配置更新源和不支持的安装包返回明确错误', () async {
    final empty = AppUpdateService(source: '');
    addTearDown(empty.dispose);
    await expectLater(
      empty.check(CancelToken()),
      throwsA(
        isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'UPDATE_NOT_CONFIGURED',
        ),
      ),
    );
    PackageInfo.setMockInitialValues(
      appName: 'Debug',
      packageName: 'com.sesame.notes.dev.debug',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await expectLater(
      service.check(CancelToken()),
      throwsA(
        isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'UPDATE_UNSUPPORTED',
        ),
      ),
    );
  });

  test('点击更新将公开元数据转交系统，进程重开恢复同一编号', () async {
    final update = AppUpdate.fromJson(manifest);
    expect((await service.startDownload(update)).id, 42);
    final next = AppUpdateService(source: 'https://example.com/update.json');
    addTearDown(next.dispose);
    service.dispose();
    expect((await next.currentDownload())!.id, 42);
    expect(
      (await next.check(CancelToken()))!.sha256Digest,
      update.sha256Digest,
    );
    expect(calls.where((call) => call.method == 'cancelDownload'), isEmpty);
  });

  test('排队和等待网络保留任务，用户显式取消才调用系统撤销', () async {
    await service.startDownload(AppUpdate.fromJson(manifest));
    task!['status'] = 'paused';
    task!['received'] = 25;
    final state = (await service.currentDownload())!;
    expect(state.active, isTrue);
    expect(state.progress, 0.25);
    await service.cancelDownload();
    expect(await service.currentDownload(), isNull);
    expect(
      calls.where((call) => call.method == 'cancelDownload'),
      hasLength(1),
    );
  });

  test('安装只传递版本和摘要，由原生层定位并重新验证自有文件', () async {
    final update = AppUpdate.fromJson(manifest);
    await service.install(update);
    expect(calls.last.method, 'install');
    expect(calls.last.arguments, {
      'buildNumber': 14,
      'sha256': update.sha256Digest,
    });
    service.dispose();
    await service.install(update);
    expect(calls.where((call) => call.method == 'install'), hasLength(1));
  });

  test('系统校验失败向上传播，状态不能被解释成已就绪', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (_) async => throw PlatformException(code: 'UPDATE_DOWNLOAD_FAILED'),
        );
    await expectLater(
      service.currentDownload(),
      throwsA(isA<PlatformException>()),
    );
    expect(
      () => UpdateDownload.fromJson({
        'id': 1,
        'status': 'unknown',
        'received': 0,
        'manifest': manifest,
      }),
      throwsFormatException,
    );
  });

  test('已安装版本的缓存任务会被清理，不重复提示安装', () async {
    await service.startDownload(AppUpdate.fromJson(manifest));
    PackageInfo.setMockInitialValues(
      appName: 'Sesame',
      packageName: 'com.sesame.notes',
      version: '1.1.0',
      buildNumber: '14',
      buildSignature: '',
    );
    expect(await service.check(CancelToken()), isNull);
    expect(
      calls.where((call) => call.method == 'cancelDownload'),
      hasLength(1),
    );
  });
}
