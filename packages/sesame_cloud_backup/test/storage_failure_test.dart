import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 错误原因可程序化读取，但日志和用户文案不得包含底层敏感正文。
void main() {
  test('配置异常保留底层原因但格式化不能泄露底层认证信息', () {
    final cause = StateError('Authorization=private-token');
    final error = CloudConfigurationException('备份连接失败，请重试', cause);
    expect(error.originalError, same(cause));
    expect(error.toString(), contains('备份连接失败'));
    expect(error.toString(), isNot(contains('private-token')));
  });

  test('重复包装保留首次原因、状态码、堆栈，并只写一次安全日志', () {
    final cause = TimeoutException('password-secret response-private');
    final origin = StackTrace.fromString(
        '#0 transfer (package:adapter/transport.dart:7:3)');
    final messages = <String>[];
    final logger =
        CloudSyncLogger(onLog: (_, message) => messages.add(message));
    try {
      try {
        throwCloudStorageFailure(
            provider: 'Test',
            operation: '上传',
            message: '上传失败，请重试',
            error: cause,
            stackTrace: origin,
            logger: logger,
            statusCode: 503);
      } catch (error, stack) {
        throwCloudStorageFailure(
            provider: 'Test',
            operation: '文件传输',
            message: '文件传输失败，请重试',
            error: error,
            stackTrace: stack,
            logger: logger);
      }
    } on CloudStorageException catch (error, stack) {
      expect(error.originalError, same(cause));
      expect(error.originalStackTrace.toString(), origin.toString());
      expect(stack.toString(), origin.toString());
      expect(error.statusCode, 503);
      expect(error.toString(), isNot(contains('password-secret')));
    }
    expect(messages, hasLength(1));
    expect(messages.single, contains('TimeoutException'));
    expect(messages.single, contains('HTTP=503'));
    expect(messages.single, contains('transport.dart:7:3'));
    expect(messages.single, isNot(contains('response-private')));
  });
}
