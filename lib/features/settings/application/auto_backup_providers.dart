/// 自动备份编排 provider 装配（本地 .snbak 快照 + 第三方云端版本化上传）。
///
/// - 本地快照 = LocalBackupService 的 .snbak 明文分帧文件（无加密）；
/// - 云端上传：已配置第三方后端即上传；未配置则跳过（本地快照仍成功）；
/// - 上传路径版本化（时间戳命名），通过文件流传输快照；
/// - 云端保留最近 5 份（冻结默认），超限按时间戳清理。
library;

import 'package:sesame_notes/infrastructure/backup/cloud_backup_transfer.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/logging/cloud_backup_logger.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

/// 云端备份目录（版本化 .snbak 存放处）。
const String cloudBackupDirectory = 'sesame_notes_backups';

/// 云端保留份数（冻结默认：最近 5 份）。
const int cloudRetentionCount = 5;

/// 本机备份服务实例（默认构造 = 生产路径；测试可 override 注入临时目录）。
final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  return LocalBackupService(
    // 冷启动和离线使用已恢复的账号身份，确保账号域数据进入快照并参与发布前校验。
    accountIdGetter: () => ref.read(currentAccountIdProvider),
    sessionGenerationGetter: () =>
        ref.read(authSessionProvider.notifier).identityGeneration,
  );
});

/// 自动备份编排 provider（app 生命周期 observer 调用 runOnLaunch）。
final autoBackupCoordinatorProvider = Provider<AutoBackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final backupService = ref.watch(localBackupServiceProvider);
  final identity = ref.watch(deviceIdentityProvider);
  return AutoBackupService(
    // 自动备份开关（本机备份页控制）：默认 true，零干预兜底。
    loadEnabled: () async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(LocalBackupService.prefsKeyAutoBackup) ?? true;
    },
    loadLastSuccess: () async {
      final row = await (db.select(
        db.backupState,
      )..where((b) => b.id.equals(0))).getSingleOrNull();
      return row?.lastSuccessAt;
    },
    markSuccess: (successAt, uploadedProvider) async {
      final providerName = uploadedProvider;
      await db
          .into(db.backupState)
          .insertOnConflictUpdate(
            BackupStateCompanion.insert(
              id: d.Value(0),
              lastSuccessAt: d.Value(successAt),
              currentProvider: d.Value(providerName),
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
      final account = ref.read(currentAccountIdProvider);
      final generation = ref.read(authIdentityGenerationProvider);

      /// 固定快照开始时的身份，后端初始化与编码等待结束后仍核验同一代次。
      bool isCurrent() =>
          ref.mounted &&
          ref.read(currentAccountIdProvider) == account &&
          ref.read(authIdentityGenerationProvider) == generation;

      // 明文备份：manifest JSON + SQLite 体，无任何加密。
      final deviceId = await identity.load();
      if (!isCurrent()) throw StateError('BACKUP_SESSION_CHANGED');
      final file = await backupService.createBackup(
        db: db,
        trigger: BackupTrigger.automatic,
        deviceId: deviceId,
        // 备份只含本地域与当前账号域：其他账号数据不进入 .snbak
        currentAccountId: account,
        // 备份 Manifest 记录当前账号昵称（恢复页账号溯源展示用）
        accountNames: currentAccountNames(ref.read),
      );
      return AutoBackupSnapshot(file: file, isCurrent: isCurrent);
    },
    uploadToCloud: (snapshot) => uploadBackupFileIfAutoSyncEnabled(
      snapshot.file,
      isCurrent: snapshot.isCurrent,
    ),
  );
});

/// 把最新 .snbak 快照上传到已配置的第三方云端（版本化路径 + 保留清理）。
///
/// 未配置第三方后端时 no-op（本地快照仍成功）；上传失败向上抛
/// （由 AutoBackupService 统一降级为 failed + dirty 标记）。
Future<String?> uploadBackupFile(File file, {bool Function()? isCurrent}) =>
    LocalBackupService.withBackupFileRead(
      file,
      () => _uploadPublishedBackupFile(file, isCurrent: isCurrent),
    );

/// 只上传已经提交的本地快照；调用方持有覆盖后端初始化及传输全过程的读取租约。
Future<String?> _uploadPublishedBackupFile(
  File file, {
  bool Function()? isCurrent,
}) async {
  if (!file.path.endsWith(LocalBackupService.backupExtension)) {
    throw StateError('仅允许上传 .snbak 备份文件');
  }
  if (await File('${file.path}.pending').exists()) {
    throw StateError('备份尚未保存完成，请稍后重试');
  }
  final cfg = await CloudServiceStore(logger: cloudBackupLogger).loadActive();
  if (cfg.isLocal) return null; // 未配置第三方，仅本地快照

  final provider = await createCloudProvider(cfg);
  // 已激活后端却拿不到 provider = 该后端配置不完整（必填项或凭据缺失）。
  // 这与"未配置第三方"不同：静默返回会让调用方把本次备份记成成功，
  // 并按天去重挡掉当天重试，因此必须按上传失败上抛。
  if (provider == null) {
    throw StateError('云备份服务配置不完整，请重新填写并激活：${cfg.backendId}');
  }
  try {
    final storage = provider.storage;
    final remoteName = p.basename(file.path);
    var remotePath = '$cloudBackupDirectory/$remoteName';
    try {
      await uploadBackupSnapshot(
        storage,
        file,
        remotePath,
        isCurrent: isCurrent,
      );
    } on CloudFileAlreadyExistsException {
      // 远端已存在同名对象时使用独立目录，保留每次上传的独立快照。
      remotePath = '$cloudBackupDirectory/${const Uuid().v4()}/$remoteName';
      await uploadBackupSnapshot(
        storage,
        file,
        remotePath,
        isCurrent: isCurrent,
      );
    }
    logger.info('AutoBackup', '云端备份上传完成: $remotePath');
    await _pruneCloudBackups(storage);
    return cfg.backendId;
  } finally {
    await provider.dispose();
  }
}

/// 云端保留策略：目录内 .snbak 超过 [cloudRetentionCount] 份时删除最旧文件。
///
/// 按文件名时间戳字典序排序（与本地命名约定一致）；清理失败仅记日志不阻断。
Future<void> _pruneCloudBackups(CloudStorageService storage) async {
  try {
    final files = await storage.list(path: '$cloudBackupDirectory/');
    final backups =
        files
            .where(
              (f) =>
                  LocalBackupService.backupTimestamp(p.basename(f.path)) !=
                  null,
            )
            .toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    if (backups.length <= cloudRetentionCount) return;
    for (final old in backups.skip(cloudRetentionCount)) {
      await storage.delete(path: old.path);
      logger.info('AutoBackup', '已清理云端旧备份: ${old.path}');
    }
  } catch (e, st) {
    // 云端清理失败不阻断上传结果（最坏结果是云端多存几份）
    logger.warning('AutoBackup', '云端备份清理失败: $e', st);
  }
}

/// 受「自动备份到云端」开关控制的云端上传：开关关闭时 no-op。
///
/// 手动「立即上传」不经过本函数（用户显式动作应绕过开关）。
Future<String?> uploadBackupFileIfAutoSyncEnabled(
  File file, {
  required bool Function() isCurrent,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(LocalBackupService.prefsKeyAutoSync) ?? true;
  if (!enabled) return null;
  return uploadBackupFile(file, isCurrent: isCurrent);
}

/// 与自动备份一致的本地快照创建（手动「立即备份」与自动路径共用装配）。
///
/// 明文备份：manifest JSON + SQLite 体，无任何加密。
Future<File> createLocalBackupNow({
  required ProviderReader read,
  Future<bool> Function(PreparedBackup)? confirm,
}) async {
  final db = read(databaseProvider);
  final backupService = read(localBackupServiceProvider);
  final deviceId = await read(deviceIdentityProvider).load();
  return backupService.createBackup(
    db: db,
    trigger: BackupTrigger.manual,
    confirm: confirm,
    deviceId: deviceId,
    // 备份只含本地域与当前账号域：其他账号数据不进入 .snbak
    currentAccountId: read(currentAccountIdProvider),
    // 备份 Manifest 记录当前账号昵称（恢复页账号溯源展示用）
    accountNames: currentAccountNames(read),
  );
}

/// 当前登录账号的「账号 id → 昵称」映射（备份 Manifest 账号引用展示用）。
///
/// 未登录 / 无昵称时返回 null（Manifest 允许账号引用昵称为空串）。
Map<String, String>? currentAccountNames(ProviderReader read) {
  final userId = read(currentAccountIdProvider);
  final name = read(accountStateProvider).profile?.displayName?.trim();
  if (userId == null || userId.isEmpty || name == null || name.isEmpty) {
    return null;
  }
  return {userId: name};
}

/// 将成功时间与上传后端写入备份状态，自动备份直接读取该记录进行按天去重。
Future<void> markBackupSuccess({
  required ProviderReader read,
  required DateTime at,
  required String? uploadedProvider,
}) async {
  final db = read(databaseProvider);
  await db
      .into(db.backupState)
      .insertOnConflictUpdate(
        BackupStateCompanion.insert(
          id: d.Value(0),
          lastSuccessAt: d.Value(at),
          currentProvider: d.Value(uploadedProvider),
        ),
      );
}

/// 手动立即备份（本机备份页头部按钮 / 备份同步区块「立即上传」共用）：
/// 本地快照 + 云端上传 + 成功记录，任何失败向上抛（由 UI 提示）。
///
/// 手动动作不受按天去重与 auto_sync 开关限制。
class BackupUploadFailedException implements Exception {
  /// 本地快照已保存，保留云端失败原因供错误边界记录和诊断。
  const BackupUploadFailedException(this.cause);

  final Object cause;

  /// 输出备份阶段与安全错误类型，原始原因保存在 cause 中。
  @override
  String toString() => '云端备份上传失败：${safeErrorSummary(cause)}';
}

Future<bool> performManualBackup({
  required ProviderReader read,
  Future<bool> Function(PreparedBackup)? confirm,
}) async {
  final account = read(currentAccountIdProvider),
      generation = read(authIdentityGenerationProvider);
  bool isCurrent() =>
      account == read(currentAccountIdProvider) &&
      generation == read(authIdentityGenerationProvider);
  late final File file;
  try {
    file = await createLocalBackupNow(read: read, confirm: confirm);
  } on StateError catch (error) {
    if (error.message == 'BACKUP_CANCELLED') return false;
    rethrow;
  }
  if (!isCurrent()) throw StateError('BACKUP_SESSION_CHANGED');
  final String? uploadedProvider;
  try {
    uploadedProvider = await uploadBackupFile(file, isCurrent: isCurrent);
  } catch (error, stackTrace) {
    Error.throwWithStackTrace(BackupUploadFailedException(error), stackTrace);
  }
  if (!isCurrent()) throw StateError('BACKUP_SESSION_CHANGED');
  await markBackupSuccess(
    read: read,
    at: DateTime.now(),
    uploadedProvider: uploadedProvider,
  );
  return true;
}

/// 从已配置的第三方云端下载最新 .snbak 备份到本地临时文件。
///
/// 未配置第三方或云端无备份时返回 null；文件流写入本次操作的独占临时目录。
/// 返回的文件供恢复页（RestoreBackupPage）作为外部备份打开。
Future<File?> downloadLatestCloudBackup() async {
  final cfg = await CloudServiceStore(logger: cloudBackupLogger).loadActive();
  if (cfg.isLocal) return null;
  final provider = await createCloudProvider(cfg);
  // 配置不完整时不能报"云端暂无备份"：那是两份完全不同的用户结论。
  if (provider == null) {
    throw StateError('云备份服务配置不完整，请重新填写并激活：${cfg.backendId}');
  }
  try {
    final storage = provider.storage;
    final files = await storage.list(path: '$cloudBackupDirectory/');
    final backups =
        files
            .where(
              (f) =>
                  LocalBackupService.backupTimestamp(p.basename(f.path)) !=
                  null,
            )
            .toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    if (backups.isEmpty) return null;
    final parent = await getTemporaryDirectory();
    final directory = await parent.createTemp('sesame-cloud-backup-');
    final target = File(p.join(directory.path, p.basename(backups.first.path)));
    try {
      if (!await downloadBackupSnapshot(storage, backups.first.path, target)) {
        await directory.delete(recursive: true);
        return null;
      }
      logger.info('AutoBackup', '云端备份下载完成');
      return target;
    } catch (_) {
      await directory.delete(recursive: true);
      rethrow;
    }
  } finally {
    await provider.dispose();
  }
}

/// 删除本次云下载的隔离目录；外部导入文件和用户备份目录不在清理范围。
Future<void> releaseDownloadedCloudBackup(File file) async {
  try {
    final root = await getTemporaryDirectory();
    final directory = file.parent;
    if (p.isWithin(p.absolute(root.path), p.absolute(directory.path)) &&
        p.basename(directory.path).startsWith('sesame-cloud-backup-') &&
        await directory.exists()) {
      await directory.delete(recursive: true);
    }
  } catch (error, stackTrace) {
    logger.error(
      'AutoBackup',
      '清理云下载临时文件失败',
      safeErrorSummary(error),
      stackTrace,
    );
  }
}

/// 自动本地备份开关值（默认 true：零干预兜底）。
final autoBackupValueProvider = FutureProvider.autoDispose<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final link = ref.keepAlive();
  ref.onDispose(() => link.close());
  return prefs.getBool(LocalBackupService.prefsKeyAutoBackup) ?? true;
});

/// 自动本地备份开关写入器：写 SharedPreferences 后 invalidate 值缓存。
class AutoBackupSetter {
  AutoBackupSetter(this._ref);
  final Ref _ref;
  Future<void> set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(LocalBackupService.prefsKeyAutoBackup, v);
    _ref.invalidate(autoBackupValueProvider);
  }
}

/// 自动本地备份开关写入器 provider。
final autoBackupSetterProvider = Provider<AutoBackupSetter>((ref) {
  return AutoBackupSetter(ref);
});

/// 「自动备份到云端」开关值（默认 true：已配置第三方时随自动备份上传）。
final autoSyncValueProvider = FutureProvider.autoDispose<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final link = ref.keepAlive();
  ref.onDispose(() => link.close());
  return prefs.getBool(LocalBackupService.prefsKeyAutoSync) ?? true;
});

/// 「自动备份到云端」开关写入器。
class AutoSyncSetter {
  AutoSyncSetter(this._ref);
  final Ref _ref;
  Future<void> set(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(LocalBackupService.prefsKeyAutoSync, v);
    _ref.invalidate(autoSyncValueProvider);
  }
}

/// 「自动备份到云端」开关写入器 provider。
final autoSyncSetterProvider = Provider<AutoSyncSetter>((ref) {
  return AutoSyncSetter(ref);
});
