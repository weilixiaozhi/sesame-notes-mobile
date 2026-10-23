import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late DayRepository repo;
  String? account;
  const a = '11111111-1111-4111-8111-111111111111';
  const b = '22222222-2222-4222-8222-222222222222';
  const exportId = '33333333-3333-4333-8333-333333333333';
  const entryId = '44444444-4444-4444-8444-444444444444';
  final createdAt = DateTime.utc(2020, 1, 1);
  final entry = DayEvent(
    id: entryId,
    dayBookId: b,
    definition: DayEventDefinition(
      category: DayCategory.birthday,
      name: '生日',
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate.solar(DateOnly(2000, 1, 1)),
    ),
    createdAt: createdAt,
    updatedAt: createdAt,
  );
  setUp(() {
    account = null;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = DayRepository(
      db,
      validateAndProject: validateAndProject,
      accountIdGetter: () => account,
      generationGetter: () => 0,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
  });
  tearDown(() => db.close());

  for (final cloud in [false, true]) {
    test('CSV导入${cloud ? '云端' : '本机'}本保留来源创建与修改时间', () async {
      account = cloud ? 'owner' : null;
      final modifiedAt = DateTime.utc(2021, 6, 8, 12, 30);
      await repo.createBook(
        id: a,
        name: '目标本',
        accountId: account,
        storageMode: cloud ? 'cloud' : 'local',
      );
      await repo.importIntoBook(
        targetDayBookId: a,
        exportId: exportId,
        entries: [
          DayEvent(
            id: entry.id,
            dayBookId: entry.dayBookId,
            definition: entry.definition,
            createdAt: createdAt,
            updatedAt: modifiedAt,
          ),
        ],
        accountId: account,
      );
      final imported = (await repo.getEvents(a, accountId: account)).single;
      expect(imported.createdAt, DateTime.utc(2020, 1, 1));
      expect(imported.updatedAt, DateTime.utc(2021, 6, 8, 12, 30));
    });
  }

  test('导A导B独立新增、重导A跳过、删除后仍跳过且不切目标', () async {
    await repo.createBook(id: a, name: 'A');
    await repo.createBook(id: b, name: 'B');
    expect(
      await repo.importIntoBook(
        targetDayBookId: a,
        exportId: exportId,
        entries: [entry],
      ),
      (imported: 1, skipped: 0),
    );
    expect(
      await repo.importIntoBook(
        targetDayBookId: b,
        exportId: exportId,
        entries: [entry],
      ),
      (imported: 1, skipped: 0),
    );
    final imported = (await repo.getEvents(a)).single;
    expect(imported.id, isNot(entryId));
    expect(imported.createdAt, createdAt);
    expect(imported.dayBookId, a);
    expect(
      await repo.importIntoBook(
        targetDayBookId: a,
        exportId: exportId,
        entries: [entry],
      ),
      (imported: 0, skipped: 1),
    );
    await repo.deleteEvent(imported.id, a);
    expect(
      await repo.importIntoBook(
        targetDayBookId: a,
        exportId: exportId,
        entries: [entry],
      ),
      (imported: 0, skipped: 1),
    );
    expect(await repo.getImportReceipts(a, exportId), {entryId});
    expect(await db.select(db.syncChanges).get(), isEmpty);
    expect(await repo.getEvents(a), isEmpty);
    expect(await repo.getEvents(b), hasLength(1));
  });

  test('文件重复entry ID在整笔写入前拒绝', () async {
    await repo.createBook(id: a, name: 'A');
    await expectLater(
      repo.importIntoBook(
        targetDayBookId: a,
        exportId: exportId,
        entries: [entry, entry],
      ),
      throwsA(isA<StateError>()),
    );
    expect(await repo.getEvents(a), isEmpty);
    expect(await repo.getImportReceipts(a, exportId), isEmpty);
  });

  test('云目标登记失败，记录与收据整体回滚', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      accountId: account,
      storageMode: 'cloud',
    );
    account = 'other';
    await expectLater(
      repo.importIntoBook(
        targetDayBookId: a,
        exportId: exportId,
        entries: [entry],
        accountId: 'owner',
      ),
      throwsA(isA<StateError>()),
    );
    expect(await repo.getEvents(a, accountId: 'owner'), isEmpty);
    expect(
      await repo.getImportReceipts(a, exportId, accountId: 'owner'),
      isEmpty,
    );
    expect(await db.select(db.syncChanges).get(), hasLength(1));
  });
}
