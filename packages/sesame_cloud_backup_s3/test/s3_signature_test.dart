import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sesame_cloud_backup_s3/src/s3_signature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('S3SignatureV4 签名', () {
    // 使用 AWS 官方 SigV4 文档中的演示凭据，保证与社区向量一致
    final signer = S3SignatureV4(
      accessKey: 'AKIDEXAMPLE',
      secretKey: 'wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY',
      region: 'us-east-1',
    );

    final uri = Uri.parse('https://examplebucket.s3.amazonaws.com/test.txt');

    /// 从实际摘要入口生成请求签名，未传摘要时验证空正文默认值。
    Map<String, String> doSign({String? payloadDigest}) {
      return signer.sign(
        method: payloadDigest == null ? 'GET' : 'PUT',
        uri: uri,
        headers: {'Host': 'examplebucket.s3.amazonaws.com'},
        payloadDigest: payloadDigest,
      );
    }

    test('空 payload 的 content-sha256 等于已知向量', () {
      final headers = doSign();
      // SHA256("") 的标准值，用于验证 _toHex 输出与官方实现一致
      expect(
        headers['x-amz-content-sha256'],
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('非空正文摘要通过实际签名入口保留为 content-sha256', () {
      final payload = utf8.encode('hello');
      final digest = sha256.convert(payload).toString();
      final headers = doSign(payloadDigest: digest);
      // 调用方的文件摘要直接进入请求头，并保持已知正文的标准摘要值。
      expect(
          headers['x-amz-content-sha256'], sha256.convert(payload).toString());
      // "hello" 的 SHA256 固定向量
      expect(
        headers['x-amz-content-sha256'],
        '2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824',
      );
    });

    test('Authorization header 结构完整且 Signature 为 64 位小写 hex', () {
      final headers = doSign(
        payloadDigest: sha256.convert(utf8.encode('hello')).toString(),
      );
      final auth = headers['Authorization']!;
      expect(auth, startsWith('AWS4-HMAC-SHA256 '));
      expect(auth, contains('Credential=AKIDEXAMPLE/'));
      expect(auth, contains('/us-east-1/s3/aws4_request'));
      expect(
          auth, contains('SignedHeaders=host;x-amz-content-sha256;x-amz-date'));
      // Signature 是 HMAC 输出经 _toHex 编码的结果，必须是 64 位小写十六进制
      final sigMatch = RegExp(r'Signature=([0-9a-f]{64})$').firstMatch(auth);
      expect(sigMatch, isNotNull);
    });

    test('x-amz-date 为 AWS 标准格式', () {
      final headers = doSign();
      expect(headers['x-amz-date'], matches(RegExp(r'^\d{8}T\d{6}Z$')));
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
  });
}
