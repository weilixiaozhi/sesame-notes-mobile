library;

import 'package:sesame_notes/utils/wire_timestamp.dart';

import '../../../data/models/private_book.dart';

/// 备份清单（BackupManifest）模型与 JSON 编解码。
///
/// - .snbak 为明文分帧文件：[u32 manifest 长度][u32 sqlite 长度]
///   [manifest JSON][SQLite 体]，长度字段为大端；
/// - format_version 与 db_schema_version 分离，打开时校验；
/// - 统计字段（pending_mutation_count / open_conflict_count /
///   last_sync_at）仅展示与审计，恢复时全部销毁。

import 'dart:convert';
import 'dart:typed_data';

/// 备份格式版本（.snbak 明文分帧协议，首版 = 1）。
///
/// 何时 bump：只有"读端无法容忍"的形状变化才升版本——删除/改名读端会读或必填的
/// 字段、改字段语义或取值格式、增删 `contents` 条目、改分帧协议；仅新增可选字段不用升。
/// 恢复会在提取副本中自动升级已支持的数据库结构，原备份文件保持不变。
/// 删除字段或改变语义需要先升版本，并明确历史备份的迁移规则；未知版本保持拒绝。
const int backupFormatVersion = 1;

/// 分帧清单列出的持久化内容，写入与读取校验共用同一组字段。
const _backupContents = [
  'day_books',
  'day_events',
  'memo_books',
  'memo_entries',
  'memo_import_receipts',
  'fitness_entities',
  'fitness_spaces',
  'fitness_import_receipts',
  'sync_changes',
  'sync_conflicts',
];

/// 备份打开失败的分类原因；每种原因对应独立用户文案。
enum BackupOpenError {
  /// 文件损坏 / 非备份文件 / 截断
  corrupt,

  /// Manifest 校验失败（字段缺失/类型错误）
  invalidManifest,

  /// 备份格式或数据库结构版本不受当前恢复入口支持。
  unsupportedSchema,
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

/// 日子本的独立恢复清单；数量来自同一个隔离快照。
class ManifestDayBook {
  final String dayBookId;
  final String name;
  final LedgerStorageOrigin storageOrigin;
  final String? sourceAccountId;
  final String? sourceDayBookId;
  final String? syncId;
  final int eventCount;
  final Map<String, int> categoryCounts;
  final int pendingCount;
  final int rejectedCount;
  final int openConflictCount;
  final bool fullyDownloaded;
  final bool isHidden;

  /// 绑定与队列数量仅供恢复判断，不回灌为活跃同步状态。
  const ManifestDayBook({
    required this.dayBookId,
    required this.name,
    required this.storageOrigin,
    this.sourceAccountId,
    this.sourceDayBookId,
    this.syncId,
    required this.eventCount,
    required this.categoryCounts,
    required this.pendingCount,
    required this.rejectedCount,
    required this.openConflictCount,
    required this.fullyDownloaded,
    this.isHidden = false,
  });

  /// 与 SQLite 一起封装的首版日子清单。
  Map<String, dynamic> toJson() => {
    'day_book_id': dayBookId,
    'name': name,
    'storage_origin': storageOrigin.wire,
    'source_account_id': sourceAccountId,
    'source_day_book_id': sourceDayBookId,
    'sync_id': syncId,
    'event_count': eventCount,
    'category_counts': categoryCounts,
    'pending_count': pendingCount,
    'rejected_count': rejectedCount,
    'open_conflict_count': openConflictCount,
    'fully_downloaded': fullyDownloaded,
    'is_hidden': isHidden,
  };

  /// 不接受缺失字段或负计数，所有分类总数必须与记录数相符。
  factory ManifestDayBook.fromJson(Map<String, dynamic> json) {
    try {
      final counts = Map<String, int>.from(json['category_counts'] as Map);
      final result = ManifestDayBook(
        dayBookId: json['day_book_id'] as String,
        name: json['name'] as String,
        storageOrigin: LedgerStorageOrigin.fromWire(
          json['storage_origin'] as String,
        ),
        sourceAccountId: json['source_account_id'] as String?,
        sourceDayBookId: json['source_day_book_id'] as String?,
        syncId: json['sync_id'] as String?,
        eventCount: json['event_count'] as int,
        categoryCounts: counts,
        pendingCount: json['pending_count'] as int,
        rejectedCount: json['rejected_count'] as int,
        openConflictCount: json['open_conflict_count'] as int,
        fullyDownloaded: json['fully_downloaded'] as bool,
        isHidden: json['is_hidden'] as bool,
      );
      if (result.dayBookId.isEmpty ||
          result.name.isEmpty ||
          counts.length != 4 ||
          ![
            'birthday',
            'anniversary',
            'countdown',
            'stage',
          ].every(counts.containsKey) ||
          [
            result.eventCount,
            result.pendingCount,
            result.rejectedCount,
            result.openConflictCount,
            ...counts.values,
          ].any((value) => value < 0) ||
          counts.values.fold<int>(0, (sum, value) => sum + value) !=
              result.eventCount) {
        throw const FormatException('counts');
      }
      return result;
    } catch (_) {
      throw const BackupFormatException(
        BackupOpenError.invalidManifest,
        '日子清单字段无效',
      );
    }
  }
}

/// 备份清单：账本分域 + 账号引用 + 同步状态统计。
class ManifestMemoBook implements ManifestPrivateBook {
  @override
  final String id;
  final String name, type;
  @override
  final LedgerStorageOrigin storageOrigin;
  @override
  final String? sourceAccountId;
  final int entryCount;
  final DateTime createdAt, updatedAt;
  final bool isHidden, pendingLocalDelete;
  const ManifestMemoBook({
    required this.id,
    required this.name,
    required this.type,
    required this.storageOrigin,
    required this.entryCount,
    required this.createdAt,
    required this.updatedAt,
    this.sourceAccountId,
    this.isHidden = false,
    this.pendingLocalDelete = false,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'storage_origin': storageOrigin.wire,
    'source_account_id': sourceAccountId,
    'entry_count': entryCount,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'is_hidden': isHidden,
    'pending_local_delete': pendingLocalDelete,
  };
  factory ManifestMemoBook.fromJson(Map<String, dynamic> j) {
    final count = j['entry_count'] as int;
    if (count < 0 || !['normal', 'credentials'].contains(j['type'])) {
      throw const FormatException('memo manifest');
    }
    return ManifestMemoBook(
      id: j['id'] as String,
      name: j['name'] as String,
      type: j['type'] as String,
      storageOrigin: LedgerStorageOrigin.fromWire(
        j['storage_origin'] as String,
      ),
      sourceAccountId: j['source_account_id'] as String?,
      entryCount: count,
      createdAt: DateTime.parse(j['created_at'] as String),
      updatedAt: DateTime.parse(j['updated_at'] as String),
      isHidden: j['is_hidden'] as bool,
      pendingLocalDelete: j['pending_local_delete'] as bool,
    );
  }
}

/// 私有本清单提供同一恢复归属接口。
abstract interface class ManifestPrivateBook {
  String get id;
  LedgerStorageOrigin get storageOrigin;
  String? get sourceAccountId;
}

/// 健身空间以稳定父本身份进入备份，与其他本子一样允许多个来源。
class ManifestFitnessSpace implements ManifestPrivateBook {
  final FitnessSpace book;
  final Map<String, int> entityCounts;
  final bool fullyDownloaded;
  final int runningCount, recoveryBranchCount;
  const ManifestFitnessSpace({
    required this.book,
    required this.entityCounts,
    required this.fullyDownloaded,
    required this.runningCount,
    this.recoveryBranchCount = 0,
  });
  @override
  String get id => book.id;
  String get name => book.name;
  @override
  LedgerStorageOrigin get storageOrigin =>
      book.isCloud ? LedgerStorageOrigin.cloud : LedgerStorageOrigin.local;
  @override
  String? get sourceAccountId => book.scopeAccountId ?? book.sourceAccountId;
  int get recordCount => entityCounts.values.fold(0, (a, b) => a + b);
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'storage_origin': storageOrigin.wire,
    'source_account_id': sourceAccountId,
    'created_at': wireTimestamp(book.createdAt),
    'updated_at': wireTimestamp(book.updatedAt),
    'is_hidden': book.isHidden,
    'pending_local_delete': book.pendingLocalDelete,
    'entity_counts': entityCounts,
    'fully_downloaded': fullyDownloaded,
    'running_count': runningCount,
    'recovery_branch_count': recoveryBranchCount,
  };
  factory ManifestFitnessSpace.fromJson(Map<String, dynamic> json) {
    final origin = LedgerStorageOrigin.fromWire(
      json['storage_origin'] as String,
    );
    final counts = Map<String, int>.from(json['entity_counts'] as Map),
        running = json['running_count'] as int,
        branches = json['recovery_branch_count'] as int;
    if (counts.values.any((v) => v < 0) ||
        running < 0 ||
        running > 1 ||
        branches < 0) {
      throw const FormatException('fitness counts');
    }
    return ManifestFitnessSpace(
      book: FitnessSpace(
        id: json['id'] as String,
        name: json['name'] as String,
        storageMode: origin == LedgerStorageOrigin.cloud ? 'cloud' : 'local',
        scopeAccountId: origin == LedgerStorageOrigin.cloud
            ? json['source_account_id'] as String?
            : null,
        sourceAccountId: json['source_account_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        isHidden: json['is_hidden'] as bool,
        pendingLocalDelete: json['pending_local_delete'] as bool,
      ),
      entityCounts: counts,
      fullyDownloaded: json['fully_downloaded'] as bool,
      runningCount: running,
      recoveryBranchCount: branches,
    );
  }
}

class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.dbSchemaVersion,
    required this.createdAt,
    required this.deviceId,
    required this.ledgers,
    required this.accounts,
    this.dayBooks = const [],
    this.memoBooks = const [],
    this.fitnessSpaces = const [],
  });

  /// 备份格式版本（与 Envelope 双写校验）。
  final int formatVersion;

  /// 客户端 DB schema 版本（与 format_version 分离）。
  final int dbSchemaVersion;

  /// 备份创建时间（UTC）。
  final DateTime createdAt;

  /// 备份来源设备。
  final String deviceId;

  /// 账本清单（分域：LOCAL / CLOUD）。
  final List<ManifestLedger> ledgers;

  /// 涉及账号引用（无凭据）。
  final List<ManifestAccount> accounts;

  /// 独立本子按业务分别声明，空列表表示没有对应本子。
  final List<ManifestDayBook> dayBooks;
  final List<ManifestMemoBook> memoBooks;
  final List<ManifestFitnessSpace> fitnessSpaces;
  int get memoCardCount => memoBooks
      .where((b) => b.type == 'credentials')
      .fold<int>(0, (n, b) => n + b.entryCount);

  /// 序列化为冻结 JSON 形状。
  Map<String, dynamic> toJson() => {
    'format_version': formatVersion,
    'db_schema_version': dbSchemaVersion,
    'created_at': createdAt.toUtc().toIso8601String(),
    'device_id': deviceId,
    'ledgers': ledgers.map((l) => l.toJson()).toList(),
    'accounts': accounts.map((a) => a.toJson()).toList(),
    'contents': [..._backupContents],
    'memo_books': memoBooks.map((b) => b.toJson()).toList(),
    'fitness_spaces': fitnessSpaces.map((s) => s.toJson()).toList(),
    'day_books': dayBooks.map((book) => book.toJson()).toList(),
  };

  /// 从 JSON 解析；必填字段缺失/类型错误 → invalidManifest。
  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    try {
      final formatVersion = json['format_version'] as int?;
      final dbSchemaVersion = json['db_schema_version'] as int?;
      final createdAtRaw = json['created_at'] as String?;
      final deviceId = json['device_id'] as String?;
      final ledgersRaw = json['ledgers'] as List<dynamic>?;
      final accountsRaw = json['accounts'] as List<dynamic>?;
      final contents = (json['contents'] as List).cast<String>();
      if (contents.length != _backupContents.length ||
          !_backupContents.every(contents.contains)) {
        throw const FormatException('contents');
      }
      final memoBooks = [
        for (final item in json['memo_books'] as List)
          ManifestMemoBook.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
      final fitnessSpaces = [
        for (final item in json['fitness_spaces'] as List)
          ManifestFitnessSpace.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
      if (fitnessSpaces.map((s) => s.id).toSet().length !=
          fitnessSpaces.length) {
        throw const FormatException('duplicate fitness scope');
      }
      final dayBooks = [
        for (final item in json['day_books'] as List)
          ManifestDayBook.fromJson(Map<String, dynamic>.from(item as Map)),
      ];
      if (memoBooks.map((b) => b.id).toSet().length != memoBooks.length ||
          dayBooks.map((b) => b.dayBookId).toSet().length != dayBooks.length) {
        throw const FormatException('duplicate books');
      }
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
        dayBooks: dayBooks,
        memoBooks: memoBooks,
        fitnessSpaces: fitnessSpaces,
        ledgers: [
          for (final item in ledgersRaw)
            ManifestLedger.fromJson(Map<String, dynamic>.from(item as Map)),
        ],
        accounts: [
          for (final item in accountsRaw)
            ManifestAccount.fromJson(Map<String, dynamic>.from(item as Map)),
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

/// .snbak 明文分帧编解码：两个大端 u32 长度（manifest、SQLite）位于帧头，
/// 后接 manifest JSON 与 SQLite 内容。
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
    if (total != bytes.length) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧长度字段损坏');
    }
    return (
      manifestJson: Uint8List.sublistView(bytes, 8, 8 + manifestLength),
      sqliteBytes: Uint8List.sublistView(bytes, 8 + manifestLength, total),
    );
  }
}
