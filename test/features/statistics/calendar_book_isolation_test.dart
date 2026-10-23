import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/statistics/application/unified_calendar_providers.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import '../../helpers/fitness_space_fixture.dart';

/// 同日不同本写入不同记录，验证日历真实查询和切本订阅不会混入另一份内容。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const first = '11111111-1111-4111-8111-111111111111';
  const second = '22222222-2222-4222-8222-222222222222';
  const entryA = '33333333-3333-4333-8333-333333333333';
  const entryB = '44444444-4444-4444-8444-444444444444';
  final date = DateTime(2026, 9, 21, 12);
  late SesameDatabase db;
  setUp(() => db = SesameDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('记账日历的月金额和当天明细只查询传入的当前账本', () async {
    final repo = LocalRepository(db);
    final a = await repo.createLedger(name: '账本A');
    final b = await repo.createLedger(name: '账本B');
    final recordA = await repo.addTransaction(
      ledgerId: a,
      type: 'expense',
      amount: '38',
      happenedAt: date,
    );
    final recordB = await repo.addTransaction(
      ledgerId: b,
      type: 'expense',
      amount: '99',
      happenedAt: date,
    );
    expect(await repo.getDailyTotalsByMonth(ledgerId: a, month: date), {
      '2026-09-21': 38.0,
    });
    expect(await repo.getDailyTotalsByMonth(ledgerId: b, month: date), {
      '2026-09-21': 99.0,
    });
    expect(
      (await repo.getTransactionsByDate(
        ledgerId: a,
        date: date,
      )).map((row) => row.t.id),
      [recordA],
    );
    expect(
      (await repo.getTransactionsByDate(
        ledgerId: b,
        date: date,
      )).map((row) => row.t.id),
      [recordB],
    );
  });

  test('纪念日切换当前本后月历订阅只投影新本记录', () async {
    final repo = DayRepository(db, validateAndProject: validateAndProject);
    for (final id in [first, second]) {
      await repo.createBook(id: id, name: id == first ? '纪念日A' : '纪念日B');
      await repo.saveEvent(
        DayEvent(
          id: id == first ? entryA : entryB,
          dayBookId: id,
          definition: DayEventDefinition(
            category: DayCategory.birthday,
            name: id == first ? '生日A' : '生日B',
            repeatType: DayRepeatType.yearly,
            statisticType: DayStatisticType.year,
            event: OriginalDate.solar(DateOnly(2000, 9, 21)),
          ),
          createdAt: date.toUtc(),
          updatedAt: date.toUtc(),
        ),
      );
    }
    final books = {for (final book in await repo.getBooks()) book.id: book};
    final selection = NotifierProvider<SimpleStateNotifier<String>, String>(
      () => SimpleStateNotifier((ref) => first),
    );
    final container = ProviderContainer(
      overrides: [
        currentDayBookProvider.overrideWith(
          (ref) => AsyncData(books[ref.watch(selection)]),
        ),
        dayEventsProvider.overrideWith((ref, id) => repo.watchEvents(id)),
      ],
    );
    addTearDown(container.dispose);
    final calendar = calendarDayEventsProvider(DateTime(2026, 9));
    final subscription = container.listen(calendar, (_, _) {});
    addTearDown(subscription.close);
    await container.read(dayEventsProvider(first).future);
    expect(
      container
          .read(calendar)
          .requireValue
          .byDate['2026-09-21']!
          .map((event) => event.id),
      [entryA],
    );
    container.read(selection.notifier).set(second);
    container.read(calendar);
    await container.read(dayEventsProvider(second).future);
    expect(
      container
          .read(calendar)
          .requireValue
          .byDate['2026-09-21']!
          .map((event) => event.id),
      [entryB],
    );
  });

  for (final type in ['normal', 'credentials']) {
    test('$type 日历数量与当天条目只包含当前本，另一本文档不参与', () async {
      final repo = MemoRepository(db);
      for (final id in [first, second]) {
        await repo.createBook(
          id: id,
          name: id == first ? '本A' : '本B',
          type: type,
        );
        await repo.saveEntry(
          MemoEntry(
            id: id == first ? entryA : entryB,
            memoBookId: id,
            bookType: type,
            title: id == first ? '内容A' : '内容B',
            createdAt: date.toUtc(),
            updatedAt: date.toUtc(),
            bodyJson: type == 'normal'
                ? '{"ops":[{"insert":"内容\\n"}]}'
                : encodeMemoFields(const [
                    MemoField(label: '账号', value: 'demo'),
                  ]),
          ),
          await repo.target(id),
          preserveTimes: true,
        );
      }
      for (final id in [first, second]) {
        expect(
          (await repo.watchEntries(id, date: date).first).map(
            (entry) => entry.id,
          ),
          [id == first ? entryA : entryB],
        );
        expect(
          await repo
              .watchCalendarCounts(
                id,
                start: DateTime(2026, 9),
                until: DateTime(2026, 10),
              )
              .first,
          {DateTime(2026, 9, 21): 1},
        );
      }
    });
  }

  test('健身日历区间查询分别绑定空间，不混入另一空间同日训练', () async {
    final a = await createFitnessTestRepository(
      db,
      spaceId: first,
      clock: () => date,
    );
    final b = await createFitnessTestRepository(
      db,
      spaceId: second,
      clock: () => date,
    );
    final workoutA = await a.createBlankWorkout(name: '训练A');
    final workoutB = await b.createBlankWorkout(name: '训练B');
    expect(
      (await a
              .watchWorkoutsInRange(
                DateTime(2026, 9),
                DateTime(2026, 10),
                calendar: true,
              )
              .first)
          .map((workout) => workout.id),
      [workoutA.id],
    );
    expect(
      (await b
              .watchWorkoutsInRange(
                DateTime(2026, 9),
                DateTime(2026, 10),
                calendar: true,
              )
              .first)
          .map((workout) => workout.id),
      [workoutB.id],
    );
  });
}
