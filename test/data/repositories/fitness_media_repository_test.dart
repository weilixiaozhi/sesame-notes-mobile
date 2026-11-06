import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/support/fitness_media_cache.dart';

import '../../helpers/test_isolation.dart';

/// 缓存回收保护唯一离线内容和未知文件，只删除显式授权的可替代副本。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  final bytes = Uint8List.fromList([...ascii.encode('GIF89a'), 1, 2]);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await logger.clear();
    root = await createTestTempDirectory('fitness-media-cache-');
  });
  tearDown(() async {
    await logger.clear();
    await root.delete(recursive: true);
  });

  /// 缓存测试只授权显式给出的可替代身份，未知文件默认受保护。
  FitnessMediaCache cache({
    int limit = 16,
    Set<String> replaceable = const {},
  }) => FitnessMediaCache(
    directory: () async => root,
    maxBytes: limit,
    reclaimableKeys: () async => replaceable,
    verifyReclaimable: (key, file) async => replaceable.contains(key),
  );

  /// 生成合法摘要文件身份，避免测试绕过正式的路径边界。
  String key(String value) => sha256.convert(utf8.encode(value)).toString();

  /// 直接读取本次独占缓存夹具，断言磁盘内容没有被回收或覆盖。
  File file(String identity) =>
      File('${root.path}${Platform.pathSeparator}$identity.gif');

  test('只回收有可靠随包替身的旧副本，读取中的独立字节和唯一媒体保留', () async {
    try {
      final safe = key('builtin');
      final unique = key('uploaded');
      final next = key('next');
      final store = cache(replaceable: {safe});
      expect(await store.write(safe, bytes), isTrue);
      expect(await store.write(unique, bytes), isTrue);
      final decodedInput = await store.read(
        safe,
        maxFileBytes: 20,
        valid: (_) => true,
      );
      expect(await store.write(next, bytes), isTrue);
      expect(await file(safe).exists(), isFalse);
      expect(decodedInput, bytes);
      expect(await file(unique).readAsBytes(), bytes);
      expect(await file(next).readAsBytes(), bytes);
    } catch (error, stackTrace) {
      printOnFailure('安全契约验证失败：$error\n$stackTrace');
      rethrow;
    }
  });

  test('旧缓存已超限时保持可读且不继续增长，未知文件和目录不删除', () async {
    try {
      final unique = key('legacy');
      await file(unique).writeAsBytes(bytes);
      final unknown = File(
        '${root.path}${Platform.pathSeparator}old-format.bin',
      );
      await unknown.writeAsBytes(bytes);
      final store = cache(limit: 4);
      expect(
        await store.read(unique, maxFileBytes: 20, valid: (_) => true),
        bytes,
      );
      expect(await store.write(key('new'), bytes), isFalse);
      expect(await unknown.readAsBytes(), bytes);
      final unsafe = Directory(file(key('directory')).path);
      await unsafe.create();
      expect(await store.write(key('directory'), bytes), isFalse);
      expect(await unsafe.exists(), isTrue);
    } catch (error, stackTrace) {
      printOnFailure('安全契约验证失败：$error\n$stackTrace');
      rethrow;
    }
  });
}
