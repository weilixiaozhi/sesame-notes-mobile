import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/features/settings/domain/backup_cleanup.dart';
import 'package:sesame_notes/infrastructure/backup/backup_file_access.dart';

import 'local_backup_service.dart';

/// 辅助文件与中间文件共用正式快照的提交标记保护。
String _publicationBase(String key) {
  if (key.endsWith('.metadata.json')) {
    return key.substring(0, key.length - '.metadata.json'.length);
  }
  if (key.endsWith('.tmp') || key.endsWith('.old')) {
    return key.substring(0, key.length - 4);
  }
  return key;
}

/// 列举时固定文件元数据，内容摘要另由用户检查生成。
class BackupCleanupObject {
  const BackupCleanupObject({
    required this.key,
    this.size,
    this.modified,
    this.changed,
    this.tag,
    this.pending = false,
    this.inUse = false,
  });

  final String key;
  final int? size;
  final DateTime? modified;
  final DateTime? changed;
  final String? tag;
  final bool pending, inUse;

  /// 元数据只是首层变化检测，删除时仍必须重新流式核对完整内容摘要。
  bool matches(BackupCleanupObject other) =>
      key == other.key &&
      size == other.size &&
      modified == other.modified &&
      changed == other.changed &&
      tag == other.tag &&
      !other.pending;
}

/// 清理仅通过已固定来源的文件能力工作，不接受任意目录或数据库连接。
abstract class BackupCleanupStorage {
  bool get isLocal;
  bool get supportsDeletion;
  bool canDeleteObject(BackupCleanupObject object);
  Future<void> requireCurrent();
  Future<List<BackupCleanupObject>> list();
  Future<T> read<T>(
    BackupCleanupObject object,
    Future<T> Function(File raw) inspect,
  );
  Future<T> protect<T>(String key, Future<T> Function() action);
  Future<void> delete(
    BackupCleanupObject object,
    Future<void> Function(File raw) verify, {
    Future<void> Function()? beforeDelete,
  });
  Future<void> dispose();
}

/// 本机范围固定为服务认领的 backups 目录，既不扫描父目录，也不跟随链接。
class LocalBackupCleanupStorage implements BackupCleanupStorage {
  LocalBackupCleanupStorage({
    required Directory? directory,
    required Future<void> Function() requireCurrent,
    required bool Function() sessionCurrent,
    Future<Directory> Function()? temporaryDirectory,
  }) : _managedDirectory = directory,
       _validateContext = requireCurrent,
       _sessionIsCurrent = sessionCurrent,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Directory? _managedDirectory;
  final Future<void> Function() _validateContext;
  final bool Function() _sessionIsCurrent;
  final Future<Directory> Function() _temporaryDirectory;
  bool _disposed = false;
  String? _canonicalRoot;

  @override
  bool get isLocal => true;

  @override
  bool get supportsDeletion => true;

  @override
  bool canDeleteObject(BackupCleanupObject object) => true;

  /// 页面关闭或会话变化后拒绝任何后续文件操作。
  @override
  Future<void> requireCurrent() async {
    if (_disposed || !_sessionIsCurrent()) {
      throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
    }
    await _validateContext();
  }

  /// 每次操作重新核对目录本体及规范路径，防止路径被替换为外部链接。
  Future<Directory?> _root() async {
    await requireCurrent();
    final root = _managedDirectory;
    if (root == null) return null;
    final type = await FileSystemEntity.type(root.path, followLinks: false);
    if (type == FileSystemEntityType.notFound) return null;
    if (type != FileSystemEntityType.directory) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    final canonical = p.normalize(await root.resolveSymbolicLinks());
    if (_canonicalRoot != null && canonical != _canonicalRoot) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    _canonicalRoot = canonical;
    return root;
  }

  /// 路径键只能是直属文件名，活动数据库及 WAL/SHM 不属于清理对象。
  Future<File> _file(String key) async {
    final root = await _root();
    if (root == null ||
        key.isEmpty ||
        key != p.basename(key) ||
        key.contains('/') ||
        key.contains('\\') ||
        key == '.' ||
        key == '..' ||
        key == 'sesame_notes.sqlite' ||
        key.endsWith('-wal') ||
        key.endsWith('-shm')) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    final file = File(p.join(root.path, key));
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    return file;
  }

  /// 查询直属普通文件；提交标记和读取租约只展示状态，不授予删除资格。
  @override
  Future<List<BackupCleanupObject>> list() async {
    final root = await _root();
    if (root == null) return [];
    final result = <BackupCleanupObject>[];
    await for (final entry in root.list(followLinks: false)) {
      if (entry is! File) continue;
      final key = p.basename(entry.path);
      if (key == 'sesame_notes.sqlite' ||
          key.endsWith('-wal') ||
          key.endsWith('-shm')) {
        continue;
      }
      final stat = await entry.stat();
      if (stat.type != FileSystemEntityType.file) continue;
      result.add(
        BackupCleanupObject(
          key: key,
          size: stat.size,
          modified: stat.modified,
          changed: stat.changed,
          pending:
              key.endsWith('.pending') ||
              await File('${_publicationBase(entry.path)}.pending').exists(),
          inUse: LocalBackupService.isBackupFileInUse(entry),
        ),
      );
    }
    await requireCurrent();
    return result;
  }

  /// 将固定文件复制到本次独占临时目录，检查和摘要都消费同一份隔离字节。
  Future<T> _copy<T>(
    BackupCleanupObject object,
    Future<T> Function(File raw) action,
  ) async {
    final file = await _file(object.key);
    final stat = await file.stat();
    final actual = BackupCleanupObject(
      key: object.key,
      size: stat.size,
      modified: stat.modified,
      changed: stat.changed,
      pending: await File('${_publicationBase(file.path)}.pending').exists(),
    );
    if (!object.matches(actual)) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    final directory = await (await _temporaryDirectory()).createTemp(
      'backup-cleanup-read-',
    );
    try {
      final copy = await file.copy(p.join(directory.path, 'object'));
      final after = await (await _file(object.key)).stat();
      if (after.size != stat.size ||
          after.modified != stat.modified ||
          after.changed != stat.changed ||
          await File('${_publicationBase(file.path)}.pending').exists()) {
        throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
      }
      await requireCurrent();
      return await action(copy);
    } finally {
      await directory.delete(recursive: true);
    }
  }

  /// 隔离复制期间持有读取租约，自动保留策略及显式清理均不得删除源文件。
  @override
  Future<T> read<T>(
    BackupCleanupObject object,
    Future<T> Function(File raw) inspect,
  ) async => LocalBackupService.withBackupFileRead(
    await _file(object.key),
    () => _copy(object, inspect),
  );

  /// 整批删除期间持续保留已经验证的有效快照。
  @override
  Future<T> protect<T>(String key, Future<T> Function() action) async =>
      LocalBackupService.withBackupFileRead(await _file(key), action);

  /// 预约删除后再次验证副本内容，最后核对原文件类型和元数据才删除精确文件。
  @override
  Future<void> delete(
    BackupCleanupObject object,
    Future<void> Function(File raw) verify, {
    Future<void> Function()? beforeDelete,
  }) async {
    final file = await _file(object.key);
    await LocalBackupService.withBackupFileDeletion(file, () async {
      await _copy(object, verify);
      await requireCurrent();
      final current = await _file(object.key);
      final stat = await current.stat();
      if (!_sessionIsCurrent() ||
          stat.size != object.size ||
          stat.modified != object.modified ||
          stat.changed != object.changed ||
          await File('${_publicationBase(current.path)}.pending').exists()) {
        throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
      }
      await beforeDelete?.call();
      if (!_sessionIsCurrent()) {
        throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
      }
      await current.delete();
    });
  }

  /// 本机来源不持有数据库或远端连接。
  @override
  Future<void> dispose() async => _disposed = true;
}

/// 云来源只接受固定备份前缀，合法碰撞子目录仍使用原始逻辑 key。
class CloudBackupCleanupStorage implements BackupCleanupStorage {
  static final _unsupportedScopes = <String>{};
  CloudBackupCleanupStorage({
    required this.storage,
    required this.scope,
    required this.prefix,
    required Future<void> Function() requireCurrent,
    required bool Function() sessionCurrent,
    required Future<void> Function() close,
    Future<Directory> Function()? temporaryDirectory,
  }) : _validateContext = requireCurrent,
       _sessionIsCurrent = sessionCurrent,
       _closeSource = close,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final CloudStorageService storage;
  final String scope, prefix;
  final Future<void> Function() _validateContext, _closeSource;
  final bool Function() _sessionIsCurrent;
  final Future<Directory> Function() _temporaryDirectory;
  bool _disposed = false;

  @override
  bool get isLocal => false;

  /// 无原子条件删除能力的后端只提供盘点和内容检查。
  @override
  bool get supportsDeletion =>
      storage is CloudConditionalDeleteStorage &&
      !_unsupportedScopes.contains(scope);

  /// 对象必须提供可供强比较的版本标识，时间和大小不承担删除身份。
  @override
  bool canDeleteObject(BackupCleanupObject object) =>
      supportsDeletion && isStrongCloudETag(object.tag);

  /// 认证身份与保存配置都必须仍与来源打开时一致。
  @override
  Future<void> requireCurrent() async {
    if (_disposed || !_sessionIsCurrent()) {
      throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
    }
    await _validateContext();
  }

  /// 不规范路径直接拒绝，不把归一化后的另一条 key 当成用户选中的对象。
  bool _safe(String key) {
    final parts = key.split('/');
    return key.startsWith('$prefix/') &&
        !key.contains('\\') &&
        !RegExp(r'[%?#:\x00-\x1f\x7f]').hasMatch(key) &&
        !parts.any((part) => part.isEmpty || part == '.' || part == '..') &&
        (parts.length == 2 ||
            parts.length == 3 &&
                RegExp(
                  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
                ).hasMatch(parts[1])) &&
        !key.endsWith('-wal') &&
        !key.endsWith('-shm') &&
        p.posix.basename(key) != 'sesame_notes.sqlite';
  }

  /// 只请求应用备份前缀，后端递归返回的合法相对 key 保持原值。
  @override
  Future<List<BackupCleanupObject>> list() async {
    await requireCurrent();
    final files = await storage.list(path: '$prefix/');
    await requireCurrent();
    final result = <BackupCleanupObject>[];
    for (final file in files) {
      if (!_safe(file.path)) continue;
      result.add(
        BackupCleanupObject(
          key: file.path,
          size: file.size,
          modified: file.lastModified,
          tag: (file.metadata?['etag'] ?? file.metadata?['version_id'])
              ?.toString(),
          pending:
              file.path.endsWith('.pending') ||
              files.any(
                (other) =>
                    other.path == '${_publicationBase(file.path)}.pending',
              ),
          inUse: BackupFileAccess.isInUse(cloudBackupFileKey(scope, file.path)),
        ),
      );
    }
    return result;
  }

  /// 下载只由用户检查或删除复核触发，正文始终流式落到本次独占文件。
  Future<T> _copy<T>(
    BackupCleanupObject object,
    Future<T> Function(File raw) action,
  ) async {
    await requireCurrent();
    if (!_safe(object.key) || object.pending) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    final latest = (await list())
        .where((file) => file.key == object.key)
        .toList();
    if (latest.length != 1 || !object.matches(latest.single)) {
      throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
    }
    final directory = await (await _temporaryDirectory()).createTemp(
      'backup-cleanup-cloud-',
    );
    try {
      final raw = File(p.join(directory.path, 'object'));
      final downloaded =
          storage is CloudConditionalDeleteStorage &&
              isStrongCloudETag(object.tag)
          ? await (storage as CloudConditionalDeleteStorage).downloadIfMatch(
              path: object.key,
              destination: raw,
              expectedETag: object.tag!,
            )
          : await storage.downloadFile(path: object.key, destination: raw);
      if (!downloaded) {
        throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
      }
      if (object.size != null && await raw.length() != object.size) {
        throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
      }
      await requireCurrent();
      final after = (await list())
          .where((item) => item.key == object.key)
          .toList();
      if (after.length != 1 || !object.matches(after.single)) {
        throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
      }
      return await action(raw);
    } finally {
      await directory.delete(recursive: true);
    }
  }

  /// 读取租约覆盖元数据复核和完整下载，避免清理撤走当前读取对象。
  @override
  Future<T> read<T>(
    BackupCleanupObject object,
    Future<T> Function(File raw) inspect,
  ) => BackupFileAccess.read(
    cloudBackupFileKey(scope, object.key),
    () => _copy(object, inspect),
  );

  /// 删除其他对象期间持续持有被保护快照的读取身份。
  @override
  Future<T> protect<T>(String key, Future<T> Function() action) =>
      BackupFileAccess.read(cloudBackupFileKey(scope, key), action);

  /// 删除预约内重新下载核验原始对象摘要，只提交原始预览 key。
  @override
  Future<void> delete(
    BackupCleanupObject object,
    Future<void> Function(File raw) verify, {
    Future<void> Function()? beforeDelete,
  }) =>
      BackupFileAccess.delete(cloudBackupFileKey(scope, object.key), () async {
        if (!canDeleteObject(object)) {
          throw const BackupCleanupException(BackupCleanupFailure.unavailable);
        }
        final conditional = storage as CloudConditionalDeleteStorage;
        try {
          await conditional.verifyConditionalDelete(prefix: prefix);
        } on CloudConditionalDeleteUnsupportedException {
          _unsupportedScopes.add(scope);
          throw const BackupCleanupException(BackupCleanupFailure.unavailable);
        }
        await _copy(object, verify);
        await requireCurrent();
        final latest = (await list())
            .where((item) => item.key == object.key)
            .toList();
        if (latest.length != 1 || !object.matches(latest.single)) {
          throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
        }
        await beforeDelete?.call();
        if (!_sessionIsCurrent()) {
          throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
        }
        await conditional.deleteIfMatch(
          path: object.key,
          expectedETag: object.tag!,
        );
      });

  /// 页面关闭后释放本次独立创建的后端会话，不影响其他备份任务。
  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _closeSource();
  }
}
