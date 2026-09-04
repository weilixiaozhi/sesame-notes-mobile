/// 备份清单（BackupManifest）模型与 JSON 编解码。
///
/// - .snbak 为**明文**分帧文件：[u32 manifest 长度][manifest JSON][u32 sqlite
///   长度][SQLite 体]，无任何加密，任何设备可直接打开恢复；
/// - format_version 与 db_schema_version 分离，打开时校验；
/// - 统计字段（pending_mutation_count / open_conflict_count /
///   last_sync_at）仅展示与审计，恢复时全部销毁。
library;

import 'dart:convert';
import 'dart:typed_data';

/// 备份格式版本（.snbak 明文分帧协议，首版 = 1）。
const int backupFormatVersion = 1;

/// 备份打开失败的分类原因；每种原因对应独立用户文案。
enum BackupOpenError {
  /// 文件损坏 / 非备份文件 / 截断
  corrupt,

  /// Manifest 校验失败（字段缺失/类型错误）
  invalidManifest,

  /// 备份 schema 旧于当前应用
  schemaTooOld,

  /// 备份 schema 新于当前应用（提示升级 App）
  schemaTooNew,
}

/// 备份格式异常：携带分类原因，UI 据此展示对应文案。
class BackupFormatException implements Exception {
  const BackupFormatException(this.reason, this.message);

  /// 失败分类（决定用户提示与后续策略）
  final BackupOpenError reason;

  /// 人类可读描述（记日志用，不直接向用户展示原始信息）
  final String message;

  @override
  String toString() => 'BackupFormatException($reason): $message';
}

/// 账本存储归属（备份时快照）。
enum LedgerStorageOrigin {
  /// 本地账本（sync_id 恒为 NULL）
  local,

  /// 云端账本（拥有云同步身份与归属账号）
  cloud;

  /// 协议字符串（大写，与冻结 JSON 一致）。
  String get wire => name.toUpperCase();

  /// 从协议字符串解析；非法值抛 [BackupFormatException]。
  static LedgerStorageOrigin fromWire(String value) {
    switch (value) {
      case 'LOCAL':
        return LedgerStorageOrigin.local;
      case 'CLOUD':
        return LedgerStorageOrigin.cloud;
      default:
        throw const BackupFormatException(
          BackupOpenError.invalidManifest,
          'storage_origin 非法',
        );
    }
  }
}

/// Manifest 中的单条账本条目。
class ManifestLedger {
  const ManifestLedger({
    required this.ledgerBackupId,
    required this.name,
    required this.storageOrigin,
    required this.originalLocalLedgerId,
    required this.cloudProvider,
    required this.originalCloudLedgerId,
    required this.originalAccountId,
    required this.ownerType,
    required this.pendingMutationCount,
    required this.openConflictCount,
    required this.lastSyncAt,
  });

  /// 本备份内的账本引用 id（恢复预览时与 RecoveryItem 对应）。
  final String ledgerBackupId;

  /// 账本名（仅展示）。
  final String name;

  /// 备份时存储归属。
  final LedgerStorageOrigin storageOrigin;

  /// LOCAL 账本原始 ledger id（CLOUD 为 null）。
  final String? originalLocalLedgerId;

  /// 云提供方（当前仅官方云 'sesame_notes'；LOCAL 为 null）。
  final String? cloudProvider;

  /// CLOUD 账本云端 ledger id。
  final String? originalCloudLedgerId;

  /// CLOUD 账本归属账号 id（无凭据，仅溯源）。
  final String? originalAccountId;

  /// 归属类型：OWNER / MEMBER。
  final String ownerType;

  /// 备份时未推送 mutation 数（仅展示与警告）。
  final int pendingMutationCount;

  /// 备份时 OPEN 冲突数（仅展示与警告）。
  final int openConflictCount;

  /// 备份时最后同步时间（仅展示；不设 last_server_revision——账本无天然的
  /// 最后服务端修订号）。
  final DateTime? lastSyncAt;

  /// 序列化为冻结 JSON 形状。
  Map<String, dynamic> toJson() => {
    'ledger_backup_id': ledgerBackupId,
    'name': name,
    'storage_origin': storageOrigin.wire,
    'original_local_ledger_id': originalLocalLedgerId,
    'cloud_provider': cloudProvider,
    'original_cloud_ledger_id': originalCloudLedgerId,
    'original_account_id': originalAccountId,
    'owner_type': ownerType,
    'pending_mutation_count': pendingMutationCount,
    'open_conflict_count': openConflictCount,
    'last_sync_at': lastSyncAt?.toUtc().toIso8601String(),
  };

  /// 从 JSON 解析；任何字段缺失/类型错误抛 [BackupFormatException]。
  factory ManifestLedger.fromJson(Map<String, dynamic> json) {
    try {
      final ledgerBackupId = json['ledger_backup_id'] as String?;
      final name = json['name'] as String?;
      final storageOrigin = json['storage_origin'] as String?;
      final ownerType = json['owner_type'] as String?;
      final pending = json['pending_mutation_count'] as int?;
      final conflicts = json['open_conflict_count'] as int?;
      if (ledgerBackupId == null ||
          ledgerBackupId.isEmpty ||
          name == null ||
          storageOrigin == null ||
          ownerType == null ||
          pending == null ||
          conflicts == null) {
        throw const FormatException('missing');
      }
      final lastSyncAtRaw = json['last_sync_at'] as String?;
      final lastSyncAt = lastSyncAtRaw == null
          ? null
          : DateTime.tryParse(lastSyncAtRaw);
      if (lastSyncAtRaw != null && lastSyncAt == null) {
        throw const FormatException('date');
      }
      return ManifestLedger(
        ledgerBackupId: ledgerBackupId,
        name: name,
        storageOrigin: LedgerStorageOrigin.fromWire(storageOrigin),
        originalLocalLedgerId: json['original_local_ledger_id'] as String?,
        cloudProvider: json['cloud_provider'] as String?,
        originalCloudLedgerId: json['original_cloud_ledger_id'] as String?,
        originalAccountId: json['original_account_id'] as String?,
        ownerType: ownerType,
        pendingMutationCount: pending,
        openConflictCount: conflicts,
        lastSyncAt: lastSyncAt,
      );
    } on BackupFormatException {
      rethrow;
    } catch (_) {
      throw const BackupFormatException(
        BackupOpenError.invalidManifest,
        '账本条目标签字段非法',
      );
    }
  }
}

/// Manifest 中的账号引用（无任何凭据，仅溯源展示）。
class ManifestAccount {
  const ManifestAccount({required this.accountId, required this.accountName});

  final String accountId;
  final String accountName;

  Map<String, dynamic> toJson() => {
    'account_id': accountId,
    'account_name': accountName,
  };

  factory ManifestAccount.fromJson(Map<String, dynamic> json) {
    final accountId = json['account_id'] as String?;
    final accountName = json['account_name'] as String?;
    if (accountId == null || accountId.isEmpty || accountName == null) {
      throw const BackupFormatException(
        BackupOpenError.invalidManifest,
        '账号引用字段非法',
      );
    }
    return ManifestAccount(accountId: accountId, accountName: accountName);
  }
}

/// 备份清单：账本分域 + 账号引用 + 同步状态统计。
class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.dbSchemaVersion,
    required this.createdAt,
    required this.deviceId,
    required this.appVersion,
    required this.ledgers,
    required this.accounts,
  });

  /// 备份格式版本（与 Envelope 双写校验）。
  final int formatVersion;

  /// 客户端 DB schema 版本（与 format_version 分离）。
  final int dbSchemaVersion;

  /// 备份创建时间（UTC）。
  final DateTime createdAt;

  /// 备份来源设备。
  final String deviceId;

  /// 备份来源应用版本。
  final String appVersion;

  /// 账本清单（分域：LOCAL / CLOUD）。
  final List<ManifestLedger> ledgers;

  /// 涉及账号引用（无凭据）。
  final List<ManifestAccount> accounts;

  /// 序列化为冻结 JSON 形状。
  Map<String, dynamic> toJson() => {
    'format_version': formatVersion,
    'db_schema_version': dbSchemaVersion,
    'created_at': createdAt.toUtc().toIso8601String(),
    'device_id': deviceId,
    'app_version': appVersion,
    'ledgers': ledgers.map((l) => l.toJson()).toList(),
    'accounts': accounts.map((a) => a.toJson()).toList(),
  };

  /// 从 JSON 解析；必填字段缺失/类型错误 → invalidManifest。
  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    try {
      final formatVersion = json['format_version'] as int?;
      final dbSchemaVersion = json['db_schema_version'] as int?;
      final createdAtRaw = json['created_at'] as String?;
      final deviceId = json['device_id'] as String?;
      final appVersion = json['app_version'] as String?;
      final ledgersRaw = json['ledgers'] as List<dynamic>?;
      final accountsRaw = json['accounts'] as List<dynamic>?;
      final createdAt = createdAtRaw == null
          ? null
          : DateTime.tryParse(createdAtRaw);
      if (formatVersion == null ||
          dbSchemaVersion == null ||
          createdAt == null ||
          deviceId == null ||
          ledgersRaw == null ||
          accountsRaw == null) {
        throw const FormatException('missing');
      }
      return BackupManifest(
        formatVersion: formatVersion,
        dbSchemaVersion: dbSchemaVersion,
        createdAt: createdAt,
        deviceId: deviceId,
        appVersion: appVersion ?? '',
        ledgers: [
          for (final item in ledgersRaw)
            if (item is Map)
              ManifestLedger.fromJson(Map<String, dynamic>.from(item)),
        ],
        accounts: [
          for (final item in accountsRaw)
            if (item is Map)
              ManifestAccount.fromJson(Map<String, dynamic>.from(item)),
        ],
      );
    } on BackupFormatException {
      rethrow;
    } catch (_) {
      throw const BackupFormatException(
        BackupOpenError.invalidManifest,
        'Manifest 字段缺失或类型错误',
      );
    }
  }
}

/// Manifest JSON 编解码（bytes 形态，供帧内编解码使用）。
class BackupManifestCodec {
  BackupManifestCodec._();

  /// 序列化为 UTF-8 字节。
  static Uint8List encodeJson(BackupManifest manifest) =>
      Uint8List.fromList(utf8.encode(jsonEncode(manifest.toJson())));

  /// 从 UTF-8 字节解析；JSON 语法错误 → invalidManifest。
  static BackupManifest decodeJson(Uint8List bytes) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) {
        throw const BackupFormatException(
          BackupOpenError.invalidManifest,
          'Manifest 必须是 JSON 对象',
        );
      }
      return BackupManifest.fromJson(Map<String, dynamic>.from(decoded));
    } on BackupFormatException {
      rethrow;
    } catch (_) {
      throw const BackupFormatException(
        BackupOpenError.invalidManifest,
        'Manifest JSON 解析失败',
      );
    }
  }
}

/// .snbak 明文分帧编解码：[u32 manifest 长度][manifest JSON][u32 sqlite 长度][SQLite 体]。
///
/// 无任何加密：manifest 与 SQLite 体均为明文，任何设备可直接解码恢复。
class BackupPayloadCodec {
  BackupPayloadCodec._();

  /// 分帧编码。
  static Uint8List encode(Uint8List manifestJson, Uint8List sqliteBytes) {
    final out = ByteData(8 + manifestJson.length + sqliteBytes.length);
    out.setUint32(0, manifestJson.length);
    out.setUint32(4, sqliteBytes.length);
    out.buffer.asUint8List().setRange(8, 8 + manifestJson.length, manifestJson);
    out.buffer.asUint8List().setRange(
      8 + manifestJson.length,
      8 + manifestJson.length + sqliteBytes.length,
      sqliteBytes,
    );
    return out.buffer.asUint8List();
  }

  /// 分帧解码；长度字段越界或截断 → corrupt。
  static ({Uint8List manifestJson, Uint8List sqliteBytes}) decode(
    Uint8List bytes,
  ) {
    if (bytes.length < 8) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧过短');
    }
    final data = ByteData.sublistView(bytes);
    final manifestLength = data.getUint32(0);
    final sqliteLength = data.getUint32(4);
    final total = 8 + manifestLength + sqliteLength;
    if (total > bytes.length) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧长度字段损坏');
    }
    return (
      manifestJson: Uint8List.sublistView(bytes, 8, 8 + manifestLength),
      sqliteBytes: Uint8List.sublistView(bytes, 8 + manifestLength, total),
    );
  }
}
