import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/day_mapper.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late DayRepository repo;
  String? account;
  var generation = 0;
  const a = '11111111-1111-4111-8111-111111111111';
  const b = '22222222-2222-4222-8222-222222222222';
  const entry = '33333333-3333-4333-8333-333333333333';
  final now = DateTime.utc(2026, 9, 7);

  /// 日期期望固定为生日原始公历，不依赖实现计算断言。
  DayEvent event(String book, {String name = '生日'}) => DayEvent(
    id: entry,
    dayBookId: book,
    definition: DayEventDefinition(
      category: 'birthday',
      name: name,
      repeatType: 'yearly',
      statisticType: 'year',
      event: OriginalDate.solar(DateOnly(2000, 1, 1)),
    ),
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    account = null;
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = DayRepository(
      db,
      validateAndProject: validateAndProject,
      accountIdGetter: () => account,
      generationGetter: () => generation,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
  });
  tearDown(() => db.close());

  test('至今阶段与单次倒数经仓储和云队列保存统一定义', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      storageMode: 'cloud',
      accountId: account,
    );
    for (final definition in [
      DayEventDefinition(
        category: DayCategory.stage,
        name: '至今',
        repeatType: DayRepeatType.none,
        statisticType: DayStatisticType.year,
        start: OriginalDate.solar(DateOnly(2000, 3, 19)),
      ),
      DayEventDefinition(
        category: DayCategory.countdown,
        name: '单次倒数',
        repeatType: DayRepeatType.none,
        statisticType: DayStatisticType.day,
        countdownMode: DayCountdownMode.fixedDate,
        event: OriginalDate.solar(DateOnly(2026, 9, 8)),
      ),
    ]) {
      await repo.saveEvent(
        DayEvent(
          id: entry,
          dayBookId: a,
          definition: definition,
          createdAt: now,
          updatedAt: now,
        ),
        accountId: account,
      );
      final saved = (await repo.getEvents(a, accountId: account)).single;
      expect(saved.definition.repeatType, DayRepeatType.none);
      expect(saved.definition.end, isNull);
      final queued =
          await (db.select(db.syncChanges)
                ..where((c) => c.entityId.equals(entry))
                ..orderBy([(c) => d.OrderingTerm.asc(c.id)]))
              .get();
      expect(
        queued,
        hasLength(definition.category == DayCategory.stage ? 1 : 2),
      );
      final payload = jsonDecode(queued.last.payload) as Map<String, dynamic>;
      expect(payload['end'], isNull);
      expect(payload['repeat_type'], 'none');
      expect(payload['category'], definition.category);
    }
  });

  test('日子上传时间以 UTC 三位毫秒表达同一瞬间，不发送微秒', () {
    final source = DateTime.parse('2026-09-07T08:09:10.123456+08:00');
    final value = DayEvent(
      id: entry,
      dayBookId: a,
      definition: event(a).definition,
      createdAt: source,
      updatedAt: source,
    );
    expect(dayEventPayload(value)['created_at'], '2026-09-07T00:09:10.123Z');
  });

  test('新建云日子本的创建时间符合真实接口的 UTC 毫秒契约', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本时间',
      storageMode: 'cloud',
      accountId: account,
    );
    final change = await db.select(db.syncChanges).getSingle();
    final payload = jsonDecode(change.payload) as Map<String, dynamic>;
    expect(
      payload['created_at'],
      matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$')),
    );
  });

  test('同名本相互隔离，删最后记录保留本，本机无上传队列', () async {
    await repo.createBook(id: a, name: '同名');
    await repo.createBook(id: b, name: '同名');
    await repo.saveEvent(event(a));
    expect(await repo.getEvents(b), isEmpty);
    expect(
      (await repo.getEvents(a)).single.definition.event!.solarDate!.iso8601,
      '2000-01-01',
    );
    await repo.deleteEvent(entry, a);
    expect(await repo.getEvents(a), isEmpty);
    expect(await repo.getBooks(), hasLength(2));
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
  test('保存固定父本，普通编辑不能接管另一父本的记录 ID', () async {
    await repo.createBook(id: a, name: 'A');
    await repo.createBook(id: b, name: 'B');
    await repo.saveEvent(event(a));
    await expectLater(repo.saveEvent(event(b)), throwsStateError);
    expect(await repo.getEvents(b), isEmpty);
    expect((await repo.getEvents(a)).single.id, entry);
  });
  test('云本与记录同事务登记账号及父依赖，其他账号无法读写', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      storageMode: 'cloud',
      accountId: account,
    );
    await repo.saveEvent(event(a), accountId: account);
    final queue = await (db.select(
      db.syncChanges,
    )..orderBy([(c) => d.OrderingTerm.asc(c.id)])).get();
    expect(queue.map((c) => c.entityType), ['day_book', 'day_event']);
    expect(
      queue.every(
        (c) => c.accountId == 'owner' && c.dayBookId == a && c.ledgerId == null,
      ),
      isTrue,
    );
    expect(await repo.getBooks(accountId: 'other'), isEmpty);
    // 换号后本子不可见：目标解析即失败，改名入口拿不到可写目标
    account = 'other';
    await expectLater(repo.target(a), throwsStateError);
  });
  test('保存前账号变化则拒绝原账号写入，业务和队列保持原值', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      storageMode: 'cloud',
      accountId: account,
    );
    account = 'other';
    await expectLater(
      repo.saveEvent(event(a), accountId: 'owner'),
      throwsStateError,
    );
    expect(await repo.getEvents(a, accountId: 'owner'), isEmpty);
    expect(await db.select(db.syncChanges).get(), hasLength(1));
  });
  test('未知提交结果的本创建不可被本删除清空队列', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      storageMode: 'cloud',
      accountId: account,
    );
    await (db.update(db.syncChanges)..where((c) => c.entityId.equals(a))).write(
      const SyncChangesCompanion(
        frozenRequest: d.Value('{"mutation_id":"frozen"}'),
      ),
    );
    await repo.deleteBook(await repo.target(a));
    final queue = await db.select(db.syncChanges).get();
    expect(queue.map((c) => c.action), ['upsert', 'delete']);
    expect(queue.first.frozenRequest, '{"mutation_id":"frozen"}');
  });
}
