import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/core/logging/cloud_backup_logger.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/backup/backup_file_access.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/backup_cleanup.dart';
import '../infrastructure/backup_cleanup_inspector.dart';
import '../infrastructure/backup_cleanup_storage.dart';
import '../infrastructure/local_backup_service.dart';
import 'auto_backup_providers.dart';

/// 只读取配置描述符，不查询活动数据库或自动连接远端存储。
Future<List<BackupCleanupSource>> _sourceLoader() async {
  final result = <BackupCleanupSource>[
    const BackupCleanupSource(id: 'local', displayName: ''),
  ];
  final store = CloudServiceStore(logger: cloudBackupLogger);
  for (final backend in CloudProviderRegistry.backends) {
    try {
      if (await store.load(backend.id) != null) {
        result.add(
          BackupCleanupSource(id: backend.id, displayName: backend.displayName),
        );
      }
    } catch (error, stack) {
      // 单个云端配置故障不能阻止管理本机文件；选择该来源时会显示明确失败。
      logger.warning(
        'BackupCleanup',
        '读取云备份来源失败：${backend.id} ${safeErrorSummary(error)}',
        stack,
      );
      result.add(
        BackupCleanupSource(id: backend.id, displayName: backend.displayName),
      );
    }
  }
  return result;
}

/// 来源列表仅列出本机和本机保存的云配置，绝不枚举其他账号或整个桶。
final backupCleanupSourcesProvider = FutureProvider<List<BackupCleanupSource>>(
  (_) => _sourceLoader(),
);

/// 页面与测试共用单飞管理器，所有删除资格都由服务强制校验。
class BackupCleanupManager {
  BackupCleanupManager({
    required Future<List<BackupCleanupSource>> Function() loadSources,
    required Future<BackupCleanupStorage> Function(BackupCleanupSource source)
    openStorage,
    BackupCleanupInspector? inspector,
  }) : _sourceLoader = loadSources,
       _storageOpener = openStorage,
       _inspector = inspector ?? BackupCleanupInspector();

  final Future<List<BackupCleanupSource>> Function() _sourceLoader;
  final Future<BackupCleanupStorage> Function(BackupCleanupSource source)
  _storageOpener;
  final BackupCleanupInspector _inspector;
  BackupCleanupStorage? _storage;
  BackupCleanupPreview? _preview;
  Map<String, BackupCleanupObject> _objects = {};
  bool _busy = false, _disposed = false;
  int _cancelGeneration = 0;
  Completer<void>? _idle;

  /// 列表只消费文件元数据，不在打开页面时隐式下载或读取所有备份正文。
  Future<BackupCleanupPreview> preview(String sourceId) => _run(() async {
    final generation = _cancelGeneration;
    _preview = null;
    _objects = {};
    await _storage?.dispose();
    _storage = null;
    final source = (await _sourceLoader())
        .where((item) => item.id == sourceId)
        .firstOrNull;
    if (_disposed || source == null) {
      throw const BackupCleanupException(BackupCleanupFailure.unavailable);
    }
    final storage = _storage = await _storageOpener(source);
    try {
      final objects = await storage.list();
      final unique = <String, BackupCleanupObject>{};
      for (final object in objects) {
        if (unique.containsKey(object.key)) {
          throw const BackupCleanupException(BackupCleanupFailure.unavailable);
        }
        unique[object.key] = object;
      }
      await storage.requireCurrent();
      if (_disposed || generation != _cancelGeneration) {
        throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
      }
      _objects = unique;
      final entries = [
        for (final object in objects) _entry(object, storage.isLocal),
      ]..sort(_newestFirst);
      return _publish(source, entries);
    } catch (_) {
      await storage.dispose();
      _storage = null;
      rethrow;
    }
  });

  /// 显式检查一个文件，云端仅下载这个对象；识别失败的文件永远不会自动转为可删。
  Future<BackupCleanupPreview> inspect(
    BackupCleanupPreview preview,
    String key,
  ) => _run(() async {
    _requirePreview(preview);
    final entry = preview.entries.where((item) => item.key == key).firstOrNull;
    final object = _objects[key];
    if (entry == null || object == null || !entry.canInspect) {
      throw const BackupCleanupException(BackupCleanupFailure.unverified);
    }
    final storage = _storage!;
    final result = await storage.read(
      object,
      (raw) => _inspector.inspect(
        raw,
        fileName: entry.fileName,
        isLocal: storage.isLocal,
        modified: object.modified,
      ),
    );
    await storage.requireCurrent();
    _requirePreview(preview);
    return _publish(preview.source, [
      for (final item in preview.entries)
        if (item.key == key)
          item.copyWith(
            status: result.status,
            sha256: result.sha256,
            createdAt: result.createdAt,
          )
        else
          item,
    ]);
  });

  /// 删除集合在调用时复制固定，页面后续选择变化不会扩展已确认范围。
  Future<BackupCleanupResult> delete(
    BackupCleanupPreview preview,
    Set<String> selectedKeys, {
    bool allowNoCurrentBackup = false,
  }) {
    final keys = Set<String>.unmodifiable(selectedKeys);
    return _run(() async {
      _requirePreview(preview);
      final selected = preview.entries
          .where((entry) => keys.contains(entry.key))
          .toList();
      if (selected.isEmpty || selected.length != keys.length) {
        throw const BackupCleanupException(BackupCleanupFailure.unverified);
      }
      if (selected.any((entry) => entry.isProtected)) {
        throw const BackupCleanupException(
          BackupCleanupFailure.protectedBackup,
        );
      }
      if (selected.any((entry) => !entry.canDelete)) {
        throw const BackupCleanupException(BackupCleanupFailure.unverified);
      }
      if (!preview.hasCurrentBackup &&
          (!allowNoCurrentBackup ||
              selected.any(
                (entry) => entry.status == BackupCleanupStatus.current,
              ))) {
        throw const BackupCleanupException(
          BackupCleanupFailure.noCurrentBackup,
        );
      }
      final storage = _storage!;
      await storage.requireCurrent();
      final listed = await storage.list();
      final fresh = <String, BackupCleanupObject>{};
      for (final item in listed) {
        if (fresh.containsKey(item.key)) {
          throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
        }
        fresh[item.key] = item;
      }
      final protected = preview.entries
          .where((entry) => entry.isProtected)
          .firstOrNull;
      for (final entry in [...selected, ?protected]) {
        final latest = fresh[entry.key];
        if (latest == null ||
            !_objects[entry.key]!.matches(latest) ||
            (storage.isLocal &&
                !_inspector.temporaryReady(entry.fileName, latest.modified))) {
          throw const BackupCleanupException(BackupCleanupFailure.fileChanged);
        }
      }

      Future<BackupCleanupResult> remove() async {
        if (protected != null) {
          await storage.read(_objects[protected.key]!, (raw) async {
            if (await BackupCleanupInspector.digest(raw) != protected.sha256) {
              throw const BackupCleanupException(
                BackupCleanupFailure.fileChanged,
              );
            }
          });
        }
        Future<void> checkProtected() async {
          if (protected == null) {
            await storage.requireCurrent();
            _requirePreview(preview);
            return;
          }
          final latest = (await storage.list())
              .where((item) => item.key == protected.key)
              .toList();
          if (latest.length != 1 ||
              !_objects[protected.key]!.matches(latest.single)) {
            throw const BackupCleanupException(
              BackupCleanupFailure.protectedBackup,
            );
          }
          if (!storage.isLocal && !isStrongCloudETag(latest.single.tag)) {
            await storage.read(_objects[protected.key]!, (raw) async {
              if (await BackupCleanupInspector.digest(raw) !=
                  protected.sha256) {
                throw const BackupCleanupException(
                  BackupCleanupFailure.protectedBackup,
                );
              }
            });
          }
          await storage.requireCurrent();
          _requirePreview(preview);
        }

        var deleted = 0, failed = 0;
        for (var index = 0; index < selected.length; index++) {
          final entry = selected[index];
          try {
            _requirePreview(preview);
            await storage.delete(_objects[entry.key]!, (raw) async {
              if (await BackupCleanupInspector.digest(raw) != entry.sha256) {
                throw const BackupCleanupException(
                  BackupCleanupFailure.fileChanged,
                );
              }
              await storage.requireCurrent();
              _requirePreview(preview);
            }, beforeDelete: checkProtected);
            deleted++;
          } catch (error, stack) {
            logger.error(
              'BackupCleanup',
              '所选备份删除未确认，需刷新核对：${safeErrorSummary(error)}',
              safeErrorSummary(error),
              stack,
            );
            failed++;
            if (_disposed ||
                error is BackupCleanupException &&
                    const {
                      BackupCleanupFailure.stalePreview,
                      BackupCleanupFailure.protectedBackup,
                      BackupCleanupFailure.unavailable,
                    }.contains(error.reason)) {
              failed += selected.length - index - 1;
              break;
            }
          }
        }
        _preview = null;
        return BackupCleanupResult(deletedCount: deleted, failedCount: failed);
      }

      return LocalBackupService.withBackupCleanup(() async {
        if (protected == null) return remove();
        return storage.protect(protected.key, remove);
      });
    });
  }

  /// 待提交和近期中间文件都不能领取删除资格，读取中的文件只展示受保护状态。
  BackupCleanupEntry _entry(BackupCleanupObject object, bool local) {
    final name = p.posix.basename(object.key);
    return BackupCleanupEntry(
      key: object.key,
      fileName: name,
      sizeBytes: object.size,
      modifiedAt: object.modified,
      createdAt: BackupCleanupInspector.namedTime(name),
      deletionSupported: _storage!.canDeleteObject(object),
      status:
          object.pending ||
              local && !_inspector.temporaryReady(name, object.modified)
          ? BackupCleanupStatus.pending
          : object.inUse
          ? BackupCleanupStatus.inUse
          : BackupCleanupStatus.unverified,
    );
  }

  /// 最新的已验证有效快照始终保留；未验证条目不承担“可恢复”的承诺。
  BackupCleanupPreview _publish(
    BackupCleanupSource source,
    List<BackupCleanupEntry> entries,
  ) {
    final current =
        entries
            .where(
              (entry) =>
                  entry.status == BackupCleanupStatus.current &&
                  entry.sha256 != null,
            )
            .toList()
          ..sort(_newestFirst);
    return _preview = BackupCleanupPreview(
      source: source,
      token: const Uuid().v4(),
      supportsDeletion: _storage!.supportsDeletion,
      entries: [
        for (final entry in entries)
          entry.copyWith(
            isProtected: current.isNotEmpty && entry.key == current.first.key,
          ),
      ],
    );
  }

  /// 时间相同时按原始 key 排序，多个设备对同一集合得到一致保护对象。
  static int _newestFirst(BackupCleanupEntry a, BackupCleanupEntry b) {
    final order = (b.createdAt ?? b.modifiedAt ?? DateTime(1970)).compareTo(
      a.createdAt ?? a.modifiedAt ?? DateTime(1970),
    );
    return order != 0 ? order : b.key.compareTo(a.key);
  }

  /// 页面关闭时同步撤销确认，已发出的删除不回滚，后续项不得继续发出。
  void cancelPending() {
    _cancelGeneration++;
    _preview = null;
  }

  /// 对象身份与随机 token 都必须等于当前服务持有的预览，不能伪造或重用旧集合。
  void _requirePreview(BackupCleanupPreview preview) {
    if (_disposed ||
        !identical(preview, _preview) ||
        preview.token != _preview?.token) {
      throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
    }
  }

  /// 检查、来源切换和删除共用单飞，错误只通过稳定原因通知页面。
  Future<T> _run<T>(Future<T> Function() action) async {
    if (_busy) throw const BackupCleanupException(BackupCleanupFailure.busy);
    if (_disposed) {
      throw const BackupCleanupException(BackupCleanupFailure.stalePreview);
    }
    _busy = true;
    final idle = _idle = Completer<void>();
    try {
      return await action();
    } on BackupCleanupException {
      rethrow;
    } on BackupFileBusyException {
      throw const BackupCleanupException(BackupCleanupFailure.inUse);
    } catch (error, stack) {
      logger.error(
        'BackupCleanup',
        '备份文件操作未完成，请刷新重试',
        safeErrorSummary(error),
        stack,
      );
      throw const BackupCleanupException(BackupCleanupFailure.unavailable);
    } finally {
      _busy = false;
      idle.complete();
      if (identical(_idle, idle)) _idle = null;
    }
  }

  /// 关闭先使所有旧确认失效，等待在途操作结束后再释放独立云会话。
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _preview = null;
    await _idle?.future;
    await _storage?.dispose();
    _storage = null;
  }
}

/// 来源会话只持有文件服务，活动业务数据库不会进入清理依赖。
final backupCleanupManagerProvider = Provider.autoDispose<BackupCleanupManager>(
  (ref) {
    final manager = BackupCleanupManager(
      loadSources: _sourceLoader,
      openStorage: (source) async {
        final account = ref.read(currentAccountIdProvider);
        final generation = ref.read(authIdentityGenerationProvider);
        bool current() =>
            ref.mounted &&
            ref.read(currentAccountIdProvider) == account &&
            ref.read(authIdentityGenerationProvider) == generation;
        Future<void> requireSession() async {
          if (!current()) {
            throw const BackupCleanupException(
              BackupCleanupFailure.stalePreview,
            );
          }
        }

        if (source.isLocal) {
          final directories = await ref
              .read(localBackupServiceProvider)
              .existingBackupDirectories();
          return LocalBackupCleanupStorage(
            directory: directories.firstOrNull,
            requireCurrent: requireSession,
            sessionCurrent: current,
          );
        }
        final configStore = CloudServiceStore(logger: cloudBackupLogger);
        final config = await configStore.load(source.id);
        if (config == null) {
          throw const BackupCleanupException(BackupCleanupFailure.unavailable);
        }
        final scope = cloudBackupScopeKey(config);
        Future<void> requireConfiguration() async {
          await requireSession();
          final latest = await configStore.load(source.id);
          if (latest == null ||
              cloudBackupScopeKey(latest) != scope ||
              !current()) {
            throw const BackupCleanupException(
              BackupCleanupFailure.stalePreview,
            );
          }
        }

        final provider = await createCloudProvider(config);
        if (provider == null) {
          throw const BackupCleanupException(BackupCleanupFailure.unavailable);
        }
        try {
          await requireConfiguration();
          return CloudBackupCleanupStorage(
            storage: provider.storage,
            scope: scope,
            prefix: cloudBackupDirectory,
            requireCurrent: requireConfiguration,
            sessionCurrent: current,
            close: provider.dispose,
          );
        } catch (_) {
          await provider.dispose();
          rethrow;
        }
      },
    );
    ref.onDispose(() {
      unawaited(
        manager.dispose().catchError((Object error, StackTrace stack) {
          logger.error(
            'BackupCleanup',
            '关闭文件清理会话失败',
            safeErrorSummary(error),
            stack,
          );
        }),
      );
    });
    return manager;
  },
);
