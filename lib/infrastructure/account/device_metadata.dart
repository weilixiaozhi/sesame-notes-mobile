import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/logging/logger_service.dart';

/// 设备资料只包含非唯一的系统型号、系统版本和应用版本，不包含硬件身份。
class DeviceMetadata {
  /// 不可读取的资料保持为空，不使用猜测值填充。
  const DeviceMetadata({
    required this.platform,
    this.appVersion,
    this.osVersion,
    this.deviceModel,
  });

  final String platform;
  final String? appVersion;
  final String? osVersion;
  final String? deviceModel;

  /// 仅有真实非空资料才进入刷新正文，避免覆盖服务端已经记录的有效值。
  Map<String, String> toJson() => {
    'platform': platform,
    'app_version': ?appVersion,
    'os_version': ?osVersion,
    'device_model': ?deviceModel,
  };
}

/// 登录、注册和会话恢复共用实时资料读取器；独立读取失败不妨碍认证。
class DeviceMetadataReader {
  /// 原生通道和版本读取可分别替换，测试不依赖真机或插件平台实现。
  DeviceMetadataReader({
    Future<Map<Object?, Object?>?> Function()? nativeReader,
    Future<String?> Function()? appVersionReader,
    String Function()? platformReader,
  }) : _nativeReader = nativeReader ?? _readNative,
       _appVersionReader = appVersionReader ?? _readAppVersion,
       _platformReader = platformReader ?? _platform;

  static const _channel = MethodChannel('com.sesame_notes.device_metadata');
  final Future<Map<Object?, Object?>?> Function() _nativeReader;
  final Future<String?> Function() _appVersionReader;
  final String Function() _platformReader;

  /// 每次认证重新读取当前应用和系统版本，升级后的既有设备可以自动补齐资料。
  Future<DeviceMetadata> read() async {
    var platform = _platform();
    try {
      final current = _platformReader().trim();
      if (current.isNotEmpty) platform = current;
    } catch (error, stackTrace) {
      logger.error(
        'DeviceMetadata',
        '设备平台资料暂时无法读取，继续使用运行环境',
        error.runtimeType,
        stackTrace,
      );
    }
    String? appVersion;
    String? osVersion;
    String? deviceModel;
    try {
      appVersion = _clean(
        await _appVersionReader().timeout(const Duration(seconds: 2)),
        64,
      );
    } catch (error, stackTrace) {
      logger.error(
        'DeviceMetadata',
        '应用版本暂时无法读取，继续认证',
        error.runtimeType,
        stackTrace,
      );
    }
    if (platform == 'android' || platform == 'ios') {
      try {
        final native = await _nativeReader().timeout(
          const Duration(seconds: 2),
        );
        osVersion = _clean(native?['os_version'], 64);
        deviceModel = _clean(native?['device_model'], 128);
      } catch (error, stackTrace) {
        logger.error(
          'DeviceMetadata',
          '设备系统资料暂时无法读取，继续认证',
          error.runtimeType,
          stackTrace,
        );
      }
    } else if (platform != 'web' && !kIsWeb) {
      osVersion = _clean(Platform.operatingSystemVersion, 64);
    }
    return DeviceMetadata(
      platform: platform,
      appVersion: appVersion,
      osVersion: osVersion,
      deviceModel: deviceModel,
    );
  }

  /// 原生侧仅返回型号与系统版本，不读取安装标识、序列号或其他唯一硬件字段。
  static Future<Map<Object?, Object?>?> _readNative() =>
      _channel.invokeMapMethod<Object?, Object?>('readDeviceMetadata');

  /// 应用版本与构建号使用已安装的版本插件读取，不使用写死的版本常量。
  static Future<String?> _readAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    final version = info.version.trim();
    final build = info.buildNumber.trim();
    if (version.isEmpty) return null;
    return build.isEmpty ? version : '$version+$build';
  }

  /// 平台来自实际运行环境；网页和桌面不伪造手机型号。
  static String _platform() => kIsWeb ? 'web' : Platform.operatingSystem;

  /// 空白、未知和非字符串资料不传输，长度与服务端现有字段约束保持一致。
  static String? _clean(Object? raw, int maxLength) {
    if (raw is! String) return null;
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'unknown') return null;
    return value.length <= maxLength ? value : value.substring(0, maxLength);
  }
}
