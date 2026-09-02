import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// 设备身份存储端口：抽象安全存储，便于测试注入内存实现。
abstract class DeviceIdStore {
  Future<String?> read();
  Future<void> write(String id);
}

/// 基于 flutter_secure_storage 的实现（device id 属敏感凭证）。
class SecureDeviceIdStore implements DeviceIdStore {
  static const _key = 'sesame_notes_device_id';

  final FlutterSecureStorage _storage;

  SecureDeviceIdStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String id) => _storage.write(key: _key, value: id);
}

/// 设备身份：首次获取生成 UUID v4 并持久化，之后始终返回同一 id。
///
/// 设计意图：契约要求 push 的 device_id 必须与登录会话绑定的设备一致，
/// 且同一设备每次启动必须复用同一标识（否则每次登录都会新建服务端设备记录）。
/// 内存缓存保证单次进程内稳定；存储层保证跨进程稳定。
class DeviceIdentity {
  final DeviceIdStore store;
  String? _cached;

  DeviceIdentity(this.store);

  /// 获取设备 id：缓存 → 存储 → 生成并持久化，三级兜底。
  Future<String> load() async {
    final cached = _cached;
    if (cached != null) return cached;

    final stored = await store.read();
    if (stored != null && stored.isNotEmpty) {
      _cached = stored;
      return stored;
    }

    final fresh = const Uuid().v4();
    await store.write(fresh);
    _cached = fresh;
    return fresh;
  }

  /// 已加载的设备 id（未加载时为 null）。
  String? get cached => _cached;
}
