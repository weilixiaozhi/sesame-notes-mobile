import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/application/support/account_snapshot_query.dart';

/// 验证跨账号与同账号重新登录都会丢弃迟到的查询结果。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final changeAccount in [false, true]) {
    test('读取过程中${changeAccount ? '切换账号' : '改变会话代次'}不返回旧结果', () async {
      var account = 'account-a';
      var generation = 0;
      final pending = Completer<String>();
      final result = readAccountSnapshot(
        area: 'QueryTest',
        accountId: 'account-a',
        currentAccountId: () => account,
        currentGeneration: () => generation,
        read: () => pending.future,
      );
      final expectation = expectLater(result, throwsStateError);
      if (changeAccount) {
        account = 'account-b';
      } else {
        generation++;
      }
      pending.complete('account-a-result');
      await expectation;
    });
  }

  test('起始账号不匹配时不访问数据源', () async {
    var queried = false;
    await expectLater(
      readAccountSnapshot(
        area: 'QueryTest',
        accountId: 'account-a',
        currentAccountId: () => 'account-b',
        currentGeneration: () => 1,
        read: () async {
          queried = true;
          return 'unavailable';
        },
      ),
      throwsStateError,
    );
    expect(queried, isFalse);
  });
}
