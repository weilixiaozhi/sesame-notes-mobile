import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/repositories/contracts/day_repositories.dart';
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';

/// 用可控查询回执验证异步读取期间的会话变化。
class _Days extends Mock implements DayEntryRepository {}

/// 查询用例不调用删除能力。
class _Lifecycle extends Mock implements DataLifecycleActions {}

/// 日子查询在返回结果前必须再次确认原账号与会话。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('日子查询通过端口复核代次，旧会话迟到结果不能发布', () async {
    final repository = _Days();
    var generation = 1;
    final pending = Completer<DayBook?>();
    when(() => repository.accountIdGetter).thenReturn(() => 'account');
    when(() => repository.generationGetter).thenReturn(() => generation);
    when(
      () => repository.getBook('book', accountId: 'account'),
    ).thenAnswer((_) => pending.future);
    final result = DayActions(
      repository,
      _Lifecycle(),
    ).getBook('book', accountId: 'account');
    final assertion = expectLater(result, throwsStateError);
    generation++;
    pending.complete(null);
    await assertion;
  });
}
