/// Mine 页「备份与云同步」统一入口（CloudServiceEntryTile）状态映射测试。
///
/// 需求锚点：
/// - 入口标题恒为「备份与云同步」，不展示副标题；
/// - 图标按备份状态切换：仅本地 / 已配置未启用 / 已启用无成功 /
///   已启用有成功 / 失败待重试；
/// - 状态计算为纯函数 [cloudBackupEntryStatusOf]，widget 只做渲染。
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/ledgers/presentation/cloud_service_entry_tile.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../../helpers/cloud_backend_registration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void Function()? unregisterBackends;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    unregisterBackends = registerRealCloudBackends();
  });
  tearDown(() => unregisterBackends?.call());

  group('cloudBackupStatusOf 纯函数映射', () {
    test('仅本地备份（无任何第三方配置）', () {
      const overview = CloudBackupOverview(
        active: CloudServiceConfig.local,
        backends: [],
      );
      expect(cloudBackupStatusOf(overview), CloudBackupStatusKind.localOnly);
    });

    test('已配置未启用（有第三方配置但激活 local）', () {
      const overview = CloudBackupOverview(
        active: CloudServiceConfig.local,
        backends: [
          CloudBackupBackendDisplay(
            id: 'webdav',
            displayName: 'WebDAV',
            fields: [],
            isConfigured: true,
            isActive: false,
            lastSuccessAt: null,
          ),
        ],
      );
      expect(
        cloudBackupStatusOf(overview),
        CloudBackupStatusKind.configuredInactive,
      );
    });

    test('已启用但尚无成功备份', () {
      const overview = CloudBackupOverview(
        active: CloudServiceConfig(backendId: 's3', settings: {}),
        backends: [],
      );
      expect(
        cloudBackupStatusOf(overview),
        CloudBackupStatusKind.activeNoSuccess,
      );
    });

    test('已启用且最近云端上传成功', () {
      final overview = CloudBackupOverview(
        active: const CloudServiceConfig(backendId: 's3', settings: {}),
        backends: const [],
        lastSuccessAt: DateTime(2026, 9, 1, 8, 30),
        lastSuccessProvider: 's3',
      );
      expect(cloudBackupStatusOf(overview), CloudBackupStatusKind.success);
    });

    test('仅有本地快照成功（未上传云端）不算云端成功', () {
      // 未配置备份密码时云端上传被跳过：lastSuccessAt 有值但提供方为 null。
      final overview = CloudBackupOverview(
        active: const CloudServiceConfig(backendId: 's3', settings: {}),
        backends: const [],
        lastSuccessAt: DateTime(2026, 9, 1, 8, 30),
        lastSuccessProvider: null,
      );
      expect(
        cloudBackupStatusOf(overview),
        CloudBackupStatusKind.activeNoSuccess,
      );
    });

    test('上次失败待重试优先于其他状态', () {
      const overview = CloudBackupOverview(
        active: CloudServiceConfig(backendId: 's3', settings: {}),
        backends: [],
        dirtySince: null,
      );
      // 覆盖：dirty 晚于成功时间仍判定失败待重试。
      final dirtyOverview = CloudBackupOverview(
        active: const CloudServiceConfig(backendId: 's3', settings: {}),
        backends: const [],
        lastSuccessAt: DateTime(2026, 8, 1, 8, 0),
        dirtySince: DateTime(2026, 8, 2, 8, 0),
      );
      expect(
        cloudBackupStatusOf(overview),
        CloudBackupStatusKind.activeNoSuccess,
      );
      expect(cloudBackupStatusOf(dirtyOverview), CloudBackupStatusKind.failed);
    });
  });

  testWidgets('入口标题为「备份与云同步」、不展示副标题且点击回调触发', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    var tapped = false;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CloudServiceEntryTile(onTap: () => tapped = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('备份与云同步'), findsOneWidget);
    // 入口不展示备份状态副标题（我的页统一去掉副标题）。
    expect(find.text('仅本地备份'), findsNothing);
    await tester.tap(find.text('备份与云同步'));
    expect(tapped, isTrue);
  });
}
