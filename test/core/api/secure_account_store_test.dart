import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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
