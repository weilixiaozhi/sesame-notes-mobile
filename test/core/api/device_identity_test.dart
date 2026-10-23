import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/infrastructure/account/device_identity.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 内存版存储桩：模拟安全存储的读写。
class MemoryDeviceIdStore implements DeviceIdStore {
  String? value;
  int writes = 0;
  bool failWrite = false;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String id) async {
    writes++;
    if (failWrite) throw StateError('模拟安全存储写入失败');
    value = id;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('DeviceIdentity', () {
    test('并发首次获取共用一次持久化并返回同一安装身份', () async {
      final store = MemoryDeviceIdStore();
      final identity = DeviceIdentity(store);

      final ids = await Future.wait([identity.load(), identity.load()]);

      expect(ids.toSet(), hasLength(1));
      expect(store.writes, 1);
      expect(store.value, ids.first);
    });

    test('持久化失败后允许重新读取并生成身份', () async {
      final store = MemoryDeviceIdStore()..failWrite = true;
      final identity = DeviceIdentity(store);

      await expectLater(identity.load(), throwsStateError);
      expect(identity.cached, isNull);
      store.failWrite = false;
      final id = await identity.load();

      expect(identity.cached, id);
      expect(store.value, id);
      expect(store.writes, 2);
    });
    test('首次获取：生成合法 UUID v4 并写入存储', () async {
      final store = MemoryDeviceIdStore();
      final identity = DeviceIdentity(store);

      final id = await identity.load();

      expect(
        Uuid.isValidUUID(fromString: id),
        isTrue,
        reason: '设备 id 必须是合法 UUID（服务端 device_id pattern 校验）',
      );
      expect(store.value, id, reason: '生成后必须持久化到安全存储');
    });

    test('再次获取：返回同一 id，不重复生成', () async {
      final store = MemoryDeviceIdStore();
      final identity = DeviceIdentity(store);

      final first = await identity.load();
      final second = await identity.load();

      expect(second, first, reason: '同一设备生命周期内 id 必须稳定');
      // 存储只被写入一次
      expect(store.value, first);
    });

    test('存储已有值：直接读回，不再生成新 id', () async {
      final existing = const Uuid().v4();
      final store = MemoryDeviceIdStore()..value = existing;
      final identity = DeviceIdentity(store);

      final id = await identity.load();

      expect(id, existing, reason: '已持久化的 id 必须原样读回');
      expect(store.value, existing);
    });

    test('缓存命中后读存储为空也不重新生成（cached 优先）', () async {
      final store = MemoryDeviceIdStore();
      final identity = DeviceIdentity(store);

      final first = await identity.load();
      // 模拟存储被外部清空
      store.value = null;
      final second = await identity.load();

      expect(second, first, reason: '内存缓存优先，存储异常不改变设备身份');
    });
  });
}
