import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import 's3_exceptions.dart';
import 's3_signature.dart';

/// S3 列表条目信息（Key + 真实 size / lastModified）。
class S3ObjectInfo {
  final String key;
  final int? size;
  final DateTime? lastModified;

  const S3ObjectInfo({required this.key, this.size, this.lastModified});
}

/// S3 REST API 客户端
///
/// 实现基础的 S3 操作：
/// - PutObject: 上传对象
/// - GetObject: 下载对象
/// - DeleteObject: 删除对象
/// - ListObjectsV2: 列出对象（含分页）
class S3Client {
  final String endpoint;
  final String region;
  final String accessKey;
  final String secretKey;
  final bool useSSL;
  final int? port;

  /// 请求超时：避免网络卡死导致同步线程无限等待。
  static const Duration _requestTimeout = Duration(seconds: 30);

  late final S3SignatureV4 _signer;
  late final String _baseUrl;
  late final http.Client _httpClient;

  S3Client({
    required this.endpoint,
    required this.region,
    required this.accessKey,
    required this.secretKey,
    this.useSSL = true,
    this.port,
  }) {
    _signer = S3SignatureV4(
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );

    final scheme = useSSL ? 'https' : 'http';
    final portStr = port != null ? ':$port' : '';
    _baseUrl = '$scheme://$endpoint$portStr';

    _httpClient = http.Client();
  }

  /// 释放资源
  void dispose() {
    _httpClient.close();
  }

  /// 文件摘要与正文都逐块处理，签名与实际发送的字节保持一致。
  Future<void> putFile(
      {required String bucket,
      required String key,
      required File file,
      Map<String, String>? metadata}) async {
    try {
      final uri = _requestUri(bucket, key);
      final digest = await sha256.bind(file.openRead()).first;
      final headers = _signer.sign(
          method: 'PUT',
          uri: uri,
          canonicalPath: _canonicalPath(bucket, key),
          payloadDigest: digest.toString(),
          headers: {
            'Host': uri.authority,
            'Content-Type': 'application/octet-stream',
            'Content-Length': '${await file.length()}',
            'If-None-Match': '*',
            for (final entry in (metadata ?? const <String, String>{}).entries)
              'x-amz-meta-${entry.key}': entry.value
          });
      await CloudHttpFileTransfer.upload(uri, file, headers);
    } catch (error, stackTrace) {
      if (error is CloudFileAlreadyExistsException) rethrow;
      throwCloudStorageFailure(
          provider: 'S3',
          operation: '文件上传',
          message: '云端备份上传失败，请重试',
          error: error,
          stackTrace: stackTrace);
    }
  }

  /// 签名后的对象响应直接写入隔离文件。
  Future<bool> getFile(
      {required String bucket,
      required String key,
      required File destination}) async {
    try {
      final uri = _requestUri(bucket, key);
      return await CloudHttpFileTransfer.download(
          uri,
          destination,
          _signer.sign(
              method: 'GET',
              uri: uri,
              headers: {'Host': uri.authority},
              canonicalPath: _canonicalPath(bucket, key)));
    } catch (error, stackTrace) {
      throwCloudStorageFailure(
          provider: 'S3',
          operation: '文件下载',
          message: '云端备份下载失败，请重试',
          error: error,
          stackTrace: stackTrace);
    }
  }

  /// DELETE Object - 删除文件
  Future<void> deleteObject({
    required String bucket,
    required String key,
  }) async {
    final uri = _requestUri(bucket, key);

    var headers = <String, String>{
      'Host': uri.authority,
    };

    headers = _signer.sign(
      method: 'DELETE',
      uri: uri,
      headers: headers,
      canonicalPath: _canonicalPath(bucket, key),
    );

    try {
      final response = await _httpClient
          .delete(uri, headers: headers)
          .timeout(_requestTimeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        // 404 也算成功（对象已不存在）
        if (response.statusCode != 404) {
          _handleError('DeleteObject', response);
        }
      }
    } on SocketException catch (e, stackTrace) {
      Error.throwWithStackTrace(
          S3NetworkException('Network error: ${e.message}',
              originalException: e),
          stackTrace);
    } on TimeoutException catch (e, stackTrace) {
      Error.throwWithStackTrace(
          S3NetworkException('Request timed out', originalException: e),
          stackTrace);
    } catch (e, stackTrace) {
      if (e is S3Exception) rethrow;
      Error.throwWithStackTrace(
          S3Exception('DeleteObject failed: $e', originalException: e),
          stackTrace);
    }
  }

  /// LIST Objects V2 - 列出对象（自动翻页，避免超过 1000 个对象被截断）。
  Future<List<S3ObjectInfo>> listObjects({
    required String bucket,
    String? prefix,
  }) async {
    final objects = <S3ObjectInfo>[];
    var continuationToken = '';
    final continuationTokens = <String>{};

    do {
      final queryParams = <String, String>{
        'list-type': '2', // ListObjectsV2
      };
      if (prefix != null && prefix.isNotEmpty) {
        queryParams['prefix'] = prefix;
      }
      if (continuationToken.isNotEmpty) {
        queryParams['continuation-token'] = continuationToken;
      }

      final uri =
          Uri.parse('$_baseUrl/$bucket').replace(queryParameters: queryParams);

      var headers = <String, String>{
        'Host': uri.authority,
      };

      headers = _signer.sign(
        method: 'GET',
        uri: uri,
        headers: headers,
        canonicalPath: '/$bucket',
      );

      try {
        final response = await _httpClient
            .get(uri, headers: headers)
            .timeout(_requestTimeout);

        if (response.statusCode == 200) {
          final page = _parseListObjectsResponse(response.body);
          final nextToken = page.nextContinuationToken;
          // 续页令牌必须推进；重复令牌会重读旧页，不能形成完整备份清单。
          if (nextToken != null && !continuationTokens.add(nextToken)) {
            throw S3Exception('云端备份列表分页未前进，请检查存储服务后重试');
          }
          objects.addAll(page.objects);
          continuationToken = nextToken ?? '';
        } else if (response.statusCode == 404) {
          throw S3BucketNotFoundException(bucket);
        } else {
          _handleError('ListObjects', response);
        }
      } on SocketException catch (e, stackTrace) {
        Error.throwWithStackTrace(
            S3NetworkException('Network error: ${e.message}',
                originalException: e),
            stackTrace);
      } on TimeoutException catch (e, stackTrace) {
        Error.throwWithStackTrace(
            S3NetworkException('Request timed out', originalException: e),
            stackTrace);
      } catch (e, stackTrace) {
        if (e is S3Exception) rethrow;
        Error.throwWithStackTrace(
            S3Exception('ListObjects failed: $e', originalException: e),
            stackTrace);
      }
    } while (continuationToken.isNotEmpty);

    return objects;
  }

  /// 解析 ListObjects 响应（XML），返回对象列表与续页 token。
  ///
  /// 对象身份和分页状态必须完整；任一页无效时整次列举失败。
  ({List<S3ObjectInfo> objects, String? nextContinuationToken})
      _parseListObjectsResponse(String xmlBody) {
    try {
      final document = XmlDocument.parse(xmlBody);
      final root = document.rootElement;
      if (root.name.local != 'ListBucketResult') {
        throw const FormatException('S3 列表响应缺少 ListBucketResult 根元素');
      }
      // 从根的直接子元素读取，不能借用嵌套错误内容中的字段证明列表完整。
      final truncatedElements =
          root.findElements('IsTruncated', namespace: '*').toList();
      if (truncatedElements.length != 1) {
        throw const FormatException('S3 列表响应必须包含唯一的 IsTruncated');
      }
      final truncated = truncatedElements.single.innerText.trim();
      if (!const ['true', 'false', '1', '0'].contains(truncated)) {
        throw const FormatException('S3 列表响应 IsTruncated 不是布尔值');
      }
      final isTruncated = truncated == 'true' || truncated == '1';
      String? nextToken;
      if (isTruncated) {
        final tokens =
            root.findElements('NextContinuationToken', namespace: '*').toList();
        if (tokens.length != 1 || tokens.single.innerText.trim().isEmpty) {
          throw const FormatException('S3 截断列表缺少唯一且非空的续页令牌');
        }
        // 令牌是服务端不透明值，查询编码前保持原样。
        nextToken = tokens.single.innerText;
      }
      final objects =
          root.findElements('Contents', namespace: '*').map((element) {
        final keys = element.findElements('Key', namespace: '*').toList();
        if (keys.length != 1 || keys.single.innerText.isEmpty) {
          throw const FormatException('S3 列表对象缺少唯一且非空的 Key');
        }
        final sizeElement =
            element.findElements('Size', namespace: '*').firstOrNull;
        final lastModifiedElement =
            element.findElements('LastModified', namespace: '*').firstOrNull;
        return S3ObjectInfo(
          key: keys.single.innerText,
          size: int.tryParse(sizeElement?.innerText ?? ''),
          lastModified: DateTime.tryParse(lastModifiedElement?.innerText ?? ''),
        );
      }).toList();
      return (
        objects: objects,
        nextContinuationToken: nextToken,
      );
    } catch (e, stackTrace) {
      Error.throwWithStackTrace(
          S3Exception('云端备份列表响应无效，请检查存储服务后重试', originalException: e),
          stackTrace);
    }
  }

  /// 构造实际请求 URI。
  Uri _requestUri(String bucket, String key) {
    return Uri.parse('$_baseUrl/$bucket/${_encodeKey(key)}');
  }

  /// 构造 SigV4 Canonical URI（按路径分段 RFC 3986 编码）。
  ///
  /// 不能依赖 `Uri.path`：它返回解码后的路径，非 ASCII / 特殊字符 Key
  /// 会签出错误签名。
  String _canonicalPath(String bucket, String key) {
    return '/$bucket/${_encodeKey(key)}';
  }

  /// URL 编码 Key（保留 /）
  String _encodeKey(String key) {
    return key.split('/').map(encodeS3UriComponent).join('/');
  }

  /// 统一错误处理
  void _handleError(String operation, http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    // 尝试解析 XML 错误信息
    String? errorCode;
    String? errorMessage;
    try {
      final document = XmlDocument.parse(body);
      errorCode = document.findAllElements('Code').firstOrNull?.innerText;
      errorMessage = document.findAllElements('Message').firstOrNull?.innerText;
    } catch (_) {
      // XML 解析失败，使用原始 body
    }

    final message = errorMessage ?? body;

    if (statusCode == 403) {
      if (errorCode == 'InvalidAccessKeyId' ||
          errorCode == 'SignatureDoesNotMatch') {
        throw S3AuthException('Authentication failed: $message');
      } else {
        throw S3PermissionDeniedException('Permission denied: $message');
      }
    } else {
      throw S3Exception(
        '$operation failed (HTTP $statusCode): $message',
        statusCode: statusCode,
      );
    }
  }
}
