/// App 生命周期恢复刷新测试。
///
/// 需求契约：从后台恢复到前台时，主壳必须把当前账本交给统一刷新入口；
/// 本地/云端分流由 SyncCoordinator.refreshData 的既有契约负责。
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shell/app_shell.dart';

import '../helpers/test_isolation.dart';

class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late String ledgerId;
  late _MockSyncCoordinator sync;

  setUp(() async {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgerId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    sync = _MockSyncCoordinator();
    when(
      () => sync.refreshData(ledgerId: ledgerId),
    ).thenAnswer((_) async => const SyncRunResult());
  });

  tearDown(() async => db.close());

  /// 构建主壳，并用当天已完成的备份状态禁用测试无关的文件系统写入。
  Widget buildApp() {
    final backup = AutoBackupService(
      loadLastSuccess: () async => DateTime.now(),
      markSuccess: (_) async {},
      markDirty: () async {},
      createLocalBackup: () async => throw StateError('测试不应创建备份文件'),
      uploadToCloud: (_) async {},
    );
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => ledgerId),
        syncCoordinatorProvider.overrideWithValue(sync),
        autoBackupCoordinatorProvider.overrideWithValue(backup),
      ],
      child: MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SesameNotesApp(),
      ),
    );
  }

  testWidgets('后台恢复前台时，用当前账本调用统一刷新入口', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    verify(() => sync.refreshData(ledgerId: ledgerId)).called(1);
    await tester.pumpWidget(const SizedBox.shrink());
    // Drift 查询流取消订阅时用零延时 Timer 清理；卸载后补一帧冲刷。
    await tester.pump(const Duration(milliseconds: 100));
  });
}
