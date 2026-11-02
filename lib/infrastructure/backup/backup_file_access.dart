import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 文件正在读取或清理时拒绝冲突操作，调用方可保留原文件后稍后重试。
class BackupFileBusyException implements Exception {
  const BackupFileBusyException();

  @override
  String toString() => '备份文件正在使用，请稍后重试';
}

/// 同一进程的快照读取和删除预约共享身份，异步文件操作期间也不会相互穿插。
class BackupFileAccess {
  BackupFileAccess._();
  static final _readers = <String, int>{};
  static final _deleting = <String>{};

  /// 供保留策略跳过在途快照，读取与删除均占用该身份。
  static bool isInUse(String key) =>
      _readers.containsKey(key) || _deleting.contains(key);

  /// 同步领取读取租约后才开始异步任务，删除预约存在时不再打开原文件。
  static Future<T> read<T>(String key, Future<T> Function() action) async {
    if (_deleting.contains(key)) throw const BackupFileBusyException();
    _readers.update(key, (count) => count + 1, ifAbsent: () => 1);
    try {
      return await action();
    } finally {
      final count = _readers[key]! - 1;
      if (count == 0) {
        _readers.remove(key);
      } else {
        _readers[key] = count;
      }
    }
  }

  /// 删除前同步预约身份，预约期间拒绝新的读取，结束后始终释放预约。
  static Future<T> delete<T>(String key, Future<T> Function() action) async {
    if (isInUse(key)) throw const BackupFileBusyException();
    _deleting.add(key);
    try {
      return await action();
    } finally {
      _deleting.remove(key);
    }
  }
}

/// 配置完整身份只使用摘要参与内存隔离，不把地址、账号或凭据写入日志。
String cloudBackupScopeKey(CloudServiceConfig config) {
  try {
    return '${config.backendId}:${sha256.convert(utf8.encode(jsonEncode(_canonical(config.settings))))}';
  } catch (_) {
    throw StateError('云备份配置无法核验，请重新打开备份管理');
  }
}

/// 对设置键稳定排序，使同一份持久配置不因 JSON 键顺序不同而改变身份。
Object? _canonical(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _canonical(value[key])};
  }
  if (value is List) return value.map(_canonical).toList();
  return value;
}

/// 云端配置根与逻辑对象路径共同确定读取和删除身份。
String cloudBackupFileKey(String scope, String path) => 'cloud:$scope:$path';
