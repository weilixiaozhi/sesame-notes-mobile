import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  group('ActiveCredential 原子凭证束', () {
    test('encode/decode 往返保留三个字段', () {
      const credential = ActiveCredential(
        userId: 'user-1',
        deviceId: 'device-1',
        refreshToken: 'rt-1',
      );
      final decoded = ActiveCredential.decode(credential.encode())!;
      expect(decoded.userId, 'user-1');
      expect(decoded.deviceId, 'device-1');
      expect(decoded.refreshToken, 'rt-1');
    });

    test('损坏 JSON / 缺字段 / 空值 → decode 返回 null（按无凭证处理）', () {
      expect(ActiveCredential.decode('not-json'), isNull);
      expect(ActiveCredential.decode('{"user_id":"u"}'), isNull);
      expect(ActiveCredential.decode('{}'), isNull);
      expect(
        ActiveCredential.decode(
          '{"user_id":"u","device_id":"d","refresh_token":""}',
        ),
        isNull,
      );
    });
  });

  group('SecureAccountStore', () {
    test('安全槽只读列表，并发追加与精确删除不会丢掉其他会话', () async {
      const first = ActiveCredential(
        userId: 'u1',
        deviceId: 'd1',
        refreshToken: 'rt1',
      );
      const second = ActiveCredential(
        userId: 'u2',
        deviceId: 'd2',
        refreshToken: 'rt2',
      );
      const third = ActiveCredential(
        userId: 'u3',
        deviceId: 'd3',
        refreshToken: 'rt3',
      );
      final markerStore = _MemorySecureStore();
      await markerStore.write(LogoutMarker(credential: first).encode());
      final store = SecureAccountStore(
        _MemorySecureStore(),
        logoutMarkerStore: markerStore,
      );
      await expectLater(store.loadLogoutMarkers(), throwsFormatException);
      await markerStore.delete();
      await store.saveLogoutMarker(const LogoutMarker(credential: first));
      expect(
        (await store.loadLogoutMarkers()).single.credential.refreshToken,
        'rt1',
      );
      await Future.wait([
        store.saveLogoutMarker(const LogoutMarker(credential: second)),
        store.saveLogoutMarker(const LogoutMarker(credential: third)),
        store.clearLogoutMarker(first),
      ]);
      expect(
        (await store.loadLogoutMarkers()).map(
          (entry) => entry.credential.refreshToken,
        ),
        ['rt2', 'rt3'],
      );
      expect(await store.load(), isNull, reason: '撤销材料不能恢复为当前账号');
    });

    // 候选槽读失败与"没有候选"是两件事：前者意味着可能有未撤销的 refresh token，
    // 语义上仍按无候选降级（下次启动重试），但必须留下诊断。
    test('候选凭证读取失败时留下诊断日志', () async {
      await logger.clear();
      final store = SecureAccountStore(
        _MemorySecureStore(),
        pendingStore: _ReadThrowingSecureStore(),
      );

      expect(await store.loadPending(), isNull);
      expect(store.lastError, isNull, reason: '候选槽诊断不能把当前凭证缺失误判成读取失败');
      expect(
        logger.logs
            .where((entry) => entry.tag == 'AccountStore')
            .map((entry) => entry.message),
        contains('读取候选凭证失败，本次按无候选处理'),
      );
      await logger.clear();
    });

    test('save/load/clear 原子读写', () async {
      final store = SecureAccountStore(_MemorySecureStore());
      expect(await store.load(), isNull);
      await store.save(
        const ActiveCredential(userId: 'u', deviceId: 'd', refreshToken: 'rt'),
      );
      expect((await store.load())!.refreshToken, 'rt');
      await store.clear();
      expect(await store.load(), isNull);
    });

    test('辅助槽写入与清除失败可降级且保留脱敏堆栈', () async {
      await logger.clear();
      final pending = _FailingPendingSecureStore();
      final store = SecureAccountStore(
        _MemorySecureStore(),
        pendingStore: pending,
      );
      const credential = ActiveCredential(
        userId: 'sensitive-user',
        deviceId: 'sensitive-device',
        refreshToken: 'sensitive-refresh-token',
      );

      await store.savePending(credential);
      expect(store.lastError, isNull);
      await store.clearPending();
      expect(store.lastError, isNull);
      final entries = logger.logs
          .where((entry) => entry.tag == 'AccountStore')
          .toList();
      expect(entries, hasLength(2));
      expect(entries.every((entry) => entry.stackTrace != null), isTrue);
      final diagnostic = entries.map((entry) => entry.toJson()).join();
      expect(diagnostic, isNot(contains('sensitive-user')));
      expect(diagnostic, isNot(contains('sensitive-device')));
      expect(diagnostic, isNot(contains('sensitive-refresh-token')));

      pending.fail = false;
      await store.savePending(credential);
      expect(store.lastError, isNull);
      expect(
        (await store.loadPending())?.refreshToken,
        credential.refreshToken,
      );
      await store.clearPending();
      expect(store.lastError, isNull);
      expect(await store.loadPending(), isNull);
      await logger.clear();
    });

    for (final save in [true, false]) {
      test('当前凭证读取失败与候选${save ? '保存' : '清除'}并发，辅助成功不抹去读取错误', () async {
        final response = Completer<String?>();
        final active = _ControlledReadSecureStore(response.future);
        final pending = _PausedPendingSecureStore();
        final store = SecureAccountStore(active, pendingStore: pending);
        const credential = ActiveCredential(
          userId: 'u',
          deviceId: 'd',
          refreshToken: 'rt',
        );
        final reading = store.load();
        final auxiliary = save
            ? store.savePending(credential)
            : store.clearPending();
        await pending.started.future;
        final failure = StateError('active-slot-unavailable');
        response.completeError(failure, StackTrace.current);
        expect(await reading, isNull);
        expect(store.lastError?.$1, same(failure));
        // 候选操作比当前槽读取晚结束，不能令认证调用者把读取故障当成正常缺失。
        pending.release.complete();
        await auxiliary;
        expect(store.lastError?.$1, same(failure));
        active.result = Future.value(null);
        expect(await store.load(), isNull);
        expect(store.lastError, isNull, reason: '仅当前凭证成功读取才能清除此错误');
      });
    }

    test('候选槽读写清除失败只记录各自诊断，不替换当前凭证读取错误', () async {
      await logger.clear();
      final store = SecureAccountStore(
        _ReadThrowingSecureStore(),
        pendingStore: _FailingPendingSecureStore(),
      );
      expect(await store.load(), isNull);
      final activeError = store.lastError;
      expect(activeError, isNotNull);
      const credential = ActiveCredential(
        userId: 'u',
        deviceId: 'd',
        refreshToken: 'rt',
      );
      await store.savePending(credential);
      expect(store.lastError?.$1, same(activeError!.$1));
      await store.clearPending();
      expect(store.lastError?.$1, same(activeError.$1));
      expect(await store.loadPending(), isNull);
      expect(store.lastError?.$1, same(activeError.$1));
      expect(
        logger.logs.where((entry) => entry.tag == 'AccountStore'),
        hasLength(3),
      );
      await logger.clear();
    });

    test('撤销槽读改写失败仍阻断材料丢失，但不污染当前凭证读取结果', () async {
      await logger.clear();
      final store = SecureAccountStore(
        _MemorySecureStore(),
        logoutMarkerStore: _FailingPendingSecureStore(),
      );
      expect(await store.load(), isNull);
      const credential = ActiveCredential(
        userId: 'u',
        deviceId: 'd',
        refreshToken: 'rt',
      );
      await expectLater(
        store.saveLogoutMarker(const LogoutMarker(credential: credential)),
        throwsStateError,
      );
      expect(store.lastError, isNull);
      expect(logger.logs.any((entry) => entry.message == '保存待撤销会话失败'), isTrue);
      await logger.clear();
    });
  });
}

class _MemorySecureStore implements SecureStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String v) async => value = v;

  @override
  Future<void> delete() async => value = null;
}

/// 只在读取时失败的安全存储：模拟平台通道不可用 / Keystore 重置。
class _ReadThrowingSecureStore implements SecureStore {
  @override
  Future<String?> read() async =>
      throw StateError('secure storage unavailable');

  @override
  Future<void> write(String v) async {}

  @override
  Future<void> delete() async {}
}

/// 控制候选槽平台失败，异常正文故意包含敏感值以验证日志脱敏。
class _FailingPendingSecureStore extends _MemorySecureStore {
  bool fail = true;

  /// 读取失败也只能影响辅助槽诊断，不能冒充当前凭证槽的读取失败。
  @override
  Future<String?> read() async {
    if (fail) throw StateError('sensitive-refresh-token');
    return super.read();
  }

  /// 模拟写入失败，恢复后保留原子凭证束的正常行为。
  @override
  Future<void> write(String value) async {
    if (fail) throw StateError(value);
    await super.write(value);
  }

  /// 模拟清除失败，恢复后可以正常清理候选材料。
  @override
  Future<void> delete() async {
    if (fail) throw StateError('sensitive-refresh-token');
    await super.delete();
  }
}

/// 精确控制当前凭证读取完成时刻，复现不同安全槽异步收尾交错。
class _ControlledReadSecureStore extends _MemorySecureStore {
  /// 注入本轮读取的完成信号，之后可以切换到正常读取结果。
  _ControlledReadSecureStore(this.result);
  Future<String?> result;

  /// 当前槽只等待测试指定的读取，不访问系统安全存储。
  @override
  Future<String?> read() => result;
}

/// 候选槽在测试放行前保持操作未完成，用于验证其迟到成功不能清除当前读取错误。
class _PausedPendingSecureStore extends _MemorySecureStore {
  final started = Completer<void>();
  final release = Completer<void>();

  /// 通知操作已进入平台边界，并等待本次测试显式释放。
  Future<void> _pause() async {
    started.complete();
    await release.future;
  }

  /// 持久化候选的完成顺序由测试控制。
  @override
  Future<void> write(String value) async {
    await _pause();
    await super.write(value);
  }

  /// 删除候选的完成顺序由测试控制。
  @override
  Future<void> delete() async {
    await _pause();
    await super.delete();
  }
}
