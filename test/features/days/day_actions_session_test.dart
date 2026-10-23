import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:sesame_notes/features/days/application/day_editor_actions.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';

/// 保存用例不调用删除入口，避免为其装配无关生命周期依赖。
class _UnusedLifecycle extends Fake implements DataLifecycleActions {}

/// 在真实数据库事务内模拟同账号的会话切换。
class _SwitchingDayRepository extends DayRepository {
  /// 保存后的回调用于制造提交前身份变化的确定性时序。
  _SwitchingDayRepository(super.db, this.afterWrite, int Function() generation)
    : super(
        validateAndProject: const DayDateRules().validateAndProject,
        generationGetter: generation,
      );
  final void Function() afterWrite;

  /// 先执行真实数据写入，再触发外部会话变化。
  @override
  Future<void> saveEvent(
    DayEvent value, {
    String? accountId,
    String? expectedSyncId,
  }) async {
    await super.saveEvent(
      value,
      accountId: accountId,
      expectedSyncId: expectedSyncId,
    );
    afterWrite();
  }
}

/// 编辑器固定会话既要在请求开始时有效，也要持续到数据库提交。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  const bookId = '11111111-1111-4111-8111-111111111111';
  const eventId = '22222222-2222-4222-8222-222222222222';

  setUp(() => db = SesameDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// 固定未来日期，隔离系统时钟与农历边界对会话测试的影响。
  DayEditorDraft draft() => (
    category: DayCategory.countdown,
    countdown: DayCountdownMode.fixedDate,
    repeat: DayRepeatType.none,
    statistic: DayStatisticType.day,
    name: '目标日期',
    intervalText: '1',
    event: OriginalDate.solar(DateOnly(2026, 10, 1)),
    start: OriginalDate.solar(DateOnly(2026, 9, 19)),
    end: OriginalDate.solar(DateOnly(2026, 10, 1)),
    untilPresent: false,
    today: DateOnly(2026, 9, 19),
  );

  for (final duringWrite in [false, true]) {
    test('会话在${duringWrite ? '事务提交前' : '编辑器打开后'}变化，日子与队列都不提交', () async {
      var generation = 0;
      final repository = _SwitchingDayRepository(db, () {
        if (duringWrite) generation++;
      }, () => generation);
      final book = await repository.createBook(id: bookId, name: '固定本');
      final actions = DayActions(repository, _UnusedLifecycle());
      final args = await actions.prepareEditor(book);
      expect(args.generation, 0);
      if (!duringWrite) generation++;
      await expectLater(
        actions.saveEditor(
          args: args,
          unconfirmedDates: {},
          draft: draft(),
          eventId: eventId,
          createdAt: DateTime.utc(2026, 9, 19),
        ),
        throwsStateError,
      );
      expect(await db.select(db.dayEvents).get(), isEmpty);
      expect(await db.select(db.syncChanges).get(), isEmpty);
    });
  }
}
