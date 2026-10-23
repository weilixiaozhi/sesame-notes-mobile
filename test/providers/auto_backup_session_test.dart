import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/cloud_service_fixture.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/auto_backup_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/device_identity.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

import '../helpers/test_isolation.dart';

/// 设备身份使用内存存储，备份链路不依赖操作系统安全存储插件。
class _DeviceStore implements DeviceIdStore {
  String? _value;

  /// 返回当前测试设备身份。
  @override
  Future<String?> read() async => _value;

  /// 保存自动生成的设备身份。
  @override
  Future<void> write(String id) async => _value = id;
}

/// 使用与内置后端相同的文件上传能力，记录真正开始发送的时刻。
class _Storage extends Fake implements CloudStorageService {
  final started = Completer<void>();
  final release = Completer<void>();
  final uploaded = <String>[];
  final remoteFiles = <CloudFile>[];
  final deleted = <String>[];
  final uploadedBytesByPath = <String, List<int>>{};
  List<int>? uploadedBytes;
  bool holdUpload = false;
  Object? uploadFailure;

  /// 读取编码后的正式上传载荷；屏障只作用于已经开始的传输。
  @override
  Future<void> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
  }) async {
    uploaded.add(path);
    final failure = uploadFailure;
    if (failure != null) throw failure;
    if (!started.isCompleted) started.complete();
    if (holdUpload) await release.future;
    uploadedBytes = base64Decode(await file.readAsString());
    uploadedBytesByPath[path] = uploadedBytes!;
    remoteFiles.add(CloudFile(name: p.basename(path), path: path));
  }

  /// 返回本轮远端目录快照，覆盖真实上传后的保留策略。
  @override
  Future<List<CloudFile>> list({required String path}) async =>
      remoteFiles.toList();

  /// 只删除被保留策略明确选中的对象，记录路径以核对文件归属。
  @override
  Future<void> delete({required String path}) async {
    deleted.add(path);
    remoteFiles.removeWhere((file) => file.path == path);
  }
}

/// 可观察连接释放，但不访问真实云服务。
class _Provider extends Fake implements CloudProvider {
  _Provider(this.storage);

  @override
  final _Storage storage;
  int disposeCalls = 0;

  /// 会话拒绝和正常发送都必须释放已初始化的后端。
  @override
  Future<void> dispose() async {
    disposeCalls++;
  }
}

/// 从正式 Provider 开始，复现本地发布成功到第三方发送之前的换号窗口。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const backendId = 'auto-session-test';
  late Directory temp;
  late SesameDatabase db;
  late ProviderContainer container;
  late LocalBackupService local;
  late _Storage storage;
  late _Provider provider;
  late Completer<void> initializing;
  late Completer<void> initializeRelease;
  Future<AutoBackupOutcome>? active;

  /// 登录提交采用真实身份代次，同账号重新登录也必须使旧发送守卫失效。
  void signIn(String account) {
    container
        .read(authSessionProvider.notifier)
        .signIn(
          AuthSession(
            accessToken: 'token-$account',
            userId: account,
            deviceId: 'device',
          ),
        );
  }

  setUp(() async {
    resetGlobalTestState();
    await logger.clear();
    temp = await createTestTempDirectory('auto-session-');
    final databaseFile = File(p.join(temp.path, 'live.sqlite'));
    db = SesameDatabase.withExecutor(NativeDatabase(databaseFile));
    storage = _Storage();
    provider = _Provider(storage);
    initializing = Completer<void>();
    initializeRelease = Completer<void>();
    active = null;
    CloudProviderRegistry.register(
      const CloudBackend(id: backendId, displayName: '测试后端', fields: []),
      (config) async {
        if (!initializing.isCompleted) initializing.complete();
        await initializeRelease.future;
        return provider;
      },
    );
    await activateTestCloudConfig(
      CloudServiceStore(),
      const CloudServiceConfig(backendId: backendId, settings: {}),
    );
    local = LocalBackupService(
      backupDir: Directory(p.join(temp.path, 'backups')),
      databaseFile: databaseFile,
      maxBackups: 1,
      accountIdGetter: () => container.read(currentAccountIdProvider),
      sessionGenerationGetter: () =>
          container.read(authIdentityGenerationProvider),
      clock: () => DateTime(2026, 10, 19, 12, 0, 0, 321, 456),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        apiClientProvider.overrideWithValue(SesameApiClient()),
        deviceIdentityProvider.overrideWithValue(
          DeviceIdentity(_DeviceStore()),
        ),
        localBackupServiceProvider.overrideWithValue(local),
      ],
    );
    signIn('account-a');
    for (final account in [null, 'account-a', 'account-b']) {
      await db
          .into(db.dayBooks)
          .insert(
            DayBooksCompanion.insert(
              id: account ?? 'local',
              name: account ?? 'local',
              storageMode: d.Value(account == null ? 'local' : 'cloud'),
              scopeAccountId: d.Value(account),
              serverRevision: d.Value(account == null ? null : 0),
              createdAt: DateTime.utc(2026),
              updatedAt: DateTime.utc(2026),
            ),
          );
    }
  });

  tearDown(() async {
    if (!initializeRelease.isCompleted) initializeRelease.complete();
    if (!storage.release.isCompleted) storage.release.complete();
    try {
      await active;
    } finally {
      container.dispose();
      await db.close();
      CloudProviderRegistry.unregister(backendId);
      await temp.delete(recursive: true);
      await logger.clear();
    }
  });

  /// 只在真实本地备份完成并开始初始化云后端后，才允许测试改变身份。
  Future<File> startUntilCloudInitialization() async {
    final coordinator = container.read(autoBackupCoordinatorProvider);
    active = coordinator.runOnLaunch();
    await Future.any([
      initializing.future,
      active!.then<void>((outcome) {
        if (!initializing.isCompleted) {
          throw StateError('自动备份未到达云端初始化阶段: $outcome');
        }
      }),
    ]);
    final backups = await local.listBackups();
    expect(backups, hasLength(1));
    final file = backups.single.file;
    final payload = BackupPayloadCodec.decode(await file.readAsBytes());
    final manifest = BackupManifestCodec.decodeJson(payload.manifestJson);
    expect(
      manifest.dayBooks.map((book) => book.dayBookId),
      unorderedEquals(['local', 'account-a']),
      reason: '待上传文件已经按原账号生成，后续守卫不能改用新账号身份',
    );
    return file;
  }

  test('手动云上传失败保留原始原因和本地快照，不写成功时间', () async {
    final failure = StateError('测试云端连接失败');
    storage.uploadFailure = failure;
    initializeRelease.complete();
    await expectLater(
      performManualBackup(read: container.read, confirm: (_) async => true),
      throwsA(
        isA<BackupUploadFailedException>().having(
          (error) => error.cause,
          '原始失败',
          same(failure),
        ),
      ),
    );
    final files = await local.listBackups();
    expect(files, hasLength(1));
    expect(await files.single.file.exists(), isTrue);
    expect(await db.select(db.backupState).get(), isEmpty);
    expect(provider.disposeCalls, 1);
  });

  test('云端秒级备份按最近五份管理，其他文件不因格式旧或名称相近被删除', () async {
    final names = [
      for (var second = 0; second < 5; second++)
        'sesame_notes_20260701_12000$second.snbak',
      'sesame_notes_20260230_120000.snbak',
      'readme.txt',
    ];
    storage.remoteFiles.addAll([
      for (final name in names)
        CloudFile(name: name, path: '$cloudBackupDirectory/$name'),
    ]);
    initializeRelease.complete();

    expect(
      await performManualBackup(
        read: container.read,
        confirm: (_) async => true,
      ),
      isTrue,
    );
    final file = (await local.listBackups()).single.file;
    expect(await file.exists(), isTrue);
    expect(storage.deleted, ['$cloudBackupDirectory/${names.first}']);
    expect(
      storage.remoteFiles.map((item) => item.name),
      containsAll(names.skip(1)),
    );
    expect(
      storage.remoteFiles.map((item) => item.name),
      contains(p.basename(file.path)),
    );
    expect(provider.disposeCalls, 1);
  });
  for (final account in ['account-b', 'account-a']) {
    test(
      '自动云端初始化期间${account == 'account-a' ? '同账号重新登录' : '换号'}，拒绝开始上传并保留本地备份',
      () async {
        final file = await startUntilCloudInitialization();
        signIn(account);
        initializeRelease.complete();
        expect(await active, AutoBackupOutcome.failed);
        expect(storage.uploaded, isEmpty);
        expect(await file.exists(), isTrue);
        expect(await local.listBackups(), hasLength(1));
        final state = await db.select(db.backupState).getSingle();
        expect(state.lastSuccessAt, isNull);
        expect(state.currentProvider, isNull);
        expect(state.dirtySince, isNotNull);
        expect(provider.disposeCalls, 1);
        expect(
          await Directory(p.join(temp.path, 'backups'))
              .list()
              .where(
                (entry) => p.basename(entry.path).startsWith('.cloud-upload-'),
              )
              .toList(),
          isEmpty,
        );
      },
    );
  }

  for (final refreshToken in [false, true]) {
    test('自动备份${refreshToken ? '仅刷新令牌' : '身份保持不变'}时正常发送原快照并按设备日去重', () async {
      final file = await startUntilCloudInitialization();
      if (refreshToken) {
        container
            .read(authSessionProvider.notifier)
            .updateToken('renewed-token');
      }
      initializeRelease.complete();
      expect(await active, AutoBackupOutcome.success);
      expect(storage.uploaded, hasLength(1));
      expect(storage.uploadedBytes, await file.readAsBytes());
      final state = await db.select(db.backupState).getSingle();
      expect(state.lastSuccessAt, isNotNull);
      expect(state.currentProvider, backendId);
      expect(provider.disposeCalls, 1);
      expect(
        await container.read(autoBackupCoordinatorProvider).runOnLaunch(),
        AutoBackupOutcome.skipped,
      );
      expect(storage.uploaded, hasLength(1));
    });
  }

  test('首份备份等待云初始化时生成同秒新快照，两次上传路径和内容保持独立', () async {
    try {
      final first = await startUntilCloudInitialization();
      final firstBytes = await first.readAsBytes();
      await (db.update(db.dayBooks)..where((row) => row.id.equals('account-a')))
          .write(const DayBooksCompanion(name: d.Value('第二份快照中的本子')));
      final second = await local.createBackup(
        db: db,
        currentAccountId: 'account-a',
        trigger: BackupTrigger.automatic,
      );
      final secondBytes = await second.readAsBytes();

      expect(second.path, isNot(first.path));
      expect(secondBytes, isNot(firstBytes));
      expect(await first.readAsBytes(), firstBytes);
      expect(
        await local.listBackups(),
        hasLength(2),
        reason: '等待云端初始化的首份快照仍在被读取，保留清理应暂时跳过',
      );
      initializeRelease.complete();
      expect(await active, AutoBackupOutcome.success);
      expect(storage.uploadedBytes, firstBytes);
      expect(await uploadBackupFile(second), backendId);

      expect(storage.uploaded.toSet(), hasLength(2));
      expect(storage.uploadedBytesByPath, {
        '$cloudBackupDirectory/${p.basename(first.path)}': firstBytes,
        '$cloudBackupDirectory/${p.basename(second.path)}': secondBytes,
      });
      expect(await local.listBackups(), hasLength(2));
      await local.pruneBackups();
      expect((await local.listBackups()).single.file.path, second.path);
      expect(await first.exists(), isFalse, reason: '传输释放后由后续保留清理收敛到原上限');
    } catch (error, stackTrace) {
      logger.error('AutoBackupSessionTest', '备份在途上传隔离验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('SDK上传已经开始后换号，允许已发起传输完成并保留设备级成功语义', () async {
    storage.holdUpload = true;
    final file = await startUntilCloudInitialization();
    initializeRelease.complete();
    await Future.any([
      storage.started.future,
      active!.then<void>((outcome) {
        if (!storage.started.isCompleted) {
          throw StateError('自动备份未开始发送: $outcome');
        }
      }),
    ]);
    await local.createBackup(
      db: db,
      currentAccountId: 'account-a',
      trigger: BackupTrigger.automatic,
    );
    expect(await file.exists(), isTrue, reason: '上传过程中首份快照持有读取租约，不受一份保留上限影响');
    signIn('account-b');
    storage.release.complete();
    expect(await active, AutoBackupOutcome.success);
    expect(storage.uploaded, hasLength(1));
    expect(storage.uploadedBytes, await file.readAsBytes());
    final state = await db.select(db.backupState).getSingle();
    expect(state.lastSuccessAt, isNotNull);
    expect(state.currentProvider, backendId);
    expect(await file.exists(), isTrue);
  });
}
