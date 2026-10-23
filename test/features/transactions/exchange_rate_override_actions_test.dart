import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  TransactionActions actions() => container.read(transactionActionsProvider);

  test('非法输入拦截不落库：0 / NaN / Infinity / -Infinity / 1e999', () async {
    for (final invalid in ['0', 'NaN', 'Infinity', '-Infinity', '1e999']) {
      await expectLater(
        actions().setRateOverride(base: 'CNY', quote: 'USD', rate: invalid),
        throwsA(isA<FormatException>()),
        reason: invalid,
      );
    }

    expect(await repo.getOverrides('CNY'), isEmpty);
  });

  test('非法输入不得覆盖已有的合法手动汇率', () async {
    await actions().setRateOverride(base: 'CNY', quote: 'USD', rate: '7.24');

    await expectLater(
      actions().setRateOverride(base: 'CNY', quote: 'USD', rate: '1e999'),
      throwsA(isA<FormatException>()),
    );

    final overrides = await repo.getOverrides('CNY');
    expect(overrides, hasLength(1));
    expect(overrides.single.rate, '7.24', reason: '拦截失败的写入不得改动旧值');
  });

  test('合法输入原样落库：用户输入的精度不二次格式化', () async {
    await actions().setRateOverride(base: 'CNY', quote: 'USD', rate: '7.5');

    final overrides = await repo.getOverrides('CNY');
    expect(overrides, hasLength(1));
    expect(overrides.single.baseCurrency, 'CNY');
    expect(overrides.single.quoteCurrency, 'USD');
    expect(overrides.single.rate, '7.5');

    // 同一币对再次保存走覆盖更新，不产生第二行。
    await actions().setRateOverride(base: 'CNY', quote: 'USD', rate: '7.25');
    final updated = await repo.getOverrides('CNY');
    expect(updated, hasLength(1));
    expect(updated.single.rate, '7.25');
  });

  test('恢复自动：删除手动覆盖并落库，重复调用幂等', () async {
    await actions().setRateOverride(base: 'CNY', quote: 'JPY', rate: '0.048');
    expect(await repo.getOverrides('CNY'), hasLength(1));

    // 编辑弹窗与列表行内「恢复自动」共用这一动作。
    await actions().removeRateOverride(base: 'CNY', quote: 'JPY');
    expect(await repo.getOverrides('CNY'), isEmpty, reason: '恢复自动必须把手动覆盖从库里删掉');

    // 已无覆盖时再次恢复自动不报错，也不会留下残留行。
    await actions().removeRateOverride(base: 'CNY', quote: 'JPY');
    expect(await repo.getOverrides('CNY'), isEmpty);
  });
}
