import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';

import '../utils/logger.dart';
import '../utils/path_helper.dart';
import 'exceptions.dart';

/// 云端存储中的文件。
@immutable
class CloudFile {
  /// 文件名。
  final String name;

  /// 相对于当前存储范围的逻辑路径，可直接传给下载与删除。
  final String path;

  /// 文件大小（字节，可选）。
  final int? size;

  /// 最后修改时间（可选）。
  final DateTime? lastModified;

  /// 后端原生对象属性（可选）。
  ///
  /// 可包含内容类型、存储标识或对象版本等信息。
  final Map<String, dynamic>? metadata;

  const CloudFile({
    required this.name,
    required this.path,
    this.size,
    this.lastModified,
    this.metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudFile &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'CloudFile(name: $name, path: $path, size: $size)';
}

/// 云备份文件存储能力；文件正文必须逐块传输，不把整份备份载入内存。
abstract class CloudStorageService {
  /// 条件创建文件；同名对象抛出 CloudFileAlreadyExistsException，绝不覆盖。
  /// 可选属性由支持的后端原生保存，不要求额外表或旁路文件。
  Future<void> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
  });

  /// 下载到调用方的隔离文件；不存在返回 false，失败不得留下半文件。
  Future<bool> downloadFile({required String path, required File destination});

  /// 从云端存储删除文件。
  ///
  /// [path] - 文件路径。
  ///
  /// 删除失败时抛出 [CloudStorageException]。
  /// 应具备幂等性（文件不存在时不报错）。
  Future<void> delete({required String path});

  /// 列出目录下的文件。
  ///
  /// [path] - 目录路径（如 'users/123/'），空字符串表示配置存储范围的根目录。
  ///
  /// 返回目录及其子目录内的文件列表，不包含目录本身。
  /// 失败时抛出 [CloudStorageException]。
  Future<List<CloudFile>> list({required String path});
}

/// 无法证明后端支持对象身份条件时，保留用户对象并交由存储管理器处理。
class CloudConditionalDeleteUnsupportedException implements Exception {
  const CloudConditionalDeleteUnsupportedException();

  @override
  String toString() => '当前存储服务无法确认安全删除能力，请使用云端管理器核对';
}

/// 清理工具可选的条件删除能力，普通保留策略仍使用原文件存储接口。
abstract interface class CloudConditionalDeleteStorage {
  /// 只通过本次独占创建的空探针验证条件，不使用用户备份试探服务行为。
  Future<void> verifyConditionalDelete({required String prefix});

  /// 条件读取把原始字节绑定到列举时的对象身份，不接受条件失败后的普通读取。
  Future<bool> downloadIfMatch({
    required String path,
    required File destination,
    required String expectedETag,
  });

  /// 原子要求对象仍具有同一强 ETag；身份变化必须失败，不能退成无条件删除。
  Future<void> deleteIfMatch({
    required String path,
    required String expectedETag,
  });
}

/// 强 ETag 必须是明确的非空引号标记，不接受弱标记、通配符或头部控制字符。
bool isStrongCloudETag(Object? value) =>
    value is String && RegExp(r'^"[\x21\x23-\x7e\x80-\xff]+"$').hasMatch(value);

/// 验证错误读取和删除条件都返回 412 且探针保持原样，再验证正确条件能够读取和删除。
/// 本函数仅拥有新建的随机空对象，任何失败都不会对用户对象做无条件删除。
Future<void> verifyCloudConditionalDelete({
  required CloudStorageService storage,
  required CloudConditionalDeleteStorage conditional,
  required String prefix,
  CloudSyncLogger? logger,
}) async {
  Directory? temporary;
  String? probePath, probeETag;
  var ownsProbe = false;

  /// 日志只保留错误类型和位置，不输出存储地址、认证材料或用户对象路径。
  void warn(String message, Object error, StackTrace stack) {
    try {
      logger?.warning('$message：${error.runtimeType}\n$stack');
    } catch (_) {
      // 日志回调不得覆盖原始安全拒绝或清理结果。
    }
  }

  /// 只读取本次随机路径，重复、缺失身份或非空内容都不能证明探针仍归本次任务。
  Future<CloudFile?> probe() async {
    final matches = (await storage.list(path: prefix))
        .where((file) => file.path == probePath)
        .toList();
    if (matches.isEmpty) return null;
    if (matches.length != 1) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    return matches.single;
  }

  try {
    if (!PathHelper.isSafeRelativePath(prefix) ||
        prefix.contains('\\') ||
        prefix.contains('//') ||
        RegExp(r'[%?#:\x00-\x1f\x7f]').hasMatch(prefix)) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    final random = Random.secure();
    final nonce = List.generate(
            24, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'))
        .join();
    probePath =
        '${PathHelper.normalize(prefix)}/.sesame_cleanup_probe_$nonce.tmp';
    temporary = await Directory.systemTemp.createTemp('cloud-delete-probe-');
    final empty = await File('${temporary.path}/empty').writeAsBytes(const []);
    if (await probe() != null) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    await storage.uploadFile(path: probePath, file: empty, metadata: {
      'app': 'sesame_notes',
      'format': 'cleanup_probe',
      'probe_id': nonce,
    });
    ownsProbe = true;
    final created = await probe();
    final tag = created?.metadata?['etag'];
    if (created?.size != 0 || !isStrongCloudETag(tag)) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    probeETag = tag as String;
    var unmatched = '"cleanup-unmatched-$nonce"';
    if (unmatched == probeETag) unmatched = '"cleanup-other-$nonce"';
    var rejectedRead = false;
    try {
      await conditional.downloadIfMatch(
        path: probePath,
        destination: File('${temporary.path}/wrong-read'),
        expectedETag: unmatched,
      );
    } on CloudStorageException catch (error) {
      if (error.statusCode != 412) rethrow;
      rejectedRead = true;
    }
    final checked = File('${temporary.path}/checked');
    if (!rejectedRead ||
        !await conditional.downloadIfMatch(
          path: probePath,
          destination: checked,
          expectedETag: probeETag,
        ) ||
        await checked.length() != 0) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    var rejected = false;
    try {
      await conditional.deleteIfMatch(
        path: probePath,
        expectedETag: unmatched,
      );
    } on CloudStorageException catch (error) {
      if (error.statusCode != 412) rethrow;
      rejected = true;
    }
    final retained = await probe();
    if (!rejected ||
        retained?.size != 0 ||
        retained?.metadata?['etag'] != probeETag) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    await conditional.deleteIfMatch(path: probePath, expectedETag: probeETag);
    if (await probe() != null) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    ownsProbe = false;
  } on CloudFileAlreadyExistsException {
    // 条件创建冲突说明本次没有该对象的所有权，不能清理碰撞路径。
    throw const CloudConditionalDeleteUnsupportedException();
  } catch (error, stack) {
    warn('条件删除能力验证未完成，用户备份保持原样', error, stack);
    rethrow;
  } finally {
    if (ownsProbe && probePath != null && probeETag != null) {
      try {
        final remaining = await probe();
        if (remaining?.size == 0 && remaining?.metadata?['etag'] == probeETag) {
          await conditional.deleteIfMatch(
              path: probePath, expectedETag: probeETag);
        }
      } catch (error, stack) {
        warn('自有空探针暂未清理，保留不明身份对象', error, stack);
      }
    }
    if (temporary != null) {
      try {
        await temporary.delete(recursive: true);
      } catch (error, stack) {
        warn('条件删除检查临时目录清理失败', error, stack);
      }
    }
  }
}
