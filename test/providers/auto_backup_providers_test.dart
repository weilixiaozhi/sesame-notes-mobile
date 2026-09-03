/// 自动备份编排集成测试（真实 DB + fake 云端后端）。
///
/// - runOnLaunch 走完整链路：本地 .snbak 快照 → 配置密码后上传版本化路径 →
///   backup_state 记录 lastSuccessAt + currentProvider；
/// - 未配置备份密码：不上传云端（设备密钥不得作为云端唯一保护）；
/// - 上传路径时间戳版本化（不固定路径覆盖），云端保留最近 5 份；
/// - 当天已成功 → skipped；未配置第三方 → 只做本地快照。
library;

import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_security_store.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

import '../helpers/test_isolation.dart';

class _FakeStorage implements CloudStorageService {
  final List<String> uploaded = [];
  final List<CloudFile> files = [];

  @override
  Future<void> upload({
    required String path,
    required String data,
    Map<String, String>? metadata,
  }) async {
    uploaded.add(path);
    files.add(CloudFile(name: p.basename(path), path: path, size: data.length));
  }

  @override
  Future<String?> download({required String path}) async => null;

  @override
  Future<void> delete({required String path}) async {
    files.removeWhere((f) => f.path == path);
  }

  @override
  Future<List<CloudFile>> list({required String path}) async {
    return files.where((f) => f.path.startsWith(path)).toList();
  }

  @override
  Future<bool> exists({required String path}) async =>
      files.any((f) => f.path == path);

  @override
  Future<CloudFile?> getMetadata({required String path}) async =>
      files.where((f) => f.path == path).firstOrNull;
}

class _FakeProvider implements CloudProvider {
  final _FakeStorage storageImpl;

  _FakeProvider(this.storageImpl);

  @override
  String get providerId => 'fake';
  @override
  String get providerName => 'Fake';
  @override
  CloudAuthService get auth => throw UnimplementedError();
  @override
  Future<void> initialize(Map<String, dynamic> config) async {}
  @override
  bool validateConfig(Map<String, dynamic> config) => true;
  @override
  Future<void> dispose() async {}
  @override
  CloudStorageService get storage => storageImpl;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late _FakeStorage fakeStorage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    fakeStorage = _FakeStorage();
  });

  tearDown(() async => db.close());

  AutoBackupService buildCoordinator() {
    return AutoBackupService(
      loadLastSuccess: () async {
        final row = await (db.select(
          db.backupState,
        )..where((b) => b.id.equals(0))).getSingleOrNull();
        return row?.lastSuccessAt;
      },
      markSuccess: (t) async {
        await db
            .into(db.backupState)
            .insertOnConflictUpdate(
              BackupStateCompanion.insert(
                id: d.Value(0),
                lastSuccessAt: d.Value(t),
                currentProvider: d.Value(
                  await loadActiveCloudBackupProviderName(),
                ),
              ),
            );
      },
      markDirty: () async {
        await db
            .into(db.backupState)
            .insertOnConflictUpdate(
              BackupStateCompanion.insert(
                id: d.Value(0),
                dirtySince: d.Value(DateTime.now()),
              ),
            );
      },
      createLocalBackup: () async {
        final file = File(
          p.join(
            Directory.systemTemp.path,
            'sesame_notes_${LocalBackupService.formatTimestamp(DateTime.now())}${LocalBackupService.backupExtension}',
          ),
        );
        await file.writeAsString('fake-snapshot');
        addTearDown(() => file.delete());
        return file;
      },
      uploadToCloud: uploadBackupFile,
      now: () => DateTime(2026, 8, 1, 10, 0),
    );
  }

  /// 注册一个测试用后端（字段声明取自测试，核心不关心其具体内容）。
  void registerFakeCloud(String backendId) {
    CloudProviderRegistry.register(
      CloudBackend(
        id: backendId,
        displayName: backendId,
        fields: const [
          CloudConfigField(key: 'url', labelKey: 'url', isRequired: true),
          CloudConfigField(
            key: 'password',
            labelKey: 'pw',
            kind: CloudConfigFieldKind.secret,
          ),
        ],
        importLegacy: (json) => json,
      ),
      (config) async => (provider: _FakeProvider(fakeStorage), auth: null),
    );
    addTearDown(() => CloudProviderRegistry.unregister(backendId));
  }

  /// 构造一份后端配置（字段即 [registerFakeCloud] 声明的两个）。
  CloudServiceConfig fakeCloudConfig(String backendId) => CloudServiceConfig(
    backendId: backendId,
    settings: const {'url': 'https://cloud.example.com', 'password': 'p'},
  );

  test('完整链路：本地快照 + 配置密码后上传版本化路径 + backup_state 记录', () async {
    registerFakeCloud('webdav');
    // 配置备份密码（云端上传的前置条件）
    await BackupSecurityStore().setPassword(password: 'my-secret-password');
    // 激活 WebDAV 配置。
    final store = CloudServiceStore();
    await store.saveAndActivate(fakeCloudConfig('webdav'));

    final outcome = await buildCoordinator().runOnLaunch();

    expect(outcome, AutoBackupOutcome.success);
    expect(fakeStorage.uploaded, hasLength(1));
    final path = fakeStorage.uploaded.single;
    expect(
      path,
      matches(
        RegExp(r'^sesame_notes_backups/sesame_notes_\d{8}_\d{6}\.snbak$'),
      ),
      reason: '上传路径必须时间戳版本化，不固定路径覆盖',
    );
    final state = await (db.select(
      db.backupState,
    )..where((b) => b.id.equals(0))).getSingle();
    expect(state.lastSuccessAt, isNotNull);
    expect(state.currentProvider, 'webdav');
  });

  test('未配置备份密码：不上传云端（设备密钥不得作为云端唯一保护）', () async {
    registerFakeCloud('webdav');
    final store = CloudServiceStore();
    await store.saveAndActivate(fakeCloudConfig('webdav'));

    final outcome = await buildCoordinator().runOnLaunch();

    expect(outcome, AutoBackupOutcome.success, reason: '本地快照成功，不上传不算失败');
    expect(fakeStorage.uploaded, isEmpty);
    final state = await (db.select(
      db.backupState,
    )..where((b) => b.id.equals(0))).getSingle();
    expect(state.currentProvider, isNull, reason: '未上传云端时，不能把本地快照误标为第三方服务备份成功');
  });

  test('云端保留：超过 5 份按时间戳清理最旧', () async {
    registerFakeCloud('s3');
    await BackupSecurityStore().setPassword(password: 'my-secret-password');
    final store = CloudServiceStore();
    await store.saveAndActivate(fakeCloudConfig('s3'));
    // 预置 6 份云端备份（旧到新）
    final base = '$cloudBackupDirectory/sesame_notes_';
    for (var i = 1; i <= 6; i++) {
      final name = '${base}202607${i.toString().padLeft(2, '0')}_090000.snbak';
      fakeStorage.files.add(
        CloudFile(name: p.basename(name), path: name, size: 1),
      );
    }

    // 手动执行上传逻辑（避免按天去重干扰）
    final file = File(
      p.join(
        Directory.systemTemp.path,
        'sesame_notes_20260801_100000${LocalBackupService.backupExtension}',
      ),
    );
    await file.writeAsString('new-backup');
    addTearDown(() => file.delete());
    await uploadBackupFile(file);

    expect(fakeStorage.files.length, 5, reason: '保留最近 5 份');
    expect(
      fakeStorage.files.map((f) => p.basename(f.path)),
      isNot(contains('sesame_notes_20260701_090000.snbak')),
    );
    expect(
      fakeStorage.files.map((f) => p.basename(f.path)),
      contains('sesame_notes_20260801_100000.snbak'),
    );
  });

  test('当天已成功：跳过（不重复备份/上传）', () async {
    registerFakeCloud('s3');
    await BackupSecurityStore().setPassword(password: 'my-secret-password');
    final store = CloudServiceStore();
    await store.saveAndActivate(fakeCloudConfig('s3'));
    final service = buildCoordinator();
    await service.runOnLaunch();
    fakeStorage.uploaded.clear();

    final outcome = await service.runOnLaunch(); // 同一天再次
    expect(outcome, AutoBackupOutcome.skipped);
    expect(fakeStorage.uploaded, isEmpty, reason: '当天已成功不得重复上传');
  });

  test('未配置第三方：只做本地快照，不尝试上传', () async {
    final outcome = await buildCoordinator().runOnLaunch();
    expect(outcome, AutoBackupOutcome.success);
    expect(fakeStorage.uploaded, isEmpty);
  });
}
