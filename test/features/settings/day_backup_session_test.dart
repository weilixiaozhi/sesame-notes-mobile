import 'dart:io';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/mappers/day_mapper.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const a = '11111111-1111-4111-8111-111111111111';
  const ledger = '22222222-2222-4222-8222-222222222222';
  final now = DateTime.utc(2026, 9, 7);
  late Directory temp;
  late SesameDatabase live;
  late BackupImportService service;
  setUp(() async {
    resetGlobalTestState();
    temp = await Directory('Temp').createTemp('day-backup-session-');
    live = SesameDatabase.withExecutor(NativeDatabase.memory());
    service = BackupImportService(tempDirOverride: temp);
  });
  tearDown(() async {
    await live.close();
    await temp.delete(recursive: true);
  });

  /// 记录变化本身影响整本覆盖，不能依赖父本名称或时间戳变化。
  DayEvent event(String id, {String name = '生日'}) => DayEvent(
    id: id,
    dayBookId: a,
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

  /// 构造含日子本和财务本的备份，可选删除业务表以验证缺表校验。
  Future<File> fixture({
    bool missingTables = false,
    bool hidden = false,
    bool withEvent = false,
  }) async {
    final file = File('${temp.path}/source.sqlite');
    final source = SesameDatabase.withExecutor(NativeDatabase(file));
    await source
        .into(source.ledgers)
        .insert(
          LedgersCompanion.insert(id: ledger, name: '备份账本', updatedAt: now),
        );
    await source
        .into(source.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: a,
            name: '备份空日子本',
            createdAt: now,
            updatedAt: now,
            isHidden: d.Value(hidden),
          ),
        );
    if (withEvent) {
      await source
          .into(source.dayEvents)
          .insert(
            dayEventToCompanion(
              event('33333333-3333-4333-8333-333333333333', name: '备份生日'),
            ),
          );
    }
    await source
        .into(source.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'transaction-a',
            ledgerId: ledger,
            txType: 'expense',
            amount: '12.34',
            happenedAt: now,
            currencyCode: 'CNY',
            nativeAmount: '12.34',
            createdAt: now,
            updatedAt: now,
          ),
        );
    final backup = await LocalBackupService(
      databaseFile: file,
      backupDir: Directory('${temp.path}/backups'),
    ).createBackup(db: source);
    await source.close();
    if (!missingTables) return backup;
    final framed = BackupPayloadCodec.decode(await backup.readAsBytes());
    final incompleteFile = File('${temp.path}/incomplete.sqlite');
    await incompleteFile.writeAsBytes(framed.sqliteBytes);
    final edit = sql.sqlite3.open(incompleteFile.path);
    edit.execute('DROP TABLE day_import_receipts');
    edit.execute('DROP TABLE day_events');
    edit.execute('DROP TABLE day_books');
    edit.execute('DROP TABLE memo_import_receipts');
    edit.execute('DROP TABLE memo_entries');
    edit.execute('DROP TABLE memo_books');
    edit.close();
    final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
    final incompleteManifest = BackupManifest(
      formatVersion: manifest.formatVersion,
      dbSchemaVersion: manifest.dbSchemaVersion,
      createdAt: manifest.createdAt,
      deviceId: manifest.deviceId,
      ledgers: manifest.ledgers,
      accounts: manifest.accounts,
    );
    await backup.writeAsBytes(
      BackupPayloadCodec.encode(
        BackupManifestCodec.encodeJson(incompleteManifest),
        await incompleteFile.readAsBytes(),
      ),
    );
    return backup;
  }

  test('缺少业务表的备份拒绝打开，源文件和现场数据不变', () async {
    final repo = DayRepository(live, validateAndProject: validateAndProject);
    await repo.createBook(id: a, name: '现场日子');
    final archive = await fixture(missingTables: true);
    final before = await archive.readAsBytes();
    await expectLater(
      service.openBackup(backupFile: archive),
      throwsA(isA<BackupFormatException>()),
    );
    expect(await archive.readAsBytes(), before);
    expect((await repo.getBook(a))!.name, '现场日子');
    expect(await live.select(live.transactions).get(), isEmpty);
  });

  test('财务与日子共同应用末尾失败全部回滚，零选中不写日志或其他本', () async {
    final archive = await fixture();
    final session = await service.openBackup(backupFile: archive);
    try {
      await service.apply(session: session, liveDb: live, localSelfId: 'self');
      expect(await live.select(live.recoveryLogs).get(), isEmpty);
      session.decisions[ledger] = RecoveryDecision.restoreLocal;
      session.dayBookDecisions[a] = RecoveryDecision.restoreLocal;
      var validations = 0;
      await expectLater(
        service.apply(
          session: session,
          liveDb: live,
          localSelfId: 'self',
          validateContext: () {
            if (++validations == 3) throw StateError('late session change');
          },
        ),
        throwsStateError,
      );
      expect(await live.select(live.ledgers).get(), isEmpty);
      expect(await live.select(live.dayBooks).get(), isEmpty);
      expect(await live.select(live.transactions).get(), isEmpty);
      expect(
        (await live.select(live.recoveryLogs).get()).every(
          (row) => row.result == 'failed',
        ),
        isTrue,
      );
      await service.apply(session: session, liveDb: live, localSelfId: 'self');
      expect((await live.select(live.dayBooks).get()).single.id, a);
      expect(await live.select(live.dayEvents).get(), isEmpty);
    } finally {
      await session.close();
    }
  });

  test('预览后本机本变化拒绝覆盖，未声明却携带日子结构拒绝整份文件', () async {
    final archive = await fixture();
    final session = await service.openBackup(backupFile: archive);
    try {
      session.dayBookDecisions[a] = RecoveryDecision.restoreLocal;
      session.dayTargetSnapshots.addAll(
        await service.captureDayTargets(live, [a]),
      );
      await DayRepository(
        live,
        validateAndProject: validateAndProject,
      ).createBook(id: a, name: '刚创建');
      await expectLater(
        service.apply(session: session, liveDb: live, localSelfId: 'self'),
        throwsStateError,
      );
      expect((await live.select(live.dayBooks).get()).single.name, '刚创建');
    } finally {
      await session.close();
    }
    final framed = BackupPayloadCodec.decode(await archive.readAsBytes());
    final manifest = BackupManifestCodec.decodeJson(framed.manifestJson);
    final undeclared = BackupManifest(
      formatVersion: 1,
      dbSchemaVersion: currentSchemaVersion,
      createdAt: now,
      deviceId: '',
      ledgers: manifest.ledgers,
      accounts: [],
    );
    await archive.writeAsBytes(
      BackupPayloadCodec.encode(
        BackupManifestCodec.encodeJson(undeclared),
        framed.sqliteBytes,
      ),
    );
    await expectLater(
      service.openBackup(backupFile: archive),
      throwsA(isA<BackupFormatException>()),
    );
  });

  for (final change in ['新增', '编辑', '删除']) {
    test('预览后$change日子记录拒绝过期整本覆盖并保留现场', () async {
      const originalId = '33333333-3333-4333-8333-333333333333';
      const addedId = '44444444-4444-4444-8444-444444444444';
      final repo = DayRepository(live, validateAndProject: validateAndProject);
      await repo.createBook(id: a, name: '现场本');
      await repo.saveEvent(event(originalId));
      final archive = await fixture();
      final session = await service.openBackup(backupFile: archive);
      try {
        session.dayBookDecisions[a] = RecoveryDecision.restoreLocal;
        session.dayTargetSnapshots.addAll(
          await service.captureDayTargets(live, [a]),
        );
        switch (change) {
          case '新增':
            await repo.saveEvent(event(addedId));
          case '编辑':
            await repo.saveEvent(event(originalId, name: '刚修改的生日'));
          case '删除':
            await repo.deleteEvent(originalId, a);
        }
        final before = await live.select(live.dayEvents).get();
        await expectLater(
          service.apply(session: session, liveDb: live, localSelfId: 'self'),
          throwsStateError,
        );
        expect(await live.select(live.dayEvents).get(), before);
        expect((await repo.getBook(a))!.name, '现场本');
      } finally {
        await session.close();
      }
    });
  }

  test('备份里的隐藏转换副本恢复为可检查本机本，不重启旧云删除操作', () async {
    final archive = await fixture(hidden: true);
    final session = await service.openBackup(backupFile: archive);
    try {
      session.dayBookDecisions[a] = RecoveryDecision.restoreLocal;
      await service.apply(session: session, liveDb: live, localSelfId: 'self');
      final books = await DayRepository(
        live,
        validateAndProject: validateAndProject,
      ).getBooks();
      expect(books.single.id, a);
      expect(books.single.isHidden, isFalse);
      expect(books.single.storageMode, 'local');
      expect(books.single.sourceOperationId, isNull);
      expect(await live.select(live.syncChanges).get(), isEmpty);
    } finally {
      await session.close();
    }
  });

  test('恢复不接管同ID运行中隐藏副本，独立保护本及记录全部使用新ID', () async {
    const eventId = '33333333-3333-4333-8333-333333333333';
    await live
        .into(live.dayBooks)
        .insert(
          DayBooksCompanion.insert(
            id: a,
            name: '正在转换',
            createdAt: now,
            updatedAt: now,
            isHidden: const d.Value(true),
            sourceOperationId: const d.Value('ongoing-move'),
          ),
        );
    await live
        .into(live.dayEvents)
        .insert(dayEventToCompanion(event(eventId, name: '转换中的最新生日')));
    final originalBook = await live.select(live.dayBooks).getSingle();
    final originalEvent = await live.select(live.dayEvents).getSingle();
    final archive = await fixture(hidden: true, withEvent: true);
    final session = await service.openBackup(backupFile: archive);
    try {
      session.dayBookDecisions[a] = RecoveryDecision.restoreLocal;
      await service.apply(session: session, liveDb: live, localSelfId: 'self');
      final repo = DayRepository(live, validateAndProject: validateAndProject);
      final restored = (await repo.getBooks()).single;
      final restoredEvent = (await repo.getEvents(restored.id)).single;
      expect(restored.id, isNot(a));
      expect(restoredEvent.id, isNot(eventId));
      expect(restoredEvent.dayBookId, restored.id);
      expect(restoredEvent.definition.name, '备份生日');
      expect(restored.sourceOperationId, isNull);
      expect(
        await (live.select(
          live.dayBooks,
        )..where((row) => row.id.equals(a))).getSingle(),
        originalBook,
      );
      expect(
        await (live.select(
          live.dayEvents,
        )..where((row) => row.id.equals(eventId))).getSingle(),
        originalEvent,
      );
    } finally {
      await session.close();
    }
  });
}
