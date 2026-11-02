import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_cleanup_controller.dart';
import 'package:sesame_notes/features/settings/domain/backup_cleanup.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_cleanup_inspector.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_cleanup_storage.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:uuid/uuid.dart';

import '../../helpers/test_isolation.dart';

const _prefix = 'sesame_notes_backups';
const _old = 'sesame_notes_20261019_120000.snbak';
const _a =
    'sesame_notes_20261102_120000_000001_00000000-0000-4000-8000-000000000001.snbak';
const _b =
    'sesame_notes_20261102_120000_000002_00000000-0000-4000-8000-000000000002.snbak';
const _c =
    'sesame_notes_20261102_120000_000003_00000000-0000-4000-8000-000000000003.snbak';
const _cloudSource = BackupCleanupSource(id: 'webdav', displayName: 'WebDAV');
const _localSource = BackupCleanupSource(id: 'local', displayName: 'Local');

/// 假云仅保存在测试内存，任何无条件用户对象删除都直接使测试失败。
class _Cloud extends Fake
    implements CloudStorageService, CloudConditionalDeleteStorage {
  final objects = <String, Uint8List>{};
  final forcedTags = <String, String>{};
  final deleted = <String>[];
  final listed = <String>[];
  final failingDeletes = <String>{};
  int downloads = 0, verified = 0;
  Future<void> Function(String key)? afterDelete;
  Future<void> Function()? onList;
  Completer<void>? readGate, entered;

  /// 每个对象内容形成强标识，测试可固定假标识以单独验证 raw 摘要边界。
  String tag(String key) =>
      forcedTags[key] ?? '"${sha256.convert(objects[key]!)}"';

  /// 故意返回所有键，验证管理层自身拒绝前缀邻居、穿越及未知子目录。
  @override
  Future<List<CloudFile>> list({required String path}) async {
    listed.add(path);
    await onList?.call();
    return [
      for (final entry in objects.entries)
        CloudFile(
          name: entry.key,
          path: entry.key,
          size: entry.value.length,
          lastModified: DateTime.utc(2026, 11, 2),
          metadata: {'etag': tag(entry.key)},
        ),
    ];
  }

  /// 本机隔离文件模拟真实流下载，不访问任何外部存储。
  @override
  Future<bool> downloadFile({
    required String path,
    required File destination,
  }) async {
    downloads++;
    if (entered != null && !entered!.isCompleted) entered!.complete();
    await readGate?.future;
    final bytes = objects[path];
    if (bytes == null) return false;
    await destination.writeAsBytes(bytes);
    return true;
  }

  /// 条件下载必须对应当前列表的强标识，不能回退到另一份同名内容。
  @override
  Future<bool> downloadIfMatch({
    required String path,
    required File destination,
    required String expectedETag,
  }) async {
    if (!objects.containsKey(path)) return false;
    if (tag(path) != expectedETag) {
      throw CloudStorageException('对象已变化', null, 412);
    }
    return downloadFile(path: path, destination: destination);
  }

  /// 协议本身由包内假 HTTP 测试覆盖，管理层仅核对明确领取能力的时机。
  @override
  Future<void> verifyConditionalDelete({required String prefix}) async {
    expect(prefix, _prefix);
    verified++;
  }

  /// 精确模拟 If-Match 条件删除及部分失败，不提供覆盖语义。
  @override
  Future<void> deleteIfMatch({
    required String path,
    required String expectedETag,
  }) async {
    if (!objects.containsKey(path) || tag(path) != expectedETag) {
      throw CloudStorageException('对象已变化', null, 412);
    }
    if (failingDeletes.contains(path)) throw StateError('模拟删除故障');
    objects.remove(path);
    deleted.add(path);
    await afterDelete?.call(path);
  }

  /// 本功能绝不能回退无条件删除。
  @override
  Future<void> delete({required String path}) async =>
      throw StateError('不允许无条件删除用户对象');
}

/// 没有条件删除能力的后端仍可列表和检查，代表现有 Supabase 文件 API。
class _ReadOnlyCloud extends Fake implements CloudStorageService {
  _ReadOnlyCloud(this.delegate);
  final _Cloud delegate;
  @override
  Future<List<CloudFile>> list({required String path}) =>
      delegate.list(path: path);
  @override
  Future<bool> downloadFile({
    required String path,
    required File destination,
  }) => delegate.downloadFile(path: path, destination: destination);
}

/// 阻塞真实恢复的首次打开，检查实际恢复入口是否领取源文件租约。
class _DelayedFile extends Fake implements File {
  _DelayedFile(this.delegate);
  final File delegate;
  final entered = Completer<void>(), release = Completer<void>();
  @override
  String get path => delegate.path;
  @override
  File get absolute => delegate.absolute;
  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) async {
    if (!entered.isCompleted) entered.complete();
    await release.future;
    return delegate.open(mode: mode);
  }

  @override
  Stream<List<int>> openRead([int? start, int? end]) =>
      delegate.openRead(start, end);
  @override
  Future<int> length() => delegate.length();
}

/// 非当前版本只用于鉴别，不重建历史 ORM，也不执行任何迁移。
Uint8List _frame(Uint8List database, int version, DateTime created) {
  final json = version == currentSchemaVersion
      ? BackupManifest(
          formatVersion: 1,
          dbSchemaVersion: version,
          createdAt: created,
          deviceId: 'cleanup-fixture',
          ledgers: const [],
          accounts: const [],
        ).toJson()
      : {
          'format_version': 1,
          'db_schema_version': version,
          'created_at': created.toIso8601String(),
          'device_id': 'cleanup-fixture',
          'ledgers': [],
          'accounts': [],
        };
  return BackupPayloadCodec.encode(
    Uint8List.fromList(utf8.encode(jsonEncode(json))),
    database,
  );
}

/// 每项测试只使用仓库 Temp 内文件及内存假云，原始业务库留在清理目录之外。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory fixtures, workspace, backups;
  late Uint8List currentDb, oldDb, futureDb, unrelatedDb;
  late Uint8List currentA, currentB, currentC, historical;
  late File active;
  late List<BackupCleanupManager> managers;

  setUpAll(() async {
    fixtures = await createTestTempDirectory('cleanup-format-fixtures-');
    final file = File('${fixtures.path}/current.sqlite');
    final db = SesameDatabase.withExecutor(NativeDatabase(file));
    try {
      await db.customSelect('SELECT 1').get();
    } finally {
      await db.close();
    }
    currentDb = await file.readAsBytes();
    for (final version in [9, 11]) {
      final copy = await file.copy('${fixtures.path}/v$version.sqlite');
      final raw = sqlite.sqlite3.open(copy.path);
      try {
        raw.execute('PRAGMA user_version=$version');
      } finally {
        raw.close();
      }
      if (version == 9) {
        oldDb = await copy.readAsBytes();
      } else {
        futureDb = await copy.readAsBytes();
      }
    }
    final foreign = File('${fixtures.path}/foreign.sqlite');
    final raw = sqlite.sqlite3.open(foreign.path);
    try {
      raw.execute('CREATE TABLE unrelated(id TEXT)');
      raw.execute('PRAGMA user_version=9');
    } finally {
      raw.close();
    }
    unrelatedDb = await foreign.readAsBytes();
    currentA = _frame(currentDb, 10, DateTime.utc(2026, 11, 2, 12, 0, 1));
    currentB = _frame(currentDb, 10, DateTime.utc(2026, 11, 2, 12, 0, 2));
    currentC = _frame(currentDb, 10, DateTime.utc(2026, 11, 2, 12, 0, 3));
    historical = _frame(oldDb, 9, DateTime.utc(2026, 10, 19));
  });
  tearDownAll(() async => fixtures.delete(recursive: true));
  setUp(() async {
    resetGlobalTestState();
    workspace = await createTestTempDirectory('backup-cleanup-safety-');
    backups = await Directory('${workspace.path}/backups').create();
    active = await File(
      '${workspace.path}/sesame_notes.sqlite',
    ).writeAsBytes(currentDb);
    managers = [];
  });
  tearDown(() async {
    for (final manager in managers) {
      await manager.dispose();
    }
    expect(await active.readAsBytes(), currentDb, reason: '清理不能读取转换或改写活动业务库');
    await workspace.delete(recursive: true);
  });

  /// 文件策略测试注入验收替身，唯一的正式验收用例另用生产文件工作器覆盖。
  BackupCleanupManager localManager({BackupCleanupInspector? inspector}) {
    final manager = BackupCleanupManager(
      loadSources: () async => [_localSource],
      inspector:
          inspector ?? BackupCleanupInspector(validateCurrent: (_) async {}),
      openStorage: (_) async => LocalBackupCleanupStorage(
        directory: backups,
        requireCurrent: () async {},
        sessionCurrent: () => true,
        temporaryDirectory: () async => workspace,
      ),
    );
    managers.add(manager);
    return manager;
  }

  /// 来源和会话由闭包固定，模拟配置或账号切换时拒绝旧确认。
  BackupCleanupManager cloudManager(
    _Cloud cloud, {
    CloudStorageService? storage,
    int Function()? epoch,
  }) {
    final scope = const Uuid().v4();
    final manager = BackupCleanupManager(
      loadSources: () async => [_cloudSource],
      inspector: BackupCleanupInspector(validateCurrent: (_) async {}),
      openStorage: (_) async {
        final identity = epoch?.call() ?? 0;
        bool current() => (epoch?.call() ?? 0) == identity;
        return CloudBackupCleanupStorage(
          storage: storage ?? cloud,
          scope: scope,
          prefix: _prefix,
          sessionCurrent: current,
          close: () async {},
          requireCurrent: () async {
            if (!current()) {
              throw const BackupCleanupException(
                BackupCleanupFailure.stalePreview,
              );
            }
          },
          temporaryDirectory: () async => workspace,
        );
      },
    );
    managers.add(manager);
    return manager;
  }

  test('云预览不下载，合法UUID碰撞key保留，越界和未知子目录不列入', () async {
    final cloud = _Cloud()
      ..objects.addAll({
        '$_prefix/$_a': currentA,
        '$_prefix/11111111-1111-4111-8111-111111111111/$_b': currentB,
        '${_prefix}_other/$_c': currentC,
        '$_prefix/archive/foreign/$_c': currentC,
        '$_prefix/../$_c': currentC,
        '$_prefix/%2e%2e/$_c': currentC,
      });
    final manager = cloudManager(cloud);
    final preview = await manager.preview('webdav');
    expect(preview.entries, hasLength(2));
    expect(preview.entries.every((entry) => !entry.canDelete), isTrue);
    expect(cloud.downloads, 0);
    expect(cloud.listed, everyElement('$_prefix/'));
  });

  test('当前Base64与binary只按实际帧识别，原始摘要不按编码猜历史', () async {
    final cloud = _Cloud()
      ..objects.addAll({
        '$_prefix/$_a': Uint8List.fromList(utf8.encode(base64Encode(currentA))),
        '$_prefix/$_b': currentB,
      });
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, '$_prefix/$_a');
    expect(
      preview.entries.firstWhere((entry) => entry.key.endsWith(_a)).status,
      BackupCleanupStatus.current,
    );
    preview = await manager.inspect(preview, '$_prefix/$_b');
    expect(
      preview.entries.where(
        (entry) => entry.status == BackupCleanupStatus.current,
      ),
      hasLength(2),
    );
    expect(
      preview.entries.singleWhere((entry) => entry.isProtected).key,
      '$_prefix/$_b',
    );
    await expectLater(
      manager.delete(preview, {'$_prefix/$_b'}),
      throwsA(
        isA<BackupCleanupException>().having(
          (e) => e.reason,
          '保护',
          BackupCleanupFailure.protectedBackup,
        ),
      ),
    );
  });

  test('同创建时间按key统一全序保护，不依赖后端列表顺序', () async {
    final cloud = _Cloud()
      ..objects.addAll({'$_prefix/$_b': currentA, '$_prefix/$_a': currentA});
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, '$_prefix/$_a');
    preview = await manager.inspect(preview, '$_prefix/$_b');
    expect(
      preview.entries.singleWhere((entry) => entry.isProtected).key,
      '$_prefix/$_b',
    );
  });

  test('显式本机清理仅删除选中旧项，保留当前有效快照及目录外业务库', () async {
    await File('${backups.path}/$_a').writeAsBytes(currentA);
    final kept = await File('${backups.path}/$_b').writeAsBytes(currentB);
    await File('${backups.path}/$_old').writeAsBytes(historical);
    final manager = localManager();
    var preview = await manager.preview('local');
    for (final name in [_a, _b, _old]) {
      preview = await manager.inspect(preview, name);
    }
    final result = await manager.delete(preview, {_a, _old});
    expect((result.deletedCount, result.failedCount), (2, 0));
    expect(await kept.readAsBytes(), currentB);
    expect(
      (await backups.list().toList()).map((file) => p.normalize(file.path)),
      [p.normalize(kept.path)],
    );
  });

  test('没有原子条件能力的云来源只读检查，不授直接删除资格', () async {
    final cloud = _Cloud()..objects['$_prefix/$_old'] = historical;
    final manager = cloudManager(cloud, storage: _ReadOnlyCloud(cloud));
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, '$_prefix/$_old');
    expect(preview.supportsDeletion, isFalse);
    expect(preview.entries.single.status, BackupCleanupStatus.unsupported);
    expect(preview.entries.single.canDelete, isFalse);
    await expectLater(
      manager.delete(preview, {'$_prefix/$_old'}, allowNoCurrentBackup: true),
      throwsA(isA<BackupCleanupException>()),
    );
    expect(cloud.deleted, isEmpty);
  });

  test('无当前备份时仅额外确认后的已核实历史文件可删，未知文件原样保留', () async {
    await File('${backups.path}/$_old').writeAsBytes(historical);
    final unknown = await File(
      '${backups.path}/personal.json',
    ).writeAsString('{"note":"保留"}');
    final manager = localManager();
    var preview = await manager.preview('local');
    preview = await manager.inspect(preview, _old);
    preview = await manager.inspect(preview, 'personal.json');
    expect(
      preview.entries
          .singleWhere((entry) => entry.key == 'personal.json')
          .canDelete,
      isFalse,
    );
    await expectLater(
      manager.delete(preview, {_old}),
      throwsA(
        isA<BackupCleanupException>().having(
          (e) => e.reason,
          '额外确认',
          BackupCleanupFailure.noCurrentBackup,
        ),
      ),
    );
    final result = await manager.delete(preview, {
      _old,
    }, allowNoCurrentBackup: true);
    expect((result.deletedCount, result.failedCount), (1, 0));
    expect(await unknown.readAsString(), '{"note":"保留"}');
  });

  for (final version in [11, 999]) {
    test('未来schema$version及辅助后缀不能取得历史删除资格', () async {
      final bytes = Uint8List.fromList(futureDb);
      ByteData.sublistView(bytes).setUint32(60, version);
      final file = await File(
        '${workspace.path}/future',
      ).writeAsBytes(_frame(bytes, version, DateTime.utc(2026)));
      final inspector = BackupCleanupInspector(
        validateCurrent: (_) async {},
        clock: () => DateTime.now().add(const Duration(days: 3)),
      );
      for (final name in [_a, '$_a.old']) {
        final result = await inspector.inspect(
          file,
          fileName: name,
          isLocal: true,
          modified: DateTime.now(),
        );
        expect(result.status, BackupCleanupStatus.unknown);
        expect(result.sha256, isNull);
      }
      final raw = await File(
        '${workspace.path}/future-raw',
      ).writeAsBytes(bytes);
      final result = await inspector.inspect(
        raw,
        fileName: '.emergency_1793610000000000.sqlite',
        isLocal: true,
        modified: DateTime.now(),
      );
      expect(result.status, BackupCleanupStatus.unknown);
    });
  }

  test('已知old名里的无关文本和冒名原始SQLite均保留，不能仅按名称或magic授权', () async {
    final text = await File(
      '${workspace.path}/unrelated',
    ).writeAsString('无关文件，请保留');
    final foreign = await File(
      '${workspace.path}/foreign',
    ).writeAsBytes(unrelatedDb);
    final inspector = BackupCleanupInspector(
      validateCurrent: (_) async {},
      clock: () => DateTime.now().add(const Duration(days: 3)),
    );
    final result = await inspector.inspect(
      text,
      fileName: '$_a.old',
      isLocal: true,
      modified: DateTime.now(),
    );
    final rawResult = await inspector.inspect(
      foreign,
      fileName: '.emergency_1793610000000000.sqlite',
      isLocal: true,
      modified: DateTime.now(),
    );
    expect(result.status, BackupCleanupStatus.unknown);
    expect(rawResult.status, BackupCleanupStatus.unknown);
    expect(await text.readAsString(), '无关文件，请保留');
    expect(await foreign.readAsBytes(), unrelatedDb);
  });

  test('检查临时资源只清理本次独占目录，不覆盖或删除既有兄弟文件', () async {
    final file = await File(
      '${workspace.path}/raw',
    ).writeAsBytes(utf8.encode(base64Encode(historical)));
    final decoded = await File('${file.path}.decoded').writeAsString('既有解码文件');
    final sql = await File(
      '${file.path}.historical-check',
    ).writeAsString('既有检查文件');
    final inspector = BackupCleanupInspector(validateCurrent: (_) async {});
    final result = await inspector.inspect(
      file,
      fileName: _old,
      isLocal: false,
      modified: DateTime.now(),
    );
    expect(result.status, BackupCleanupStatus.unsupported);
    expect(await decoded.readAsString(), '既有解码文件');
    expect(await sql.readAsString(), '既有检查文件');
  });

  test('历史辅助只接受完整应用内容，正确旁路与完整old可识别且不恢复', () async {
    final sidecar = await File('${workspace.path}/sidecar').writeAsString(
      jsonEncode({
        'metadata': {
          'app': 'sesame_notes',
          'format': 'snbak',
          'encoding': 'base64',
        },
        'updatedAt': '2026-10-19T12:00:00Z',
      }),
    );
    final old = await File('${workspace.path}/old').writeAsBytes(historical);
    final raw = await File('${workspace.path}/raw').writeAsBytes(oldDb);
    final inspector = BackupCleanupInspector(
      validateCurrent: (_) async {},
      clock: () => DateTime.now().add(const Duration(days: 3)),
    );
    for (final item in [
      (sidecar, '$_old.metadata.json'),
      (old, '$_old.old'),
      (raw, '.emergency_1793610000000000.sqlite'),
    ]) {
      final result = await inspector.inspect(
        item.$1,
        fileName: item.$2,
        isLocal: true,
        modified: DateTime.now(),
      );
      expect(result.status, BackupCleanupStatus.auxiliary);
      expect(result.sha256, isNotNull);
    }
    await sidecar.writeAsString(
      '{"metadata":{"app":"other"},"updatedAt":"2026-10-19T12:00:00Z"}',
    );
    expect(
      (await inspector.inspect(
        sidecar,
        fileName: '$_old.metadata.json',
        isLocal: false,
        modified: DateTime.now(),
      )).status,
      BackupCleanupStatus.unknown,
    );
  });

  test('真实schema1紧急快照允许空设备字符串，缺失或null仍不能认领', () async {
    final database = Uint8List.fromList(oldDb);
    ByteData.sublistView(database).setUint32(60, 1);
    final manifest = <String, Object?>{
      'format_version': 1,
      'db_schema_version': 1,
      'created_at': '2026-09-16T12:00:00Z',
      'device_id': '',
      'ledgers': [],
      'accounts': [],
    };
    final file = File('${workspace.path}/emergency.snbak');
    final inspector = BackupCleanupInspector();
    for (final form in ['empty', 'missing', 'null']) {
      final data = Map<String, Object?>.from(manifest);
      if (form == 'missing') data.remove('device_id');
      if (form == 'null') data['device_id'] = null;
      final bytes = BackupPayloadCodec.encode(
        Uint8List.fromList(utf8.encode(jsonEncode(data))),
        database,
      );
      await file.writeAsBytes(bytes);
      final result = await inspector.inspect(
        file,
        fileName: 'sesame_notes_emergency_20260916_120000.snbak',
        isLocal: true,
        modified: DateTime.now(),
      );
      expect(
        result.status,
        form == 'empty'
            ? BackupCleanupStatus.unsupported
            : BackupCleanupStatus.unknown,
      );
      expect(result.sha256 != null, form == 'empty');
      expect(await file.readAsBytes(), bytes);
    }
  });

  test('pending及近期中间文件不能检查，外部路径不能作为原始key读取', () async {
    await File('${backups.path}/$_a').writeAsBytes(currentA);
    await File('${backups.path}/$_a.pending').writeAsString('');
    await File('${backups.path}/$_old.old').writeAsBytes(historical);
    final manager = localManager();
    final preview = await manager.preview('local');
    expect(
      preview.entries.every((entry) => !entry.canInspect && !entry.canDelete),
      isTrue,
    );
    final storage = LocalBackupCleanupStorage(
      directory: backups,
      requireCurrent: () async {},
      sessionCurrent: () => true,
      temporaryDirectory: () async => workspace,
    );
    await expectLater(
      storage.read(
        const BackupCleanupObject(key: '../sesame_notes.sqlite'),
        (_) async {},
      ),
      throwsA(isA<BackupCleanupException>()),
    );
  });

  test('同key同元数据但raw重新编码后拒删，不只比较解码后的内容', () async {
    final encoded = base64Encode(historical);
    Uint8List representation(int offset) => Uint8List.fromList(
      utf8.encode(
        '${encoded.substring(0, offset)}\n${encoded.substring(offset)}',
      ),
    );
    final key = '$_prefix/$_old';
    final cloud = _Cloud()
      ..objects[key] = representation(12)
      ..forcedTags[key] = '"fixed-reported-tag"';
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, key);
    cloud.objects[key] = representation(20);
    final result = await manager.delete(preview, {
      key,
    }, allowNoCurrentBackup: true);
    expect((result.deletedCount, result.failedCount), (0, 1));
    expect(cloud.objects.containsKey(key), isTrue);
    expect(cloud.deleted, isEmpty);
  });

  test('来源会话变化使检查和删除旧确认失效', () async {
    var epoch = 0;
    final cloud = _Cloud()..objects['$_prefix/$_old'] = historical;
    final manager = cloudManager(cloud, epoch: () => epoch);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, '$_prefix/$_old');
    epoch++;
    await expectLater(
      manager.delete(preview, {'$_prefix/$_old'}, allowNoCurrentBackup: true),
      throwsA(
        isA<BackupCleanupException>().having(
          (e) => e.reason,
          '会话',
          BackupCleanupFailure.stalePreview,
        ),
      ),
    );
    expect(cloud.deleted, isEmpty);
  });

  test('下载后新增pending立即拒删，碰撞子目录仍按原始key删除', () async {
    const key = '$_prefix/11111111-1111-4111-8111-111111111111/$_old';
    final cloud = _Cloud()..objects[key] = historical;
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, key);
    cloud.onList = () async {
      if (cloud.downloads >= 2) cloud.objects['$key.pending'] = Uint8List(0);
    };
    final result = await manager.delete(preview, {
      key,
    }, allowNoCurrentBackup: true);
    expect((result.deletedCount, result.failedCount), (0, 1));
    expect(cloud.deleted, isEmpty);
    cloud.onList = null;
    cloud.objects.remove('$key.pending');
    preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, key);
    final removed = await manager.delete(preview, {
      key,
    }, allowNoCurrentBackup: true);
    expect(removed.deletedCount, 1);
    expect(cloud.deleted, [key]);
  });

  test('独立文件删除失败只保留该项，其余确认项按实际结果反馈且保护项不动', () async {
    final cloud = _Cloud()
      ..objects.addAll({
        '$_prefix/$_a': historical,
        '$_prefix/$_b': historical,
        '$_prefix/$_c': currentC,
      })
      ..failingDeletes.add('$_prefix/$_b');
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    for (final name in [_a, _b, _c]) {
      preview = await manager.inspect(preview, '$_prefix/$name');
    }
    final result = await manager.delete(preview, {
      '$_prefix/$_a',
      '$_prefix/$_b',
    });
    expect((result.deletedCount, result.failedCount), (1, 1));
    expect(cloud.deleted, ['$_prefix/$_a']);
    expect(cloud.objects.keys.toSet(), {'$_prefix/$_b', '$_prefix/$_c'});
  });

  test('删除已经生效但响应异常时结果待确认，刷新按真实云列表收敛', () async {
    final key = '$_prefix/$_old';
    final cloud = _Cloud()..objects[key] = historical;
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, key);
    cloud.afterDelete = (_) async => throw TimeoutException('删除响应未收到');
    final result = await manager.delete(preview, {
      key,
    }, allowNoCurrentBackup: true);
    expect(
      (result.deletedCount, result.failedCount),
      (0, 1),
      reason: '未收到确认不能假定文件已保留，也不能计为确认删除',
    );
    expect(cloud.objects, isEmpty, reason: '服务端可能已经完成请求');
    expect(
      (await manager.preview('webdav')).entries,
      isEmpty,
      reason: '重新列举实际文件，不能沿用旧预览冒称保留',
    );
  });

  test('第一项删除后保护快照消失立即停止余批，部分结果不伪装全成功', () async {
    final cloud = _Cloud()
      ..objects.addAll({
        '$_prefix/$_a': currentA,
        '$_prefix/$_b': currentB,
        '$_prefix/$_c': currentC,
      });
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    for (final name in [_a, _b, _c]) {
      preview = await manager.inspect(preview, '$_prefix/$name');
    }
    cloud.afterDelete = (_) async {
      cloud.objects.remove('$_prefix/$_c');
    };
    final result = await manager.delete(preview, {
      '$_prefix/$_a',
      '$_prefix/$_b',
    });
    expect((result.deletedCount, result.failedCount), (1, 1));
    expect(cloud.deleted, hasLength(1));
    expect(cloud.objects.length, 1);
  });

  test('关闭清理后不继续第二项，已发出的第一项只按实际结果计数', () async {
    final cloud = _Cloud()
      ..objects.addAll({
        '$_prefix/$_a': historical,
        '$_prefix/$_b': historical,
      });
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    for (final name in [_a, _b]) {
      preview = await manager.inspect(preview, '$_prefix/$name');
    }
    final entered = Completer<void>(), release = Completer<void>();
    cloud.afterDelete = (_) async {
      entered.complete();
      await release.future;
    };
    final pending = manager.delete(preview, {
      '$_prefix/$_a',
      '$_prefix/$_b',
    }, allowNoCurrentBackup: true);
    await entered.future;
    manager.cancelPending();
    release.complete();
    final result = await pending;
    expect((result.deletedCount, result.failedCount), (1, 1));
    expect(cloud.deleted, hasLength(1));
  });

  test('无保护快照时在最后列举期间取消，也不能发出该项删除', () async {
    final cloud = _Cloud()..objects['$_prefix/$_old'] = historical;
    final manager = cloudManager(cloud);
    var preview = await manager.preview('webdav');
    preview = await manager.inspect(preview, '$_prefix/$_old');
    var listsAfterDownload = 0;
    cloud.onList = () async {
      if (cloud.downloads >= 2 && ++listsAfterDownload == 2) {
        manager.cancelPending();
      }
    };
    final result = await manager.delete(preview, {
      '$_prefix/$_old',
    }, allowNoCurrentBackup: true);
    expect((result.deletedCount, result.failedCount), (0, 1));
    expect(cloud.deleted, isEmpty);
  });

  test('单飞拒绝并行来源切换，页面关闭后迟到检查不能发布新资格', () async {
    final cloud = _Cloud()..objects['$_prefix/$_old'] = historical;
    final manager = cloudManager(cloud);
    final preview = await manager.preview('webdav');
    cloud.readGate = Completer<void>();
    cloud.entered = Completer<void>();
    final pending = manager.inspect(preview, '$_prefix/$_old');
    await cloud.entered!.future;
    await expectLater(
      manager.preview('webdav'),
      throwsA(
        isA<BackupCleanupException>().having(
          (e) => e.reason,
          '单飞',
          BackupCleanupFailure.busy,
        ),
      ),
    );
    manager.cancelPending();
    cloud.readGate!.complete();
    await expectLater(
      pending,
      throwsA(
        isA<BackupCleanupException>().having(
          (e) => e.reason,
          '关闭',
          BackupCleanupFailure.stalePreview,
        ),
      ),
    );
  });

  test('真实恢复从帧读取开始持租约，显式清理不能删除正在打开的源文件', () async {
    final oldFile = await File('${backups.path}/$_a').writeAsBytes(currentA);
    await File('${backups.path}/$_b').writeAsBytes(currentB);
    final manager = localManager();
    var preview = await manager.preview('local');
    preview = await manager.inspect(preview, _a);
    preview = await manager.inspect(preview, _b);
    final delayed = _DelayedFile(oldFile);
    final pending = BackupImportService(
      tempDirOverride: workspace,
    ).openBackup(backupFile: delayed);
    await delayed.entered.future;
    try {
      final result = await manager.delete(preview, {_a});
      expect((result.deletedCount, result.failedCount), (0, 1));
      expect(await oldFile.readAsBytes(), currentA);
    } finally {
      delayed.release.complete();
    }
    final session = await pending;
    await session.close();
    expect(LocalBackupService.isBackupFileInUse(oldFile), isFalse);
  });

  test('生产文件工作器核验当前内容，辅助原件和活动库均保持不变', () async {
    final file = await File(
      '${workspace.path}/valid.snbak',
    ).writeAsBytes(currentA);
    final before = await file.readAsBytes();
    final result = await BackupCleanupInspector().inspect(
      file,
      fileName: _a,
      isLocal: true,
      modified: DateTime.now(),
    );
    expect(result.status, BackupCleanupStatus.current);
    expect(await file.readAsBytes(), before);
  });
}
