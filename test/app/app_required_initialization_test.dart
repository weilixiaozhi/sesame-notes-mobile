import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';

/// 失败发生在安全存储端口，凭证门面保留实际读取失败的语义。
class _RecoverableSecureStore implements SecureStore {
  bool unreadable = false;
  String? value;

  /// 模拟系统钥匙串暂时不可读，修复后仍使用同一个存储实例。
  @override
  Future<String?> read() async {
    if (unreadable) throw StateError('injected secure storage failure');
    return value;
  }

  /// 保留真实门面对同一存储槽的写入语义。
  @override
  Future<void> write(String next) async => value = next;

  /// 空槽与不可读是不同状态。
  @override
  Future<void> delete() async => value = null;
}

/// 必需凭证读取失败保留错误语义，损坏内容按空凭证处理。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(logger.clear);

  test('严格凭证读取保留原始失败堆栈，宽松读取及损坏JSON保持原语义', () async {
    final raw = _RecoverableSecureStore()..unreadable = true;
    final store = SecureAccountStore(raw);
    expect(await store.load(), isNull);
    expect(store.lastError, isNotNull);
    try {
      await store.load(requireReadable: true);
      fail('必需凭证读取不能把系统存储失败当作无凭证');
    } on StateError catch (error, stackTrace) {
      expect(error.message, contains('当前账号信息暂时无法读取'));
      expect(stackTrace.toString(), contains('_RecoverableSecureStore.read'));
    }
    raw.unreadable = false;
    raw.value = 'invalid-json';
    expect(await store.load(requireReadable: true), isNull);
    expect(store.lastError, isNull);
  });
}
