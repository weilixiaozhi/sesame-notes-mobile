import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';

/// 文件选择器辅助工具类
///
/// 提供对 FilePicker 的封装，处理部分 Android 设备不支持扩展名过滤的问题。
class FilePickerHelper {
  FilePickerHelper._();

  /// 选择指定扩展名的文件
  ///
  /// [allowedExtensions] - 允许的文件扩展名列表（不含点号），如 ['csv', 'json']
  ///
  /// 部分 Android 设备不支持扩展名过滤，会抛出 PlatformException。
  /// 此方法会自动 fallback 到选择任意文件，然后手动验证扩展名。
  ///
  /// 如果用户取消选择，返回 null。
  /// 如果选择的文件扩展名不匹配，抛出 [FileExtensionException]。
  static Future<PlatformFile?> pickFileWithExtensions({
    required List<String> allowedExtensions,
  }) async {
    PlatformFile? result;

    try {
      // 尝试使用扩展名过滤
      result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );
    } on PlatformException catch (e) {
      // 设备不支持扩展名过滤，fallback 到选择任意文件
      logger.warning('FilePickerHelper', '设备不支持扩展名过滤，fallback 到选择任意文件: $e');
      result = await FilePicker.pickFile(type: FileType.any);
    }

    // 用户取消选择
    if (result == null) return null;

    // 验证扩展名
    final fileName = result.name.toLowerCase();
    final hasValidExtension = allowedExtensions.any(
      (ext) => fileName.endsWith('.${ext.toLowerCase()}'),
    );

    if (!hasValidExtension) {
      throw FileExtensionException(
        expectedExtensions: allowedExtensions,
        actualPath: result.path ?? result.name,
      );
    }

    return result;
  }
}

/// 文件扩展名不匹配异常
class FileExtensionException implements Exception {
  final List<String> expectedExtensions;
  final String actualPath;

  FileExtensionException({
    required this.expectedExtensions,
    required this.actualPath,
  });

  @override
  String toString() {
    final extensionsText = expectedExtensions.map((e) => '.$e').join(', ');
    return '请选择以下格式的文件：$extensionsText';
  }
}
