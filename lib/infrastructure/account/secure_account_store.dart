import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 安全存储端口：抽象 flutter_secure_storage，便于测试注入内存实现。
abstract class SecureStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
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

/// 待撤销标记：凭证只用于服务端撤销，不恢复为当前登录账号。
class LogoutMarker {
  final ActiveCredential credential;

  const LogoutMarker({required this.credential});

  /// 序列化撤销材料，始终由系统安全存储持久化。
  String encode() => jsonEncode({
    'user_id': credential.userId,
    'device_id': credential.deviceId,
    'refresh_token': credential.refreshToken,
  });

  /// 仅接受完整凭证，损坏内容不能用于撤销。
  static LogoutMarker? decode(String raw) {
    final credential = ActiveCredential.decode(raw);
    return credential == null ? null : LogoutMarker(credential: credential);
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
  Future<void>? _activeWrite;
  Future<void>? _markerWrite;

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

  /// 读取当前凭证束；未保存或损坏返回 null，必需初始化可要求读取错误直接失败。
  Future<ActiveCredential?> load({bool requireReadable = false}) async {
    try {
      final raw = await store.read();
      _lastError = null;
      if (raw == null || raw.isEmpty) return null;
      return ActiveCredential.decode(raw);
    } catch (error, stackTrace) {
      _lastError = (error, stackTrace);
      if (requireReadable) {
        logger.error(
          'AccountStore',
          '当前账号信息暂时无法读取，请重试',
          safeErrorSummary(error),
          stackTrace,
        );
        // 对外保留稳定说明，堆栈仍定位到实际失败的安全存储读取操作。
        Error.throwWithStackTrace(StateError('当前账号信息暂时无法读取，请重试'), stackTrace);
      }
      return null;
    }
  }

  (Object, StackTrace)? _lastError;

  /// 最近一次读取失败（测试与诊断用）。
  (Object, StackTrace)? get lastError => _lastError;

  /// 原子写入凭证束。
  Future<void> save(ActiveCredential credential) =>
      _writeActive(() => store.write(credential.encode()));

  /// 清除凭证束。
  Future<void> clear() => _writeActive(store.delete);

  /// 当前凭证按调用顺序落盘，避免迟到的刷新写入覆盖随后提交的退出或换号。
  Future<void> _writeActive(Future<void> Function() write) {
    final next = (_activeWrite ?? Future<void>.value()).then((_) => write());
    // 调用方仍收到本次错误，后续凭证操作可以继续执行，避免一次失败卡死退出。
    late final Future<void> settled;
    settled = next
        .catchError((Object error, StackTrace stackTrace) {
          logger.error('AccountStore', '当前账号凭证写入失败', error, stackTrace);
        })
        .whenComplete(() {
          // 空队列不保留旧调度区的 Future，下一次写入使用调用方当前的异步时钟。
          if (identical(_activeWrite, settled)) _activeWrite = null;
        });
    _activeWrite = settled;
    return next;
  }

  /// 两阶段提交的候选凭证（B 认证成功后、ActiveCredential 提交前落盘）。
  Future<ActiveCredential?> loadPending() async {
    try {
      final raw = await pendingStore.read();
      if (raw == null || raw.isEmpty) return null;
      return ActiveCredential.decode(raw);
    } catch (error, stackTrace) {
      // 读失败不等于"没有候选"：候选槽可能还留着未撤销的 refresh token。
      // 语义仍按无候选降级（启动恢复下次会重试），但失败必须留痕。
      logger.error('AccountStore', '读取候选凭证失败，本次按无候选处理', error, stackTrace);
      return null;
    }
  }

  /// 写入候选凭证槽；启动恢复会把未提交候选移入服务端撤销待办。
  ///
  /// 辅助槽位写失败不阻断主流程（ActiveCredential 原子写入才是提交闸门），
  /// 失败保存在 lastError 供诊断；不可用平台不阻断登录。
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

  /// 读取当前列表格式的待撤销会话，保留多次离线换号的材料。
  Future<List<LogoutMarker>> loadLogoutMarkers() async {
    try {
      final raw = await logoutMarkerStore.read();
      if (raw == null || raw.isEmpty) return [];
      final value = jsonDecode(raw);
      if (value is! List) throw const FormatException('待撤销凭证必须是列表');
      final values = value;
      return values.map((value) {
        final marker = LogoutMarker.decode(jsonEncode(value));
        if (marker == null) throw const FormatException('待撤销凭证格式无效');
        return marker;
      }).toList();
    } catch (error, stackTrace) {
      logger.error('AccountStore', '读取待撤销会话失败', error.runtimeType, stackTrace);
      rethrow;
    }
  }

  /// 在清除当前凭证前持久化撤销材料；写失败必须阻止材料丢失。
  Future<void> saveLogoutMarker(LogoutMarker marker) =>
      _updateLogoutMarkers((markers) {
        if (!markers.any(
          (entry) =>
              entry.credential.refreshToken == marker.credential.refreshToken,
        )) {
          markers.add(marker);
        }
      });

  /// 原子替换轮换后的撤销材料，避免撤销失败后只剩已失效的旧令牌。
  Future<void> replaceLogoutMarker(
    ActiveCredential previous,
    ActiveCredential next,
  ) => _updateLogoutMarkers((markers) {
    markers.removeWhere(
      (entry) => entry.credential.refreshToken == previous.refreshToken,
    );
    markers.add(LogoutMarker(credential: next));
  });

  /// 只删除服务端已确认完成的会话，其余待撤销材料继续保留。
  Future<void> clearLogoutMarker(ActiveCredential credential) =>
      _updateLogoutMarkers((markers) {
        markers.removeWhere(
          (entry) => entry.credential.refreshToken == credential.refreshToken,
        );
      });

  /// 串行读改写安全槽位，避免启动恢复和新账号退出覆盖彼此的待办。
  Future<void> _updateLogoutMarkers(void Function(List<LogoutMarker>) update) {
    final next = (_markerWrite ?? Future<void>.value()).then((_) async {
      try {
        final markers = await loadLogoutMarkers();
        update(markers);
        if (markers.isEmpty) {
          await logoutMarkerStore.delete();
        } else {
          await logoutMarkerStore.write(
            jsonEncode(
              markers.map((marker) => jsonDecode(marker.encode())).toList(),
            ),
          );
        }
      } catch (error, stackTrace) {
        _lastError = (error, stackTrace);
        logger.error(
          'AccountStore',
          '保存待撤销会话失败',
          error.runtimeType,
          stackTrace,
        );
        throw StateError('退出信息保存失败，请稍后重试');
      }
    });
    late final Future<void> settled;
    settled = next.catchError((Object _) {}).whenComplete(() {
      if (identical(_markerWrite, settled)) _markerWrite = null;
    });
    _markerWrite = settled;
    return next;
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
