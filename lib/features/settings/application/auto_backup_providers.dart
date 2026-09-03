/// 自动备份编排 provider 装配（本地 .snbak 快照 + 第三方云端版本化上传）。
///
/// - 本地快照 = LocalBackupService 的 .snbak Envelope（配置了备份密码时用
///   autoKey 加密，否则设备密钥——本机自动备份场景）；
/// - 云端上传：**仅当已配置备份密码**（autoKey 存在）时上传——云端备份必须受
///   密码派生密钥保护，设备密钥不是唯一保护；未配置则跳过上传（本地备份仍成功）；
/// - 上传路径版本化（时间戳命名）；base64 仅作传输编码，内容已是密文；
/// - 云端保留最近 5 份（冻结默认），超限按时间戳清理。
library;

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/identity/local_user_identity.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/settings/infrastructure/auto_backup_service.dart';
import 'package:sesame_notes/features/settings/domain/backup_crypto.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_security_store.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';

/// 云端备份目录（版本化 .snbak 存放处）。
const String cloudBackupDirectory = 'sesame_notes_backups';

/// 云端保留份数（冻结默认：最近 5 份）。
const int cloudRetentionCount = 5;

/// 本机备份服务实例（默认构造 = 生产路径；测试可 override 注入临时目录）。
final localBackupServiceProvider = Provider<LocalBackupService>((ref) {
  return LocalBackupService();
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
    markSuccess: (successAt) async {
      final providerName = await loadActiveCloudBackupProviderName();
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
      // 自动备份的加密输入（Multi-Key-Slot）：配置了备份密码时用
      // 钥匙串恢复词写 RECOVERY slot（云端可凭恢复词恢复），设备密钥写
      // DEVICE_LOCAL slot（本机兜底，非唯一保护）。
      final securityStore = BackupSecurityStore();
      final localSelfId = await LocalSelfId.getOrCreate();
      final deviceId = await identity.load();
      return backupService.createBackup(
        db: db,
        secrets: BackupSecrets(
          recoveryKey: await securityStore.loadRecoveryKey(),
          deviceKey: BackupCrypto.deviceKeyFromLocalSelfId(localSelfId),
        ),
        deviceId: deviceId,
        // 备份只含本地域与当前账号域：其他账号数据不进入 .snbak
        currentAccountId: ref.read(authSessionProvider)?.userId,
      );
    },
    uploadToCloud: uploadBackupFileIfAutoSyncEnabled,
  );
});

/// 把最新 .snbak 快照上传到已配置的第三方云端（版本化路径 + 保留清理）。
///
/// 未配置第三方后端或未配置备份密码时 no-op（本地快照仍成功）；上传失败向上抛
/// （由 AutoBackupService 统一降级为 failed + dirty 标记）。
Future<void> uploadBackupFile(File file) async {
  if (!file.path.endsWith(LocalBackupService.backupExtension)) {
    throw StateError('仅允许上传 .snbak 备份文件');
  }
  final cfg = await CloudServiceStore().loadActive();
  if (cfg.isLocal) return; // 未配置第三方，仅本地快照

  // 云端备份必须受密码派生密钥保护：未配置备份密码时不上传（防设备密钥唯一保护）。
  if (!await BackupSecurityStore().hasPassword()) {
    logger.warning('AutoBackup', '未配置备份密码，跳过云端上传（本地快照已生成）');
    return;
  }

  final services = await createCloudServices(cfg);
  final provider = services.provider;
  if (provider == null) return;
  try {
    final storage = provider.storage;
    final remoteName = p.basename(file.path);
    final remotePath = '$cloudBackupDirectory/$remoteName';
    final bytes = await file.readAsBytes();
    // base64 仅作传输编码：内容已是 Envelope 密文。
    await storage.upload(
      path: remotePath,
      data: base64Encode(bytes),
      metadata: const {
        'app': 'sesame_notes',
        'format': 'snbak',
        'encoding': 'base64',
      },
    );
    logger.info('AutoBackup', '云端备份上传完成: $remotePath');
    await _pruneCloudBackups(storage);
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
              (f) => p
                  .basename(f.path)
                  .endsWith(LocalBackupService.backupExtension),
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

/// 读取当前可完成云端上传的第三方后端名。
///
/// 未配置第三方后端或备份密码时，本次只会生成本地快照，
/// 因此返回 null，避免把本地成功误记为云端成功。
Future<String?> loadActiveCloudBackupProviderName() async {
  try {
    final cfg = await CloudServiceStore().loadActive();
    if (cfg.isLocal || !await BackupSecurityStore().hasPassword()) return null;
    return cfg.backendId;
  } catch (e, st) {
    logger.error('AutoBackup', '读取当前云端备份服务失败', e, st);
    rethrow;
  }
}

/// 受「自动备份到云端」开关控制的云端上传：开关关闭时 no-op。
///
/// 手动「立即上传」不经过本函数（用户显式动作应绕过开关）。
Future<void> uploadBackupFileIfAutoSyncEnabled(File file) async {
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(LocalBackupService.prefsKeyAutoSync) ?? true;
  if (!enabled) return;
  await uploadBackupFile(file);
}

/// 读取器签名：Ref.read 与 WidgetRef.read 的 tear-off 都满足，供页面与服务共用。
typedef CloudReadFn = T Function<T>(ProviderListenable<T> listenable);

/// 与自动备份一致的本地快照创建（手动「立即备份」与自动路径共用装配）。
///
/// 加密输入（Multi-Key-Slot）：配置了备份密码时用恢复词写 RECOVERY slot
/// （云端可凭恢复词恢复），设备密钥写 DEVICE_LOCAL slot（本机兜底）。
Future<File> createLocalBackupNow({required CloudReadFn read}) async {
  final db = read(databaseProvider);
  final backupService = read(localBackupServiceProvider);
  final securityStore = BackupSecurityStore();
  final localSelfId = await LocalSelfId.getOrCreate();
  final deviceId = await read(deviceIdentityProvider).load();
  return backupService.createBackup(
    db: db,
    secrets: BackupSecrets(
      recoveryKey: await securityStore.loadRecoveryKey(),
      deviceKey: BackupCrypto.deviceKeyFromLocalSelfId(localSelfId),
    ),
    deviceId: deviceId,
    // 备份只含本地域与当前账号域：其他账号数据不进入 .snbak
    currentAccountId: read(authSessionProvider)?.userId,
  );
}

/// 记录成功：写入 backup_state 单例行 + 当天去重标记。
Future<void> markBackupSuccess({required CloudReadFn read, required DateTime at}) async {
  final providerName = await loadActiveCloudBackupProviderName();
  final db = read(databaseProvider);
  await db
      .into(db.backupState)
      .insertOnConflictUpdate(
        BackupStateCompanion.insert(
          id: d.Value(0),
          lastSuccessAt: d.Value(at),
          currentProvider: d.Value(providerName),
        ),
      );
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    LocalBackupService.prefsKeyLastBackupDate,
    LocalBackupService.todayString(),
  );
}

/// 记录失败：写入 dirtySince（下次触发自动重试）。
Future<void> markBackupDirty({required CloudReadFn read}) async {
  final db = read(databaseProvider);
  await db
      .into(db.backupState)
      .insertOnConflictUpdate(
        BackupStateCompanion.insert(
          id: d.Value(0),
          dirtySince: d.Value(DateTime.now()),
        ),
      );
}

/// 手动立即备份（本机备份页头部按钮 / 备份同步区块「立即上传」共用）：
/// 本地快照 + 云端上传 + 成功记录，任何失败向上抛（由 UI 提示）。
///
/// 手动动作不受按天去重与 auto_sync 开关限制。
Future<void> performManualBackup({required CloudReadFn read}) async {
  final file = await createLocalBackupNow(read: read);
  await uploadBackupFile(file);
  await markBackupSuccess(read: read, at: DateTime.now());
}

/// 从已配置的第三方云端下载最新 .snbak 备份到本地临时文件。
///
/// 未配置第三方或云端无备份时返回 null；下载内容按 base64 解码还原原始
/// Envelope 字节。返回的文件供恢复页（RestoreBackupPage）作为外部备份打开。
Future<File?> downloadLatestCloudBackup({required CloudReadFn read}) async {
  final cfg = await CloudServiceStore().loadActive();
  if (cfg.isLocal) return null;
  final services = await createCloudServices(cfg);
  final provider = services.provider;
  if (provider == null) return null;
  try {
    final storage = provider.storage;
    final files = await storage.list(path: '$cloudBackupDirectory/');
    final backups =
        files
            .where(
              (f) => p
                  .basename(f.path)
                  .endsWith(LocalBackupService.backupExtension),
            )
            .toList()
          ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
    if (backups.isEmpty) return null;
    final data = await storage.download(path: backups.first.path);
    if (data == null || data.isEmpty) return null;
    // base64 仅作传输编码：解码还原 Envelope 原始字节。
    final bytes = base64Decode(data);
    final dir = await getTemporaryDirectory();
    final target = File(p.join(dir.path, p.basename(backups.first.path)));
    await target.writeAsBytes(bytes, flush: true);
    logger.info('AutoBackup', '云端备份下载完成: ${target.path}');
    return target;
  } finally {
    await provider.dispose();
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
