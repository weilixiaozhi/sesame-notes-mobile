import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// 本地设备身份（localSelfId）持久化服务。
///
/// 设计意图：localSelfId 是每台设备首次启动生成一次并持久化的稳定标识，
/// 作为本地账本「我」成员（LOCAL self member）的派生键——
/// member_id = uuidV5(ledgerId, localSelfId)，同账本稳定、跨账本不同。
/// 登录/退出只改变成员行的账号绑定，不改写任何历史账务身份。
class LocalSelfId {
  LocalSelfId._();

  /// SharedPreferences 存储 key。
  static const String prefsKey = 'local_self_id';

  static const _uuid = Uuid();

  /// UUID v4 格式校验（兼容大写）。
  static final RegExp _uuidV4Pattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );

  /// 进程内已确定的 localSelfId Future，所有调用共用同一次读取或生成。
  static Future<String>? _cached;

  static bool _isValidUuid(String value) => _uuidV4Pattern.hasMatch(value);

  /// 清空进程内缓存，使每项测试独立读取 prefs。
  @visibleForTesting
  static void resetForTest() {
    _cached = null;
  }

  /// 读取或生成 localSelfId。
  ///
  /// 首次调用时 prefs 无值 → 生成 UUID 并持久化；后续直接返回已存值。
  /// 进程内缓存 Future，并发首次调用共用同一次生成；写入失败会降级为
  /// 内存 UUID 并记录错误，而不是静默当作成功返回。
  static Future<String> getOrCreate() {
    final cached = _cached;
    if (cached != null) return cached;

    final future = () async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getString(prefsKey);
        if (existing != null && _isValidUuid(existing)) {
          return existing;
        }
        if (existing != null && existing.isNotEmpty) {
          logger.warning('LocalSelfId', '检测到非法 localSelfId，重新生成');
        }

        final generated = _uuid.v4();
        final saved = await prefs.setString(prefsKey, generated);
        if (!saved) {
          throw StateError('SharedPreferences.setString 返回 false');
        }
        logger.info('LocalSelfId', '首次生成 localSelfId');
        return generated;
      } catch (e, st) {
        // prefs 不可用或写入失败时退化为内存 UUID（不持久化，仅本次运行有效）。
        // 这种情况极罕见，展示层仍可正常工作，下次启动重新生成。
        logger.error('LocalSelfId', '读取/写入 prefs 失败，退化为内存 UUID', e, st);
        return _uuid.v4();
      }
    }();
    _cached = future;
    return future;
  }
}
