// 设备身份持久化测试。
//
// 需求锚点（敏感凭证入安全存储 + 设备会话）：
// - 首次获取：生成 UUID v4 并写入安全存储；
// - 再次获取：返回同一 id（不重复生成）；
// - 存储已有值：直接读回，不生成新 id；
// - 设备 id 必须是合法 UUID v4（服务端 device_id pattern 校验）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/api/device_identity.dart';
import 'package:uuid/uuid.dart';

/// 内存版存储桩：模拟安全存储的读写。
class MemoryDeviceIdStore implements DeviceIdStore {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String id) async {
    value = id;
  }
}

void main() {
  group('DeviceIdentity', () {
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
