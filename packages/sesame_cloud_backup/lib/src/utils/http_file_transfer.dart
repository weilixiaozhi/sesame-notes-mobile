import 'dart:io';
import 'dart:convert';
import '../core/exceptions.dart';
import 'storage_failure.dart';

/// 分块写入文件并等待刷盘；保持上游格式或网络异常，不被二次关闭掩盖。
Future<void> writeCloudFile(File target, Stream<List<int>> contents) async {
  final output = await target.open(mode: FileMode.write);
  try {
    await for (final chunk in contents) {
      await output.writeFrom(chunk);
    }
    await output.flush();
  } finally {
    await output.close();
  }
}

/// 已确定端点和认证头的文件传输；禁止重定向携带凭据，数据逐块读写。
class CloudHttpFileTransfer {
  static const _timeout = Duration(seconds: 30);

  /// 上传不可变的本地文件，响应只接受服务端成功状态。
  static Future<void> upload(Uri uri, File file, Map<String, String> headers,
      {String method = 'PUT'}) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.openUrl(method, uri);
      request.followRedirects = false;
      headers.forEach((key, value) => request.headers.set(key, value));
      request.contentLength = await file.length();
      await request
          .addStream(file.openRead().timeout(_timeout))
          .timeout(_timeout);
      final response = await request.close().timeout(_timeout);
      if (response.statusCode == 412 || response.statusCode == 409) {
        throw const CloudFileAlreadyExistsException();
      }
      if (response.statusCode == 400) {
        final text = StringBuffer();
        await for (final chunk
            in response.transform(utf8.decoder).timeout(_timeout)) {
          text.write(chunk);
          if (text.length > 65536) break;
        }
        final message = text.toString();
        if (message.contains('Duplicate') ||
            message.contains('already exists')) {
          throw const CloudFileAlreadyExistsException();
        }
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw CloudStorageException('云端备份上传失败，请重试', null, response.statusCode);
      }
      await response.drain<void>().timeout(_timeout);
    } catch (error, stackTrace) {
      if (error is CloudFileAlreadyExistsException) rethrow;
      throwCloudStorageFailure(
          provider: 'HTTP',
          operation: '文件上传',
          message: '云端备份上传失败，请重试',
          error: error,
          stackTrace: stackTrace);
    } finally {
      client.close(force: true);
    }
  }

  /// 下载到隔离文件；404 返回 false，失败清除不完整文件。
  static Future<bool> download(
      Uri uri, File destination, Map<String, String> headers) async {
    final client = HttpClient()..connectionTimeout = _timeout;
    try {
      final request = await client.getUrl(uri);
      request.followRedirects = false;
      headers.forEach((key, value) => request.headers.set(key, value));
      final response = await request.close().timeout(_timeout);
      if (response.statusCode == 404) return false;
      if (response.statusCode != 200) {
        throw CloudStorageException('云端备份下载失败，请重试', null, response.statusCode);
      }
      await writeCloudFile(destination, response.timeout(_timeout));
      return true;
    } catch (error, stackTrace) {
      try {
        if (await destination.exists()) await destination.delete();
      } catch (_) {
        // 原始传输故障优先上抛；调用方仍持有隔离文件并负责最终目录清理。
      }
      throwCloudStorageFailure(
          provider: 'HTTP',
          operation: '文件下载',
          message: '云端备份下载失败，请重试',
          error: error,
          stackTrace: stackTrace);
    } finally {
      client.close(force: true);
    }
  }
}
