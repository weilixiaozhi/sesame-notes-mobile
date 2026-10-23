import 'dart:async';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import '../../helpers/test_isolation.dart';

class _Session extends Fake implements RecoverySession {
  int closed = 0;
  @override
  Future<void> close() async {
    if (closed == 0) closed++;
  }

  @override
  final manifest = BackupManifest(
    formatVersion: 1,
    dbSchemaVersion: 1,
    createdAt: DateTime.utc(2026),
    deviceId: 'test',
    ledgers: [],
    accounts: [],
  );
  @override
  final Map<String, String> dayTargetSnapshots = {};
  @override
  final Map<String, String> memoTargetSnapshots = {};
  @override
  final Map<String, String> fitnessTargetSnapshots = {};
}

class _Importer extends BackupImportService {
  final calls = <Completer<RecoverySession>>[];
  @override
  Future<RecoverySession> openBackup({required File backupFile}) {
    final call = Completer<RecoverySession>();
    calls.add(call);
    return call.future;
  }

  @override
  Future<List<RecoveryItem>> listRecoveryItems(RecoverySession session) async =>
      [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _Importer importer;
  late ProviderContainer container;
  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    importer = _Importer();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        backupRestoreFlowProvider.overrideWith(
          () => BackupRestoreFlowNotifier(importService: importer),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });
  test('打开途中销毁，迟到的恢复会话仍关闭且不再写已销毁状态', () async {
    final flow = container.read(backupRestoreFlowProvider.notifier);
    final pending = flow.openBackup(file: File('Temp/probe.snbak'));
    await pumpEventQueue();
    expect(importer.calls, hasLength(1));
    container.dispose();
    final late = _Session();
    importer.calls.single.complete(late);
    await pending;
    expect(late.closed, 1);
  });
  test('后一次打开获胜，旧响应不能覆盖新会话或遗留句柄', () async {
    final flow = container.read(backupRestoreFlowProvider.notifier);
    final first = flow.openBackup(file: File('Temp/first.snbak'));
    await pumpEventQueue();
    final second = flow.openBackup(file: File('Temp/second.snbak'));
    await pumpEventQueue();
    final newer = _Session();
    importer.calls[1].complete(newer);
    await second;
    final older = _Session();
    importer.calls[0].complete(older);
    await first;
    expect(container.read(backupRestoreFlowProvider).session, same(newer));
    expect(older.closed, 1);
    expect(newer.closed, 0);
    await flow.closeSession();
    expect(newer.closed, 1);
  });
}
