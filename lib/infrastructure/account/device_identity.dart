import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:uuid/uuid.dart';

/// 设备身份存储端口：抽象安全存储，便于测试注入内存实现。
abstract class DeviceIdStore {
  Future<String?> read();
  Future<void> write(String id);
}

/// 基于 flutter_secure_storage 持久保存安装标识。
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

/// 安装身份：首次获取生成 UUID v4 并持久化，之后始终返回同一 id。
///
/// 登录和注册通过 installation_id 识别同一次安装；会话 device_id 来自认证响应。
/// 内存缓存保证单次进程内稳定；存储层保证跨进程稳定。
class DeviceIdentity {
  final DeviceIdStore store;
  String? _cached;
  Future<String>? _loading;

  DeviceIdentity(this.store);

  /// 获取安装 id：缓存 → 存储 → 生成并持久化，三级兜底。
  Future<String> load() {
    final cached = _cached;
    if (cached != null) return Future.value(cached);
    final loading = _loading;
    if (loading != null) return loading;

    // 首次并发认证共用同一次读取和写入，确保所有调用拿到相同安装身份。
    late final Future<String> current;
    current = _loadOnce().whenComplete(() {
      if (identical(_loading, current)) _loading = null;
    });
    _loading = current;
    return current;
  }

  /// 身份持久化成功后才发布缓存；失败保留重试能力，不返回临时身份。
  Future<String> _loadOnce() async {
    try {
      final stored = await store.read();
      if (stored != null && stored.isNotEmpty) {
        _cached = stored;
        return stored;
      }

      final fresh = const Uuid().v4();
      await store.write(fresh);
      _cached = fresh;
      return fresh;
    } catch (error, stackTrace) {
      logger.error(
        'DeviceIdentity',
        '设备身份暂时无法准备，请稍后重试',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 已加载的设备 id（未加载时为 null）。
  String? get cached => _cached;
}
