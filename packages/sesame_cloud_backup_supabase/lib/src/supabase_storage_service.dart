library;

import 'dart:io';

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Supabase implementation of [CloudStorageService].
class SupabaseStorageService implements CloudStorageService {
  final supabase.SupabaseClient _client;
  final String _bucketName;
  final String? _pathPrefix;
  final CloudSyncLogger? _logger;

  SupabaseStorageService(
    this._client,
    this._bucketName, [
    this._pathPrefix,
    CloudSyncLogger? logger,
  ]) : _logger = logger;

  /// 认证端点与路径使用 SDK 配置，文件正文直接发送，避免 SDK 整包缓冲。
  @override
  Future<void> uploadFile(
      {required String path,
      required File file,
      Map<String, String>? metadata}) async {
    try {
      final user = _client.auth.currentUser;
      final token = _client.auth.currentSession?.accessToken;
      if (user == null || token == null) {
        throw CloudNotAuthenticatedException('请重新登录云备份服务');
      }
      final fullPath = _buildUserPath(user.id, path);
      final api = _client.storage.from(_bucketName);
      final object =
          Uri(pathSegments: [_bucketName, ...fullPath.split('/')]).path;
      await CloudHttpFileTransfer.upload(
          Uri.parse('${api.url}/object/$object'),
          file,
          {
            ...api.headers,
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/octet-stream',
            'x-upsert': 'false'
          },
          method: 'POST');
    } catch (error, stackTrace) {
      if (error is CloudFileAlreadyExistsException) rethrow;
      _fail('文件上传', error, stackTrace);
    }
  }

  /// 响应逐块落盘，当前认证头只发送到配置的存储端点。
  @override
  Future<bool> downloadFile(
      {required String path, required File destination}) async {
    try {
      final user = _client.auth.currentUser;
      final token = _client.auth.currentSession?.accessToken;
      if (user == null || token == null) {
        throw CloudNotAuthenticatedException('请重新登录云备份服务');
      }
      final api = _client.storage.from(_bucketName);
      final object = Uri(pathSegments: [
        _bucketName,
        ..._buildUserPath(user.id, path).split('/')
      ]).path;
      return await CloudHttpFileTransfer.download(
          Uri.parse('${api.url}/object/$object'),
          destination,
          {...api.headers, 'Authorization': 'Bearer $token'});
    } catch (error, stackTrace) {
      _fail('文件下载', error, stackTrace);
    }
  }

  @override
  Future<void> delete({required String path}) async {
    try {
      // 只操作当前客户端登录用户的对象路径。
      final user = _client.auth.currentUser;
      if (user == null) {
        throw CloudNotAuthenticatedException('User not authenticated');
      }

      final fullPath = _buildUserPath(user.id, path);

      await _client.storage.from(_bucketName).remove([fullPath]);
    } on supabase.StorageException catch (e, stackTrace) {
      _fail('删除', e, stackTrace);
    } catch (e, stackTrace) {
      if (e is CloudNotAuthenticatedException) rethrow;
      _fail('删除', e, stackTrace);
    }
  }

  @override
  Future<List<CloudFile>> list({required String path}) async {
    try {
      // Check if user is authenticated
      final user = _client.auth.currentUser;
      if (user == null) {
        throw CloudNotAuthenticatedException('User not authenticated');
      }

      // 空目录只列举当前客户端的配置根，文件操作继续要求有效对象路径。
      final fullPath =
          path.isEmpty ? _userRoot(user.id) : _buildUserPath(user.id, path);

      final result = <CloudFile>[];
      var offset = 0;
      while (true) {
        final files = await _client.storage.from(_bucketName).list(
            path: fullPath,
            searchOptions: supabase.SearchOptions(limit: 100, offset: offset));
        for (final file in files) {
          if (file.name.isEmpty ||
              file.name.contains('/') ||
              file.name.contains('\\') ||
              !PathHelper.isSafeRelativePath(file.name)) {
            continue;
          }
          final relative = PathHelper.join([path, file.name]);
          if (file.id == null) {
            result.addAll(await list(path: relative));
          } else {
            result.add(CloudFile(
                name: file.name,
                path: relative,
                size: file.metadata?['size'] as int?,
                lastModified: file.updatedAt == null
                    ? null
                    : DateTime.parse(file.updatedAt!),
                metadata: file.metadata));
          }
        }
        if (files.length < 100) break;
        offset += files.length;
      }
      return result;
    } on supabase.StorageException catch (e, stackTrace) {
      _fail('列举文件', e, stackTrace);
    } catch (e, stackTrace) {
      if (e is CloudNotAuthenticatedException) rethrow;
      _fail('列举文件', e, stackTrace);
    }
  }

  /// 目录列举和对象操作使用相同的用户根目录及配置前缀。
  String _userRoot(String userId) => PathHelper.normalize(
        (_pathPrefix ?? 'users/{userId}').replaceAll('{userId}', userId),
      );

  /// 验证相对对象路径后拼接用户根，禁止文件操作落到目录本身。
  String _buildUserPath(String userId, String path) {
    // 拒绝绝对路径与 .. 段，防止拼接用户前缀后逃逸到其他目录。
    if (!PathHelper.isSafeRelativePath(path)) {
      throw CloudStorageException('Invalid path: $path');
    }

    return PathHelper.join([_userRoot(userId), path]);
  }

  /// 统一保留底层错误与首次失败堆栈，日志中不包含请求或备份正文。
  Never _fail(String operation, Object error, StackTrace stackTrace) =>
      throwCloudStorageFailure(
        provider: 'Supabase',
        operation: operation,
        message: '云端备份$operation失败，请重试',
        error: error,
        stackTrace: stackTrace,
        logger: _logger,
        statusCode: error is supabase.StorageException
            ? int.tryParse(error.statusCode ?? '')
            : null,
      );
}
