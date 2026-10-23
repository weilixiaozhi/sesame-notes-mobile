import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

class AppLockService {
  /// 应用锁开关 prefs 键（providers 层与测试统一引用，避免改名静默失联）。
  static const prefsKeyEnabled = 'app_lock_enabled';

  /// PIN 哈希 prefs 键。
  static const prefsKeyPinHash = 'app_lock_pin_hash';

  /// 生物识别开关 prefs 键。
  static const prefsKeyBiometricEnabled = 'app_lock_biometric_enabled';

  /// 超时秒数 prefs 键。
  static const prefsKeyTimeoutSeconds = 'app_lock_timeout_seconds';

  /// 最后进入后台时间 prefs 键。
  static const prefsKeyLastBackgroundTime = 'app_lock_last_background_time';

  /// 连续失败次数 prefs 键。
  static const prefsKeyFailedAttempts = 'app_lock_failed_attempts';

  /// 锁定截止时间戳 prefs 键。
  static const prefsKeyLockedUntil = 'app_lock_locked_until';

  /// 连续输错达到该次数后进入锁定窗口。
  static const _maxAttempts = 5;

  /// 锁定窗口时长。
  static const _lockDuration = Duration(seconds: 30);

  /// PIN 哈希版本前缀（PBKDF2-HMAC-SHA256）。
  static const _pinHashVersion = 'pbkdf2_sha256';

  /// PBKDF2 迭代次数：4~6 位数字 PIN 空间小，必须加盐 + 迭代抗离线破解。
  static const _pinIterations = 100000;

  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// 最近一次解锁时间（内存中，防止解锁后立即被 resumed 事件重新锁定）
  static DateTime? _lastUnlockTime;

  /// 记录解锁时间
  static void recordUnlock() {
    _lastUnlockTime = DateTime.now();
    logger.info('AppLock', '已记录解锁时间');
  }

  /// 加盐 + PBKDF2-HMAC-SHA256 哈希 PIN 码。
  ///
  /// 输出格式：`pbkdf2_sha256$迭代次数$盐(base64)$哈希(base64)`。
  /// 每次设置 PIN 都会生成新盐，同 PIN 两次哈希结果不同。
  static String hashPin(String pin) {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = _pbkdf2Sha256(pin, salt, _pinIterations);
    return '$_pinHashVersion\$$_pinIterations\$'
        '${base64Encode(salt)}\$${base64Encode(hash)}';
  }

  /// 保存 PIN 和开启标记，全部存储步骤成功后才完成设置动作。
  static Future<void> setPin(String pin) async {
    await _writePreferences((prefs) async {
      _requireSaved(await prefs.setString(prefsKeyPinHash, hashPin(pin)));
      _requireSaved(await prefs.setBool(prefsKeyEnabled, true));
      await _resetFailures(prefs);
    });
    logger.info('AppLock', 'PIN已设置');
  }

  /// 验证 PIN 码
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(prefsKeyPinHash);
    if (savedHash == null) return false;
    if (await isLocked()) return false;

    final ok = _verifyHash(pin, savedHash);
    if (ok) {
      await _resetFailures(prefs);
    } else {
      await _recordFailure(prefs);
    }
    return ok;
  }

  /// 是否处于输错锁定窗口。
  static Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(prefsKeyLockedUntil) ?? 0;
    return DateTime.now().millisecondsSinceEpoch < until;
  }

  /// 清除 PIN 码并禁用锁定
  static Future<void> clearPin() async {
    await _writePreferences((prefs) async {
      _requireSaved(await prefs.remove(prefsKeyPinHash));
      _requireSaved(await prefs.setBool(prefsKeyEnabled, false));
      _requireSaved(await prefs.setBool(prefsKeyBiometricEnabled, false));
      await _resetFailures(prefs);
    });
    logger.info('AppLock', 'PIN已清除，应用锁已禁用');
  }

  /// 是否有已保存的 PIN
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(prefsKeyPinHash) != null;
  }

  /// 只保存开关值，创建与清除 PIN 使用各自的复合动作。
  static Future<void> setEnabled(bool enabled) async {
    await _writePreferences((prefs) async {
      _requireSaved(await prefs.setBool(prefsKeyEnabled, enabled));
    });
    logger.info('AppLock', '应用锁: ${enabled ? "开启" : "关闭"}');
  }

  /// 是否已启用生物识别
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKeyBiometricEnabled) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _writePreferences((prefs) async {
      _requireSaved(await prefs.setBool(prefsKeyBiometricEnabled, enabled));
    });
    logger.info('AppLock', '生物识别: ${enabled ? "开启" : "关闭"}');
  }

  /// 设置超时时间（秒）
  static Future<void> setTimeoutSeconds(int seconds) async {
    await _writePreferences((prefs) async {
      _requireSaved(await prefs.setInt(prefsKeyTimeoutSeconds, seconds));
    });
    logger.info('AppLock', '超时时间设置: ${seconds}s');
  }

  /// 记录进入后台时间
  static Future<void> recordBackgroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    _requireSaved(
      await prefs.setInt(
        prefsKeyLastBackgroundTime,
        DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 检查从后台恢复是否需要锁定
  static Future<bool> shouldLockOnResume() async {
    // 刚解锁后短时间内不重新锁定（防止 Face ID/PIN 解锁后
    // 因系统弹窗导致的 resumed 事件触发重新锁定）
    if (_lastUnlockTime != null &&
        DateTime.now().difference(_lastUnlockTime!) <
            const Duration(seconds: 3)) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(prefsKeyEnabled) ?? false;
    if (!enabled) return false;

    final lastBgTime = prefs.getInt(prefsKeyLastBackgroundTime);
    if (lastBgTime == null) return false;

    final timeoutSeconds = prefs.getInt(prefsKeyTimeoutSeconds) ?? 0;
    if (timeoutSeconds == 0) return true; // 立即锁定

    final elapsed = DateTime.now().millisecondsSinceEpoch - lastBgTime;
    return elapsed >= timeoutSeconds * 1000;
  }

  /// 检查设备是否支持生物识别
  static Future<bool> canUseBiometrics() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuth && isDeviceSupported;
    } catch (e) {
      logger.error('AppLock', '检查生物识别支持失败', e);
      return false;
    }
  }

  /// 执行生物识别认证
  static Future<bool> authenticateWithBiometrics({
    String reason = '请验证身份以解锁应用',
  }) async {
    try {
      // 以命名参数指定认证选项：仅生物识别 + 跨前后台保持认证状态
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (e) {
      logger.error('AppLock', '生物识别认证失败', e);
      return false;
    }
  }

  /// 校验 PBKDF2-HMAC-SHA256 哈希，格式无效时拒绝验证。
  static bool _verifyHash(String pin, String savedHash) {
    if (savedHash.startsWith('$_pinHashVersion\$')) {
      try {
        final parts = savedHash.split('\$');
        if (parts.length != 4) return false;
        final iterations = int.tryParse(parts[1]);
        if (iterations == null || iterations < 1) return false;
        final salt = base64Decode(parts[2]);
        final expected = base64Decode(parts[3]);
        final actual = _pbkdf2Sha256(pin, salt, iterations);
        if (actual.length != expected.length) return false;
        // 恒定时间比较，避免时序侧信道。
        var diff = 0;
        for (var i = 0; i < actual.length; i++) {
          diff |= actual[i] ^ expected[i];
        }
        return diff == 0;
      } catch (e, st) {
        // 记录异常类型和位置，避免在日志中暴露哈希与盐。
        logger.error('AppLock', 'PIN 哈希解析失败（${e.runtimeType}）', null, st);
        return false;
      }
    }
    return false;
  }

  /// PBKDF2-HMAC-SHA256 实现（输出 32 字节）。
  static List<int> _pbkdf2Sha256(
    String password,
    List<int> salt,
    int iterations,
  ) {
    final hmac = Hmac(sha256, utf8.encode(password));
    // 只取 1 个块：SHA-256 输出 32 字节，已覆盖 256 位强度。
    final blockIndex = 1;
    final u1 = <int>[
      ...salt,
      (blockIndex >> 24) & 0xff,
      (blockIndex >> 16) & 0xff,
      (blockIndex >> 8) & 0xff,
      blockIndex & 0xff,
    ];
    var previous = hmac.convert(u1).bytes;
    var result = List<int>.from(previous);
    for (var i = 1; i < iterations; i++) {
      previous = hmac.convert(previous).bytes;
      result = List<int>.generate(
        result.length,
        (j) => result[j] ^ previous[j],
      );
    }
    return result;
  }

  /// 记录一次验证失败；达到阈值后进入锁定窗口。
  static Future<void> _recordFailure(SharedPreferences prefs) async {
    final attempts = (prefs.getInt(prefsKeyFailedAttempts) ?? 0) + 1;
    _requireSaved(await prefs.setInt(prefsKeyFailedAttempts, attempts));
    if (attempts >= _maxAttempts) {
      final lockedUntil = DateTime.now()
          .add(_lockDuration)
          .millisecondsSinceEpoch;
      _requireSaved(await prefs.setInt(prefsKeyLockedUntil, lockedUntil));
      logger.warning('AppLock', '连续输错 $_maxAttempts 次，锁定 $_lockDuration');
    } else {
      logger.warning('AppLock', 'PIN 验证失败($attempts/$_maxAttempts)');
    }
  }

  /// 清空失败计数与锁定窗口（设置新 PIN / 验证成功 / 清除 PIN 时调用）。
  static Future<void> _resetFailures(SharedPreferences prefs) async {
    _requireSaved(await prefs.remove(prefsKeyFailedAttempts));
    _requireSaved(await prefs.remove(prefsKeyLockedUntil));
  }

  /// 平台返回 false 时拒绝宣告保存成功。
  static void _requireSaved(bool saved) {
    if (!saved) throw StateError('应用锁设置未能保存，请稍后重试');
  }

  /// 写入失败后重读存储事实，避免插件的临时缓存影响恢复前台的锁定判断。
  static Future<void> _writePreferences(
    Future<void> Function(SharedPreferences prefs) write,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      await write(prefs);
    } catch (error, stackTrace) {
      try {
        await prefs.reload();
      } catch (reloadError, reloadStackTrace) {
        logger.error('AppLock', '应用锁存储事实重读失败', reloadError, reloadStackTrace);
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
