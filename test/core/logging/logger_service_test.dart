import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 日志持久化只保留可定位的错误类型与代码，不复制业务参数或认证材料。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('数据库参数、解析正文与请求票据不进入日志字段', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await logger.clear();

    fakeAsync((time) {
      logger.error(
        'PrivacyTest',
        '保存失败',
        SqliteException(
          extendedResultCode: 19,
          message: 'constraint failed',
          causingStatement: 'INSERT INTO memo_entries VALUES (?)',
          parametersToStatement: ['private-password-value'],
        ),
      );
      logger.error(
        'PrivacyTest',
        '解析失败',
        const FormatException('private-note-value'),
      );
      logger.error(
        'PrivacyTest',
        '请求失败',
        DioException(
          requestOptions: RequestOptions(path: '/socket?ticket=private-ticket'),
          message: 'private-ticket',
          type: DioExceptionType.connectionError,
        ),
      );

      expect(logger.logs.first.error, 'SqliteException(code=19)');
      time.elapse(const Duration(seconds: 2));
      time.flushMicrotasks();
      final persisted = preferences.getString('app_logs')!;
      expect(persisted, isNot(contains('private-')));
      expect(persisted, contains('SqliteException(code=19)'));
      expect(persisted, contains('connectionError'));
      unawaited(logger.clear());
      time.flushMicrotasks();
    });
  });
}
