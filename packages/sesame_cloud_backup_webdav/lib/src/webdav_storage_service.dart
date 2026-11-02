library;

import 'dart:io' as io;

import 'package:dio/dio.dart' as dio;
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'webdav_errors.dart';

/// WebDAV implementation of [CloudStorageService].
class WebDAVStorageService
    implements CloudStorageService, CloudConditionalDeleteStorage {
  final webdav.Client _client;
  final String _remotePath;
  final CloudSyncLogger? _logger;
  final _verifiedDeletePrefixes = <String>{};
  final _deleteChecks = <String, Future<void>>{};

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

  /// 单次独立连接只给实际 GET 固定 If-Match，认证协商不携带对象前提。
  @override
  Future<bool> downloadIfMatch({
    required String path,
    required io.File destination,
    required String expectedETag,
  }) async {
    if (!isStrongCloudETag(expectedETag)) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    final connection = webdav.WdDio(
      options: _client.c.options.copyWith(headers: {
        for (final entry in _client.c.options.headers.entries)
          if (entry.key.toLowerCase() != 'if-match') entry.key: entry.value,
      }),
    );
    connection.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // OPTIONS 负责认证，只有真实内容读取才能证明 GET 条件被服务器执行。
        if (options.method.toUpperCase() == 'GET') {
          options.headers['If-Match'] = expectedETag;
        }
        handler.next(options);
      },
    ));
    final client = webdav.Client(
      uri: _client.uri,
      c: connection,
      auth: _client.auth,
    );
    try {
      await client.read2File(_buildPath(path), destination.path);
      return true;
    } catch (error, stackTrace) {
      try {
        if (await destination.exists()) await destination.delete();
      } catch (_) {
        // 隔离文件清理不能覆盖对象条件失败的实际原因。
      }
      final status = webDavStatusCode(error);
      if (status == 404) return false;
      if (status == 412) {
        throw CloudStorageException('云端对象已变化，未读取文件', null, status);
      }
      _fail('条件读取', error, stackTrace);
    } finally {
      connection.close(force: true);
    }
  }

  /// 幂等删除指定文件，不操作其他对象。
  @override
  Future<void> delete({required String path}) async {
    try {
      await _client.remove(_buildPath(path));
    } catch (e, stackTrace) {
      if (_isNotFound(e)) return;
      _fail('删除', e, stackTrace);
    }
  }

  /// 首次显式清理使用本次独占空对象验证服务确实执行条件，成功后按前缀复用。
  @override
  Future<void> verifyConditionalDelete({required String prefix}) {
    if (_verifiedDeletePrefixes.contains(prefix)) return Future.value();
    final pending = _deleteChecks[prefix];
    if (pending != null) return pending;
    late final Future<void> check;
    check = verifyCloudConditionalDelete(
      storage: this,
      conditional: this,
      prefix: prefix,
      logger: _logger,
    ).then((_) {
      _verifiedDeletePrefixes.add(prefix);
    }).whenComplete(() {
      if (identical(_deleteChecks[prefix], check)) _deleteChecks.remove(prefix);
    });
    _deleteChecks[prefix] = check;
    return check;
  }

  /// 条件头仅属于本次 DELETE，不污染连接或影响另一份快照的请求。
  @override
  Future<void> deleteIfMatch(
      {required String path, required String expectedETag}) async {
    if (!isStrongCloudETag(expectedETag)) {
      throw const CloudConditionalDeleteUnsupportedException();
    }
    try {
      final response = await _client.c.req<void>(
        _client,
        'DELETE',
        _buildPath(path),
        optionsHandler: (options) =>
            options.headers!['If-Match'] = expectedETag,
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw CloudStorageException(
            '云端对象已变化或删除被拒绝，原文件已保留', null, response.statusCode);
      }
    } catch (error, stackTrace) {
      final status = webDavStatusCode(error);
      if (status == 412 || status == 404) {
        throw CloudStorageException('云端对象已变化，未删除文件', null, status);
      }
      _fail('条件删除', error, stackTrace);
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
        } else {
          result.add(CloudFile(
              name: name,
              path: relative,
              size: file.size,
              lastModified: file.mTime,
              metadata: {if (isStrongCloudETag(file.eTag)) 'etag': file.eTag}));
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
