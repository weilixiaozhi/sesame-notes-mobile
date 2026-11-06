import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sesame_cloud_backup_s3/src/s3_signature.dart';
import 'package:flutter_test/flutter_test.dart';

/// 验证请求签名的正文摘要、授权格式和独立 HMAC 协议向量。
void main() {
  group('S3SignatureV4 签名', () {
    // 使用 AWS 官方 SigV4 文档中的演示凭据，保证与社区向量一致
    final signer = S3SignatureV4(
      accessKey: 'AKIDEXAMPLE',
      secretKey: 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
      region: 'us-east-1',
    );

    final uri = Uri.parse('https://examplebucket.s3.amazonaws.com/test.txt');

    test('空正文与文件摘要保持已知向量，授权字段符合AWS签名协议', () {
      try {
        for (final (digest, expected) in [
          (
            null,
            'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
          ),
          (
            sha256.convert(utf8.encode('hello')).toString(),
            '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824'
          ),
        ]) {
          final headers = signer.sign(
            method: digest == null ? 'GET' : 'PUT',
            uri: uri,
            headers: {'Host': 'examplebucket.s3.amazonaws.com'},
            payloadDigest: digest,
          );
          expect(headers['x-amz-content-sha256'], expected);
          expect(headers['x-amz-date'], matches(RegExp(r'^\d{8}T\d{6}Z$')));
          final auth = headers['Authorization']!;
          expect(auth, startsWith('AWS4-HMAC-SHA256 Credential=AKIDEXAMPLE/'));
          expect(auth, contains('/us-east-1/s3/aws4_request'));
          expect(auth,
              contains('SignedHeaders=host;x-amz-content-sha256;x-amz-date'));
          expect(auth, matches(RegExp(r'Signature=[0-9a-f]{64}$')));
        }
      } catch (error, stackTrace) {
        printOnFailure('S3 正文摘要和授权协议验证失败：$error\n$stackTrace');
        rethrow;
      }
    });
    test('特殊字符路径与查询使用严格组件编码，HMAC匹配独立规范请求', () {
      final headers = signer.sign(
        method: 'GET',
        uri: Uri.parse(
            'https://examplebucket.s3.amazonaws.com/test%21%27%28%29%2A'
            '?prefix=z%21%27%28%29%2A%20x'),
        headers: {'Host': 'examplebucket.s3.amazonaws.com'},
      );
      final date = headers['x-amz-date']!;
      final stamp = date.substring(0, 8);
      final emptyHash = sha256.convert(const <int>[]).toString();
      // 路径与查询预期直接固定为规范字节，不调用被测编码函数生成预期。
      final canonical = 'GET\n/test%21%27%28%29%2A\n'
          'prefix=z%21%27%28%29%2A%20x\n'
          'host:examplebucket.s3.amazonaws.com\n'
          'x-amz-content-sha256:$emptyHash\n'
          'x-amz-date:$date\n\n'
          'host;x-amz-content-sha256;x-amz-date\n$emptyHash';
      final toSign = 'AWS4-HMAC-SHA256\n$date\n'
          '$stamp/us-east-1/s3/aws4_request\n'
          '${sha256.convert(utf8.encode(canonical))}';
      List<int> key =
          utf8.encode('AWS4wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY');
      for (final part in [stamp, 'us-east-1', 's3', 'aws4_request']) {
        key = Hmac(sha256, key).convert(utf8.encode(part)).bytes;
      }
      final expected =
          Hmac(sha256, key).convert(utf8.encode(toSign)).toString();
      expect(headers['Authorization'], endsWith('Signature=$expected'));
    });

    for (final method in ['GET', 'DELETE']) {
      test('$method对象条件值进入规范请求，HMAC匹配独立条件向量', () {
        final headers = signer.sign(
          method: method,
          uri: uri,
          headers: {
            'Host': 'examplebucket.s3.amazonaws.com',
            'If-Match': '"opaque-version-1"',
          },
        );
        final date = headers['x-amz-date']!;
        final stamp = date.substring(0, 8);
        final emptyHash = sha256.convert(const <int>[]).toString();
        // 规范条件头使用独立固定文本，防止请求值未进入签名却仍通过结构检查。
        final canonical = '$method\n/test.txt\n\n'
            'host:examplebucket.s3.amazonaws.com\n'
            'if-match:"opaque-version-1"\n'
            'x-amz-content-sha256:$emptyHash\n'
            'x-amz-date:$date\n\n'
            'host;if-match;x-amz-content-sha256;x-amz-date\n$emptyHash';
        final toSign = 'AWS4-HMAC-SHA256\n$date\n'
            '$stamp/us-east-1/s3/aws4_request\n'
            '${sha256.convert(utf8.encode(canonical))}';
        List<int> key =
            utf8.encode('AWS4wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY');
        for (final part in [stamp, 'us-east-1', 's3', 'aws4_request']) {
          key = Hmac(sha256, key).convert(utf8.encode(part)).bytes;
        }
        final expected =
            Hmac(sha256, key).convert(utf8.encode(toSign)).toString();
        expect(
            headers['Authorization'],
            contains(
                'SignedHeaders=host;if-match;x-amz-content-sha256;x-amz-date'));
        expect(headers['Authorization'], endsWith('Signature=$expected'));
      });
    }
  });
}
