import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_recovery_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const a = '11111111-1111-4111-8111-111111111111';
  const b = '22222222-2222-4222-8222-222222222222';
  const x = '33333333-3333-4333-8333-333333333333';
  const y = '44444444-4444-4444-8444-444444444444';
  final now = DateTime.utc(2026, 9, 7);
  DayBook book(String id) => DayBook(
    id: id,
    name: id == a ? 'A' : 'B',
    createdAt: now,
    updatedAt: now,
  );
  DayEvent event(String id, String parent) => DayEvent(
    id: id,
    dayBookId: parent,
    definition: DayEventDefinition(
      category: 'birthday',
      name: '生日',
      repeatType: 'yearly',
      statisticType: 'year',
      event: OriginalDate.solar(DateOnly(2000, 1, 1)),
    ),
    createdAt: now,
    updatedAt: now,
  );
  late SesameDatabase db;
  late DayRepository repo;
  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = DayRepository(db, validateAndProject: validateAndProject);
  });
  tearDown(() => db.close());

  test('只恢复A整本替换并保留ID，B与其收据零变更，空本可恢复', () async {
    await repo.createBook(id: a, name: '现场A');
    await repo.createBook(id: b, name: 'B');
    await repo.saveEvent(event(y, a));
    await repo.saveEvent(event(x, b));
    await repo.restoreFromBackup(book: book(a), events: [], receipts: []);
    expect(await repo.getEvents(a), isEmpty);
    expect((await repo.getEvents(b)).single.id, x);
    expect((await repo.getBook(a))!.name, 'A');
    await repo.restoreFromBackup(
      book: book(a),
      events: [event(y, a)],
      receipts: [],
    );
    expect((await repo.getEvents(a)).single.id, y);
  });

  test('跨本ID撞车拒绝整个本地事务，不能接管其他本或留下半份恢复', () async {
    await repo.createBook(id: a, name: '现场A');
    await repo.createBook(id: b, name: '现场B');
    await repo.saveEvent(event(x, b));
    await expectLater(
      db.transaction(() async {
        await repo.restoreFromBackup(
          book: book(a),
          events: [event(y, a)],
          receipts: [],
        );
        await repo.restoreFromBackup(
          book: book(a),
          events: [event(x, a)],
          receipts: [],
        );
      }),
      throwsStateError,
    );
    expect((await repo.getBook(a))!.name, '现场A');
    expect(await repo.getEvents(a), isEmpty);
    expect((await repo.getEvents(b)).single.id, x);
  });

  test('新副本全重映射、清同步身份、继承删除收据，重复CSV不复活', () async {
    final source = DayBook(
      id: a,
      name: '云本',
      storageMode: 'cloud',
      scopeAccountId: 'account-a',
      syncId: 'binding-a',
      createdAt: now,
      updatedAt: now,
    );
    final id = await repo.restoreFromBackup(
      book: source,
      events: [event(x, a)],
      receipts: [
        (exportId: y, sourceEntryId: x, localEventId: x, importedAt: now),
        (exportId: y, sourceEntryId: a, localEventId: null, importedAt: now),
      ],
      forceCopy: true,
    );
    final restored = (await repo.getBook(id))!;
    final child = (await repo.getEvents(id)).single;
    expect(id, isNot(a));
    expect(child.id, isNot(x));
    expect(child.dayBookId, id);
    expect(restored.storageMode, 'local');
    expect(restored.syncId, isNull);
    expect(restored.scopeAccountId, isNull);
    expect(restored.sourceAccountId, 'account-a');
    expect(restored.sourceDayBookId, a);
    expect(await repo.getImportReceipts(id, y), {x, a});
    final receipts = await db.select(db.dayImportReceipts).get();
    expect(
      receipts
          .singleWhere((receipt) => receipt.sourceEntryId == x)
          .localEventId,
      child.id,
    );
  });

  test('当前空业务结构可读，缺少业务表时拒绝且不修改文件', () async {
    final temp = await Directory('Temp').createTemp('day-readonly-');
    addTearDown(() => temp.delete(recursive: true));
    final file = File('${temp.path}/source.sqlite');
    final src = SesameDatabase.withExecutor(NativeDatabase(file));
    await src.customSelect('SELECT 1').get();
    await src.close();
    final manifest = BackupManifest(
      formatVersion: 1,
      dbSchemaVersion: currentSchemaVersion,
      createdAt: now,
      deviceId: '',
      ledgers: [],
      accounts: [],
    );
    final first = BackupRecoveryRepository.open(file.path);
    first.validateDayManifest(manifest);
    first.validateMemoManifest(manifest);
    first.close();
    final editable = sql.sqlite3.open(file.path);
    editable.execute('DROP TABLE day_events');
    editable.execute('DROP TABLE day_books');
    editable.execute('DROP TABLE day_import_receipts');
    editable.close();
    final before = await file.readAsBytes();
    final incomplete = BackupRecoveryRepository.open(file.path);
    expect(
      () => incomplete.validateDayManifest(manifest),
      throwsA(isA<BackupFormatException>()),
    );
    incomplete.listLedgers();
    incomplete.close();
    expect(await file.readAsBytes(), before);
  });
}
