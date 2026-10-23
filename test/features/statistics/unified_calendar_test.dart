import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/statistics/application/unified_calendar_providers.dart';
import '../../helpers/fitness_space_fixture.dart';

/// 验证统一日历的日期边界、本子隔离和完整记录计数。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('可见网格按整周覆盖跨年补位日，查询结束日不包含在内', () {
    final range = calendarGridRange(DateTime(2027, 1));
    expect(range.start, DateTime(2026, 12, 28));
    expect(range.until, DateTime(2027, 2, 1));
    expect(calendarGridRange(DateTime(2026, 2)).until, DateTime(2026, 3, 2));
  });

  test('不可读取的日期投影保持异常记录，不能自行派生为正常周年', () {
    final stamp = DateTime.utc(2026);
    final event = DayEvent(
      id: 'unreadable',
      dayBookId: 'book',
      definition: DayEventDefinition(
        category: DayCategory.anniversary,
        name: '待修复',
        repeatType: DayRepeatType.yearly,
        statisticType: DayStatisticType.year,
        event: OriginalDate.solar(DateOnly(2020, 9, 21)),
      ),
      createdAt: stamp,
      updatedAt: stamp,
      hasUnreadableDate: true,
    );
    final result = projectCalendarDayEvents([event], DateTime(2026, 9));
    expect(result.byDate, isEmpty);
    expect(result.invalid, [event]);
  });

  test('周年按发生日而非创建日归入日历，阶段同日起止只展示一条', () {
    final stamp = DateTime.utc(2020);
    DayEvent event(String id, DayEventDefinition definition) => DayEvent(
      id: id,
      dayBookId: 'book',
      definition: definition,
      createdAt: stamp,
      updatedAt: stamp,
    );
    final projected = projectCalendarDayEvents([
      event(
        'anniversary',
        DayEventDefinition(
          category: DayCategory.anniversary,
          name: '周年',
          repeatType: DayRepeatType.yearly,
          statisticType: DayStatisticType.year,
          event: OriginalDate.solar(DateOnly(2023, 9, 21)),
        ),
      ),
      event(
        'stage',
        DayEventDefinition(
          category: DayCategory.stage,
          name: '阶段',
          repeatType: DayRepeatType.none,
          statisticType: DayStatisticType.day,
          start: OriginalDate.solar(DateOnly(2026, 9, 21)),
          end: OriginalDate.solar(DateOnly(2026, 9, 21)),
        ),
      ),
    ], DateTime(2026, 9));
    expect(projected.invalid, isEmpty);
    expect(projected.byDate['2026-09-21']!.map((event) => event.id), [
      'anniversary',
      'stage',
    ]);
    expect(projected.byDate.length, 1);
  });

  test('添加训练采用选中日期，真实创建时钟和未开始状态保持不变', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repository = await createFitnessTestRepository(
      db,
      clock: () => DateTime(2026, 9, 21),
    );
    final actions = FitnessActions(
      queryPort: repository,
      workoutPort: repository,
      libraryPort: repository,
      preferencesPort: repository,
    );
    final draft = await actions.createBlankWorkout(
      scheduledDate: DateTime(2026, 8, 31, 23, 59),
    );
    expect(draft.scheduledDate, '2026-08-31');
    expect(draft.runSegments, isEmpty);
    expect(draft.status, 'scheduled');
    expect((await actions.getWorkout(draft.id))!.scheduledDate, '2026-08-31');
  });

  test('月历数量不受列表分页影响，并排除其他本子和区间结束日', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = MemoRepository(db);
    const book = '11111111-1111-4111-8111-111111111111';
    const other = '22222222-2222-4222-8222-222222222222';
    for (final id in [book, other]) {
      await repo.createBook(id: id, name: '本子', type: 'normal');
    }
    for (var index = 0; index < 104; index++) {
      final id = index == 102 ? other : book;
      final date = index == 103
          ? DateTime(2026, 10, 1)
          : DateTime(2026, 9, 21, 23, 59);
      await repo.saveEntry(
        MemoEntry(
          id: '00000000-0000-4000-8000-${index.toString().padLeft(12, '0')}',
          memoBookId: id,
          bookType: 'normal',
          title: '笔记',
          bodyJson: '{"ops":[{"insert":"正文\\n"}]}',
          createdAt: DateTime.utc(2000),
          updatedAt: date.toUtc(),
        ),
        await repo.target(id),
        preserveTimes: true,
      );
    }
    final counts = await repo
        .watchCalendarCounts(
          book,
          start: DateTime(2026, 9),
          until: DateTime(2026, 10),
        )
        .first;
    expect(counts, {DateTime(2026, 9, 21): 102});
    expect(
      await repo
          .watchEntries(book, date: DateTime(2026, 9, 21), limit: 50)
          .first,
      hasLength(50),
    );
  });
}
