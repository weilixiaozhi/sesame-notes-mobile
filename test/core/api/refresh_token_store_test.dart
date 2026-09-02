// Refresh Token 安全存储测试。
//
// 需求锚点：
// - Refresh Token 只入安全存储，不落 SharedPreferences/日志；
// - 写入后可读回；
// - 登出后清除；
// - 未写入时读取为 null（不抛错）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/api/refresh_token_store.dart';

/// 内存版存储桩。
class MemoryTokenStore implements TokenStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String token) async {
    value = token;
  }

  @override
  Future<void> delete() async {
    value = null;
  }
}

void main() {
  group('RefreshTokenStore', () {
    test('写入后读回同一值', () async {
      final store = MemoryTokenStore();
      final tokenStore = RefreshTokenStore(store);

      await tokenStore.save('rt-token-1');

      expect(await tokenStore.load(), 'rt-token-1');
      expect(store.value, 'rt-token-1', reason: '必须写入底层安全存储');
    });

    test('未写入时读取为 null', () async {
      final tokenStore = RefreshTokenStore(MemoryTokenStore());

      expect(await tokenStore.load(), isNull);
    });

    test('登出清除后读取为 null', () async {
      final store = MemoryTokenStore();
      final tokenStore = RefreshTokenStore(store);
      await tokenStore.save('rt-token-1');

      await tokenStore.clear();

      expect(await tokenStore.load(), isNull);
      expect(store.value, isNull, reason: '清除必须同步到底层存储');
    });

    test('覆盖写入替换旧值（token 轮换）', () async {
      final tokenStore = RefreshTokenStore(MemoryTokenStore());
      await tokenStore.save('rt-old');

      await tokenStore.save('rt-new');

      expect(await tokenStore.load(), 'rt-new');
    });
  });
}
