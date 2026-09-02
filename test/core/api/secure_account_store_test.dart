import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/secure_account_store.dart';

void main() {
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
