library;

import 'dart:io' as io;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'webdav_errors.dart';

/// WebDAV implementation of [CloudStorageService].
class WebDAVStorageService implements CloudStorageService {
  final webdav.Client _client;
  final String _remotePath;
  final CloudSyncLogger? _logger;

  WebDAVStorageService(this._client, this._remotePath,
      {CloudSyncLogger? logger})
      : _logger = logger;

  /// 本地文件按流条件创建，远程目录由当前连接创建。
  @override
  Future<void> uploadFile(
      {required String path,
      required io.File file,
      Map<String, String>? metadata}) async {
    try {
      final fullPath = _buildPath(path);
      await _ensureDirectory(PathHelper.dirname(fullPath));
      // 先完成认证协商，避免服务器挑战使不可重复读取的文件流被重试。
      final options = await _client.c.wdOptions(_client, fullPath);
      if (options.statusCode != 200) {
        throw CloudStorageException('云端备份上传失败，请重试', null, options.statusCode);
      }
      final length = await file.length();
      // 条件创建头属于本次 PUT，不能修改共享连接选项，否则并发上传会互相撤销条件。
      final response = await _client.c.req<void>(
        _client,
        'PUT',
        fullPath,
        data: file.openRead(),
        optionsHandler: (options) {
          options.headers!['If-None-Match'] = '*';
          options.headers!['content-length'] = length;
        },
      );
      if (response.statusCode == 412) {
        throw const CloudFileAlreadyExistsException();
      }
      if (!const [200, 201, 204].contains(response.statusCode)) {
        throw CloudStorageException('云端备份上传失败，请重试', null, response.statusCode);
      }
    } catch (error, stackTrace) {
      if (error is CloudFileAlreadyExistsException) rethrow;
      if (webDavStatusCode(error) == 412) {
        throw const CloudFileAlreadyExistsException();
      }
      _fail('文件上传', error, stackTrace);
    }
  }

  /// 下载直接写隔离文件，404 与其他错误分别处理。
  @override
  Future<bool> downloadFile(
      {required String path, required io.File destination}) async {
    try {
      await _client.read2File(_buildPath(path), destination.path);
      return true;
    } catch (error, stackTrace) {
      try {
        if (await destination.exists()) await destination.delete();
      } catch (_) {
        // 清理失败不能覆盖需要诊断的原始下载错误。
      }
      if (_isNotFound(error)) return false;
      _fail('文件下载', error, stackTrace);
    }
  }

  @override
  Future<void> delete({required String path}) async {
    try {
      final fullPath = _buildPath(path);

      try {
        await _client.remove(fullPath);
      } catch (error) {
        // 对象已被其他操作删除时，继续完成可选的旧旁路文件清理。
        if (!_isNotFound(error)) rethrow;
      }
      await _deleteLegacyMetadata(fullPath);
    } catch (e, stackTrace) {
      _fail('删除', e, stackTrace);
    }
  }

  @override
  Future<List<CloudFile>> list({required String path}) async {
    try {
      // 空相对路径表示已配置的备份根目录，文件操作仍要求非空的安全路径。
      final fullPath = path.isEmpty ? _remotePath : _buildPath(path);

      // List files
      final files = await _client.readDir(fullPath);

      final result = <CloudFile>[];
      for (final file in files) {
        final name = file.name;
        if (name == null ||
            name.isEmpty ||
            name.contains('/') ||
            name.contains('\\') ||
            !PathHelper.isSafeRelativePath(name)) {
          continue;
        }
        final relative = PathHelper.join([path, name]);
        if (file.isDir == true) {
          result.addAll(await list(path: relative));
        } else if (!name.endsWith('.metadata.json')) {
          result.add(CloudFile(
              name: name,
              path: relative,
              size: file.size,
              lastModified: file.mTime,
              metadata: const {}));
        }
      }
      return result;
    } catch (e, stackTrace) {
      _fail('列举文件', e, stackTrace);
    }
  }

  /// Builds the full path with remote path prefix.
  String _buildPath(String path) {
    // 拒绝绝对路径与 .. 段，防止拼接 remotePath 后逃逸到其他目录。
    if (!PathHelper.isSafeRelativePath(path)) {
      throw CloudStorageException('Invalid path: $path');
    }
    return PathHelper.join([_remotePath, path]);
  }

  /// 判断异常是否为 404（优先取 HTTP 状态码，兜底字符串匹配）。
  bool _isNotFound(Object error) {
    final statusCode = webDavStatusCode(error);
    if (statusCode != null) return statusCode == 404;
    final text = error.toString().toLowerCase();
    return text.contains('404') || text.contains('not found');
  }

  /// 目录明确不存在时递归创建；认证、取消和网络异常保留其失败语义。
  Future<void> _ensureDirectory(String dirPath) async {
    try {
      await _client.readDir(dirPath);
      return;
    } catch (e) {
      if (!_isNotFound(e)) rethrow;
      await _createDirectoryRecursively(dirPath);
    }
  }

  /// 逐级创建缺失目录，只有并发创建冲突才重新读取确认目录已存在。
  Future<void> _createDirectoryRecursively(String dirPath) async {
    final parts = dirPath.split('/').where((p) => p.isNotEmpty).toList();
    var currentPath = '';

    for (final part in parts) {
      currentPath = currentPath.isEmpty ? part : '$currentPath/$part';
      try {
        await _client.readDir(currentPath);
      } catch (e) {
        if (!_isNotFound(e)) rethrow;
        try {
          await _client.mkdir(currentPath);
        } catch (createError) {
          final status = webDavStatusCode(createError);
          if (status != 405 && status != 409) rethrow;
          await _client.readDir(currentPath);
        }
      }
    }
  }

  /// 尽力清理历史旁路文件，清理失败不改变真实对象的删除结果。
  Future<void> _deleteLegacyMetadata(String filePath) async {
    try {
      final metadataPath = '$filePath.metadata.json';
      await _client.remove(metadataPath);
    } catch (e, stackTrace) {
      if (_isNotFound(e)) return;
      try {
        _logger?.warning(
          'WebDAV 历史旁路文件清理失败：${e.runtimeType}'
          ' HTTP=${webDavStatusCode(e)}\n$stackTrace',
        );
      } catch (_) {
        // 日志回调失败也不能改变已经完成的对象操作。
      }
    }
  }

  /// 统一保留底层错误与首次失败堆栈，日志中不包含请求或备份正文。
  Never _fail(String operation, Object error, StackTrace stackTrace) =>
      throwCloudStorageFailure(
        provider: 'WebDAV',
        operation: operation,
        message: '云端备份$operation失败，请重试',
        error: error,
        stackTrace: stackTrace,
        logger: _logger,
        statusCode: webDavStatusCode(error),
      );
}
