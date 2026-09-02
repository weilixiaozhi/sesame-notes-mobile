import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储端口：抽象 flutter_secure_storage，便于测试注入内存实现。
abstract class SecureStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

/// 基于 flutter_secure_storage 的实现（凭证属敏感数据）。
class SecureFlutterStore implements SecureStore {
  static const _key = 'sesame_notes_active_credential';

  final FlutterSecureStorage _storage;

  SecureFlutterStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}

/// 当前账号的原子凭证束：user_id、服务端 device_id 与 Refresh Token 同写同换。
///
/// 设计意图：三个值以单个 JSON 原子保存，避免崩溃后出现
/// 「B 的 Token + A 的账号/设备指针」；Refresh 轮换只覆盖这一个值，
/// 凭证提交统一由账号协调器在数据域校验完成后写入。
class ActiveCredential {
  final String userId;
  final String deviceId;
  final String refreshToken;

  const ActiveCredential({
    required this.userId,
    required this.deviceId,
    required this.refreshToken,
  });

  /// 序列化为单个 JSON 值；字段名不含手机号、密码或 Access Token。
  String encode() => jsonEncode({
    'user_id': userId,
    'device_id': deviceId,
    'refresh_token': refreshToken,
  });

  /// 解析失败返回 null（损坏数据按无凭证处理，启动恢复会走未登录分支）。
  static ActiveCredential? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final userId = map['user_id'] as String?;
      final deviceId = map['device_id'] as String?;
      final refreshToken = map['refresh_token'] as String?;
      if (userId == null ||
          userId.isEmpty ||
          deviceId == null ||
          deviceId.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty) {
        return null;
      }
      return ActiveCredential(
        userId: userId,
        deviceId: deviceId,
        refreshToken: refreshToken,
      );
    } catch (_) {
      return null;
    }
  }
}

/// 登出进行中标记：记录待撤销的服务端会话（purge 完成后、撤销前崩溃时兜底）。
class LogoutMarker {
  final ActiveCredential credential;

  const LogoutMarker({required this.credential});

  String encode() => jsonEncode({
    'user_id': credential.userId,
    'device_id': credential.deviceId,
    'refresh_token': credential.refreshToken,
  });

  static LogoutMarker? decode(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final userId = map['user_id'] as String?;
      final deviceId = map['device_id'] as String?;
      final refreshToken = map['refresh_token'] as String?;
      if (userId == null || deviceId == null || refreshToken == null) {
        return null;
      }
      return LogoutMarker(
        credential: ActiveCredential(
          userId: userId,
          deviceId: deviceId,
          refreshToken: refreshToken,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}

/// ActiveCredential 存取门面：统一 load/save/clear 语义。
///
/// 三个存储槽位（当前凭证 / 候选凭证 / 登出标记）必须同源同生命周期：
/// 崩溃恢复按槽位状态推断两阶段提交进行到哪一步。
class SecureAccountStore {
  final SecureStore store;
  final SecureStore pendingStore;
  final SecureStore logoutMarkerStore;

  SecureAccountStore(
    this.store, {
    SecureStore? pendingStore,
    SecureStore? logoutMarkerStore,
  }) : pendingStore =
           pendingStore ??
           const KeyedSecureFlutterStore('sesame_notes_pending_credential'),
       logoutMarkerStore =
           logoutMarkerStore ??
           const KeyedSecureFlutterStore('sesame_notes_logout_in_progress');

  /// 读取当前凭证束；未保存或损坏返回 null。
  Future<ActiveCredential?> load() async {
    try {
      final raw = await store.read();
      if (raw == null || raw.isEmpty) return null;
      return ActiveCredential.decode(raw);
    } catch (error, stackTrace) {
      // 安全存储读取失败按未登录处理，异常留待启动恢复日志
      _lastError = (error, stackTrace);
      return null;
    }
  }

  (Object, StackTrace)? _lastError;

  /// 最近一次读取失败（测试与诊断用）。
  (Object, StackTrace)? get lastError => _lastError;

  /// 原子写入凭证束。
  Future<void> save(ActiveCredential credential) =>
      store.write(credential.encode());

  /// 清除凭证束。
  Future<void> clear() => store.delete();

  /// 两阶段提交的候选凭证（B 认证成功后、ActiveCredential 提交前落盘）。
  Future<ActiveCredential?> loadPending() async {
    try {
      final raw = await pendingStore.read();
      if (raw == null || raw.isEmpty) return null;
      return ActiveCredential.decode(raw);
    } catch (_) {
      return null;
    }
  }

  /// 写入候选凭证（崩溃后可恢复 B 提交流程）。
  ///
  /// 辅助槽位写失败不阻断主流程（ActiveCredential 原子写入才是提交闸门），
  /// 失败仅记录日志；不可用平台（测试环境/受限设备）不误伤登录。
  Future<void> savePending(ActiveCredential credential) async {
    try {
      await pendingStore.write(credential.encode());
    } catch (error, stackTrace) {
      _lastError = (error, stackTrace);
    }
  }

  /// 清除候选凭证。
  Future<void> clearPending() async {
    try {
      await pendingStore.delete();
    } catch (error, stackTrace) {
      _lastError = (error, stackTrace);
    }
  }

  /// 读取登出进行中标记（启动恢复用）。
  Future<LogoutMarker?> loadLogoutMarker() async {
    try {
      final raw = await logoutMarkerStore.read();
      if (raw == null || raw.isEmpty) return null;
      return LogoutMarker.decode(raw);
    } catch (_) {
      return null;
    }
  }

  /// 写登出进行中标记：捕获 A 凭证，purge/撤销完成前崩溃也能收尾。
  /// 辅助槽位写失败只记录日志，不阻断登出主流程。
  Future<void> saveLogoutMarker(LogoutMarker marker) async {
    try {
      await logoutMarkerStore.write(marker.encode());
    } catch (error, stackTrace) {
      _lastError = (error, stackTrace);
    }
  }

  /// 清除登出进行中标记。
  Future<void> clearLogoutMarker() async {
    try {
      await logoutMarkerStore.delete();
    } catch (error, stackTrace) {
      _lastError = (error, stackTrace);
    }
  }
}

/// 基于 flutter_secure_storage 的指定键实现：同一存储实例、不同 key，
/// 用于候选凭证与登出标记两个独立槽位。
class KeyedSecureFlutterStore implements SecureStore {
  final String _key;
  final FlutterSecureStorage _storage;

  const KeyedSecureFlutterStore(this._key, [FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);

  @override
  Future<void> delete() => _storage.delete(key: _key);
}
