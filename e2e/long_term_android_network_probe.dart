/// Android 实机网络验收入口；只允许独立 profile 测试包与本机专用代理。
/// 构建注入 APP_ENV=test、API_BASE_URL=http://127.0.0.1:17892、
/// UPDATE_MANIFEST_URL=空、唯一 NETWORK_PROBE_RUN_ID；不依赖 flutter_test。
/// 代理 GET /__acceptance/status 返回 mode，业务模式为 online/offline/drop_once。
/// WAIT_RESTART 必须由宿主强制停止本测试包再启动；控制等待最多三分钟。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart' as memo;
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:uuid/uuid.dart';

const _base = 'http://127.0.0.1:17892';
const _runId = String.fromEnvironment('NETWORK_PROBE_RUN_ID');
const _prefix = 'ANDROID_NETWORK_PROBE_JSON:';
const _waitingLimit = Duration(minutes: 3);
final _status = ValueNotifier<String>('正在检查独立验收环境');

/// 显示简单 QA 状态，具体阶段及证据通过结构化日志交给宿主。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: Scaffold(
        body: Center(
          child: ValueListenableBuilder<String>(
            valueListenable: _status,
            builder: (context, value, child) => Padding(
              padding: const EdgeInsets.all(AppDimens.domainPageInset),
              child: Text(value),
            ),
          ),
        ),
      ),
    ),
  );
  try {
    AppEnvironment.validate();
    final package = await PackageInfo.fromPlatform();
    _check(
      Platform.isAndroid && kProfileMode && AppEnvironment.name == 'test',
      '需要 Android profile 测试环境',
    );
    _check(package.packageName == 'com.sesame.notes.test.probe', '仅允许独立测试包');
    _check(
      AppEnvironment.apiBaseUrl == _base &&
          AppEnvironment.updateManifestUrl.isEmpty,
      '服务入口必须为专用本机代理且关闭更新',
    );
    _check(
      RegExp(r'^[a-zA-Z0-9_-]{1,80}$').hasMatch(_runId),
      '必须提供唯一且合法的 NETWORK_PROBE_RUN_ID',
    );
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'network-$_runId'));
    await directory.create(recursive: true);
    await _NetworkProbe(directory).run();
  } catch (error, stack) {
    _emit('FAILED', {
      'error': safeErrorSummary(error),
      'stack': stack.toString(),
      'scope': '独立测试包；实际代理 socket 故障注入；未改变手机或主机网络开关',
    });
    _status.value = '网络验收未完成，请保留日志并检查阶段错误';
  }
}

/// 验收断言在 profile 模式也生效，不使用会被编译移除的 assert。
void _check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

/// 日志只输出阶段、身份及散列；不输出会话凭据或备忘正文。
void _emit(String phase, [Map<String, Object?> details = const {}]) {
  _status.value = '网络验收：$phase';
  debugPrintSynchronously(
    '$_prefix${jsonEncode({'phase': phase, 'run_id': _runId, 'utc': DateTime.now().toUtc().toIso8601String(), ...details})}',
  );
}

/// 对象键排序后比较，允许服务端 JSON 对象采用不同的字段排列。
Object? _canonical(Object? value) {
  if (value is List) return value.map(_canonical).toList();
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  return value;
}

/// 计算完整内容及同步身份的散列，报告不落正文。
String _hash(Object? value) =>
    sha256.convert(utf8.encode(jsonEncode(_canonical(value)))).toString();

/// 通过两份真实磁盘库和生产同步服务检验断网、重启及丢回执。
class _NetworkProbe {
  _NetworkProbe(this.directory);
  final Directory directory;
  late final File phaseFile = File(p.join(directory.path, 'phase.json'));
  final Dio control = Dio(
    BaseOptions(
      baseUrl: _base,
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      followRedirects: false,
    ),
  );
  final List<String> outcomes = [];
  final List<String> outgoingBodies = [];
  Map<String, dynamic> state = {};
  SesameDatabase? dbA, dbB;
  SesameApiClient? clientA, clientB;
  late SyncService a, b;

  /// 只创建显式测试 API 客户端，记录同步请求摘要与服务端确认状态。
  SesameApiClient _client({String? token, bool observe = false}) {
    final client = SesameApiClient(
      basePathOverride: _base,
      serializers: apiSerializers,
    );
    client.dio.options
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 5)
      ..sendTimeout = const Duration(seconds: 30)
      ..followRedirects = false;
    if (token != null) client.setBearerAuth('bearerAuth', token);
    if (observe) {
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path == '/api/v1/sync/push') {
              outgoingBodies.add(
                options.data is String
                    ? options.data as String
                    : jsonEncode(options.data),
              );
            }
            handler.next(options);
          },
          onResponse: (response, handler) {
            if (response.requestOptions.path == '/api/v1/sync/push' &&
                response.data is Map) {
              final rows = (response.data as Map)['outcomes'];
              if (rows is List) {
                for (final row in rows) {
                  if (row is Map && row['status'] is String) {
                    outcomes.add(row['status'] as String);
                  }
                }
              }
            }
            handler.next(response);
          },
        ),
      );
    }
    return client;
  }

  /// 只等待专用控制端点，不以其可达性推断业务网络可用。
  Future<void> _waitMode(String mode) async {
    final timer = Stopwatch()..start();
    while (timer.elapsed < _waitingLimit) {
      try {
        final response = await control.get<Map<String, dynamic>>(
          '/__acceptance/status',
        );
        if (response.data?['mode'] == mode) return;
      } on DioException {
        // 宿主启动代理的短暂间隙只继续等候，整体等待仍受三分钟上限约束。
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    throw TimeoutException('等待代理模式 $mode 超过三分钟');
  }

  /// phase 文件先完整写入临时文件再原子替换，强杀后不把半份状态当成成功。
  Future<void> _persist(String phase) async {
    try {
      state['phase'] = phase;
      final next = File('${phaseFile.path}.next');
      await next.writeAsString(jsonEncode(state), flush: true);
      await next.rename(phaseFile.path);
    } catch (error, stack) {
      logger.error(
        'AndroidNetworkProbe',
        '验收阶段保存失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 为独立测试账号取得两个安装身份，凭据只保留在测试包自己的目录。
  Future<void> _initialize() async {
    await _waitMode('online');
    final first = _client();
    try {
      final phone =
          '138${(DateTime.now().microsecondsSinceEpoch % 100000000).toString().padLeft(8, '0')}';
      final installA = const Uuid().v4(), installB = const Uuid().v4();
      const password = 'synthetic-android-network-password';
      final registered = (await first.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {
          'country_code': '+86',
          'phone': phone,
          'password': password,
          'device': {
            'installation_id': installA,
            'name': 'Android隔离端A',
            'platform': 'android',
          },
        },
      )).data!;
      final loggedIn = (await first.dio.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {
          'country_code': '+86',
          'phone': phone,
          'password': password,
          'device': {
            'installation_id': installB,
            'name': 'Android隔离端B',
            'platform': 'android',
          },
        },
      )).data!;
      _check(registered['device_id'] != loggedIn['device_id'], '两逻辑端必须有独立设备身份');
      state = {
        'run_id': _runId,
        'account': (registered['user'] as Map)['user_id'],
        'device_a': registered['device_id'],
        'device_b': loggedIn['device_id'],
        'token_a': registered['access_token'],
        'token_b': loggedIn['access_token'],
        'book': const Uuid().v4(),
        'original': const Uuid().v4(),
        'offline_new': const Uuid().v4(),
        'uncertain': const Uuid().v4(),
      };
      await _persist('initialized');
    } catch (error, stack) {
      logger.error(
        'AndroidNetworkProbe',
        '隔离账号初始化失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    } finally {
      first.dio.close(force: true);
    }
  }

  /// 每次进程启动重新打开同一文件；队列来自产品数据库而非内存复制。
  void _open() {
    dbA = SesameDatabase.withExecutor(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'a.sqlite')),
      ),
    );
    dbB = SesameDatabase.withExecutor(
      NativeDatabase.createInBackground(
        File(p.join(directory.path, 'b.sqlite')),
      ),
    );
    clientA = _client(token: state['token_a'] as String, observe: true);
    clientB = _client(token: state['token_b'] as String);
    a = _service(dbA!, clientA!, state['device_a'] as String);
    b = _service(dbB!, clientB!, state['device_b'] as String);
  }

  /// 复用真实备忘仓储、同事务 outbox 与同步实现，不替换业务传输。
  SyncService _service(
    SesameDatabase db,
    SesameApiClient client,
    String device,
  ) {
    final account = state['account'] as String;
    final repository = MemoRepository(
      db,
      accountIdGetter: () => account,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
    return SyncService(
      client: client,
      db: db,
      deviceId: device,
      currentAccountIdGetter: () => account,
      memoRepository: repository,
    );
  }

  /// 通过生产写入口产生正文及同步队列，保留修改时的创建时间。
  Future<void> _save(String id, String title) async {
    final repository = a.memoRepository!;
    final book = state['book'] as String;
    final existing = await repository.getEntries(
      book,
      accountId: state['account'] as String,
    );
    final matches = existing.where((entry) => entry.id == id);
    final now = DateTime.now().toUtc();
    await repository.saveEntry(
      memo.MemoEntry(
        id: id,
        memoBookId: book,
        bookType: 'normal',
        title: title,
        bodyJson: jsonEncode({
          'ops': [
            {
              'insert': '合成记录 中文🙂\n',
              'attributes': {'bold': true},
            },
            {'insert': '$title\n'},
          ],
        }),
        createdAt: matches.isEmpty ? now : matches.single.createdAt,
        updatedAt: now,
      ),
      await repository.target(book),
    );
  }

  /// 读取当前测试父本的完整内容，连同关系和内容时间一起核对。
  Future<Map<String, Object?>> _contents(SyncService service) async {
    final entries = await service.memoRepository!.getEntries(
      state['book'] as String,
      accountId: state['account'] as String,
    );
    return {
      for (final entry in entries)
        entry.id: {
          'parent': entry.memoBookId,
          'payload': entry.payload,
          'deleted': entry.deletedAt?.toIso8601String(),
        },
    };
  }

  /// 未确认队列必须保留原 mutation 和正文；首次发送允许增加冻结请求快照。
  Future<List<Map<String, Object?>>> _pending({bool frozen = true}) async {
    final rows =
        await (dbA!.select(dbA!.syncChanges)
              ..where(
                (row) =>
                    row.memoBookId.equals(state['book'] as String) &
                    row.pushedAt.isNull(),
              )
              ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
            .get();
    return [
      for (final row in rows)
        {
          'mutation': row.mutationId,
          'entity': row.entityId,
          'payload': row.payload,
          'base_revision': row.baseRevision,
          'pushed_at': row.pushedAt?.toIso8601String(),
          if (frozen) 'frozen': row.frozenRequest,
        },
    ];
  }

  /// 只接受实际无 HTTP 回执的传输失败，业务验证错误不能算作断网通过。
  Future<void> _expectTransportFailure() async {
    try {
      await a.push();
    } on DioException catch (error) {
      _check(
        error.response == null && error.type != DioExceptionType.cancel,
        '需要真实无回执网络失败',
      );
      _emit('TRANSPORT_FAILURE_OBSERVED', {'type': error.type.name});
      return;
    }
    throw StateError('预期代理断开 socket，但同步未报告传输失败');
  }

  /// 在线基线完成后，在代理已离线的条件下保存一条修改和一条新增。
  Future<void> _offlineAndStop() async {
    final book = state['book'] as String;
    await a.memoRepository!.createBook(
      id: book,
      name: 'Android网络隔离验收',
      type: 'normal',
      storageMode: 'cloud',
    );
    await _save(state['original'] as String, '在线初始版本');
    await a.push();
    await a.fullMemoBook(memoBookId: book);
    await b.fullMemoBook(memoBookId: book);
    _check(
      _hash(await _contents(a)) == _hash(await _contents(b)),
      '在线基线两端内容不同',
    );
    _check((await _pending()).isEmpty, '在线基线仍有未确认队列');
    _emit('WAIT_OFFLINE', {'action': '将本任务代理切为 offline；只断开业务请求 socket'});
    await _waitMode('offline');
    await _save(state['original'] as String, '离线修改');
    await _save(state['offline_new'] as String, '离线新增');
    final before = await _pending(frozen: false);
    _check(before.length == 2, '离线保存必须产生两条待办');
    await _expectTransportFailure();
    _check(
      _hash(await _pending(frozen: false)) == _hash(before),
      '网络失败改变了待办身份或正文',
    );
    final pending = await _pending();
    _check(pending.every((row) => row['frozen'] is String), '首次发送前必须持久化冻结正文');
    state['pending_hash'] = _hash(pending);
    state['contents_hash'] = _hash(await _contents(a));
    await _persist('awaiting_relaunch');
    _emit('WAIT_RESTART', {
      'action':
          '强制停止且重新启动 com.sesame.notes.test.probe；代理保持 offline；宿主保留停止命令及前后PID',
      'pending': pending.length,
      'pending_sha256': state['pending_hash'],
      'contents_sha256': state['contents_hash'],
    });
    await Completer<void>().future.timeout(
      _waitingLimit,
      onTimeout: () async {
        // 正常超时关库不能作为强杀证据，必须先让当前运行失效。
        await _persist('failed_relaunch');
        throw TimeoutException('等待宿主强制重启超过三分钟');
      },
    );
  }

  /// 真实新进程先核对落盘证据，再恢复上传并制造提交后回执丢失。
  Future<void> _resume() async {
    final pending = await _pending();
    _check(
      pending.length == 2 && _hash(pending) == state['pending_hash'],
      '强制重启后队列身份或冻结正文发生变化',
    );
    _check(
      _hash(await _contents(a)) == state['contents_hash'],
      '强制重启后本地内容发生变化',
    );
    _emit('WAIT_ONLINE', {
      'action': '将本任务代理恢复 online',
      'pending_after_restart': pending.length,
      'pending_sha256': _hash(pending),
      'contents_sha256': state['contents_hash'],
    });
    await _waitMode('online');
    await a.push();
    _check((await _pending()).isEmpty, '恢复网络后待办未清空');
    await b.fullMemoBook(memoBookId: state['book'] as String);
    _check(
      _hash(await _contents(b)) == state['contents_hash'],
      '恢复网络后另一逻辑端内容不同',
    );
    _emit('OFFLINE_RESTART_PASSED', {
      'pending': 0,
      'logical_devices': 2,
      'physical_phones': 1,
    });
    await _save(state['uncertain'] as String, '提交后回执丢失');
    _check((await _pending()).length == 1, '丢回执阶段必须仅有一条待办');
    final expectedContents = await _contents(a);
    _check(expectedContents.length == 3, '丢回执阶段本地预期内容必须包含三条记录');
    // 全量同步可能同时覆盖两端，因此先把发送前的完整内容基线独立持久化。
    state['uncertain_expected_contents_hash'] = _hash(expectedContents);
    await _persist('awaiting_ack_loss_check');
    _emit('WAIT_DROP', {'action': '将本任务代理切为 drop_once；收到上游200后断开下游socket'});
    await _waitMode('drop_once');
    outgoingBodies.clear();
    outcomes.clear();
    await _expectTransportFailure();
    final unknown = await _pending();
    _check(
      unknown.length == 1 && unknown.single['frozen'] is String,
      '不明确回执必须保留冻结待办',
    );
    _check(outgoingBodies.length == 1, '丢回执阶段只允许实际发送一次请求');
    final body = outgoingBodies.single;
    _emit('ACK_LOSS_OBSERVED', {
      'pending': 1,
      'mutation_id': unknown.single['mutation'],
      'request_sha256': _hash(body),
    });
    await _waitMode('online');
    await a.push();
    _check(
      outgoingBodies.length == 2 && outgoingBodies.last == body,
      '重试必须复用完整请求字节',
    );
    _check(
      outcomes.length == 1 && outcomes.single == 'ignored',
      '服务端必须确认幂等重放而非再次写入',
    );
    _check((await _pending()).isEmpty, '重放确认后待办未清空');
    await a.fullMemoBook(memoBookId: state['book'] as String);
    await b.fullMemoBook(memoBookId: state['book'] as String);
    final finalContents = await _contents(a);
    final peerContents = await _contents(b);
    _check(
      finalContents.length == 3 &&
          _hash(finalContents) == state['uncertain_expected_contents_hash'],
      '最终本端内容与发送前预期数量、正文或关系不同',
    );
    _check(
      peerContents.length == 3 &&
          _hash(peerContents) == state['uncertain_expected_contents_hash'],
      '最终另一逻辑端内容与发送前预期数量、正文或关系不同',
    );
    _check(
      (await dbA!.customSelect('PRAGMA foreign_key_check').get()).isEmpty,
      '本地外键关系异常',
    );
    state['final_contents_hash'] = _hash(finalContents);
    await _persist('complete');
    _emit('COMPLETE', {
      'rows': 3,
      'pending': 0,
      'replayed_outcome': 'ignored',
      'same_request_bytes': true,
      'expected_contents_sha256': state['uncertain_expected_contents_hash'],
      'contents_sha256': state['final_contents_hash'],
      'physical_phones': 1,
      'logical_devices': 2,
      'restart': 'host_force_stop_then_relaunch',
      'restart_evidence_required': 'host_stop_command_and_new_pid',
      'fault': 'loopback_proxy_socket_close',
      'scope': '实际Android文件库与HTTP；未覆盖编辑器草稿或保存事务中途强杀',
    });
  }

  /// 阶段只从本测试子目录恢复；结束时关闭自身资源，不触及其他应用。
  Future<void> run() async {
    try {
      if (await phaseFile.exists()) {
        state =
            jsonDecode(await phaseFile.readAsString()) as Map<String, dynamic>;
        _check(state['run_id'] == _runId, '验收目录与运行身份不同');
      } else {
        await _initialize();
      }
      if (state['phase'] == 'complete') {
        _emit('ALREADY_COMPLETE', {
          'contents_sha256': state['final_contents_hash'],
        });
        return;
      }
      if (state['phase'] == 'failed_relaunch') {
        throw StateError('本次运行已因等待强制重启超时失效，请使用新的运行身份');
      }
      _open();
      if (state['phase'] == 'initialized') {
        await _offlineAndStop();
      } else if (state['phase'] == 'awaiting_relaunch') {
        await _resume();
      } else {
        throw StateError('验收阶段不完整，请使用新的运行身份');
      }
    } catch (error, stack) {
      logger.error(
        'AndroidNetworkProbe',
        '实机网络验收未完成',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    } finally {
      clientA?.dio.close(force: true);
      clientB?.dio.close(force: true);
      control.close(force: true);
      await dbA?.close();
      await dbB?.close();
    }
  }
}
