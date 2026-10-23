import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bookId = '11111111-1111-4111-8111-111111111111';
const _eventId = '22222222-2222-4222-8222-222222222222';
const _bindingA = '33333333-3333-4333-8333-333333333333';

const _account = 'account-a';

/// 保留生命周期派发与真实数据库事务，隔离不相关的网络刷新。
class _Coordinator extends Fake implements SyncCoordinator {
  /// 本用例只执行已获得全局写入机会的动作。
  @override
  Future<T> runDataMutation<T>(Future<T> Function() action) => action();
}

/// 在真实删除执行后制造会话变化，验证提交前复核可以回滚记录和队列。
class _Repository extends DayRepository {
  /// 账号和代次仍由真实仓储写边界读取。
  _Repository(super.db, int Function() generation)
    : super(
        validateAndProject: const DayDateRules().validateAndProject,
        accountIdGetter: () => _account,
        generationGetter: generation,
        changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => _account),
      );
  void Function()? afterDelete;

  /// 注入点位于删除动作完成与外层事务提交之间。
  @override
  Future<void> deleteEvent(
    String id,
    String dayBookId, {
    String? accountId,
  }) async {
    await super.deleteEvent(id, dayBookId, accountId: accountId);
    afterDelete?.call();
  }
}

/// 验证删除的会话边界与事务回滚，合法删除同步更新记录和云队列。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase database;
  late _Repository repository;
  late ProviderContainer container;
  late DayActions actions;
  var generation = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await logger.clear();
    generation = 0;
    database = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _Repository(database, () => generation);
    container = ProviderContainer(
      overrides: [
        currentAccountIdProvider.overrideWithValue(_account),
        databaseProvider.overrideWithValue(database),
        dayRepositoryProvider.overrideWithValue(repository),
        syncCoordinatorProvider.overrideWithValue(_Coordinator()),
        dayActionsProvider.overrideWith((ref) => actions),
      ],
    );
    actions = DayActions(repository, container.read(dataLifecycleProvider));
  });

  tearDown(() async {
    container.dispose();
    await database.close();
    await logger.clear();
  });

  /// 建立完整可写的本与记录，删除用例只观察随后产生的队列变化。
  Future<DayEvent> seed({bool cloud = true}) async {
    await repository.createBook(
      id: _bookId,
      name: '原始日子本',
      storageMode: cloud ? 'cloud' : 'local',
      accountId: _account,
      generation: generation,
    );
    if (cloud) {
      await (database.update(
        database.dayBooks,
      )..where((book) => book.id.equals(_bookId))).write(
        const DayBooksCompanion(
          syncId: d.Value(_bindingA),
          serverRevision: d.Value(1),
          fullCursor: d.Value('snapshot'),
        ),
      );
    }
    final event = DayEvent(
      id: _eventId,
      dayBookId: _bookId,
      definition: DayEventDefinition(
        category: DayCategory.birthday,
        name: '测试生日',
        repeatType: DayRepeatType.yearly,
        statisticType: DayStatisticType.year,
        event: OriginalDate.solar(DateOnly(2000, 1, 1)),
      ),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    await repository.saveEvent(event, accountId: _account);
    await database.delete(database.syncChanges).go();
    return event;
  }

  /// 原条目仍可见且没有新增删除意图。
  Future<void> expectPreserved() async {
    final row = await database.select(database.dayEvents).getSingle();
    expect(row.id, _eventId);
    expect(row.deletedAt, isNull);
    expect(await database.select(database.syncChanges).get(), isEmpty);
  }

  test('删除落盘后同账号会话变化，外层事务回滚墓碑和删除队列', () async {
    final event = await seed();
    final target = await actions.target(_bookId);
    repository.afterDelete = () => generation++;
    await expectLater(actions.deleteEvent(event, target), throwsStateError);
    await expectPreserved();
  });

  for (final cloud in [false, true]) {
    test('目标未变化时正常删除 cloud=$cloud', () async {
      final event = await seed(cloud: cloud);
      final target = await actions.target(_bookId);
      await actions.deleteEvent(event, target);
      final rows = await database.select(database.dayEvents).get();
      final changes = await database.select(database.syncChanges).get();
      if (cloud) {
        expect(rows.single.deletedAt, isNotNull);
        expect(changes.single.entityId, _eventId);
        expect(changes.single.action, 'delete');
      } else {
        expect(rows, isEmpty);
        expect(changes, isEmpty);
      }
    });
  }
}
