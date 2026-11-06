import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/shared/services/notification/notification_factory.dart';

/// 在仓库根目录的 Temp 中创建唯一测试目录，调用方在 tearDown 中清理。
Future<Directory> createTestTempDirectory(String prefix) async {
  try {
    final root = Directory('Temp').absolute;
    await root.create(recursive: true);
    // 系统为前缀补上随机后缀，使并行测试拥有独立的文件工作区。
    return await root.createTemp(prefix);
  } catch (error, stackTrace) {
    stderr.writeln('无法创建测试临时目录，请检查项目 Temp 目录的读写权限。');
    stderr.writeln(
      '测试目录创建失败：prefix=$prefix，工作目录=${Directory.current.path}\n'
      '$error\n$stackTrace',
    );
    rethrow;
  }
}

/// 同步创建仓库 Temp 下的唯一测试目录，适用于同步 setUp 和文件夹具。
Directory createTestTempDirectorySync(String prefix) {
  try {
    final root = Directory('Temp').absolute;
    root.createSync(recursive: true);
    return root.createTempSync(prefix);
  } catch (error, stackTrace) {
    stderr.writeln('无法创建测试临时目录，请检查项目 Temp 目录的读写权限。');
    stderr.writeln(
      '测试目录创建失败：prefix=$prefix，工作目录=${Directory.current.path}\n'
      '$error\n$stackTrace',
    );
    rethrow;
  }
}

/// 将偏好与通知单例恢复为用例基线，隔离持久化和服务状态。
///
/// [initialPrefs] 提供当前用例的偏好初始数据，空映射表示清空。
void resetGlobalTestState({Map<String, Object> initialPrefs = const {}}) {
  try {
    SharedPreferences.setMockInitialValues(initialPrefs);
    NotificationFactory.reset();
  } catch (error, stackTrace) {
    stderr.writeln('无法重置测试初始状态，请检查偏好存储与服务配置。');
    stderr.writeln('测试状态重置失败：${error.runtimeType}\n$stackTrace');
    rethrow;
  }
}
