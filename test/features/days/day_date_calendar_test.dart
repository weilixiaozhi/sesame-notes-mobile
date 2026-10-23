import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/application/day_editor_actions.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bookId = '11111111-1111-4111-8111-111111111111';
  const eventId = '22222222-2222-4222-8222-222222222222';
  final stamp = DateTime.utc(2026, 9, 8);

  /// 缺少公历投影的原始日期，只能由用户重新确认后修复。
  OriginalDate damagedLunar() => const OriginalDate(
    calendarType: DayCalendarType.lunar,
    originalYear: 2023,
    originalMonth: 2,
    originalDay: 1,
    isLeapMonth: true,
  );

  test('公历切农历只改表达：闰二月初一仍是同一个公历日', () {
    final lunar = convertDayCalendar(
      OriginalDate.solar(DateOnly(2023, 3, 22)),
      DayCalendarType.lunar,
    );
    expect(lunar.calendarType, DayCalendarType.lunar);
    expect(lunar.originalYear, 2023);
    expect(lunar.originalMonth, 2);
    expect(lunar.originalDay, 1);
    expect(lunar.isLeapMonth, isTrue);
    expect(lunar.solarDate, DateOnly(2023, 3, 22));
  });

  test('农历切回公历还原同一个公历日', () {
    final lunar = convertDayCalendar(
      OriginalDate.solar(DateOnly(2023, 3, 22)),
      DayCalendarType.lunar,
    );
    final roundTrip = convertDayCalendar(lunar, DayCalendarType.solar);
    expect(roundTrip.calendarType, DayCalendarType.solar);
    expect(roundTrip.originalYear, 2023);
    expect(roundTrip.originalMonth, 3);
    expect(roundTrip.originalDay, 22);
    expect(roundTrip.solarDate, DateOnly(2023, 3, 22));
  });

  test('已是目标历法时原值原样返回，不重新解释日期', () {
    final solar = OriginalDate.solar(DateOnly(2023, 3, 22));
    final damaged = damagedLunar();
    expect(convertDayCalendar(solar, DayCalendarType.solar), same(solar));
    expect(convertDayCalendar(damaged, DayCalendarType.lunar), same(damaged));
  });

  test('损坏投影不得被历法切换绕过修复确认', () {
    expect(
      () => convertDayCalendar(damagedLunar(), DayCalendarType.solar),
      throwsA(
        predicate(
          (error) =>
              error is DayDateException &&
              error.code == 'unreadable_projection',
        ),
      ),
    );
    // 公历端点缺少投影时同样不能被换算成农历。
    const damagedSolar = OriginalDate(
      calendarType: DayCalendarType.solar,
      originalYear: 2023,
      originalMonth: 3,
      originalDay: 22,
    );
    expect(
      () => convertDayCalendar(damagedSolar, DayCalendarType.lunar),
      throwsA(isA<DayDateException>()),
    );
  });

  test('待确认的原始日期不参与保存，重新确认前不落库', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repository = DayRepository(
      db,
      validateAndProject: validateAndProject,
    );
    addTearDown(db.close);
    final book = await repository.createBook(id: bookId, name: '家庭日子');
    final today = DateOnly(2026, 9, 8);
    final anchor = OriginalDate.solar(today);
    await expectLater(
      saveDayEditorEvent(
        repository: repository,
        args: DayEditorArgs(
          generation: 0,
          book: book,
          accountId: null,
          event: DayEvent(
            id: eventId,
            dayBookId: bookId,
            definition: DayEventDefinition(
              category: DayCategory.birthday,
              name: '爸爸生日',
              repeatType: DayRepeatType.yearly,
              statisticType: DayStatisticType.year,
              event: damagedLunar(),
            ),
            createdAt: stamp,
            updatedAt: stamp,
            hasUnreadableDate: true,
          ),
        ),
        currentAccountId: null,
        unconfirmedDates: const {'event'},
        draft: (
          category: DayCategory.birthday,
          countdown: DayCountdownMode.fixedDate,
          repeat: DayRepeatType.yearly,
          statistic: DayStatisticType.year,
          name: '爸爸生日',
          intervalText: '1',
          event: anchor,
          start: anchor,
          end: anchor,
          untilPresent: true,
          today: today,
        ),
        eventId: eventId,
        createdAt: stamp,
      ),
      throwsA(
        predicate(
          (error) =>
              error is DayDateException &&
              error.code == 'date_confirmation_required',
        ),
      ),
    );
    expect(await repository.getEvents(bookId), isEmpty);
  });
}
