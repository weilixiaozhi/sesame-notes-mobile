import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/application/day_editor_actions.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const bookId = 'f0574b63-5417-41a4-9f05-7dff4d5d526e';
  const otherBookId = 'de1ce6ad-527c-4ac5-bf39-913ee1d662f1';
  const countdownId = '939f9f93-7a1c-4270-850c-4f9957f1529c';
  const birthdayId = '7e1a5c24-8f3b-4d61-9c02-5b7a1f0d3e88';
  final today = DateOnly(2026, 9, 7);
  final stamp = DateTime.utc(2026, 9, 1);

  late SesameDatabase db;
  late DayRepository repository;
  late DayBook book;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = DayRepository(db, validateAndProject: validateAndProject);
    book = await repository.createBook(
      id: bookId,
      name: 'A',
      storageMode: 'local',
    );
    container = ProviderContainer(
      overrides: [
        dayRepositoryProvider.overrideWithValue(repository),
        dayTodayProvider.overrideWithValue(today),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 编辑器表单快照：默认阶段至今，首日取设备今天。
  DayEditorDraft draft({
    String category = DayCategory.stage,
    String countdown = DayCountdownMode.fixedDate,
    String repeat = DayRepeatType.none,
    String statistic = DayStatisticType.year,
    String name = '阶段',
    String intervalText = '1',
    OriginalDate? event,
    OriginalDate? start,
    OriginalDate? end,
    bool untilPresent = true,
  }) => (
    category: category,
    countdown: countdown,
    repeat: repeat,
    statistic: statistic,
    name: name,
    intervalText: intervalText,
    event: event ?? OriginalDate.solar(today),
    start: start ?? OriginalDate.solar(today),
    end: end ?? OriginalDate.solar(today),
    untilPresent: untilPresent,
    today: today,
  );

  /// 固定日期倒数：原始公历目标 2026-09-01。
  DayEvent fixedCountdown() => DayEvent(
    id: countdownId,
    dayBookId: bookId,
    definition: DayEventDefinition(
      category: DayCategory.countdown,
      name: '项目倒数',
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.fixedDate,
      event: OriginalDate.solar(DateOnly(2026, 9, 1)),
    ),
    createdAt: stamp,
    updatedAt: stamp,
  );

  /// X 天倒数：原始起点 2026-09-01 加固定间隔。
  DayEvent intervalCountdown({required int intervalDays}) => DayEvent(
    id: countdownId,
    dayBookId: bookId,
    definition: DayEventDefinition(
      category: DayCategory.countdown,
      name: '项目倒数',
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.intervalDays,
      intervalDays: intervalDays,
      start: OriginalDate.solar(DateOnly(2026, 9, 1)),
    ),
    createdAt: stamp,
    updatedAt: stamp,
  );

  /// 正常生日记录用于验证异常记录不影响其他记录。
  DayEvent normalBirthday() => DayEvent(
    id: birthdayId,
    dayBookId: bookId,
    definition: DayEventDefinition(
      category: DayCategory.birthday,
      name: '正常生日',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate.solar(DateOnly(2000, 9, 7)),
    ),
    createdAt: stamp,
    updatedAt: stamp,
  );

  /// 经真实仓储提交编辑器草稿，固定目标本与创建时间。
  Future<DayEventDefinition> save(
    DayEditorDraft value, {
    String eventId = countdownId,
    Set<String> unconfirmed = const {},
    DayEvent? original,
  }) => saveDayEditorEvent(
    repository: repository,
    args: DayEditorArgs(
      generation: 0,
      book: book,
      accountId: null,
      event: original,
    ),
    currentAccountId: null,
    unconfirmedDates: unconfirmed,
    draft: value,
    eventId: eventId,
    createdAt: stamp,
  );

  test('阶段默认至今，切换农历后开始仍指向同一公历日', () async {
    final defaults = buildDayEditorDefinition(draft());
    expect(defaults.start!.solarDate, today);
    expect(defaults.end, isNull);

    // 切换到农历只重新表达原始日期，公历投影保持同一天。
    final lunarStart = convertDayCalendar(
      OriginalDate.solar(today),
      DayCalendarType.lunar,
    );
    final lunarEnd = convertDayCalendar(
      OriginalDate.solar(today),
      DayCalendarType.lunar,
    );
    final saved = await save(
      draft(category: DayCategory.stage, start: lunarStart, end: lunarEnd),
    );
    expect(saved.start!.calendarType, DayCalendarType.lunar);
    expect(saved.start!.solarDate, today);
    expect(saved.end, isNull);

    final stored = (await repository.getEvents(bookId)).single.definition;
    expect(stored.start!.calendarType, DayCalendarType.lunar);
    expect(stored.start!.solarDate, today);
    expect(stored.end, isNull);
  });

  for (final lunar in [false, true]) {
    test('阶段${lunar ? '农历' : '公历'}结束滚轮支持至今与固定日期，取消不提交选择', () async {
      OriginalDate end() => lunar
          ? convertDayCalendar(OriginalDate.solar(today), DayCalendarType.lunar)
          : OriginalDate.solar(today);

      // 取消选择（仍为至今）：结束端点不落库。
      final canceled = await save(
        draft(category: DayCategory.stage, start: end(), end: end()),
      );
      expect(canceled.end, isNull);
      expect(
        (await repository.getEvents(bookId)).single.definition.end,
        isNull,
      );

      // 确认固定日期：按选择的历法保存，实际公历日期不变。
      final confirmed = await save(
        draft(
          category: DayCategory.stage,
          start: end(),
          end: end(),
          untilPresent: false,
        ),
      );
      final expected = lunar ? DayCalendarType.lunar : DayCalendarType.solar;
      expect(confirmed.end!.calendarType, expected);
      expect(confirmed.end!.solarDate, today);
      final stored = (await repository.getEvents(bookId)).single.definition;
      expect(stored.end!.calendarType, expected);
      expect(stored.end!.solarDate, today);
    });
  }

  test('生日与倒数日只保存合法枚举，非法组合零写入', () async {
    final countdownDefinition = await save(
      draft(
        category: DayCategory.countdown,
        repeat: DayRepeatType.none,
        statistic: DayStatisticType.day,
        name: '项目倒数',
        event: OriginalDate.solar(DateOnly(2026, 10, 1)),
      ),
    );
    expect(countdownDefinition.repeatType, DayRepeatType.none);
    expect(countdownDefinition.statisticType, DayStatisticType.day);
    expect(
      (await repository.getEvents(bookId)).single.definition.repeatType,
      DayRepeatType.none,
    );

    // 倒数日不接受年循环，生日不接受无循环与废弃的周岁统计。
    final invalidDrafts = [
      draft(
        category: DayCategory.countdown,
        repeat: DayRepeatType.yearly,
        statistic: DayStatisticType.day,
        event: OriginalDate.solar(DateOnly(2026, 10, 1)),
      ),
      draft(
        category: DayCategory.birthday,
        repeat: DayRepeatType.none,
        event: OriginalDate.solar(DateOnly(2000, 9, 7)),
      ),
      draft(
        category: DayCategory.birthday,
        repeat: DayRepeatType.yearly,
        statistic: 'age',
        event: OriginalDate.solar(DateOnly(2000, 9, 7)),
      ),
    ];
    for (final invalid in invalidDrafts) {
      await expectLater(
        save(invalid, eventId: birthdayId),
        throwsA(isA<DayDateException>()),
      );
    }
    expect(await repository.getEvents(bookId), hasLength(1));
  });

  test('X 天倒数拒绝非法天数，不落库并保留原记录', () async {
    final original = intervalCountdown(intervalDays: 5);
    await repository.saveEvent(original);
    final before = (await db.select(db.dayEvents).get()).single;

    for (final invalid in ['-1', '1.5']) {
      await expectLater(
        save(
          draft(
            category: DayCategory.countdown,
            countdown: DayCountdownMode.intervalDays,
            statistic: DayStatisticType.day,
            name: '项目倒数',
            intervalText: invalid,
            start: OriginalDate.solar(DateOnly(2026, 9, 1)),
          ),
          original: original,
        ),
        throwsA(isA<DayDateException>()),
      );
      expect((await db.select(db.dayEvents).get()).single, before);
      expect(
        (await repository.getEvents(bookId)).single.definition.intervalDays,
        5,
      );
    }
  });

  test('外部切本不改变已打开编辑器的固定目标', () async {
    final other = await repository.createBook(
      id: otherBookId,
      name: 'B',
      storageMode: 'local',
    );
    await container.read(currentDayBookIdProvider.future);
    await container.read(currentDayBookIdProvider.notifier).select(other.id);
    expect(container.read(currentDayBookIdProvider).value, other.id);

    await save(
      draft(
        category: DayCategory.birthday,
        repeat: DayRepeatType.yearly,
        statistic: DayStatisticType.year,
        name: '保留输入',
        event: OriginalDate.solar(DateOnly(2000, 9, 7)),
        start: OriginalDate.solar(today),
        end: OriginalDate.solar(today),
      ),
    );
    expect((await repository.getEvents(bookId)).single.definition.name, '保留输入');
    expect(await repository.getEvents(other.id), isEmpty);
  });

  test('父本删除后保存失败且不产生记录', () async {
    await repository.deleteBook(await repository.target(bookId));
    await expectLater(save(draft()), throwsA(isA<StateError>()));
    expect(await db.select(db.dayEvents).get(), isEmpty);
  });

  test('损坏投影：读取拒绝、必须重新确认，重新选日期后才修复', () async {
    final original = fixedCountdown();
    await repository.saveEvent(original);
    // 损坏投影超出 SQL CHECK 能力，仅在隔离内存库模拟文件损坏。
    await db.customStatement('PRAGMA ignore_check_constraints = ON');
    try {
      await db.customStatement(
        "UPDATE day_events SET event_solar_date = '2026-02-30' WHERE id = ?",
        [countdownId],
      );
    } finally {
      await db.customStatement('PRAGMA ignore_check_constraints = OFF');
    }

    // 严格读取拒绝坏投影，展示流保留原记录并标记不可读。
    await expectLater(
      repository.getEvents(bookId),
      throwsA(isA<DayDateException>()),
    );
    final broken = (await repository.watchEvents(bookId).first).single;
    expect(broken.hasUnreadableDate, isTrue);
    expect(
      () => requireReadableDayDates(broken),
      throwsA(
        isA<DayDateException>().having(
          (error) => error.code,
          'code',
          'unreadable_projection',
        ),
      ),
    );
    final unconfirmed = unconfirmedDayDateKeys(broken);
    expect(unconfirmed, {'event'});

    // 未重新确认（取消日期修复）时任何输入都不写库。
    final before = (await db.select(db.dayEvents).get()).single;
    await expectLater(
      save(
        draft(
          category: DayCategory.countdown,
          statistic: DayStatisticType.day,
          name: '项目倒数',
          event: OriginalDate.solar(DateOnly(2026, 9, 1)),
        ),
        original: broken,
        unconfirmed: unconfirmed,
      ),
      throwsA(
        isA<DayDateException>().having(
          (error) => error.code,
          'code',
          'date_confirmation_required',
        ),
      ),
    );
    expect((await db.select(db.dayEvents).get()).single, before);

    // 用户重新选择日期并确认后才提交修复，名称保持不变。
    final repaired = await save(
      draft(
        category: DayCategory.countdown,
        statistic: DayStatisticType.day,
        name: '项目倒数',
        event: OriginalDate.solar(DateOnly(2026, 9, 1)),
      ),
      original: broken,
    );
    expect(repaired.event!.solarDate!.iso8601, '2026-09-01');
    final stored = (await repository.getEvents(bookId)).single;
    expect(stored.definition.name, '项目倒数');
    expect(stored.definition.event!.solarDate!.iso8601, '2026-09-01');
  });

  test('农历定义不可读：异常记录可定位，正常记录始终可用', () async {
    await repository.saveEvent(normalBirthday());
    await repository.saveEvent(fixedCountdown());
    // 农历真实性超出 SQL CHECK 能力，改成不存在的闰二月三十。
    await db.customStatement(
      "UPDATE day_events SET event_calendar_type = 'lunar', "
      'event_original_year = 2023, event_original_month = 2, '
      'event_original_day = 30, event_is_leap_month = 1, '
      "event_solar_date = '2023-03-22' WHERE id = ?",
      [countdownId],
    );

    final events = await repository.watchEvents(bookId).first;
    expect(events, hasLength(2));
    // 与首页同一口径：正常记录照常算出下次日期，异常记录单独隔离。
    final display = dayDisplayEntries<DateOnly?>(
      events,
      (definition) => const DayDateRules().nextOccurrence(definition, today),
    );
    expect(display.valid.map((event) => event.definition.name), ['正常生日']);
    expect(display.values[birthdayId]!.iso8601, '2026-09-07');
    expect(display.invalid.map((event) => event.id), [countdownId]);

    // 异常记录保留原始定义与名称，用户可定位进入编辑器重新确认。
    final broken = events.firstWhere((event) => event.id == countdownId);
    expect(broken.definition.name, '项目倒数');
    expect(
      () => requireReadableDayDates(broken),
      throwsA(isA<DayDateException>()),
    );
    expect(unconfirmedDayDateKeys(broken), {'event'});

    // 重新选择真实存在的闰二月初一后，投影按新选择修复。
    final repaired = await save(
      draft(
        category: DayCategory.countdown,
        statistic: DayStatisticType.day,
        name: '项目倒数',
        event: const OriginalDate(
          calendarType: DayCalendarType.lunar,
          originalYear: 2023,
          originalMonth: 2,
          originalDay: 1,
          isLeapMonth: true,
        ),
      ),
      original: broken,
    );
    expect(repaired.event!.solarDate!.iso8601, '2023-03-22');
    final stored = (await repository.getEvents(
      bookId,
    )).firstWhere((event) => event.id == countdownId);
    expect(stored.definition.name, '项目倒数');
    expect(stored.definition.event!.solarDate!.iso8601, '2023-03-22');
  });
}
