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

  /// 进程内已确定的 localSelfId Future，所有调用共用同一次生成/恢复。
  static Future<String>? _cached;

  /// 串行化操作队列尾部，保证 getOrCreate 与 restoreIfAbsent 不会并发读写。
  static Future<void> _operationTail = Future<void>.value();

  /// 将操作追加到串行队列，避免并发首调各自生成不同 UUID。
  static Future<T> _runExclusive<T>(Future<T> Function() action) {
    final result = _operationTail.then((_) => action());
    _operationTail = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  static bool _isValidUuid(String value) => _uuidV4Pattern.hasMatch(value);

  static void _cacheValue(String value) {
    _cached = Future<String>.value(value);
  }

  /// 仅测试用：清空进程内静态缓存，使下一次调用重新走 prefs 路径。
  ///
  /// `_cached` 与 `_operationTail` 是进程级状态，随机顺序批量跑测试时，
  /// 前一个用例（如 restoreIfAbsent）会写入缓存，污染后续 getOrCreate 的断言；
  /// 测试 setUp 调用本方法即可保证每个用例从干净基线起步。生产代码不调用。
  @visibleForTesting
  static void resetForTest() {
    _cached = null;
    _operationTail = Future<void>.value();
  }

  /// 读取或生成 localSelfId。
  ///
  /// 首次调用时 prefs 无值 → 生成 UUID 并持久化；后续直接返回已存值。
  /// 进程内缓存 Future，并发首次调用共用同一次生成；写入失败会降级为
  /// 内存 UUID 并记录错误，而不是静默当作成功返回。
  static Future<String> getOrCreate() {
    final cached = _cached;
    if (cached != null) return cached;

    final future = _runExclusive<String>(() async {
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
    });
    _cached = future;
    return future;
  }

  /// 读取已持久化的 localSelfId（不生成）。
  ///
  /// 供备份/恢复等「只读不写」场景使用；未设置时返回 null。
  static Future<String?> read() {
    return _runExclusive<String?>(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getString(prefsKey);
        if (existing == null) return null;
        if (!_isValidUuid(existing)) {
          logger.warning('LocalSelfId', '检测到非法 localSelfId，read 返回 null');
          return null;
        }
        return existing;
      } catch (e, st) {
        logger.warning('LocalSelfId', '读取 prefs 失败', '$e\n$st');
        return null;
      }
    });
  }

  /// 写入指定 localSelfId（恢复备份用）。
  ///
  /// 仅当当前无值时写入，避免覆盖设备已有身份导致旧记录解析错位。
  static Future<void> restoreIfAbsent(String value) {
    return _runExclusive<void>(() async {
      // 恢复值必须是合法 UUID v4，损坏的备份数据不允许写入 prefs。
      if (!_isValidUuid(value)) {
        logger.error('LocalSelfId', '拒绝恢复非法 localSelfId: $value');
        return;
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final existing = prefs.getString(prefsKey);
        if (existing != null && _isValidUuid(existing)) {
          _cacheValue(existing);
          return;
        }
        if (existing != null && existing.isNotEmpty) {
          logger.warning('LocalSelfId', '检测到非法已存 localSelfId，将用备份值覆盖');
        }

        final saved = await prefs.setString(prefsKey, value);
        if (!saved) {
          throw StateError('SharedPreferences.setString 返回 false');
        }
        _cacheValue(value);
        logger.info('LocalSelfId', '从备份恢复 localSelfId');
      } catch (e, st) {
        logger.warning('LocalSelfId', '恢复 localSelfId 失败', '$e\n$st');
      }
    });
  }
}
