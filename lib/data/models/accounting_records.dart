/// Ledger 的不可变业务快照，不提供数据库查询或写入能力。
class LedgerSnapshot {
  final String id;
  final String name;
  final String currency;
  final int monthStartDay;
  final bool aaEnabled;
  final String role;
  final int memberCount;
  final String storageMode;
  final String? scopeAccountId;
  final String? ownerAccountId;
  final DateTime? archivedAt;
  final DateTime? archiveUpdatedAt;
  final String? archiveDeviceId;
  final String? archiveServerCursor;
  final String? syncId;
  final String? bindingStatus;
  final String? selfMemberId;
  final String? originType;
  final String? originLedgerId;
  final String? originSyncId;
  final String? originAccountId;
  final String? originBackupId;
  final int? originLastRevision;
  final DateTime? detachedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const LedgerSnapshot({
    required this.id,
    required this.name,
    required this.currency,
    required this.monthStartDay,
    required this.aaEnabled,
    required this.role,
    required this.memberCount,
    required this.storageMode,
    this.scopeAccountId,
    this.ownerAccountId,
    this.archivedAt,
    this.archiveUpdatedAt,
    this.archiveDeviceId,
    this.archiveServerCursor,
    this.syncId,
    this.bindingStatus,
    this.selfMemberId,
    this.originType,
    this.originLedgerId,
    this.originSyncId,
    this.originAccountId,
    this.originBackupId,
    this.originLastRevision,
    this.detachedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

/// Category 的不可变业务快照，不提供数据库查询或写入能力。
class CategorySnapshot {
  final String id;
  final String name;
  final String kind;
  final int level;
  final int sortOrder;
  final String? icon;
  final String? parentId;
  final String? scopeAccountId;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const CategorySnapshot({
    required this.id,
    required this.name,
    required this.kind,
    required this.level,
    required this.sortOrder,
    this.icon,
    this.parentId,
    this.scopeAccountId,
    required this.updatedAt,
    this.deletedAt,
  });
}

/// Transaction 的不可变业务快照，不提供数据库查询或写入能力。
class TransactionSnapshot {
  final String id;
  final String ledgerId;
  final String txType;
  final String amount;
  final DateTime happenedAt;
  final String? note;
  final String? categoryId;
  final String currencyCode;
  final String nativeAmount;
  final String? recurringId;
  final String? occurrenceDate;
  final String? createdByMemberId;
  final String? lastEditedByMemberId;
  final String? payerMemberId;
  final int? aaMode;
  final int version;
  final int? serverRevision;
  final DateTime? lastEditedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const TransactionSnapshot({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.happenedAt,
    this.note,
    this.categoryId,
    required this.currencyCode,
    required this.nativeAmount,
    this.recurringId,
    this.occurrenceDate,
    this.createdByMemberId,
    this.lastEditedByMemberId,
    this.payerMemberId,
    this.aaMode,
    required this.version,
    this.serverRevision,
    this.lastEditedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

/// LedgerMember 的不可变业务快照，不提供数据库查询或写入能力。
class LedgerMemberSnapshot {
  final String id;
  final String ledgerId;
  final String displayName;
  final String memberType;
  final String? linkedAccountId;
  final String? originMemberId;
  final String? originAccountId;
  final String role;
  final String? avatarUrl;
  final int avatarVersion;
  final String status;
  final DateTime joinedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const LedgerMemberSnapshot({
    required this.id,
    required this.ledgerId,
    required this.displayName,
    required this.memberType,
    this.linkedAccountId,
    this.originMemberId,
    this.originAccountId,
    required this.role,
    this.avatarUrl,
    required this.avatarVersion,
    required this.status,
    required this.joinedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

/// TransactionSplit 的不可变业务快照，不提供数据库查询或写入能力。
class TransactionSplitSnapshot {
  final int id;
  final String transactionId;
  final String memberId;
  final String amount;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const TransactionSplitSnapshot({
    required this.id,
    required this.transactionId,
    required this.memberId,
    required this.amount,
  });
}

/// RecurringTransaction 的不可变业务快照，不提供数据库查询或写入能力。
class RecurringTransactionSnapshot {
  final String id;
  final String ledgerId;
  final String txType;
  final String amount;
  final String currencyCode;
  final String? categoryId;
  final String? note;
  final String frequency;
  final int protocolVersion;
  final String timeZone;
  final int interval;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final int? monthOfYear;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastGeneratedDate;
  final bool enabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const RecurringTransactionSnapshot({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.currencyCode,
    this.categoryId,
    this.note,
    required this.frequency,
    this.protocolVersion = 1,
    this.timeZone = 'UTC',
    required this.interval,
    this.dayOfMonth,
    this.dayOfWeek,
    this.monthOfYear,
    required this.startDate,
    this.endDate,
    this.lastGeneratedDate,
    required this.enabled,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
}

/// ExchangeRate 的不可变业务快照，不提供数据库查询或写入能力。
class ExchangeRateSnapshot {
  final String baseCurrency;
  final String quoteCurrency;
  final String rateDate;
  final String rate;
  final String source;
  final DateTime fetchedAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const ExchangeRateSnapshot({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateDate,
    required this.rate,
    required this.source,
    required this.fetchedAt,
  });
}

/// ExchangeRateOverride 的不可变业务快照，不提供数据库查询或写入能力。
class ExchangeRateOverrideSnapshot {
  final String id;
  final String baseCurrency;
  final String quoteCurrency;
  final String rate;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? scopeAccountId;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const ExchangeRateOverrideSnapshot({
    required this.id,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.updatedAt,
    this.deletedAt,
    this.scopeAccountId,
  });
}

/// RecordEditHistory 的不可变业务快照，不提供数据库查询或写入能力。
class RecordEditHistorySnapshot {
  final int id;
  final String recordId;
  final int version;
  final String? operatorMemberId;
  final String summary;
  final DateTime createdAt;

  /// 使用显式业务字段构造快照，测试无需初始化数据库。
  const RecordEditHistorySnapshot({
    required this.id,
    required this.recordId,
    required this.version,
    this.operatorMemberId,
    required this.summary,
    required this.createdAt,
  });
}
