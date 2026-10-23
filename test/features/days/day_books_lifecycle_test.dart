import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

/// 账号事实的唯一来源：仓储 accountIdGetter 与 Provider 都读它。
class _Account extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final accountProvider = NotifierProvider<_Account, String?>(_Account.new);

/// 事务内登记完变更后再切换身份，模拟创建期间换号或登录代次前进。
class _HookedRecorder extends ChangeRecorderImpl {
  _HookedRecorder(
    super.db, {
    required super.accountIdGetter,
    required this.afterRecord,
  });

  final void Function() afterRecord;

  @override
  Future<void> recordDayChange({
    required String entityType,
    required String entityId,
    required String dayBookId,
    required String accountId,
    required String action,
    required String payload,
    required DateTime updatedAt,
    required int baseRevision,
  }) async {
    await super.recordDayChange(
      entityType: entityType,
      entityId: entityId,
      dayBookId: dayBookId,
      accountId: accountId,
      action: action,
      payload: payload,
      updatedAt: updatedAt,
      baseRevision: baseRevision,
    );
    afterRecord();
  }
}

/// 首次写入失败的偏好存储，用于「保存失败后重试」路径。
class _FailOncePreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const firstId = '11111111-1111-4111-8111-111111111111';
  const secondId = '22222222-2222-4222-8222-222222222222';
  const cloudId = '33333333-3333-4333-8333-333333333333';
  const eventId = '44444444-4444-4444-8444-444444444444';
  final stamp = DateTime.utc(2026, 9, 8);

  late SesameDatabase db;
  late DayRepository repository;
  late ProviderContainer container;
  var generation = 0;
  var afterRecord = () {};

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    generation = 0;
    afterRecord = () {};
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = DayRepository(
      db,
      validateAndProject: validateAndProject,
      accountIdGetter: () => container.read(accountProvider),
      generationGetter: () => generation,
      changeRecorder: _HookedRecorder(
        db,
        accountIdGetter: () => container.read(accountProvider),
        afterRecord: () => afterRecord(),
      ),
    );
    container = ProviderContainer(
      overrides: [
        dayRepositoryProvider.overrideWithValue(repository),
        currentAccountIdProvider.overrideWith(
          (ref) => ref.watch(accountProvider),
        ),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 登录状态同时改变仓储读取范围与业务 Provider。
  void signIn(String? accountId) =>
      container.read(accountProvider.notifier).set(accountId);

  /// 云本与记录在同一事务登记同步变更。
  Future<List<SyncChange>> changes() => db.select(db.syncChanges).get();

  /// 生日记录固定原始公历，断言不依赖实现计算。
  DayEvent birthday(String dayBookId) => DayEvent(
    id: eventId,
    dayBookId: dayBookId,
    definition: DayEventDefinition(
      category: DayCategory.birthday,
      name: '爸爸生日',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate.solar(DateOnly(2000, 9, 8)),
    ),
    createdAt: stamp,
    updatedAt: stamp,
  );

  test('新建本机本：名称规范化落库、保存后成为当前本、不产生同步队列', () async {
    await repository.createBook(id: firstId, name: '已有日子');
    final created = await repository.createBook(id: secondId, name: ' 新建日子本 ');
    expect(created.name, '新建日子本');
    expect((await repository.getBook(secondId))!.name, '新建日子本');
    expect(created.storageMode, 'local');
    expect(await changes(), isEmpty);
    // 首次进入按第一个本兜底，保存动作才把选择指向新建本。
    expect(await container.read(currentDayBookIdProvider.future), firstId);
    await container.read(currentDayBookIdProvider.notifier).select(created.id);
    expect(await container.read(currentDayBookIdProvider.future), created.id);
    // 选择按未登录身份持久化，重启后仍指向同一个本。
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('current_day_book_id_local'), created.id);
  });

  test('已登录新建云本：归属云端并登记完整同步变更', () async {
    signIn('account');
    final created = await repository.createBook(
      id: cloudId,
      name: '云端纪念日',
      storageMode: 'cloud',
      accountId: 'account',
    );
    expect(created.storageMode, 'cloud');
    expect(created.scopeAccountId, 'account');
    final queued = (await changes()).single;
    expect(queued.entityType, 'day_book');
    expect(queued.entityId, created.id);
    expect(queued.dayBookId, created.id);
    expect(queued.ledgerId, isNull);
    expect(queued.accountId, 'account');
    expect(queued.action, 'upsert');
    expect(queued.pushedAt, isNull);
  });

  test('云端本改名保持云端归属并追加同步变更', () async {
    signIn('account');
    final created = await repository.createBook(
      id: cloudId,
      name: '云端纪念日',
      storageMode: 'cloud',
      accountId: 'account',
    );
    await repository.renameBook(await repository.target(created.id), ' 家庭纪念日 ');
    final saved = await repository.getBook(cloudId, accountId: 'account');
    expect(saved!.name, '家庭纪念日');
    expect(saved.storageMode, 'cloud');
    expect(saved.scopeAccountId, 'account');
    final queued = await changes();
    expect(queued, hasLength(2));
    expect(queued.every((change) => change.dayBookId == cloudId), isTrue);
    expect(queued.every((change) => change.accountId == 'account'), isTrue);
    expect(queued.every((change) => change.action == 'upsert'), isTrue);
    expect(queued.every((change) => change.pushedAt == null), isTrue);
  });

  test('点击本卡切换当前本，读取本子快照的编辑入口不改写当前选择', () async {
    final first = await repository.createBook(id: firstId, name: '家庭日子');
    final second = await repository.createBook(id: secondId, name: '工作日子');
    expect(await container.read(currentDayBookIdProvider.future), first.id);
    await container.read(currentDayBookIdProvider.notifier).select(second.id);
    expect(await container.read(currentDayBookIdProvider.future), second.id);
    // 编辑入口打开时只读取本子快照与目标，不改变当前本。
    expect((await repository.getBook(second.id))!.name, '工作日子');
    await repository.target(second.id);
    expect(await container.read(currentDayBookIdProvider.future), second.id);
  });

  test('删除本机本连同其中的记录一并移除，其他本保留', () async {
    final target = await repository.createBook(id: firstId, name: '家庭日子');
    await repository.createBook(id: secondId, name: '工作日子');
    await repository.saveEvent(birthday(firstId));
    await repository.deleteBook(await repository.target(target.id));
    expect(await repository.getBook(firstId), isNull);
    expect(
      await (db.select(
        db.dayEvents,
      )..where((row) => row.dayBookId.equals(firstId))).get(),
      isEmpty,
    );
    expect(await repository.getBook(secondId), isNotNull);
    expect(await changes(), isEmpty);
  });

  test('选中失败重试只改名不重复创建，最终仍选中同一个本', () async {
    final prefs = _FailOncePreferences();
    var failures = 1;
    when(() => prefs.getString(any())).thenReturn(null);
    when(
      () => prefs.setString(any(), any()),
    ).thenAnswer((_) async => failures-- <= 0);
    final scoped = ProviderContainer(
      overrides: [
        dayRepositoryProvider.overrideWithValue(repository),
        currentAccountIdProvider.overrideWith(
          (ref) => ref.watch(accountProvider),
        ),
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
      ],
    );
    addTearDown(scoped.dispose);
    final first = await repository.createBook(id: firstId, name: '家庭日子');
    expect(await scoped.read(currentDayBookIdProvider.future), first.id);
    final created = await repository.createBook(id: secondId, name: ' 第一次 ');
    expect(created.name, '第一次');
    // 偏好写入失败：本子已经落库，但选择不发布。
    await expectLater(
      scoped.read(currentDayBookIdProvider.notifier).select(created.id),
      throwsStateError,
    );
    expect(scoped.read(currentDayBookIdProvider).value, first.id);
    expect(await repository.getBooks(), hasLength(2));
    // 重试改为同一个本改名并重新选择，不新增第二个本。
    await repository.renameBook(await repository.target(created.id), '重试改名');
    await scoped.read(currentDayBookIdProvider.notifier).select(created.id);
    expect(await scoped.read(currentDayBookIdProvider.future), created.id);
    expect(await repository.getBooks(), hasLength(2));
    expect((await repository.getBook(secondId))!.name, '重试改名');
  });

  for (final sameAccount in [true, false]) {
    test('创建事务期间身份变化整体回滚且不发布迟到选择 sameAccount=$sameAccount', () async {
      signIn('account');
      afterRecord = () {
        if (!sameAccount) signIn('other');
        generation = 1;
      };
      await expectLater(
        repository.createBook(
          id: cloudId,
          name: '不能保存的旧输入',
          storageMode: 'cloud',
          accountId: 'account',
          generation: 0,
        ),
        throwsA(
          predicate(
            (error) =>
                error is StateError && error.message == 'DAY_SESSION_CHANGED',
          ),
        ),
      );
      // 本子与同步队列随事务整体回滚。
      expect(await db.select(db.dayBooks).get(), isEmpty);
      expect(await changes(), isEmpty);
      // 身份变化后没有可写目标，迟到的选择不会发布。
      expect(await container.read(currentDayBookIdProvider.future), isNull);
      await expectLater(
        container.read(currentDayBookIdProvider.notifier).select(cloudId),
        throwsStateError,
      );
      expect(container.read(currentDayBookIdProvider).value, isNull);
    });
  }
}
