import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/memos/application/memo_book_actions.dart';
import 'package:sesame_notes/shared/application/private_book_actions.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

final _accountProvider =
    NotifierProvider<SimpleStateNotifier<String?>, String?>(
      () => SimpleStateNotifier((ref) => null),
    );

/// 使用真实数据库验证表单用例的稳定身份和事务回滚。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late ProviderContainer container;
  const id = '11111111-1111-4111-8111-111111111111';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWith(
          (ref) => ref.watch(_accountProvider),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('创建成功后重复保存同一本子，只改名且不创建第二条记录', () async {
    final actions = container.read(memoBookActionsProvider('normal'));
    final created = await actions.save(
      id: id,
      name: '首个名称',
      accountId: null,
      generation: 0,
    );
    final renamed = await actions.save(
      id: id,
      name: '重试名称',
      accountId: null,
      generation: 0,
      expected: created,
    );
    expect(renamed.id, created.id);
    expect(renamed.name, '重试名称');
    expect(await db.select(db.memoBooks).get(), hasLength(1));
  });

  test('旧表单在账号切换后无法改名，已保存名称保持不变', () async {
    final actions = container.read(memoBookActionsProvider('normal'));
    final created = await actions.save(
      id: id,
      name: '原名称',
      accountId: null,
      generation: 0,
    );
    container.read(_accountProvider.notifier).set('another-account');
    await expectLater(
      actions.save(
        id: id,
        name: '迟到名称',
        accountId: null,
        generation: 0,
        expected: created,
      ),
      throwsStateError,
    );
    expect((await db.select(db.memoBooks).getSingle()).name, '原名称');
  });

  test('本子快照不能被用作另一个本子的写入授权', () async {
    final actions = container.read(memoBookActionsProvider('normal'));
    final first = await actions.save(
      id: id,
      name: '本子一',
      accountId: null,
      generation: 0,
    );
    const otherId = '22222222-2222-4222-8222-222222222222';
    await actions.save(
      id: otherId,
      name: '本子二',
      accountId: null,
      generation: 0,
    );
    await expectLater(
      actions.save(
        id: otherId,
        name: '错误目标',
        accountId: null,
        generation: 0,
        expected: first,
      ),
      throwsStateError,
    );
    final other = await (db.select(
      db.memoBooks,
    )..where((book) => book.id.equals(otherId))).getSingle();
    expect(other.name, '本子二');
  });

  test('创建过程中账号变化，最终复核回滚本子与同步队列', () async {
    final provider = Provider(
      (ref) => PrivateBookActions(
        ref,
        _SwitchingStore(ref.read(memoRepositoryProvider), () {
          container.read(_accountProvider.notifier).set('another-account');
        }),
      ),
    );
    await expectLater(
      container
          .read(provider)
          .save(id: id, name: '不应提交', accountId: null, generation: 0),
      throwsStateError,
    );
    expect(await db.select(db.memoBooks).get(), isEmpty);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
}

/// 在真实插入完成之后模拟账号切换，事务由被测用例控制。
class _SwitchingStore implements PrivateBookStore {
  /// 将身份变化安排在插入之后、最终提交之前。
  _SwitchingStore(this._repository, this._switchAccount);
  final MemoRepository _repository;
  final void Function() _switchAccount;

  /// 当前测试对应备忘录本子。
  @override
  String get targetType => 'memo_book';

  /// 使用真实 Drift 事务验证失败回滚。
  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      _repository.db.transaction(action);

  /// 返回已插入本子的真实快照。
  @override
  Future<PrivateBookSnapshot> load(String id, String? accountId) async {
    final book = await _repository.getBook(id, accountId: accountId);
    if (book == null) throw StateError('book missing');
    return (book: book, count: book.entryCount);
  }

  /// 插入成功后立即改变账号，触发应用事务末尾的身份复核。
  @override
  Future<void> create(
    String id,
    String name,
    String? accountId,
    int generation,
    String storageMode,
  ) async {
    await _repository.createBook(id: id, name: name, type: 'normal');
    _switchAccount();
  }

  /// 固定绑定读取仍经过真实仓储。
  @override
  Future<PrivateBookTarget> target(String id) => _repository.target(id);

  /// 名称更新使用同一固定目标规则。
  @override
  Future<void> rename(PrivateBookTarget target, String name) =>
      _repository.renameBook(target, name);
}
