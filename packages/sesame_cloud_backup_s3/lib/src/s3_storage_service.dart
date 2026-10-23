import 'dart:io';

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 's3_client.dart';
import 's3_exceptions.dart';

/// S3 存储服务实现
class S3StorageService implements CloudStorageService {
  final S3Client client;
  final String bucket;
  final CloudSyncLogger? _logger;

  /// 复用后端连接，并把文件与元数据故障交给统一诊断边界。
  S3StorageService(this.client, this.bucket, {CloudSyncLogger? logger})
      : _logger = logger;

  /// 文件上传使用经过校验的逻辑路径，并按条件创建对象。
  @override
  Future<void> uploadFile(
      {required String path,
      required File file,
      Map<String, String>? metadata}) async {
    try {
      await client.putFile(
          bucket: bucket,
          key: _normalizePath(path),
          file: file,
          metadata: metadata);
    } catch (error, stackTrace) {
      if (error is CloudFileAlreadyExistsException) rethrow;
      _fail('文件上传', error, stackTrace);
    }
  }

  /// 下载流式写文件，404 返回 false。
  @override
  Future<bool> downloadFile(
      {required String path, required File destination}) async {
    try {
      return await client.getFile(
          bucket: bucket, key: _normalizePath(path), destination: destination);
    } catch (error, stackTrace) {
      _fail('文件下载', error, stackTrace);
    }
  }

  /// 删除指定逻辑路径的对象，缺失对象由客户端按幂等成功处理。
  @override
  Future<void> delete({required String path}) async {
    try {
      await client.deleteObject(
        bucket: bucket,
        key: _normalizePath(path),
      );
    } on S3Exception catch (e, stackTrace) {
      _fail('删除', e, stackTrace);
    } catch (e, stackTrace) {
      _fail('删除', e, stackTrace);
    }
  }

  /// 只有完整列举才能交给备份选择和清理，协议失败保留原始原因供调用边界记录。
  @override
  Future<List<CloudFile>> list({required String path}) async {
    try {
      // 空目录代表桶根，非空目录仍按相对路径规则校验。
      final prefix = path.isEmpty ? '' : _normalizePath(path);
      final files = await client.listObjects(
        bucket: bucket,
        // 存储接口接受目录路径；分隔符保证 backups 不会同时列出 backups-other。
        prefix: prefix.isEmpty
            ? null
            : prefix.endsWith('/')
                ? prefix
                : '$prefix/',
      );
      return files
          .where((info) => !info.key.endsWith('/'))
          .map((info) => CloudFile(
                name: info.key,
                path: info.key,
                size: info.size,
                lastModified: info.lastModified,
              ))
          .toList();
    } catch (e, stackTrace) {
      throwCloudStorageFailure(
        provider: 'S3',
        operation: '列举文件',
        message: '无法读取云端备份列表，请检查存储服务后重试',
        error: e,
        stackTrace: stackTrace,
        logger: _logger,
        statusCode: e is S3Exception ? e.statusCode : null,
      );
    }
  }

  /// 校验相对对象路径，并拒绝路径穿越。
  ///
  /// S3 的 Key 不应该以 / 开头，也不得包含 `..` / `.` 段，
  /// 防止业务层误传越权路径。
  String _normalizePath(String path) {
    if (!PathHelper.isSafeRelativePath(path)) {
      throw CloudStorageException('Invalid path: $path');
    }
    return path;
  }

  /// 只向日志输出稳定阶段、错误类型、状态码和原始堆栈。
  Never _fail(String operation, Object error, StackTrace stackTrace) =>
      throwCloudStorageFailure(
        provider: 'S3',
        operation: operation,
        message: '云端备份$operation失败，请重试',
        error: error,
        stackTrace: stackTrace,
        logger: _logger,
        statusCode: error is S3Exception ? error.statusCode : null,
      );
}
