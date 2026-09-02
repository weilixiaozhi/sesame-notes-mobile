// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $LedgersTable extends Ledgers with TableInfo<$LedgersTable, Ledger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CNY'),
  );
  static const VerificationMeta _monthStartDayMeta = const VerificationMeta(
    'monthStartDay',
  );
  @override
  late final GeneratedColumn<int> monthStartDay = GeneratedColumn<int>(
    'month_start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _aaEnabledMeta = const VerificationMeta(
    'aaEnabled',
  );
  @override
  late final GeneratedColumn<bool> aaEnabled = GeneratedColumn<bool>(
    'aa_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aa_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _memberCountMeta = const VerificationMeta(
    'memberCount',
  );
  @override
  late final GeneratedColumn<int> memberCount = GeneratedColumn<int>(
    'member_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _storageModeMeta = const VerificationMeta(
    'storageMode',
  );
  @override
  late final GeneratedColumn<String> storageMode = GeneratedColumn<String>(
    'storage_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _scopeAccountIdMeta = const VerificationMeta(
    'scopeAccountId',
  );
  @override
  late final GeneratedColumn<String> scopeAccountId = GeneratedColumn<String>(
    'scope_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bindingStatusMeta = const VerificationMeta(
    'bindingStatus',
  );
  @override
  late final GeneratedColumn<String> bindingStatus = GeneratedColumn<String>(
    'binding_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selfMemberIdMeta = const VerificationMeta(
    'selfMemberId',
  );
  @override
  late final GeneratedColumn<String> selfMemberId = GeneratedColumn<String>(
    'self_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originTypeMeta = const VerificationMeta(
    'originType',
  );
  @override
  late final GeneratedColumn<String> originType = GeneratedColumn<String>(
    'origin_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originLedgerIdMeta = const VerificationMeta(
    'originLedgerId',
  );
  @override
  late final GeneratedColumn<String> originLedgerId = GeneratedColumn<String>(
    'origin_ledger_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originSyncIdMeta = const VerificationMeta(
    'originSyncId',
  );
  @override
  late final GeneratedColumn<String> originSyncId = GeneratedColumn<String>(
    'origin_sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originAccountIdMeta = const VerificationMeta(
    'originAccountId',
  );
  @override
  late final GeneratedColumn<String> originAccountId = GeneratedColumn<String>(
    'origin_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originBackupIdMeta = const VerificationMeta(
    'originBackupId',
  );
  @override
  late final GeneratedColumn<String> originBackupId = GeneratedColumn<String>(
    'origin_backup_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originLastRevisionMeta =
      const VerificationMeta('originLastRevision');
  @override
  late final GeneratedColumn<int> originLastRevision = GeneratedColumn<int>(
    'origin_last_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detachedAtMeta = const VerificationMeta(
    'detachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detachedAt = GeneratedColumn<DateTime>(
    'detached_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    currency,
    monthStartDay,
    aaEnabled,
    role,
    memberCount,
    storageMode,
    scopeAccountId,
    syncId,
    bindingStatus,
    selfMemberId,
    originType,
    originLedgerId,
    originSyncId,
    originAccountId,
    originBackupId,
    originLastRevision,
    detachedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledgers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ledger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('month_start_day')) {
      context.handle(
        _monthStartDayMeta,
        monthStartDay.isAcceptableOrUnknown(
          data['month_start_day']!,
          _monthStartDayMeta,
        ),
      );
    }
    if (data.containsKey('aa_enabled')) {
      context.handle(
        _aaEnabledMeta,
        aaEnabled.isAcceptableOrUnknown(data['aa_enabled']!, _aaEnabledMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('member_count')) {
      context.handle(
        _memberCountMeta,
        memberCount.isAcceptableOrUnknown(
          data['member_count']!,
          _memberCountMeta,
        ),
      );
    }
    if (data.containsKey('storage_mode')) {
      context.handle(
        _storageModeMeta,
        storageMode.isAcceptableOrUnknown(
          data['storage_mode']!,
          _storageModeMeta,
        ),
      );
    }
    if (data.containsKey('scope_account_id')) {
      context.handle(
        _scopeAccountIdMeta,
        scopeAccountId.isAcceptableOrUnknown(
          data['scope_account_id']!,
          _scopeAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('binding_status')) {
      context.handle(
        _bindingStatusMeta,
        bindingStatus.isAcceptableOrUnknown(
          data['binding_status']!,
          _bindingStatusMeta,
        ),
      );
    }
    if (data.containsKey('self_member_id')) {
      context.handle(
        _selfMemberIdMeta,
        selfMemberId.isAcceptableOrUnknown(
          data['self_member_id']!,
          _selfMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_type')) {
      context.handle(
        _originTypeMeta,
        originType.isAcceptableOrUnknown(data['origin_type']!, _originTypeMeta),
      );
    }
    if (data.containsKey('origin_ledger_id')) {
      context.handle(
        _originLedgerIdMeta,
        originLedgerId.isAcceptableOrUnknown(
          data['origin_ledger_id']!,
          _originLedgerIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_sync_id')) {
      context.handle(
        _originSyncIdMeta,
        originSyncId.isAcceptableOrUnknown(
          data['origin_sync_id']!,
          _originSyncIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_account_id')) {
      context.handle(
        _originAccountIdMeta,
        originAccountId.isAcceptableOrUnknown(
          data['origin_account_id']!,
          _originAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_backup_id')) {
      context.handle(
        _originBackupIdMeta,
        originBackupId.isAcceptableOrUnknown(
          data['origin_backup_id']!,
          _originBackupIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_last_revision')) {
      context.handle(
        _originLastRevisionMeta,
        originLastRevision.isAcceptableOrUnknown(
          data['origin_last_revision']!,
          _originLastRevisionMeta,
        ),
      );
    }
    if (data.containsKey('detached_at')) {
      context.handle(
        _detachedAtMeta,
        detachedAt.isAcceptableOrUnknown(data['detached_at']!, _detachedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ledger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ledger(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      monthStartDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_start_day'],
      )!,
      aaEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aa_enabled'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      memberCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}member_count'],
      )!,
      storageMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_mode'],
      )!,
      scopeAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_account_id'],
      ),
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      bindingStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}binding_status'],
      ),
      selfMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}self_member_id'],
      ),
      originType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_type'],
      ),
      originLedgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_ledger_id'],
      ),
      originSyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_sync_id'],
      ),
      originAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_account_id'],
      ),
      originBackupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_backup_id'],
      ),
      originLastRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origin_last_revision'],
      ),
      detachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detached_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LedgersTable createAlias(String alias) {
    return $LedgersTable(attachedDatabase, alias);
  }
}

class Ledger extends DataClass implements Insertable<Ledger> {
  /// UUID v4 主键：离线创建时客户端生成，push 后服务端接受同一 id。
  final String id;
  final String name;
  final String currency;

  /// 自定义每月起始日(1-28),统计/预算/小部件按 [当月N日, 次月N日) 聚合。
  final int monthStartDay;

  /// AA 分摊开关(契约字段 aa_enabled)。
  final bool aaEnabled;

  /// 当前用户在账本中的角色(契约字段 role: owner/editor)。
  final String role;

  /// 成员数(契约字段 member_count)。
  final int memberCount;

  /// 账本归属(客户端本地列,不进同步): 'local' = 纯本地账本, 'cloud' = 云端账本。
  final String storageMode;

  /// 账号数据域：null = 本地域（LOCAL 账本），非 null = 云账号 user_id。
  /// 登录/登出/换账号按此列隔离，禁止跨账号读取或推送。
  final String? scopeAccountId;

  /// 云同步时间线身份(3.1): 同一云端账本的所有设备共享同一 sync_id,
  /// 由服务端生成并在绑定/确认时写入; 本地账本恒为 NULL(无同步身份),
  /// Detach/Fork 时清除 binding 而非生成伪 sync_id。
  final String? syncId;

  /// 同步绑定状态(3.7): NULL/bound = 正常; 'stale' = SYNC_ID_MISMATCH 后
  /// 本地 binding 与云端时间线不一致, 同步暂停等待用户决策(放弃本地/Detach)。
  final String? bindingStatus;

  /// 本人在该账本中的成员 id（本地账本首次建账本时创建 LOCAL 成员；
  /// 云端账本登录后按 linked_account_id 解析）。身份不随登录变化。
  final String? selfMemberId;

  /// 溯源:来源类型(CLOUD_BACKUP / LOCAL_BACKUP),仅 provenance,不授予同步语义。
  final String? originType;

  /// 溯源:来源账本 id(备份里的原始 ledger id)。
  final String? originLedgerId;

  /// 溯源:备份时来源账本的 sync_id(只读;永不作活跃 sync_id)。
  final String? originSyncId;

  /// 溯源:来源账号 id(只读;不恢复绑定关系)。
  final String? originAccountId;

  /// 溯源:来源备份(备份文件 id/名,审计用)。
  final String? originBackupId;

  /// 溯源:备份时最后服务端 revision(只读;永不作 base_revision)。
  final int? originLastRevision;

  /// 溯源:Fork/恢复落盘时间(审计用)。
  final DateTime? detachedAt;

  /// 本地创建时间(客户端本地列;契约不含 ledger.created_at)。
  final DateTime createdAt;

  /// 服务端更新时间(同步 LWW 依据)。
  final DateTime updatedAt;

  /// 本地 tombstone:同步收到 delete 事件时写入,查询默认过滤。
  final DateTime? deletedAt;
  const Ledger({
    required this.id,
    required this.name,
    required this.currency,
    required this.monthStartDay,
    required this.aaEnabled,
    required this.role,
    required this.memberCount,
    required this.storageMode,
    this.scopeAccountId,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['currency'] = Variable<String>(currency);
    map['month_start_day'] = Variable<int>(monthStartDay);
    map['aa_enabled'] = Variable<bool>(aaEnabled);
    map['role'] = Variable<String>(role);
    map['member_count'] = Variable<int>(memberCount);
    map['storage_mode'] = Variable<String>(storageMode);
    if (!nullToAbsent || scopeAccountId != null) {
      map['scope_account_id'] = Variable<String>(scopeAccountId);
    }
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    if (!nullToAbsent || bindingStatus != null) {
      map['binding_status'] = Variable<String>(bindingStatus);
    }
    if (!nullToAbsent || selfMemberId != null) {
      map['self_member_id'] = Variable<String>(selfMemberId);
    }
    if (!nullToAbsent || originType != null) {
      map['origin_type'] = Variable<String>(originType);
    }
    if (!nullToAbsent || originLedgerId != null) {
      map['origin_ledger_id'] = Variable<String>(originLedgerId);
    }
    if (!nullToAbsent || originSyncId != null) {
      map['origin_sync_id'] = Variable<String>(originSyncId);
    }
    if (!nullToAbsent || originAccountId != null) {
      map['origin_account_id'] = Variable<String>(originAccountId);
    }
    if (!nullToAbsent || originBackupId != null) {
      map['origin_backup_id'] = Variable<String>(originBackupId);
    }
    if (!nullToAbsent || originLastRevision != null) {
      map['origin_last_revision'] = Variable<int>(originLastRevision);
    }
    if (!nullToAbsent || detachedAt != null) {
      map['detached_at'] = Variable<DateTime>(detachedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LedgersCompanion toCompanion(bool nullToAbsent) {
    return LedgersCompanion(
      id: Value(id),
      name: Value(name),
      currency: Value(currency),
      monthStartDay: Value(monthStartDay),
      aaEnabled: Value(aaEnabled),
      role: Value(role),
      memberCount: Value(memberCount),
      storageMode: Value(storageMode),
      scopeAccountId: scopeAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeAccountId),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      bindingStatus: bindingStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(bindingStatus),
      selfMemberId: selfMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(selfMemberId),
      originType: originType == null && nullToAbsent
          ? const Value.absent()
          : Value(originType),
      originLedgerId: originLedgerId == null && nullToAbsent
          ? const Value.absent()
          : Value(originLedgerId),
      originSyncId: originSyncId == null && nullToAbsent
          ? const Value.absent()
          : Value(originSyncId),
      originAccountId: originAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(originAccountId),
      originBackupId: originBackupId == null && nullToAbsent
          ? const Value.absent()
          : Value(originBackupId),
      originLastRevision: originLastRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(originLastRevision),
      detachedAt: detachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(detachedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Ledger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ledger(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      currency: serializer.fromJson<String>(json['currency']),
      monthStartDay: serializer.fromJson<int>(json['monthStartDay']),
      aaEnabled: serializer.fromJson<bool>(json['aaEnabled']),
      role: serializer.fromJson<String>(json['role']),
      memberCount: serializer.fromJson<int>(json['memberCount']),
      storageMode: serializer.fromJson<String>(json['storageMode']),
      scopeAccountId: serializer.fromJson<String?>(json['scopeAccountId']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      bindingStatus: serializer.fromJson<String?>(json['bindingStatus']),
      selfMemberId: serializer.fromJson<String?>(json['selfMemberId']),
      originType: serializer.fromJson<String?>(json['originType']),
      originLedgerId: serializer.fromJson<String?>(json['originLedgerId']),
      originSyncId: serializer.fromJson<String?>(json['originSyncId']),
      originAccountId: serializer.fromJson<String?>(json['originAccountId']),
      originBackupId: serializer.fromJson<String?>(json['originBackupId']),
      originLastRevision: serializer.fromJson<int?>(json['originLastRevision']),
      detachedAt: serializer.fromJson<DateTime?>(json['detachedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'currency': serializer.toJson<String>(currency),
      'monthStartDay': serializer.toJson<int>(monthStartDay),
      'aaEnabled': serializer.toJson<bool>(aaEnabled),
      'role': serializer.toJson<String>(role),
      'memberCount': serializer.toJson<int>(memberCount),
      'storageMode': serializer.toJson<String>(storageMode),
      'scopeAccountId': serializer.toJson<String?>(scopeAccountId),
      'syncId': serializer.toJson<String?>(syncId),
      'bindingStatus': serializer.toJson<String?>(bindingStatus),
      'selfMemberId': serializer.toJson<String?>(selfMemberId),
      'originType': serializer.toJson<String?>(originType),
      'originLedgerId': serializer.toJson<String?>(originLedgerId),
      'originSyncId': serializer.toJson<String?>(originSyncId),
      'originAccountId': serializer.toJson<String?>(originAccountId),
      'originBackupId': serializer.toJson<String?>(originBackupId),
      'originLastRevision': serializer.toJson<int?>(originLastRevision),
      'detachedAt': serializer.toJson<DateTime?>(detachedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Ledger copyWith({
    String? id,
    String? name,
    String? currency,
    int? monthStartDay,
    bool? aaEnabled,
    String? role,
    int? memberCount,
    String? storageMode,
    Value<String?> scopeAccountId = const Value.absent(),
    Value<String?> syncId = const Value.absent(),
    Value<String?> bindingStatus = const Value.absent(),
    Value<String?> selfMemberId = const Value.absent(),
    Value<String?> originType = const Value.absent(),
    Value<String?> originLedgerId = const Value.absent(),
    Value<String?> originSyncId = const Value.absent(),
    Value<String?> originAccountId = const Value.absent(),
    Value<String?> originBackupId = const Value.absent(),
    Value<int?> originLastRevision = const Value.absent(),
    Value<DateTime?> detachedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Ledger(
    id: id ?? this.id,
    name: name ?? this.name,
    currency: currency ?? this.currency,
    monthStartDay: monthStartDay ?? this.monthStartDay,
    aaEnabled: aaEnabled ?? this.aaEnabled,
    role: role ?? this.role,
    memberCount: memberCount ?? this.memberCount,
    storageMode: storageMode ?? this.storageMode,
    scopeAccountId: scopeAccountId.present
        ? scopeAccountId.value
        : this.scopeAccountId,
    syncId: syncId.present ? syncId.value : this.syncId,
    bindingStatus: bindingStatus.present
        ? bindingStatus.value
        : this.bindingStatus,
    selfMemberId: selfMemberId.present ? selfMemberId.value : this.selfMemberId,
    originType: originType.present ? originType.value : this.originType,
    originLedgerId: originLedgerId.present
        ? originLedgerId.value
        : this.originLedgerId,
    originSyncId: originSyncId.present ? originSyncId.value : this.originSyncId,
    originAccountId: originAccountId.present
        ? originAccountId.value
        : this.originAccountId,
    originBackupId: originBackupId.present
        ? originBackupId.value
        : this.originBackupId,
    originLastRevision: originLastRevision.present
        ? originLastRevision.value
        : this.originLastRevision,
    detachedAt: detachedAt.present ? detachedAt.value : this.detachedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Ledger copyWithCompanion(LedgersCompanion data) {
    return Ledger(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      currency: data.currency.present ? data.currency.value : this.currency,
      monthStartDay: data.monthStartDay.present
          ? data.monthStartDay.value
          : this.monthStartDay,
      aaEnabled: data.aaEnabled.present ? data.aaEnabled.value : this.aaEnabled,
      role: data.role.present ? data.role.value : this.role,
      memberCount: data.memberCount.present
          ? data.memberCount.value
          : this.memberCount,
      storageMode: data.storageMode.present
          ? data.storageMode.value
          : this.storageMode,
      scopeAccountId: data.scopeAccountId.present
          ? data.scopeAccountId.value
          : this.scopeAccountId,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      bindingStatus: data.bindingStatus.present
          ? data.bindingStatus.value
          : this.bindingStatus,
      selfMemberId: data.selfMemberId.present
          ? data.selfMemberId.value
          : this.selfMemberId,
      originType: data.originType.present
          ? data.originType.value
          : this.originType,
      originLedgerId: data.originLedgerId.present
          ? data.originLedgerId.value
          : this.originLedgerId,
      originSyncId: data.originSyncId.present
          ? data.originSyncId.value
          : this.originSyncId,
      originAccountId: data.originAccountId.present
          ? data.originAccountId.value
          : this.originAccountId,
      originBackupId: data.originBackupId.present
          ? data.originBackupId.value
          : this.originBackupId,
      originLastRevision: data.originLastRevision.present
          ? data.originLastRevision.value
          : this.originLastRevision,
      detachedAt: data.detachedAt.present
          ? data.detachedAt.value
          : this.detachedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ledger(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('monthStartDay: $monthStartDay, ')
          ..write('aaEnabled: $aaEnabled, ')
          ..write('role: $role, ')
          ..write('memberCount: $memberCount, ')
          ..write('storageMode: $storageMode, ')
          ..write('scopeAccountId: $scopeAccountId, ')
          ..write('syncId: $syncId, ')
          ..write('bindingStatus: $bindingStatus, ')
          ..write('selfMemberId: $selfMemberId, ')
          ..write('originType: $originType, ')
          ..write('originLedgerId: $originLedgerId, ')
          ..write('originSyncId: $originSyncId, ')
          ..write('originAccountId: $originAccountId, ')
          ..write('originBackupId: $originBackupId, ')
          ..write('originLastRevision: $originLastRevision, ')
          ..write('detachedAt: $detachedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    currency,
    monthStartDay,
    aaEnabled,
    role,
    memberCount,
    storageMode,
    scopeAccountId,
    syncId,
    bindingStatus,
    selfMemberId,
    originType,
    originLedgerId,
    originSyncId,
    originAccountId,
    originBackupId,
    originLastRevision,
    detachedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ledger &&
          other.id == this.id &&
          other.name == this.name &&
          other.currency == this.currency &&
          other.monthStartDay == this.monthStartDay &&
          other.aaEnabled == this.aaEnabled &&
          other.role == this.role &&
          other.memberCount == this.memberCount &&
          other.storageMode == this.storageMode &&
          other.scopeAccountId == this.scopeAccountId &&
          other.syncId == this.syncId &&
          other.bindingStatus == this.bindingStatus &&
          other.selfMemberId == this.selfMemberId &&
          other.originType == this.originType &&
          other.originLedgerId == this.originLedgerId &&
          other.originSyncId == this.originSyncId &&
          other.originAccountId == this.originAccountId &&
          other.originBackupId == this.originBackupId &&
          other.originLastRevision == this.originLastRevision &&
          other.detachedAt == this.detachedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LedgersCompanion extends UpdateCompanion<Ledger> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> currency;
  final Value<int> monthStartDay;
  final Value<bool> aaEnabled;
  final Value<String> role;
  final Value<int> memberCount;
  final Value<String> storageMode;
  final Value<String?> scopeAccountId;
  final Value<String?> syncId;
  final Value<String?> bindingStatus;
  final Value<String?> selfMemberId;
  final Value<String?> originType;
  final Value<String?> originLedgerId;
  final Value<String?> originSyncId;
  final Value<String?> originAccountId;
  final Value<String?> originBackupId;
  final Value<int?> originLastRevision;
  final Value<DateTime?> detachedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LedgersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.currency = const Value.absent(),
    this.monthStartDay = const Value.absent(),
    this.aaEnabled = const Value.absent(),
    this.role = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.scopeAccountId = const Value.absent(),
    this.syncId = const Value.absent(),
    this.bindingStatus = const Value.absent(),
    this.selfMemberId = const Value.absent(),
    this.originType = const Value.absent(),
    this.originLedgerId = const Value.absent(),
    this.originSyncId = const Value.absent(),
    this.originAccountId = const Value.absent(),
    this.originBackupId = const Value.absent(),
    this.originLastRevision = const Value.absent(),
    this.detachedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgersCompanion.insert({
    required String id,
    required String name,
    this.currency = const Value.absent(),
    this.monthStartDay = const Value.absent(),
    this.aaEnabled = const Value.absent(),
    this.role = const Value.absent(),
    this.memberCount = const Value.absent(),
    this.storageMode = const Value.absent(),
    this.scopeAccountId = const Value.absent(),
    this.syncId = const Value.absent(),
    this.bindingStatus = const Value.absent(),
    this.selfMemberId = const Value.absent(),
    this.originType = const Value.absent(),
    this.originLedgerId = const Value.absent(),
    this.originSyncId = const Value.absent(),
    this.originAccountId = const Value.absent(),
    this.originBackupId = const Value.absent(),
    this.originLastRevision = const Value.absent(),
    this.detachedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<Ledger> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? currency,
    Expression<int>? monthStartDay,
    Expression<bool>? aaEnabled,
    Expression<String>? role,
    Expression<int>? memberCount,
    Expression<String>? storageMode,
    Expression<String>? scopeAccountId,
    Expression<String>? syncId,
    Expression<String>? bindingStatus,
    Expression<String>? selfMemberId,
    Expression<String>? originType,
    Expression<String>? originLedgerId,
    Expression<String>? originSyncId,
    Expression<String>? originAccountId,
    Expression<String>? originBackupId,
    Expression<int>? originLastRevision,
    Expression<DateTime>? detachedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (currency != null) 'currency': currency,
      if (monthStartDay != null) 'month_start_day': monthStartDay,
      if (aaEnabled != null) 'aa_enabled': aaEnabled,
      if (role != null) 'role': role,
      if (memberCount != null) 'member_count': memberCount,
      if (storageMode != null) 'storage_mode': storageMode,
      if (scopeAccountId != null) 'scope_account_id': scopeAccountId,
      if (syncId != null) 'sync_id': syncId,
      if (bindingStatus != null) 'binding_status': bindingStatus,
      if (selfMemberId != null) 'self_member_id': selfMemberId,
      if (originType != null) 'origin_type': originType,
      if (originLedgerId != null) 'origin_ledger_id': originLedgerId,
      if (originSyncId != null) 'origin_sync_id': originSyncId,
      if (originAccountId != null) 'origin_account_id': originAccountId,
      if (originBackupId != null) 'origin_backup_id': originBackupId,
      if (originLastRevision != null)
        'origin_last_revision': originLastRevision,
      if (detachedAt != null) 'detached_at': detachedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? currency,
    Value<int>? monthStartDay,
    Value<bool>? aaEnabled,
    Value<String>? role,
    Value<int>? memberCount,
    Value<String>? storageMode,
    Value<String?>? scopeAccountId,
    Value<String?>? syncId,
    Value<String?>? bindingStatus,
    Value<String?>? selfMemberId,
    Value<String?>? originType,
    Value<String?>? originLedgerId,
    Value<String?>? originSyncId,
    Value<String?>? originAccountId,
    Value<String?>? originBackupId,
    Value<int?>? originLastRevision,
    Value<DateTime?>? detachedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LedgersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      monthStartDay: monthStartDay ?? this.monthStartDay,
      aaEnabled: aaEnabled ?? this.aaEnabled,
      role: role ?? this.role,
      memberCount: memberCount ?? this.memberCount,
      storageMode: storageMode ?? this.storageMode,
      scopeAccountId: scopeAccountId ?? this.scopeAccountId,
      syncId: syncId ?? this.syncId,
      bindingStatus: bindingStatus ?? this.bindingStatus,
      selfMemberId: selfMemberId ?? this.selfMemberId,
      originType: originType ?? this.originType,
      originLedgerId: originLedgerId ?? this.originLedgerId,
      originSyncId: originSyncId ?? this.originSyncId,
      originAccountId: originAccountId ?? this.originAccountId,
      originBackupId: originBackupId ?? this.originBackupId,
      originLastRevision: originLastRevision ?? this.originLastRevision,
      detachedAt: detachedAt ?? this.detachedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (monthStartDay.present) {
      map['month_start_day'] = Variable<int>(monthStartDay.value);
    }
    if (aaEnabled.present) {
      map['aa_enabled'] = Variable<bool>(aaEnabled.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (memberCount.present) {
      map['member_count'] = Variable<int>(memberCount.value);
    }
    if (storageMode.present) {
      map['storage_mode'] = Variable<String>(storageMode.value);
    }
    if (scopeAccountId.present) {
      map['scope_account_id'] = Variable<String>(scopeAccountId.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (bindingStatus.present) {
      map['binding_status'] = Variable<String>(bindingStatus.value);
    }
    if (selfMemberId.present) {
      map['self_member_id'] = Variable<String>(selfMemberId.value);
    }
    if (originType.present) {
      map['origin_type'] = Variable<String>(originType.value);
    }
    if (originLedgerId.present) {
      map['origin_ledger_id'] = Variable<String>(originLedgerId.value);
    }
    if (originSyncId.present) {
      map['origin_sync_id'] = Variable<String>(originSyncId.value);
    }
    if (originAccountId.present) {
      map['origin_account_id'] = Variable<String>(originAccountId.value);
    }
    if (originBackupId.present) {
      map['origin_backup_id'] = Variable<String>(originBackupId.value);
    }
    if (originLastRevision.present) {
      map['origin_last_revision'] = Variable<int>(originLastRevision.value);
    }
    if (detachedAt.present) {
      map['detached_at'] = Variable<DateTime>(detachedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('currency: $currency, ')
          ..write('monthStartDay: $monthStartDay, ')
          ..write('aaEnabled: $aaEnabled, ')
          ..write('role: $role, ')
          ..write('memberCount: $memberCount, ')
          ..write('storageMode: $storageMode, ')
          ..write('scopeAccountId: $scopeAccountId, ')
          ..write('syncId: $syncId, ')
          ..write('bindingStatus: $bindingStatus, ')
          ..write('selfMemberId: $selfMemberId, ')
          ..write('originType: $originType, ')
          ..write('originLedgerId: $originLedgerId, ')
          ..write('originSyncId: $originSyncId, ')
          ..write('originAccountId: $originAccountId, ')
          ..write('originBackupId: $originBackupId, ')
          ..write('originLastRevision: $originLastRevision, ')
          ..write('detachedAt: $detachedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerMembersTable extends LedgerMembers
    with TableInfo<$LedgerMembersTable, LedgerMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledgers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberTypeMeta = const VerificationMeta(
    'memberType',
  );
  @override
  late final GeneratedColumn<String> memberType = GeneratedColumn<String>(
    'member_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkedAccountIdMeta = const VerificationMeta(
    'linkedAccountId',
  );
  @override
  late final GeneratedColumn<String> linkedAccountId = GeneratedColumn<String>(
    'linked_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMemberIdMeta = const VerificationMeta(
    'originMemberId',
  );
  @override
  late final GeneratedColumn<String> originMemberId = GeneratedColumn<String>(
    'origin_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originAccountIdMeta = const VerificationMeta(
    'originAccountId',
  );
  @override
  late final GeneratedColumn<String> originAccountId = GeneratedColumn<String>(
    'origin_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('editor'),
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarVersionMeta = const VerificationMeta(
    'avatarVersion',
  );
  @override
  late final GeneratedColumn<int> avatarVersion = GeneratedColumn<int>(
    'avatar_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerId,
    displayName,
    memberType,
    linkedAccountId,
    originMemberId,
    originAccountId,
    role,
    avatarUrl,
    avatarVersion,
    status,
    joinedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<LedgerMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('member_type')) {
      context.handle(
        _memberTypeMeta,
        memberType.isAcceptableOrUnknown(data['member_type']!, _memberTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_memberTypeMeta);
    }
    if (data.containsKey('linked_account_id')) {
      context.handle(
        _linkedAccountIdMeta,
        linkedAccountId.isAcceptableOrUnknown(
          data['linked_account_id']!,
          _linkedAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_member_id')) {
      context.handle(
        _originMemberIdMeta,
        originMemberId.isAcceptableOrUnknown(
          data['origin_member_id']!,
          _originMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('origin_account_id')) {
      context.handle(
        _originAccountIdMeta,
        originAccountId.isAcceptableOrUnknown(
          data['origin_account_id']!,
          _originAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('avatar_version')) {
      context.handle(
        _avatarVersionMeta,
        avatarVersion.isAcceptableOrUnknown(
          data['avatar_version']!,
          _avatarVersionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      memberType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_type'],
      )!,
      linkedAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_account_id'],
      ),
      originMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_member_id'],
      ),
      originAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_account_id'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      avatarVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}avatar_version'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $LedgerMembersTable createAlias(String alias) {
    return $LedgerMembersTable(attachedDatabase, alias);
  }
}

class LedgerMember extends DataClass implements Insertable<LedgerMember> {
  /// member_id:PLACEHOLDER 复用虚拟用户 v4 id;LOCAL/REGISTERED 用确定性
  /// UUIDv5(ledger_id, 身份键)派生(同账本稳定、跨账本不同)。
  final String id;

  /// 所属账本;账本删除时成员级联清除。
  final String ledgerId;

  /// 显示名:本地成员由用户维护,云端成员来自服务端成员资料。
  final String displayName;

  /// 成员类型: LOCAL=本机本地成员, REGISTERED=已绑定云端账号,
  /// PLACEHOLDER=占位成员(原虚拟用户)。
  final String memberType;

  /// 已绑定的云端账号 userId(REGISTERED 必有;LOCAL 登录后绑定、退出解绑)。
  final String? linkedAccountId;

  /// 溯源:来源云端成员 id(备份恢复/映射场景保留,不参与认证)。
  final String? originMemberId;

  /// 溯源:来源云端账号 id(备份恢复/映射场景保留,不参与认证)。
  final String? originAccountId;

  /// 成员角色(客户端镜像语义,与契约 role 对齐):owner/editor（邀请即编辑，无只读档）。
  final String role;

  /// 云端成员头像(URL + 版本号,version 变化时重新拉取)。
  final String? avatarUrl;
  final int avatarVersion;

  /// 成员生命周期: ACTIVE=正常, LEFT=主动退出, REMOVED=被移出。
  /// 历史账务引用不随状态变化——成员行永不删除。
  final String status;

  /// 加入时间(云端成员取服务端 joined_at)。
  final DateTime joinedAt;
  final DateTime createdAt;

  /// 同步/本地编辑时间(LWW 依据)。
  final DateTime updatedAt;

  /// 本地 tombstone。
  final DateTime? deletedAt;
  const LedgerMember({
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['display_name'] = Variable<String>(displayName);
    map['member_type'] = Variable<String>(memberType);
    if (!nullToAbsent || linkedAccountId != null) {
      map['linked_account_id'] = Variable<String>(linkedAccountId);
    }
    if (!nullToAbsent || originMemberId != null) {
      map['origin_member_id'] = Variable<String>(originMemberId);
    }
    if (!nullToAbsent || originAccountId != null) {
      map['origin_account_id'] = Variable<String>(originAccountId);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['avatar_version'] = Variable<int>(avatarVersion);
    map['status'] = Variable<String>(status);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  LedgerMembersCompanion toCompanion(bool nullToAbsent) {
    return LedgerMembersCompanion(
      id: Value(id),
      ledgerId: Value(ledgerId),
      displayName: Value(displayName),
      memberType: Value(memberType),
      linkedAccountId: linkedAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedAccountId),
      originMemberId: originMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(originMemberId),
      originAccountId: originAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(originAccountId),
      role: Value(role),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      avatarVersion: Value(avatarVersion),
      status: Value(status),
      joinedAt: Value(joinedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory LedgerMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerMember(
      id: serializer.fromJson<String>(json['id']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      memberType: serializer.fromJson<String>(json['memberType']),
      linkedAccountId: serializer.fromJson<String?>(json['linkedAccountId']),
      originMemberId: serializer.fromJson<String?>(json['originMemberId']),
      originAccountId: serializer.fromJson<String?>(json['originAccountId']),
      role: serializer.fromJson<String>(json['role']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      avatarVersion: serializer.fromJson<int>(json['avatarVersion']),
      status: serializer.fromJson<String>(json['status']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'displayName': serializer.toJson<String>(displayName),
      'memberType': serializer.toJson<String>(memberType),
      'linkedAccountId': serializer.toJson<String?>(linkedAccountId),
      'originMemberId': serializer.toJson<String?>(originMemberId),
      'originAccountId': serializer.toJson<String?>(originAccountId),
      'role': serializer.toJson<String>(role),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'avatarVersion': serializer.toJson<int>(avatarVersion),
      'status': serializer.toJson<String>(status),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  LedgerMember copyWith({
    String? id,
    String? ledgerId,
    String? displayName,
    String? memberType,
    Value<String?> linkedAccountId = const Value.absent(),
    Value<String?> originMemberId = const Value.absent(),
    Value<String?> originAccountId = const Value.absent(),
    String? role,
    Value<String?> avatarUrl = const Value.absent(),
    int? avatarVersion,
    String? status,
    DateTime? joinedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => LedgerMember(
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    displayName: displayName ?? this.displayName,
    memberType: memberType ?? this.memberType,
    linkedAccountId: linkedAccountId.present
        ? linkedAccountId.value
        : this.linkedAccountId,
    originMemberId: originMemberId.present
        ? originMemberId.value
        : this.originMemberId,
    originAccountId: originAccountId.present
        ? originAccountId.value
        : this.originAccountId,
    role: role ?? this.role,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    avatarVersion: avatarVersion ?? this.avatarVersion,
    status: status ?? this.status,
    joinedAt: joinedAt ?? this.joinedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  LedgerMember copyWithCompanion(LedgerMembersCompanion data) {
    return LedgerMember(
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      memberType: data.memberType.present
          ? data.memberType.value
          : this.memberType,
      linkedAccountId: data.linkedAccountId.present
          ? data.linkedAccountId.value
          : this.linkedAccountId,
      originMemberId: data.originMemberId.present
          ? data.originMemberId.value
          : this.originMemberId,
      originAccountId: data.originAccountId.present
          ? data.originAccountId.value
          : this.originAccountId,
      role: data.role.present ? data.role.value : this.role,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      avatarVersion: data.avatarVersion.present
          ? data.avatarVersion.value
          : this.avatarVersion,
      status: data.status.present ? data.status.value : this.status,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerMember(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('displayName: $displayName, ')
          ..write('memberType: $memberType, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('originMemberId: $originMemberId, ')
          ..write('originAccountId: $originAccountId, ')
          ..write('role: $role, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarVersion: $avatarVersion, ')
          ..write('status: $status, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ledgerId,
    displayName,
    memberType,
    linkedAccountId,
    originMemberId,
    originAccountId,
    role,
    avatarUrl,
    avatarVersion,
    status,
    joinedAt,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerMember &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.displayName == this.displayName &&
          other.memberType == this.memberType &&
          other.linkedAccountId == this.linkedAccountId &&
          other.originMemberId == this.originMemberId &&
          other.originAccountId == this.originAccountId &&
          other.role == this.role &&
          other.avatarUrl == this.avatarUrl &&
          other.avatarVersion == this.avatarVersion &&
          other.status == this.status &&
          other.joinedAt == this.joinedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class LedgerMembersCompanion extends UpdateCompanion<LedgerMember> {
  final Value<String> id;
  final Value<String> ledgerId;
  final Value<String> displayName;
  final Value<String> memberType;
  final Value<String?> linkedAccountId;
  final Value<String?> originMemberId;
  final Value<String?> originAccountId;
  final Value<String> role;
  final Value<String?> avatarUrl;
  final Value<int> avatarVersion;
  final Value<String> status;
  final Value<DateTime> joinedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const LedgerMembersCompanion({
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.memberType = const Value.absent(),
    this.linkedAccountId = const Value.absent(),
    this.originMemberId = const Value.absent(),
    this.originAccountId = const Value.absent(),
    this.role = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.avatarVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerMembersCompanion.insert({
    required String id,
    required String ledgerId,
    required String displayName,
    required String memberType,
    this.linkedAccountId = const Value.absent(),
    this.originMemberId = const Value.absent(),
    this.originAccountId = const Value.absent(),
    this.role = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.avatarVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerId = Value(ledgerId),
       displayName = Value(displayName),
       memberType = Value(memberType),
       updatedAt = Value(updatedAt);
  static Insertable<LedgerMember> custom({
    Expression<String>? id,
    Expression<String>? ledgerId,
    Expression<String>? displayName,
    Expression<String>? memberType,
    Expression<String>? linkedAccountId,
    Expression<String>? originMemberId,
    Expression<String>? originAccountId,
    Expression<String>? role,
    Expression<String>? avatarUrl,
    Expression<int>? avatarVersion,
    Expression<String>? status,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (displayName != null) 'display_name': displayName,
      if (memberType != null) 'member_type': memberType,
      if (linkedAccountId != null) 'linked_account_id': linkedAccountId,
      if (originMemberId != null) 'origin_member_id': originMemberId,
      if (originAccountId != null) 'origin_account_id': originAccountId,
      if (role != null) 'role': role,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (avatarVersion != null) 'avatar_version': avatarVersion,
      if (status != null) 'status': status,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerId,
    Value<String>? displayName,
    Value<String>? memberType,
    Value<String?>? linkedAccountId,
    Value<String?>? originMemberId,
    Value<String?>? originAccountId,
    Value<String>? role,
    Value<String?>? avatarUrl,
    Value<int>? avatarVersion,
    Value<String>? status,
    Value<DateTime>? joinedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return LedgerMembersCompanion(
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      displayName: displayName ?? this.displayName,
      memberType: memberType ?? this.memberType,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      originMemberId: originMemberId ?? this.originMemberId,
      originAccountId: originAccountId ?? this.originAccountId,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarVersion: avatarVersion ?? this.avatarVersion,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (memberType.present) {
      map['member_type'] = Variable<String>(memberType.value);
    }
    if (linkedAccountId.present) {
      map['linked_account_id'] = Variable<String>(linkedAccountId.value);
    }
    if (originMemberId.present) {
      map['origin_member_id'] = Variable<String>(originMemberId.value);
    }
    if (originAccountId.present) {
      map['origin_account_id'] = Variable<String>(originAccountId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (avatarVersion.present) {
      map['avatar_version'] = Variable<int>(avatarVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerMembersCompanion(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('displayName: $displayName, ')
          ..write('memberType: $memberType, ')
          ..write('linkedAccountId: $linkedAccountId, ')
          ..write('originMemberId: $originMemberId, ')
          ..write('originAccountId: $originAccountId, ')
          ..write('role: $role, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('avatarVersion: $avatarVersion, ')
          ..write('status: $status, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _scopeAccountIdMeta = const VerificationMeta(
    'scopeAccountId',
  );
  @override
  late final GeneratedColumn<String> scopeAccountId = GeneratedColumn<String>(
    'scope_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    level,
    sortOrder,
    icon,
    parentId,
    scopeAccountId,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('scope_account_id')) {
      context.handle(
        _scopeAccountIdMeta,
        scopeAccountId.isAcceptableOrUnknown(
          data['scope_account_id']!,
          _scopeAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      scopeAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_account_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  /// UUID v4 主键(user-global 分类,共享账本读取 Owner 的分类)。
  final String id;
  final String name;

  /// 契约字段 kind: expense/income/transfer。
  final String kind;

  /// 层级: 1=一级, 2=二级(契约字段 level)。
  final int level;
  final int sortOrder;
  final String? icon;

  /// 父分类 UUID(契约字段 parent_id)。
  final String? parentId;

  /// 账号数据域：null = 本机域；非 null = 云账号 user_id（每账号一份）。
  final String? scopeAccountId;
  final DateTime updatedAt;

  /// 本地 tombstone。
  final DateTime? deletedAt;
  const Category({
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    map['level'] = Variable<int>(level);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || scopeAccountId != null) {
      map['scope_account_id'] = Variable<String>(scopeAccountId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      level: Value(level),
      sortOrder: Value(sortOrder),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      scopeAccountId: scopeAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeAccountId),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      level: serializer.fromJson<int>(json['level']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      icon: serializer.fromJson<String?>(json['icon']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      scopeAccountId: serializer.fromJson<String?>(json['scopeAccountId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'level': serializer.toJson<int>(level),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'icon': serializer.toJson<String?>(icon),
      'parentId': serializer.toJson<String?>(parentId),
      'scopeAccountId': serializer.toJson<String?>(scopeAccountId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? kind,
    int? level,
    int? sortOrder,
    Value<String?> icon = const Value.absent(),
    Value<String?> parentId = const Value.absent(),
    Value<String?> scopeAccountId = const Value.absent(),
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    level: level ?? this.level,
    sortOrder: sortOrder ?? this.sortOrder,
    icon: icon.present ? icon.value : this.icon,
    parentId: parentId.present ? parentId.value : this.parentId,
    scopeAccountId: scopeAccountId.present
        ? scopeAccountId.value
        : this.scopeAccountId,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      level: data.level.present ? data.level.value : this.level,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      icon: data.icon.present ? data.icon.value : this.icon,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      scopeAccountId: data.scopeAccountId.present
          ? data.scopeAccountId.value
          : this.scopeAccountId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('icon: $icon, ')
          ..write('parentId: $parentId, ')
          ..write('scopeAccountId: $scopeAccountId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    level,
    sortOrder,
    icon,
    parentId,
    scopeAccountId,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.level == this.level &&
          other.sortOrder == this.sortOrder &&
          other.icon == this.icon &&
          other.parentId == this.parentId &&
          other.scopeAccountId == this.scopeAccountId &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> kind;
  final Value<int> level;
  final Value<int> sortOrder;
  final Value<String?> icon;
  final Value<String?> parentId;
  final Value<String?> scopeAccountId;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.level = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.icon = const Value.absent(),
    this.parentId = const Value.absent(),
    this.scopeAccountId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String kind,
    required int level,
    this.sortOrder = const Value.absent(),
    this.icon = const Value.absent(),
    this.parentId = const Value.absent(),
    this.scopeAccountId = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       kind = Value(kind),
       level = Value(level),
       updatedAt = Value(updatedAt);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? level,
    Expression<int>? sortOrder,
    Expression<String>? icon,
    Expression<String>? parentId,
    Expression<String>? scopeAccountId,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (level != null) 'level': level,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (icon != null) 'icon': icon,
      if (parentId != null) 'parent_id': parentId,
      if (scopeAccountId != null) 'scope_account_id': scopeAccountId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? kind,
    Value<int>? level,
    Value<int>? sortOrder,
    Value<String?>? icon,
    Value<String?>? parentId,
    Value<String?>? scopeAccountId,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
      icon: icon ?? this.icon,
      parentId: parentId ?? this.parentId,
      scopeAccountId: scopeAccountId ?? this.scopeAccountId,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (scopeAccountId.present) {
      map['scope_account_id'] = Variable<String>(scopeAccountId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('icon: $icon, ')
          ..write('parentId: $parentId, ')
          ..write('scopeAccountId: $scopeAccountId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledgers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<String> txType = GeneratedColumn<String>(
    'tx_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthOfYearMeta = const VerificationMeta(
    'monthOfYear',
  );
  @override
  late final GeneratedColumn<int> monthOfYear = GeneratedColumn<int>(
    'month_of_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastGeneratedDateMeta = const VerificationMeta(
    'lastGeneratedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastGeneratedDate =
      GeneratedColumn<DateTime>(
        'last_generated_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerId,
    txType,
    amount,
    currencyCode,
    categoryId,
    note,
    frequency,
    interval,
    dayOfMonth,
    dayOfWeek,
    monthOfYear,
    startDate,
    endDate,
    lastGeneratedDate,
    enabled,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('month_of_year')) {
      context.handle(
        _monthOfYearMeta,
        monthOfYear.isAcceptableOrUnknown(
          data['month_of_year']!,
          _monthOfYearMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('last_generated_date')) {
      context.handle(
        _lastGeneratedDateMeta,
        lastGeneratedDate.isAcceptableOrUnknown(
          data['last_generated_date']!,
          _lastGeneratedDateMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tx_type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      ),
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      ),
      monthOfYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_of_year'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      lastGeneratedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_generated_date'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransaction extends DataClass
    implements Insertable<RecurringTransaction> {
  /// UUID v4 主键(仅经 sync push 创建,客户端生成)。
  final String id;
  final String ledgerId;
  final String txType;

  /// 模板金额:规范化 Decimal 字符串。
  final String amount;

  /// 模板原记账币种。
  final String currencyCode;
  final String? categoryId;
  final String? note;

  /// 重复规则: daily/weekly/monthly/yearly。
  final String frequency;
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

  /// 本地 tombstone。
  final DateTime? deletedAt;
  const RecurringTransaction({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.currencyCode,
    this.categoryId,
    this.note,
    required this.frequency,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['tx_type'] = Variable<String>(txType);
    map['amount'] = Variable<String>(amount);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['frequency'] = Variable<String>(frequency);
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || dayOfMonth != null) {
      map['day_of_month'] = Variable<int>(dayOfMonth);
    }
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<int>(dayOfWeek);
    }
    if (!nullToAbsent || monthOfYear != null) {
      map['month_of_year'] = Variable<int>(monthOfYear);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || lastGeneratedDate != null) {
      map['last_generated_date'] = Variable<DateTime>(lastGeneratedDate);
    }
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      ledgerId: Value(ledgerId),
      txType: Value(txType),
      amount: Value(amount),
      currencyCode: Value(currencyCode),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      frequency: Value(frequency),
      interval: Value(interval),
      dayOfMonth: dayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfMonth),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      monthOfYear: monthOfYear == null && nullToAbsent
          ? const Value.absent()
          : Value(monthOfYear),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      lastGeneratedDate: lastGeneratedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedDate),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransaction(
      id: serializer.fromJson<String>(json['id']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      txType: serializer.fromJson<String>(json['txType']),
      amount: serializer.fromJson<String>(json['amount']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      frequency: serializer.fromJson<String>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      dayOfMonth: serializer.fromJson<int?>(json['dayOfMonth']),
      dayOfWeek: serializer.fromJson<int?>(json['dayOfWeek']),
      monthOfYear: serializer.fromJson<int?>(json['monthOfYear']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      lastGeneratedDate: serializer.fromJson<DateTime?>(
        json['lastGeneratedDate'],
      ),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'txType': serializer.toJson<String>(txType),
      'amount': serializer.toJson<String>(amount),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'categoryId': serializer.toJson<String?>(categoryId),
      'note': serializer.toJson<String?>(note),
      'frequency': serializer.toJson<String>(frequency),
      'interval': serializer.toJson<int>(interval),
      'dayOfMonth': serializer.toJson<int?>(dayOfMonth),
      'dayOfWeek': serializer.toJson<int?>(dayOfWeek),
      'monthOfYear': serializer.toJson<int?>(monthOfYear),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'lastGeneratedDate': serializer.toJson<DateTime?>(lastGeneratedDate),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RecurringTransaction copyWith({
    String? id,
    String? ledgerId,
    String? txType,
    String? amount,
    String? currencyCode,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? frequency,
    int? interval,
    Value<int?> dayOfMonth = const Value.absent(),
    Value<int?> dayOfWeek = const Value.absent(),
    Value<int?> monthOfYear = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<DateTime?> lastGeneratedDate = const Value.absent(),
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RecurringTransaction(
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    txType: txType ?? this.txType,
    amount: amount ?? this.amount,
    currencyCode: currencyCode ?? this.currencyCode,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    note: note.present ? note.value : this.note,
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    dayOfMonth: dayOfMonth.present ? dayOfMonth.value : this.dayOfMonth,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    monthOfYear: monthOfYear.present ? monthOfYear.value : this.monthOfYear,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    lastGeneratedDate: lastGeneratedDate.present
        ? lastGeneratedDate.value
        : this.lastGeneratedDate,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RecurringTransaction copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      txType: data.txType.present ? data.txType.value : this.txType,
      amount: data.amount.present ? data.amount.value : this.amount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      monthOfYear: data.monthOfYear.present
          ? data.monthOfYear.value
          : this.monthOfYear,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      lastGeneratedDate: data.lastGeneratedDate.present
          ? data.lastGeneratedDate.value
          : this.lastGeneratedDate,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransaction(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('txType: $txType, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('monthOfYear: $monthOfYear, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('lastGeneratedDate: $lastGeneratedDate, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ledgerId,
    txType,
    amount,
    currencyCode,
    categoryId,
    note,
    frequency,
    interval,
    dayOfMonth,
    dayOfWeek,
    monthOfYear,
    startDate,
    endDate,
    lastGeneratedDate,
    enabled,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransaction &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.txType == this.txType &&
          other.amount == this.amount &&
          other.currencyCode == this.currencyCode &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.dayOfMonth == this.dayOfMonth &&
          other.dayOfWeek == this.dayOfWeek &&
          other.monthOfYear == this.monthOfYear &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.lastGeneratedDate == this.lastGeneratedDate &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransaction> {
  final Value<String> id;
  final Value<String> ledgerId;
  final Value<String> txType;
  final Value<String> amount;
  final Value<String> currencyCode;
  final Value<String?> categoryId;
  final Value<String?> note;
  final Value<String> frequency;
  final Value<int> interval;
  final Value<int?> dayOfMonth;
  final Value<int?> dayOfWeek;
  final Value<int?> monthOfYear;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<DateTime?> lastGeneratedDate;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.txType = const Value.absent(),
    this.amount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.monthOfYear = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.lastGeneratedDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    required String id,
    required String ledgerId,
    required String txType,
    required String amount,
    required String currencyCode,
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    required String frequency,
    this.interval = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.monthOfYear = const Value.absent(),
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.lastGeneratedDate = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerId = Value(ledgerId),
       txType = Value(txType),
       amount = Value(amount),
       currencyCode = Value(currencyCode),
       frequency = Value(frequency),
       startDate = Value(startDate),
       updatedAt = Value(updatedAt);
  static Insertable<RecurringTransaction> custom({
    Expression<String>? id,
    Expression<String>? ledgerId,
    Expression<String>? txType,
    Expression<String>? amount,
    Expression<String>? currencyCode,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<int>? dayOfMonth,
    Expression<int>? dayOfWeek,
    Expression<int>? monthOfYear,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<DateTime>? lastGeneratedDate,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (txType != null) 'tx_type': txType,
      if (amount != null) 'amount': amount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (monthOfYear != null) 'month_of_year': monthOfYear,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (lastGeneratedDate != null) 'last_generated_date': lastGeneratedDate,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerId,
    Value<String>? txType,
    Value<String>? amount,
    Value<String>? currencyCode,
    Value<String?>? categoryId,
    Value<String?>? note,
    Value<String>? frequency,
    Value<int>? interval,
    Value<int?>? dayOfMonth,
    Value<int?>? dayOfWeek,
    Value<int?>? monthOfYear,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<DateTime?>? lastGeneratedDate,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      txType: txType ?? this.txType,
      amount: amount ?? this.amount,
      currencyCode: currencyCode ?? this.currencyCode,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      monthOfYear: monthOfYear ?? this.monthOfYear,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<String>(txType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (monthOfYear.present) {
      map['month_of_year'] = Variable<int>(monthOfYear.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (lastGeneratedDate.present) {
      map['last_generated_date'] = Variable<DateTime>(lastGeneratedDate.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('txType: $txType, ')
          ..write('amount: $amount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('monthOfYear: $monthOfYear, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('lastGeneratedDate: $lastGeneratedDate, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ledgers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _txTypeMeta = const VerificationMeta('txType');
  @override
  late final GeneratedColumn<String> txType = GeneratedColumn<String>(
    'tx_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _happenedAtMeta = const VerificationMeta(
    'happenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> happenedAt = GeneratedColumn<DateTime>(
    'happened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _excludeFromStatsMeta = const VerificationMeta(
    'excludeFromStats',
  );
  @override
  late final GeneratedColumn<bool> excludeFromStats = GeneratedColumn<bool>(
    'exclude_from_stats',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("exclude_from_stats" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nativeAmountMeta = const VerificationMeta(
    'nativeAmount',
  );
  @override
  late final GeneratedColumn<String> nativeAmount = GeneratedColumn<String>(
    'native_amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurringIdMeta = const VerificationMeta(
    'recurringId',
  );
  @override
  late final GeneratedColumn<String> recurringId = GeneratedColumn<String>(
    'recurring_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_transactions (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdByMemberIdMeta = const VerificationMeta(
    'createdByMemberId',
  );
  @override
  late final GeneratedColumn<String> createdByMemberId =
      GeneratedColumn<String>(
        'created_by_member_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastEditedByMemberIdMeta =
      const VerificationMeta('lastEditedByMemberId');
  @override
  late final GeneratedColumn<String> lastEditedByMemberId =
      GeneratedColumn<String>(
        'last_edited_by_member_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _payerMemberIdMeta = const VerificationMeta(
    'payerMemberId',
  );
  @override
  late final GeneratedColumn<String> payerMemberId = GeneratedColumn<String>(
    'payer_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aaModeMeta = const VerificationMeta('aaMode');
  @override
  late final GeneratedColumn<int> aaMode = GeneratedColumn<int>(
    'aa_mode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _serverRevisionMeta = const VerificationMeta(
    'serverRevision',
  );
  @override
  late final GeneratedColumn<int> serverRevision = GeneratedColumn<int>(
    'server_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastEditedAtMeta = const VerificationMeta(
    'lastEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastEditedAt = GeneratedColumn<DateTime>(
    'last_edited_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerId,
    txType,
    amount,
    happenedAt,
    note,
    categoryId,
    excludeFromStats,
    currencyCode,
    nativeAmount,
    recurringId,
    createdByMemberId,
    lastEditedByMemberId,
    payerMemberId,
    aaMode,
    version,
    serverRevision,
    lastEditedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('tx_type')) {
      context.handle(
        _txTypeMeta,
        txType.isAcceptableOrUnknown(data['tx_type']!, _txTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_txTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('happened_at')) {
      context.handle(
        _happenedAtMeta,
        happenedAt.isAcceptableOrUnknown(data['happened_at']!, _happenedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_happenedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('exclude_from_stats')) {
      context.handle(
        _excludeFromStatsMeta,
        excludeFromStats.isAcceptableOrUnknown(
          data['exclude_from_stats']!,
          _excludeFromStatsMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('native_amount')) {
      context.handle(
        _nativeAmountMeta,
        nativeAmount.isAcceptableOrUnknown(
          data['native_amount']!,
          _nativeAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nativeAmountMeta);
    }
    if (data.containsKey('recurring_id')) {
      context.handle(
        _recurringIdMeta,
        recurringId.isAcceptableOrUnknown(
          data['recurring_id']!,
          _recurringIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by_member_id')) {
      context.handle(
        _createdByMemberIdMeta,
        createdByMemberId.isAcceptableOrUnknown(
          data['created_by_member_id']!,
          _createdByMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('last_edited_by_member_id')) {
      context.handle(
        _lastEditedByMemberIdMeta,
        lastEditedByMemberId.isAcceptableOrUnknown(
          data['last_edited_by_member_id']!,
          _lastEditedByMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('payer_member_id')) {
      context.handle(
        _payerMemberIdMeta,
        payerMemberId.isAcceptableOrUnknown(
          data['payer_member_id']!,
          _payerMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('aa_mode')) {
      context.handle(
        _aaModeMeta,
        aaMode.isAcceptableOrUnknown(data['aa_mode']!, _aaModeMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('server_revision')) {
      context.handle(
        _serverRevisionMeta,
        serverRevision.isAcceptableOrUnknown(
          data['server_revision']!,
          _serverRevisionMeta,
        ),
      );
    }
    if (data.containsKey('last_edited_at')) {
      context.handle(
        _lastEditedAtMeta,
        lastEditedAt.isAcceptableOrUnknown(
          data['last_edited_at']!,
          _lastEditedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      txType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tx_type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
      happenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}happened_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      excludeFromStats: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}exclude_from_stats'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      nativeAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}native_amount'],
      )!,
      recurringId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_id'],
      ),
      createdByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_member_id'],
      ),
      lastEditedByMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_edited_by_member_id'],
      ),
      payerMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payer_member_id'],
      ),
      aaMode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aa_mode'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      serverRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_revision'],
      ),
      lastEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_edited_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  /// UUID v4 主键:离线创建时客户端生成。
  final String id;
  final String ledgerId;

  /// 契约字段 tx_type: expense/income/transfer。
  final String txType;

  /// 交易金额:规范化 Decimal 字符串(positive,≤28 位整数 + ≤10 位小数)。
  final String amount;
  final DateTime happenedAt;
  final String? note;

  /// 分类 UUID 弱引用：共享账本可引用仅存在于 Owner 镜像表的分类。
  final String? categoryId;
  final bool excludeFromStats;

  /// 交易币种(ISO 大写),与 native_amount 成对出现。
  final String currencyCode;

  /// 折算到账本本位币的金额快照:规范化 Decimal 字符串。
  final String nativeAmount;

  /// 周期模板 UUID 弱引用。
  final String? recurringId;

  /// 记账人(创建者)成员 id:引用 ledger_members,与登录账号解耦。
  final String? createdByMemberId;

  /// 最后编辑人成员 id:引用 ledger_members。
  final String? lastEditedByMemberId;

  /// 支出人(付款人)成员 id:引用 ledger_members。
  final String? payerMemberId;

  /// AA 分摊模式: null/0=人均, 1=不分摊, 2=指定金额(契约字段 aa_mode)。
  final int? aaMode;

  /// 编辑版本号:创建为 1,每次修改 +1(含删除)。
  final int version;

  /// 服务端已知 revision(3.2/3.3):云端账本交易在推送成功后更新,
  /// 本地编辑的 base_revision 与 pull 冲突检测以此为准;本地账本恒为 NULL。
  final int? serverRevision;
  final DateTime? lastEditedAt;
  final DateTime createdAt;

  /// 服务端更新时间(同步 LWW 依据)。
  final DateTime updatedAt;

  /// 本地 tombstone。
  final DateTime? deletedAt;
  const Transaction({
    required this.id,
    required this.ledgerId,
    required this.txType,
    required this.amount,
    required this.happenedAt,
    this.note,
    this.categoryId,
    required this.excludeFromStats,
    required this.currencyCode,
    required this.nativeAmount,
    this.recurringId,
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
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['tx_type'] = Variable<String>(txType);
    map['amount'] = Variable<String>(amount);
    map['happened_at'] = Variable<DateTime>(happenedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['exclude_from_stats'] = Variable<bool>(excludeFromStats);
    map['currency_code'] = Variable<String>(currencyCode);
    map['native_amount'] = Variable<String>(nativeAmount);
    if (!nullToAbsent || recurringId != null) {
      map['recurring_id'] = Variable<String>(recurringId);
    }
    if (!nullToAbsent || createdByMemberId != null) {
      map['created_by_member_id'] = Variable<String>(createdByMemberId);
    }
    if (!nullToAbsent || lastEditedByMemberId != null) {
      map['last_edited_by_member_id'] = Variable<String>(lastEditedByMemberId);
    }
    if (!nullToAbsent || payerMemberId != null) {
      map['payer_member_id'] = Variable<String>(payerMemberId);
    }
    if (!nullToAbsent || aaMode != null) {
      map['aa_mode'] = Variable<int>(aaMode);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || serverRevision != null) {
      map['server_revision'] = Variable<int>(serverRevision);
    }
    if (!nullToAbsent || lastEditedAt != null) {
      map['last_edited_at'] = Variable<DateTime>(lastEditedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      ledgerId: Value(ledgerId),
      txType: Value(txType),
      amount: Value(amount),
      happenedAt: Value(happenedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      excludeFromStats: Value(excludeFromStats),
      currencyCode: Value(currencyCode),
      nativeAmount: Value(nativeAmount),
      recurringId: recurringId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringId),
      createdByMemberId: createdByMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByMemberId),
      lastEditedByMemberId: lastEditedByMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEditedByMemberId),
      payerMemberId: payerMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(payerMemberId),
      aaMode: aaMode == null && nullToAbsent
          ? const Value.absent()
          : Value(aaMode),
      version: Value(version),
      serverRevision: serverRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(serverRevision),
      lastEditedAt: lastEditedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastEditedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      txType: serializer.fromJson<String>(json['txType']),
      amount: serializer.fromJson<String>(json['amount']),
      happenedAt: serializer.fromJson<DateTime>(json['happenedAt']),
      note: serializer.fromJson<String?>(json['note']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      excludeFromStats: serializer.fromJson<bool>(json['excludeFromStats']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      nativeAmount: serializer.fromJson<String>(json['nativeAmount']),
      recurringId: serializer.fromJson<String?>(json['recurringId']),
      createdByMemberId: serializer.fromJson<String?>(
        json['createdByMemberId'],
      ),
      lastEditedByMemberId: serializer.fromJson<String?>(
        json['lastEditedByMemberId'],
      ),
      payerMemberId: serializer.fromJson<String?>(json['payerMemberId']),
      aaMode: serializer.fromJson<int?>(json['aaMode']),
      version: serializer.fromJson<int>(json['version']),
      serverRevision: serializer.fromJson<int?>(json['serverRevision']),
      lastEditedAt: serializer.fromJson<DateTime?>(json['lastEditedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'txType': serializer.toJson<String>(txType),
      'amount': serializer.toJson<String>(amount),
      'happenedAt': serializer.toJson<DateTime>(happenedAt),
      'note': serializer.toJson<String?>(note),
      'categoryId': serializer.toJson<String?>(categoryId),
      'excludeFromStats': serializer.toJson<bool>(excludeFromStats),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'nativeAmount': serializer.toJson<String>(nativeAmount),
      'recurringId': serializer.toJson<String?>(recurringId),
      'createdByMemberId': serializer.toJson<String?>(createdByMemberId),
      'lastEditedByMemberId': serializer.toJson<String?>(lastEditedByMemberId),
      'payerMemberId': serializer.toJson<String?>(payerMemberId),
      'aaMode': serializer.toJson<int?>(aaMode),
      'version': serializer.toJson<int>(version),
      'serverRevision': serializer.toJson<int?>(serverRevision),
      'lastEditedAt': serializer.toJson<DateTime?>(lastEditedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Transaction copyWith({
    String? id,
    String? ledgerId,
    String? txType,
    String? amount,
    DateTime? happenedAt,
    Value<String?> note = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    bool? excludeFromStats,
    String? currencyCode,
    String? nativeAmount,
    Value<String?> recurringId = const Value.absent(),
    Value<String?> createdByMemberId = const Value.absent(),
    Value<String?> lastEditedByMemberId = const Value.absent(),
    Value<String?> payerMemberId = const Value.absent(),
    Value<int?> aaMode = const Value.absent(),
    int? version,
    Value<int?> serverRevision = const Value.absent(),
    Value<DateTime?> lastEditedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    txType: txType ?? this.txType,
    amount: amount ?? this.amount,
    happenedAt: happenedAt ?? this.happenedAt,
    note: note.present ? note.value : this.note,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    excludeFromStats: excludeFromStats ?? this.excludeFromStats,
    currencyCode: currencyCode ?? this.currencyCode,
    nativeAmount: nativeAmount ?? this.nativeAmount,
    recurringId: recurringId.present ? recurringId.value : this.recurringId,
    createdByMemberId: createdByMemberId.present
        ? createdByMemberId.value
        : this.createdByMemberId,
    lastEditedByMemberId: lastEditedByMemberId.present
        ? lastEditedByMemberId.value
        : this.lastEditedByMemberId,
    payerMemberId: payerMemberId.present
        ? payerMemberId.value
        : this.payerMemberId,
    aaMode: aaMode.present ? aaMode.value : this.aaMode,
    version: version ?? this.version,
    serverRevision: serverRevision.present
        ? serverRevision.value
        : this.serverRevision,
    lastEditedAt: lastEditedAt.present ? lastEditedAt.value : this.lastEditedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      txType: data.txType.present ? data.txType.value : this.txType,
      amount: data.amount.present ? data.amount.value : this.amount,
      happenedAt: data.happenedAt.present
          ? data.happenedAt.value
          : this.happenedAt,
      note: data.note.present ? data.note.value : this.note,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      excludeFromStats: data.excludeFromStats.present
          ? data.excludeFromStats.value
          : this.excludeFromStats,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      nativeAmount: data.nativeAmount.present
          ? data.nativeAmount.value
          : this.nativeAmount,
      recurringId: data.recurringId.present
          ? data.recurringId.value
          : this.recurringId,
      createdByMemberId: data.createdByMemberId.present
          ? data.createdByMemberId.value
          : this.createdByMemberId,
      lastEditedByMemberId: data.lastEditedByMemberId.present
          ? data.lastEditedByMemberId.value
          : this.lastEditedByMemberId,
      payerMemberId: data.payerMemberId.present
          ? data.payerMemberId.value
          : this.payerMemberId,
      aaMode: data.aaMode.present ? data.aaMode.value : this.aaMode,
      version: data.version.present ? data.version.value : this.version,
      serverRevision: data.serverRevision.present
          ? data.serverRevision.value
          : this.serverRevision,
      lastEditedAt: data.lastEditedAt.present
          ? data.lastEditedAt.value
          : this.lastEditedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('txType: $txType, ')
          ..write('amount: $amount, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('excludeFromStats: $excludeFromStats, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('nativeAmount: $nativeAmount, ')
          ..write('recurringId: $recurringId, ')
          ..write('createdByMemberId: $createdByMemberId, ')
          ..write('lastEditedByMemberId: $lastEditedByMemberId, ')
          ..write('payerMemberId: $payerMemberId, ')
          ..write('aaMode: $aaMode, ')
          ..write('version: $version, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('lastEditedAt: $lastEditedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    ledgerId,
    txType,
    amount,
    happenedAt,
    note,
    categoryId,
    excludeFromStats,
    currencyCode,
    nativeAmount,
    recurringId,
    createdByMemberId,
    lastEditedByMemberId,
    payerMemberId,
    aaMode,
    version,
    serverRevision,
    lastEditedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.txType == this.txType &&
          other.amount == this.amount &&
          other.happenedAt == this.happenedAt &&
          other.note == this.note &&
          other.categoryId == this.categoryId &&
          other.excludeFromStats == this.excludeFromStats &&
          other.currencyCode == this.currencyCode &&
          other.nativeAmount == this.nativeAmount &&
          other.recurringId == this.recurringId &&
          other.createdByMemberId == this.createdByMemberId &&
          other.lastEditedByMemberId == this.lastEditedByMemberId &&
          other.payerMemberId == this.payerMemberId &&
          other.aaMode == this.aaMode &&
          other.version == this.version &&
          other.serverRevision == this.serverRevision &&
          other.lastEditedAt == this.lastEditedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<String> ledgerId;
  final Value<String> txType;
  final Value<String> amount;
  final Value<DateTime> happenedAt;
  final Value<String?> note;
  final Value<String?> categoryId;
  final Value<bool> excludeFromStats;
  final Value<String> currencyCode;
  final Value<String> nativeAmount;
  final Value<String?> recurringId;
  final Value<String?> createdByMemberId;
  final Value<String?> lastEditedByMemberId;
  final Value<String?> payerMemberId;
  final Value<int?> aaMode;
  final Value<int> version;
  final Value<int?> serverRevision;
  final Value<DateTime?> lastEditedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.txType = const Value.absent(),
    this.amount = const Value.absent(),
    this.happenedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.excludeFromStats = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.nativeAmount = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.createdByMemberId = const Value.absent(),
    this.lastEditedByMemberId = const Value.absent(),
    this.payerMemberId = const Value.absent(),
    this.aaMode = const Value.absent(),
    this.version = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.lastEditedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required String ledgerId,
    required String txType,
    required String amount,
    required DateTime happenedAt,
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.excludeFromStats = const Value.absent(),
    required String currencyCode,
    required String nativeAmount,
    this.recurringId = const Value.absent(),
    this.createdByMemberId = const Value.absent(),
    this.lastEditedByMemberId = const Value.absent(),
    this.payerMemberId = const Value.absent(),
    this.aaMode = const Value.absent(),
    this.version = const Value.absent(),
    this.serverRevision = const Value.absent(),
    this.lastEditedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerId = Value(ledgerId),
       txType = Value(txType),
       amount = Value(amount),
       happenedAt = Value(happenedAt),
       currencyCode = Value(currencyCode),
       nativeAmount = Value(nativeAmount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<String>? ledgerId,
    Expression<String>? txType,
    Expression<String>? amount,
    Expression<DateTime>? happenedAt,
    Expression<String>? note,
    Expression<String>? categoryId,
    Expression<bool>? excludeFromStats,
    Expression<String>? currencyCode,
    Expression<String>? nativeAmount,
    Expression<String>? recurringId,
    Expression<String>? createdByMemberId,
    Expression<String>? lastEditedByMemberId,
    Expression<String>? payerMemberId,
    Expression<int>? aaMode,
    Expression<int>? version,
    Expression<int>? serverRevision,
    Expression<DateTime>? lastEditedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (txType != null) 'tx_type': txType,
      if (amount != null) 'amount': amount,
      if (happenedAt != null) 'happened_at': happenedAt,
      if (note != null) 'note': note,
      if (categoryId != null) 'category_id': categoryId,
      if (excludeFromStats != null) 'exclude_from_stats': excludeFromStats,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (nativeAmount != null) 'native_amount': nativeAmount,
      if (recurringId != null) 'recurring_id': recurringId,
      if (createdByMemberId != null) 'created_by_member_id': createdByMemberId,
      if (lastEditedByMemberId != null)
        'last_edited_by_member_id': lastEditedByMemberId,
      if (payerMemberId != null) 'payer_member_id': payerMemberId,
      if (aaMode != null) 'aa_mode': aaMode,
      if (version != null) 'version': version,
      if (serverRevision != null) 'server_revision': serverRevision,
      if (lastEditedAt != null) 'last_edited_at': lastEditedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerId,
    Value<String>? txType,
    Value<String>? amount,
    Value<DateTime>? happenedAt,
    Value<String?>? note,
    Value<String?>? categoryId,
    Value<bool>? excludeFromStats,
    Value<String>? currencyCode,
    Value<String>? nativeAmount,
    Value<String?>? recurringId,
    Value<String?>? createdByMemberId,
    Value<String?>? lastEditedByMemberId,
    Value<String?>? payerMemberId,
    Value<int?>? aaMode,
    Value<int>? version,
    Value<int?>? serverRevision,
    Value<DateTime?>? lastEditedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      txType: txType ?? this.txType,
      amount: amount ?? this.amount,
      happenedAt: happenedAt ?? this.happenedAt,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      excludeFromStats: excludeFromStats ?? this.excludeFromStats,
      currencyCode: currencyCode ?? this.currencyCode,
      nativeAmount: nativeAmount ?? this.nativeAmount,
      recurringId: recurringId ?? this.recurringId,
      createdByMemberId: createdByMemberId ?? this.createdByMemberId,
      lastEditedByMemberId: lastEditedByMemberId ?? this.lastEditedByMemberId,
      payerMemberId: payerMemberId ?? this.payerMemberId,
      aaMode: aaMode ?? this.aaMode,
      version: version ?? this.version,
      serverRevision: serverRevision ?? this.serverRevision,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (txType.present) {
      map['tx_type'] = Variable<String>(txType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (happenedAt.present) {
      map['happened_at'] = Variable<DateTime>(happenedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (excludeFromStats.present) {
      map['exclude_from_stats'] = Variable<bool>(excludeFromStats.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (nativeAmount.present) {
      map['native_amount'] = Variable<String>(nativeAmount.value);
    }
    if (recurringId.present) {
      map['recurring_id'] = Variable<String>(recurringId.value);
    }
    if (createdByMemberId.present) {
      map['created_by_member_id'] = Variable<String>(createdByMemberId.value);
    }
    if (lastEditedByMemberId.present) {
      map['last_edited_by_member_id'] = Variable<String>(
        lastEditedByMemberId.value,
      );
    }
    if (payerMemberId.present) {
      map['payer_member_id'] = Variable<String>(payerMemberId.value);
    }
    if (aaMode.present) {
      map['aa_mode'] = Variable<int>(aaMode.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (serverRevision.present) {
      map['server_revision'] = Variable<int>(serverRevision.value);
    }
    if (lastEditedAt.present) {
      map['last_edited_at'] = Variable<DateTime>(lastEditedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('txType: $txType, ')
          ..write('amount: $amount, ')
          ..write('happenedAt: $happenedAt, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('excludeFromStats: $excludeFromStats, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('nativeAmount: $nativeAmount, ')
          ..write('recurringId: $recurringId, ')
          ..write('createdByMemberId: $createdByMemberId, ')
          ..write('lastEditedByMemberId: $lastEditedByMemberId, ')
          ..write('payerMemberId: $payerMemberId, ')
          ..write('aaMode: $aaMode, ')
          ..write('version: $version, ')
          ..write('serverRevision: $serverRevision, ')
          ..write('lastEditedAt: $lastEditedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionSplitsTable extends TransactionSplits
    with TableInfo<$TransactionSplitsTable, TransactionSplit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionSplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _memberIdMeta = const VerificationMeta(
    'memberId',
  );
  @override
  late final GeneratedColumn<String> memberId = GeneratedColumn<String>(
    'member_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, transactionId, memberId, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionSplit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('member_id')) {
      context.handle(
        _memberIdMeta,
        memberId.isAcceptableOrUnknown(data['member_id']!, _memberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memberIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionSplit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionSplit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      memberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $TransactionSplitsTable createAlias(String alias) {
    return $TransactionSplitsTable(attachedDatabase, alias);
  }
}

class TransactionSplit extends DataClass
    implements Insertable<TransactionSplit> {
  /// 本地自增行标识(纯本地,不参与契约;契约内 splits 以交易内嵌数组传输,无独立 id)。
  final int id;

  /// 所属交易 UUID;交易删除时级联清理。
  final String transactionId;

  /// 参与人成员 id:引用 ledger_members。
  final String memberId;

  /// 分摊金额:规范化 Decimal 字符串(正值,≤28 位整数 + ≤10 位小数)。
  final String amount;
  const TransactionSplit({
    required this.id,
    required this.transactionId,
    required this.memberId,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['member_id'] = Variable<String>(memberId);
    map['amount'] = Variable<String>(amount);
    return map;
  }

  TransactionSplitsCompanion toCompanion(bool nullToAbsent) {
    return TransactionSplitsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      memberId: Value(memberId),
      amount: Value(amount),
    );
  }

  factory TransactionSplit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionSplit(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      memberId: serializer.fromJson<String>(json['memberId']),
      amount: serializer.fromJson<String>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'memberId': serializer.toJson<String>(memberId),
      'amount': serializer.toJson<String>(amount),
    };
  }

  TransactionSplit copyWith({
    int? id,
    String? transactionId,
    String? memberId,
    String? amount,
  }) => TransactionSplit(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    memberId: memberId ?? this.memberId,
    amount: amount ?? this.amount,
  );
  TransactionSplit copyWithCompanion(TransactionSplitsCompanion data) {
    return TransactionSplit(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      memberId: data.memberId.present ? data.memberId.value : this.memberId,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionSplit(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('memberId: $memberId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transactionId, memberId, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionSplit &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.memberId == this.memberId &&
          other.amount == this.amount);
}

class TransactionSplitsCompanion extends UpdateCompanion<TransactionSplit> {
  final Value<int> id;
  final Value<String> transactionId;
  final Value<String> memberId;
  final Value<String> amount;
  const TransactionSplitsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.memberId = const Value.absent(),
    this.amount = const Value.absent(),
  });
  TransactionSplitsCompanion.insert({
    this.id = const Value.absent(),
    required String transactionId,
    required String memberId,
    required String amount,
  }) : transactionId = Value(transactionId),
       memberId = Value(memberId),
       amount = Value(amount);
  static Insertable<TransactionSplit> custom({
    Expression<int>? id,
    Expression<String>? transactionId,
    Expression<String>? memberId,
    Expression<String>? amount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (memberId != null) 'member_id': memberId,
      if (amount != null) 'amount': amount,
    });
  }

  TransactionSplitsCompanion copyWith({
    Value<int>? id,
    Value<String>? transactionId,
    Value<String>? memberId,
    Value<String>? amount,
  }) {
    return TransactionSplitsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      memberId: memberId ?? this.memberId,
      amount: amount ?? this.amount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (memberId.present) {
      map['member_id'] = Variable<String>(memberId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionSplitsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('memberId: $memberId, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }
}

class $RecordEditHistoriesTable extends RecordEditHistories
    with TableInfo<$RecordEditHistoriesTable, RecordEditHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecordEditHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operatorMemberIdMeta = const VerificationMeta(
    'operatorMemberId',
  );
  @override
  late final GeneratedColumn<String> operatorMemberId = GeneratedColumn<String>(
    'operator_member_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordId,
    version,
    operatorMemberId,
    summary,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'record_edit_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecordEditHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('operator_member_id')) {
      context.handle(
        _operatorMemberIdMeta,
        operatorMemberId.isAcceptableOrUnknown(
          data['operator_member_id']!,
          _operatorMemberIdMeta,
        ),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecordEditHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecordEditHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      operatorMemberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operator_member_id'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecordEditHistoriesTable createAlias(String alias) {
    return $RecordEditHistoriesTable(attachedDatabase, alias);
  }
}

class RecordEditHistory extends DataClass
    implements Insertable<RecordEditHistory> {
  /// 本地自增 id(纯本地表,不参与同步契约)。
  final int id;
  final String recordId;
  final int version;

  /// 操作者成员 id:引用 ledger_members。
  final String? operatorMemberId;
  final String summary;
  final DateTime createdAt;
  const RecordEditHistory({
    required this.id,
    required this.recordId,
    required this.version,
    this.operatorMemberId,
    required this.summary,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['record_id'] = Variable<String>(recordId);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || operatorMemberId != null) {
      map['operator_member_id'] = Variable<String>(operatorMemberId);
    }
    map['summary'] = Variable<String>(summary);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecordEditHistoriesCompanion toCompanion(bool nullToAbsent) {
    return RecordEditHistoriesCompanion(
      id: Value(id),
      recordId: Value(recordId),
      version: Value(version),
      operatorMemberId: operatorMemberId == null && nullToAbsent
          ? const Value.absent()
          : Value(operatorMemberId),
      summary: Value(summary),
      createdAt: Value(createdAt),
    );
  }

  factory RecordEditHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecordEditHistory(
      id: serializer.fromJson<int>(json['id']),
      recordId: serializer.fromJson<String>(json['recordId']),
      version: serializer.fromJson<int>(json['version']),
      operatorMemberId: serializer.fromJson<String?>(json['operatorMemberId']),
      summary: serializer.fromJson<String>(json['summary']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'recordId': serializer.toJson<String>(recordId),
      'version': serializer.toJson<int>(version),
      'operatorMemberId': serializer.toJson<String?>(operatorMemberId),
      'summary': serializer.toJson<String>(summary),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecordEditHistory copyWith({
    int? id,
    String? recordId,
    int? version,
    Value<String?> operatorMemberId = const Value.absent(),
    String? summary,
    DateTime? createdAt,
  }) => RecordEditHistory(
    id: id ?? this.id,
    recordId: recordId ?? this.recordId,
    version: version ?? this.version,
    operatorMemberId: operatorMemberId.present
        ? operatorMemberId.value
        : this.operatorMemberId,
    summary: summary ?? this.summary,
    createdAt: createdAt ?? this.createdAt,
  );
  RecordEditHistory copyWithCompanion(RecordEditHistoriesCompanion data) {
    return RecordEditHistory(
      id: data.id.present ? data.id.value : this.id,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      version: data.version.present ? data.version.value : this.version,
      operatorMemberId: data.operatorMemberId.present
          ? data.operatorMemberId.value
          : this.operatorMemberId,
      summary: data.summary.present ? data.summary.value : this.summary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecordEditHistory(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('version: $version, ')
          ..write('operatorMemberId: $operatorMemberId, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, recordId, version, operatorMemberId, summary, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecordEditHistory &&
          other.id == this.id &&
          other.recordId == this.recordId &&
          other.version == this.version &&
          other.operatorMemberId == this.operatorMemberId &&
          other.summary == this.summary &&
          other.createdAt == this.createdAt);
}

class RecordEditHistoriesCompanion extends UpdateCompanion<RecordEditHistory> {
  final Value<int> id;
  final Value<String> recordId;
  final Value<int> version;
  final Value<String?> operatorMemberId;
  final Value<String> summary;
  final Value<DateTime> createdAt;
  const RecordEditHistoriesCompanion({
    this.id = const Value.absent(),
    this.recordId = const Value.absent(),
    this.version = const Value.absent(),
    this.operatorMemberId = const Value.absent(),
    this.summary = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecordEditHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required String recordId,
    required int version,
    this.operatorMemberId = const Value.absent(),
    required String summary,
    this.createdAt = const Value.absent(),
  }) : recordId = Value(recordId),
       version = Value(version),
       summary = Value(summary);
  static Insertable<RecordEditHistory> custom({
    Expression<int>? id,
    Expression<String>? recordId,
    Expression<int>? version,
    Expression<String>? operatorMemberId,
    Expression<String>? summary,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordId != null) 'record_id': recordId,
      if (version != null) 'version': version,
      if (operatorMemberId != null) 'operator_member_id': operatorMemberId,
      if (summary != null) 'summary': summary,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecordEditHistoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? recordId,
    Value<int>? version,
    Value<String?>? operatorMemberId,
    Value<String>? summary,
    Value<DateTime>? createdAt,
  }) {
    return RecordEditHistoriesCompanion(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      version: version ?? this.version,
      operatorMemberId: operatorMemberId ?? this.operatorMemberId,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (operatorMemberId.present) {
      map['operator_member_id'] = Variable<String>(operatorMemberId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecordEditHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('version: $version, ')
          ..write('operatorMemberId: $operatorMemberId, ')
          ..write('summary: $summary, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCurrencyMeta = const VerificationMeta(
    'quoteCurrency',
  );
  @override
  late final GeneratedColumn<String> quoteCurrency = GeneratedColumn<String>(
    'quote_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateDateMeta = const VerificationMeta(
    'rateDate',
  );
  @override
  late final GeneratedColumn<String> rateDate = GeneratedColumn<String>(
    'rate_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    baseCurrency,
    quoteCurrency,
    rateDate,
    rate,
    source,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('quote_currency')) {
      context.handle(
        _quoteCurrencyMeta,
        quoteCurrency.isAcceptableOrUnknown(
          data['quote_currency']!,
          _quoteCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quoteCurrencyMeta);
    }
    if (data.containsKey('rate_date')) {
      context.handle(
        _rateDateMeta,
        rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateDateMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    baseCurrency,
    quoteCurrency,
    rateDate,
  };
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      quoteCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_currency'],
      )!,
      rateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_date'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  final String baseCurrency;
  final String quoteCurrency;
  final String rateDate;
  final String rate;
  final String source;
  final DateTime fetchedAt;
  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateDate,
    required this.rate,
    required this.source,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base_currency'] = Variable<String>(baseCurrency);
    map['quote_currency'] = Variable<String>(quoteCurrency);
    map['rate_date'] = Variable<String>(rateDate);
    map['rate'] = Variable<String>(rate);
    map['source'] = Variable<String>(source);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      baseCurrency: Value(baseCurrency),
      quoteCurrency: Value(quoteCurrency),
      rateDate: Value(rateDate),
      rate: Value(rate),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      quoteCurrency: serializer.fromJson<String>(json['quoteCurrency']),
      rateDate: serializer.fromJson<String>(json['rateDate']),
      rate: serializer.fromJson<String>(json['rate']),
      source: serializer.fromJson<String>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'quoteCurrency': serializer.toJson<String>(quoteCurrency),
      'rateDate': serializer.toJson<String>(rateDate),
      'rate': serializer.toJson<String>(rate),
      'source': serializer.toJson<String>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExchangeRate copyWith({
    String? baseCurrency,
    String? quoteCurrency,
    String? rateDate,
    String? rate,
    String? source,
    DateTime? fetchedAt,
  }) => ExchangeRate(
    baseCurrency: baseCurrency ?? this.baseCurrency,
    quoteCurrency: quoteCurrency ?? this.quoteCurrency,
    rateDate: rateDate ?? this.rateDate,
    rate: rate ?? this.rate,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      quoteCurrency: data.quoteCurrency.present
          ? data.quoteCurrency.value
          : this.quoteCurrency,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      rate: data.rate.present ? data.rate.value : this.rate,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rateDate: $rateDate, ')
          ..write('rate: $rate, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    baseCurrency,
    quoteCurrency,
    rateDate,
    rate,
    source,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.baseCurrency == this.baseCurrency &&
          other.quoteCurrency == this.quoteCurrency &&
          other.rateDate == this.rateDate &&
          other.rate == this.rate &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<String> baseCurrency;
  final Value<String> quoteCurrency;
  final Value<String> rateDate;
  final Value<String> rate;
  final Value<String> source;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const ExchangeRatesCompanion({
    this.baseCurrency = const Value.absent(),
    this.quoteCurrency = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.rate = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    required String baseCurrency,
    required String quoteCurrency,
    required String rateDate,
    required String rate,
    required String source,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : baseCurrency = Value(baseCurrency),
       quoteCurrency = Value(quoteCurrency),
       rateDate = Value(rateDate),
       rate = Value(rate),
       source = Value(source),
       fetchedAt = Value(fetchedAt);
  static Insertable<ExchangeRate> custom({
    Expression<String>? baseCurrency,
    Expression<String>? quoteCurrency,
    Expression<String>? rateDate,
    Expression<String>? rate,
    Expression<String>? source,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (quoteCurrency != null) 'quote_currency': quoteCurrency,
      if (rateDate != null) 'rate_date': rateDate,
      if (rate != null) 'rate': rate,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<String>? baseCurrency,
    Value<String>? quoteCurrency,
    Value<String>? rateDate,
    Value<String>? rate,
    Value<String>? source,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return ExchangeRatesCompanion(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      rateDate: rateDate ?? this.rateDate,
      rate: rate ?? this.rate,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (quoteCurrency.present) {
      map['quote_currency'] = Variable<String>(quoteCurrency.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<String>(rateDate.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rateDate: $rateDate, ')
          ..write('rate: $rate, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRateOverridesTable extends ExchangeRateOverrides
    with TableInfo<$ExchangeRateOverridesTable, ExchangeRateOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRateOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCurrencyMeta = const VerificationMeta(
    'quoteCurrency',
  );
  @override
  late final GeneratedColumn<String> quoteCurrency = GeneratedColumn<String>(
    'quote_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<String> rate = GeneratedColumn<String>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scopeAccountIdMeta = const VerificationMeta(
    'scopeAccountId',
  );
  @override
  late final GeneratedColumn<String> scopeAccountId = GeneratedColumn<String>(
    'scope_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    baseCurrency,
    quoteCurrency,
    rate,
    updatedAt,
    deletedAt,
    scopeAccountId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rate_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('quote_currency')) {
      context.handle(
        _quoteCurrencyMeta,
        quoteCurrency.isAcceptableOrUnknown(
          data['quote_currency']!,
          _quoteCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quoteCurrencyMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('scope_account_id')) {
      context.handle(
        _scopeAccountIdMeta,
        scopeAccountId.isAcceptableOrUnknown(
          data['scope_account_id']!,
          _scopeAccountIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExchangeRateOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateOverride(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      quoteCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_currency'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      scopeAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_account_id'],
      ),
    );
  }

  @override
  $ExchangeRateOverridesTable createAlias(String alias) {
    return $ExchangeRateOverridesTable(attachedDatabase, alias);
  }
}

class ExchangeRateOverride extends DataClass
    implements Insertable<ExchangeRateOverride> {
  /// 确定性 UUIDv5 主键:uuidV5(exchangeRateNamespace, `'<账号id>:<BASE>:<QUOTE>'`)
  /// 派生(与服务端 entity-id.ts 同算法),同账号同币对收敛同一实体。
  final String id;
  final String baseCurrency;
  final String quoteCurrency;

  /// 汇率:规范化 Decimal 字符串(≤20 位整数 + ≤18 位小数)。
  final String rate;
  final DateTime updatedAt;

  /// 本地 tombstone。
  final DateTime? deletedAt;

  /// 账号数据域：null = 本机域；非 null = 云账号 user_id（每账号一份）。
  final String? scopeAccountId;
  const ExchangeRateOverride({
    required this.id,
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rate,
    required this.updatedAt,
    this.deletedAt,
    this.scopeAccountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['base_currency'] = Variable<String>(baseCurrency);
    map['quote_currency'] = Variable<String>(quoteCurrency);
    map['rate'] = Variable<String>(rate);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || scopeAccountId != null) {
      map['scope_account_id'] = Variable<String>(scopeAccountId);
    }
    return map;
  }

  ExchangeRateOverridesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRateOverridesCompanion(
      id: Value(id),
      baseCurrency: Value(baseCurrency),
      quoteCurrency: Value(quoteCurrency),
      rate: Value(rate),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      scopeAccountId: scopeAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeAccountId),
    );
  }

  factory ExchangeRateOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateOverride(
      id: serializer.fromJson<String>(json['id']),
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      quoteCurrency: serializer.fromJson<String>(json['quoteCurrency']),
      rate: serializer.fromJson<String>(json['rate']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      scopeAccountId: serializer.fromJson<String?>(json['scopeAccountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'quoteCurrency': serializer.toJson<String>(quoteCurrency),
      'rate': serializer.toJson<String>(rate),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'scopeAccountId': serializer.toJson<String?>(scopeAccountId),
    };
  }

  ExchangeRateOverride copyWith({
    String? id,
    String? baseCurrency,
    String? quoteCurrency,
    String? rate,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> scopeAccountId = const Value.absent(),
  }) => ExchangeRateOverride(
    id: id ?? this.id,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    quoteCurrency: quoteCurrency ?? this.quoteCurrency,
    rate: rate ?? this.rate,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    scopeAccountId: scopeAccountId.present
        ? scopeAccountId.value
        : this.scopeAccountId,
  );
  ExchangeRateOverride copyWithCompanion(ExchangeRateOverridesCompanion data) {
    return ExchangeRateOverride(
      id: data.id.present ? data.id.value : this.id,
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      quoteCurrency: data.quoteCurrency.present
          ? data.quoteCurrency.value
          : this.quoteCurrency,
      rate: data.rate.present ? data.rate.value : this.rate,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      scopeAccountId: data.scopeAccountId.present
          ? data.scopeAccountId.value
          : this.scopeAccountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateOverride(')
          ..write('id: $id, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rate: $rate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('scopeAccountId: $scopeAccountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baseCurrency,
    quoteCurrency,
    rate,
    updatedAt,
    deletedAt,
    scopeAccountId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateOverride &&
          other.id == this.id &&
          other.baseCurrency == this.baseCurrency &&
          other.quoteCurrency == this.quoteCurrency &&
          other.rate == this.rate &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.scopeAccountId == this.scopeAccountId);
}

class ExchangeRateOverridesCompanion
    extends UpdateCompanion<ExchangeRateOverride> {
  final Value<String> id;
  final Value<String> baseCurrency;
  final Value<String> quoteCurrency;
  final Value<String> rate;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> scopeAccountId;
  final Value<int> rowid;
  const ExchangeRateOverridesCompanion({
    this.id = const Value.absent(),
    this.baseCurrency = const Value.absent(),
    this.quoteCurrency = const Value.absent(),
    this.rate = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.scopeAccountId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRateOverridesCompanion.insert({
    required String id,
    required String baseCurrency,
    required String quoteCurrency,
    required String rate,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.scopeAccountId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       baseCurrency = Value(baseCurrency),
       quoteCurrency = Value(quoteCurrency),
       rate = Value(rate),
       updatedAt = Value(updatedAt);
  static Insertable<ExchangeRateOverride> custom({
    Expression<String>? id,
    Expression<String>? baseCurrency,
    Expression<String>? quoteCurrency,
    Expression<String>? rate,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? scopeAccountId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (quoteCurrency != null) 'quote_currency': quoteCurrency,
      if (rate != null) 'rate': rate,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (scopeAccountId != null) 'scope_account_id': scopeAccountId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRateOverridesCompanion copyWith({
    Value<String>? id,
    Value<String>? baseCurrency,
    Value<String>? quoteCurrency,
    Value<String>? rate,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? scopeAccountId,
    Value<int>? rowid,
  }) {
    return ExchangeRateOverridesCompanion(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      rate: rate ?? this.rate,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      scopeAccountId: scopeAccountId ?? this.scopeAccountId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (quoteCurrency.present) {
      map['quote_currency'] = Variable<String>(quoteCurrency.value);
    }
    if (rate.present) {
      map['rate'] = Variable<String>(rate.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (scopeAccountId.present) {
      map['scope_account_id'] = Variable<String>(scopeAccountId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateOverridesCompanion(')
          ..write('id: $id, ')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rate: $rate, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('scopeAccountId: $scopeAccountId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SharedLedgerCategoriesTable extends SharedLedgerCategories
    with TableInfo<$SharedLedgerCategoriesTable, SharedLedgerCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedLedgerCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    ledgerId,
    categoryId,
    name,
    kind,
    icon,
    sortOrder,
    level,
    parentId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_ledger_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<SharedLedgerCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ledgerId, categoryId};
  @override
  SharedLedgerCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedLedgerCategory(
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SharedLedgerCategoriesTable createAlias(String alias) {
    return $SharedLedgerCategoriesTable(attachedDatabase, alias);
  }
}

class SharedLedgerCategory extends DataClass
    implements Insertable<SharedLedgerCategory> {
  final String ledgerId;

  /// Owner 的分类 UUID(契约 category_id)。
  final String categoryId;
  final String name;
  final String kind;
  final String? icon;
  final int sortOrder;
  final int level;

  /// 父分类 UUID(共享镜像内的父子链)。
  final String? parentId;
  final DateTime updatedAt;
  const SharedLedgerCategory({
    required this.ledgerId,
    required this.categoryId,
    required this.name,
    required this.kind,
    this.icon,
    required this.sortOrder,
    required this.level,
    this.parentId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ledger_id'] = Variable<String>(ledgerId);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['level'] = Variable<int>(level);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SharedLedgerCategoriesCompanion toCompanion(bool nullToAbsent) {
    return SharedLedgerCategoriesCompanion(
      ledgerId: Value(ledgerId),
      categoryId: Value(categoryId),
      name: Value(name),
      kind: Value(kind),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      sortOrder: Value(sortOrder),
      level: Value(level),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      updatedAt: Value(updatedAt),
    );
  }

  factory SharedLedgerCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedLedgerCategory(
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<String>(json['kind']),
      icon: serializer.fromJson<String?>(json['icon']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      level: serializer.fromJson<int>(json['level']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ledgerId': serializer.toJson<String>(ledgerId),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(kind),
      'icon': serializer.toJson<String?>(icon),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'level': serializer.toJson<int>(level),
      'parentId': serializer.toJson<String?>(parentId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SharedLedgerCategory copyWith({
    String? ledgerId,
    String? categoryId,
    String? name,
    String? kind,
    Value<String?> icon = const Value.absent(),
    int? sortOrder,
    int? level,
    Value<String?> parentId = const Value.absent(),
    DateTime? updatedAt,
  }) => SharedLedgerCategory(
    ledgerId: ledgerId ?? this.ledgerId,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    icon: icon.present ? icon.value : this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    level: level ?? this.level,
    parentId: parentId.present ? parentId.value : this.parentId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SharedLedgerCategory copyWithCompanion(SharedLedgerCategoriesCompanion data) {
    return SharedLedgerCategory(
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      icon: data.icon.present ? data.icon.value : this.icon,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      level: data.level.present ? data.level.value : this.level,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedLedgerCategory(')
          ..write('ledgerId: $ledgerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('level: $level, ')
          ..write('parentId: $parentId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    ledgerId,
    categoryId,
    name,
    kind,
    icon,
    sortOrder,
    level,
    parentId,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedLedgerCategory &&
          other.ledgerId == this.ledgerId &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.icon == this.icon &&
          other.sortOrder == this.sortOrder &&
          other.level == this.level &&
          other.parentId == this.parentId &&
          other.updatedAt == this.updatedAt);
}

class SharedLedgerCategoriesCompanion
    extends UpdateCompanion<SharedLedgerCategory> {
  final Value<String> ledgerId;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String> kind;
  final Value<String?> icon;
  final Value<int> sortOrder;
  final Value<int> level;
  final Value<String?> parentId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SharedLedgerCategoriesCompanion({
    this.ledgerId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.level = const Value.absent(),
    this.parentId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedLedgerCategoriesCompanion.insert({
    required String ledgerId,
    required String categoryId,
    required String name,
    required String kind,
    this.icon = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.level = const Value.absent(),
    this.parentId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : ledgerId = Value(ledgerId),
       categoryId = Value(categoryId),
       name = Value(name),
       kind = Value(kind),
       updatedAt = Value(updatedAt);
  static Insertable<SharedLedgerCategory> custom({
    Expression<String>? ledgerId,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? icon,
    Expression<int>? sortOrder,
    Expression<int>? level,
    Expression<String>? parentId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (icon != null) 'icon': icon,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (level != null) 'level': level,
      if (parentId != null) 'parent_id': parentId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedLedgerCategoriesCompanion copyWith({
    Value<String>? ledgerId,
    Value<String>? categoryId,
    Value<String>? name,
    Value<String>? kind,
    Value<String?>? icon,
    Value<int>? sortOrder,
    Value<int>? level,
    Value<String?>? parentId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SharedLedgerCategoriesCompanion(
      ledgerId: ledgerId ?? this.ledgerId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      level: level ?? this.level,
      parentId: parentId ?? this.parentId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedLedgerCategoriesCompanion(')
          ..write('ledgerId: $ledgerId, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('icon: $icon, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('level: $level, ')
          ..write('parentId: $parentId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncChangesTable extends SyncChanges
    with TableInfo<$SyncChangesTable, SyncChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pushedAtMeta = const VerificationMeta(
    'pushedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pushedAt = GeneratedColumn<DateTime>(
    'pushed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mutationIdMeta = const VerificationMeta(
    'mutationId',
  );
  @override
  late final GeneratedColumn<String> mutationId = GeneratedColumn<String>(
    'mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    ledgerId,
    accountId,
    action,
    payload,
    updatedAt,
    pushedAt,
    mutationId,
    baseRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('pushed_at')) {
      context.handle(
        _pushedAtMeta,
        pushedAt.isAcceptableOrUnknown(data['pushed_at']!, _pushedAtMeta),
      );
    }
    if (data.containsKey('mutation_id')) {
      context.handle(
        _mutationIdMeta,
        mutationId.isAcceptableOrUnknown(data['mutation_id']!, _mutationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mutationIdMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      pushedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pushed_at'],
      ),
      mutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mutation_id'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
    );
  }

  @override
  $SyncChangesTable createAlias(String alias) {
    return $SyncChangesTable(attachedDatabase, alias);
  }
}

class SyncChange extends DataClass implements Insertable<SyncChange> {
  /// 本地自增队列序号(纯本地)。
  final int id;

  /// 契约 entity_type: ledger/transaction/category/recurring_transaction/
  /// exchange_rate_override/virtual_user。
  final String entityType;

  /// 契约 entity_id: UUID。
  final String entityId;

  /// 契约 ledger_id: user-global 实体为 null。
  final String? ledgerId;

  /// 归属账号（数据域）：null = 无法归属的旧数据（禁止推送）；
  /// 非 null 时只有当前账号的 SyncService 能读取/推送。
  final String? accountId;

  /// 契约 action: upsert/delete。
  final String action;

  /// 完整实体 JSON(契约 payload)。
  final String payload;

  /// 变更时间(UTC,契约 updated_at)。
  final DateTime updatedAt;

  /// 非 null 表示已推送(服务端确认后清除或标记)。
  final DateTime? pushedAt;

  /// 幂等键(UUID,契约 mutation_id):离线创建时生成,推送重试复用同一值,
  /// 服务端按 (device_id, mutation_id) 去重,防止网络重试重复落库。
  final String mutationId;

  /// 乐观并发基线(3.3):该 mutation 基于的服务端 revision。
  /// 同实体链式递增(前序 base+1),服务端据此做 CAS 冲突检测。
  final int? baseRevision;
  const SyncChange({
    required this.id,
    required this.entityType,
    required this.entityId,
    this.ledgerId,
    this.accountId,
    required this.action,
    required this.payload,
    required this.updatedAt,
    this.pushedAt,
    required this.mutationId,
    this.baseRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    if (!nullToAbsent || ledgerId != null) {
      map['ledger_id'] = Variable<String>(ledgerId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || pushedAt != null) {
      map['pushed_at'] = Variable<DateTime>(pushedAt);
    }
    map['mutation_id'] = Variable<String>(mutationId);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    return map;
  }

  SyncChangesCompanion toCompanion(bool nullToAbsent) {
    return SyncChangesCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      ledgerId: ledgerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ledgerId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      action: Value(action),
      payload: Value(payload),
      updatedAt: Value(updatedAt),
      pushedAt: pushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pushedAt),
      mutationId: Value(mutationId),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
    );
  }

  factory SyncChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncChange(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      ledgerId: serializer.fromJson<String?>(json['ledgerId']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      pushedAt: serializer.fromJson<DateTime?>(json['pushedAt']),
      mutationId: serializer.fromJson<String>(json['mutationId']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'ledgerId': serializer.toJson<String?>(ledgerId),
      'accountId': serializer.toJson<String?>(accountId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'pushedAt': serializer.toJson<DateTime?>(pushedAt),
      'mutationId': serializer.toJson<String>(mutationId),
      'baseRevision': serializer.toJson<int?>(baseRevision),
    };
  }

  SyncChange copyWith({
    int? id,
    String? entityType,
    String? entityId,
    Value<String?> ledgerId = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    String? action,
    String? payload,
    DateTime? updatedAt,
    Value<DateTime?> pushedAt = const Value.absent(),
    String? mutationId,
    Value<int?> baseRevision = const Value.absent(),
  }) => SyncChange(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    ledgerId: ledgerId.present ? ledgerId.value : this.ledgerId,
    accountId: accountId.present ? accountId.value : this.accountId,
    action: action ?? this.action,
    payload: payload ?? this.payload,
    updatedAt: updatedAt ?? this.updatedAt,
    pushedAt: pushedAt.present ? pushedAt.value : this.pushedAt,
    mutationId: mutationId ?? this.mutationId,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
  );
  SyncChange copyWithCompanion(SyncChangesCompanion data) {
    return SyncChange(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      pushedAt: data.pushedAt.present ? data.pushedAt.value : this.pushedAt,
      mutationId: data.mutationId.present
          ? data.mutationId.value
          : this.mutationId,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncChange(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('accountId: $accountId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pushedAt: $pushedAt, ')
          ..write('mutationId: $mutationId, ')
          ..write('baseRevision: $baseRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    ledgerId,
    accountId,
    action,
    payload,
    updatedAt,
    pushedAt,
    mutationId,
    baseRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncChange &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.ledgerId == this.ledgerId &&
          other.accountId == this.accountId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.updatedAt == this.updatedAt &&
          other.pushedAt == this.pushedAt &&
          other.mutationId == this.mutationId &&
          other.baseRevision == this.baseRevision);
}

class SyncChangesCompanion extends UpdateCompanion<SyncChange> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String?> ledgerId;
  final Value<String?> accountId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> pushedAt;
  final Value<String> mutationId;
  final Value<int?> baseRevision;
  const SyncChangesCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.pushedAt = const Value.absent(),
    this.mutationId = const Value.absent(),
    this.baseRevision = const Value.absent(),
  });
  SyncChangesCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    this.ledgerId = const Value.absent(),
    this.accountId = const Value.absent(),
    required String action,
    required String payload,
    required DateTime updatedAt,
    this.pushedAt = const Value.absent(),
    required String mutationId,
    this.baseRevision = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       payload = Value(payload),
       updatedAt = Value(updatedAt),
       mutationId = Value(mutationId);
  static Insertable<SyncChange> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? ledgerId,
    Expression<String>? accountId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? pushedAt,
    Expression<String>? mutationId,
    Expression<int>? baseRevision,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (accountId != null) 'account_id': accountId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (pushedAt != null) 'pushed_at': pushedAt,
      if (mutationId != null) 'mutation_id': mutationId,
      if (baseRevision != null) 'base_revision': baseRevision,
    });
  }

  SyncChangesCompanion copyWith({
    Value<int>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String?>? ledgerId,
    Value<String?>? accountId,
    Value<String>? action,
    Value<String>? payload,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? pushedAt,
    Value<String>? mutationId,
    Value<int?>? baseRevision,
  }) {
    return SyncChangesCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      ledgerId: ledgerId ?? this.ledgerId,
      accountId: accountId ?? this.accountId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      updatedAt: updatedAt ?? this.updatedAt,
      pushedAt: pushedAt ?? this.pushedAt,
      mutationId: mutationId ?? this.mutationId,
      baseRevision: baseRevision ?? this.baseRevision,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (pushedAt.present) {
      map['pushed_at'] = Variable<DateTime>(pushedAt.value);
    }
    if (mutationId.present) {
      map['mutation_id'] = Variable<String>(mutationId.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncChangesCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('accountId: $accountId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('pushedAt: $pushedAt, ')
          ..write('mutationId: $mutationId, ')
          ..write('baseRevision: $baseRevision')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverCursorMeta = const VerificationMeta(
    'serverCursor',
  );
  @override
  late final GeneratedColumn<String> serverCursor = GeneratedColumn<String>(
    'server_cursor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('0'),
  );
  static const VerificationMeta _lastPushAtMeta = const VerificationMeta(
    'lastPushAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPushAt = GeneratedColumn<DateTime>(
    'last_push_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    serverCursor,
    lastPushAt,
    lastPullAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('server_cursor')) {
      context.handle(
        _serverCursorMeta,
        serverCursor.isAcceptableOrUnknown(
          data['server_cursor']!,
          _serverCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_push_at')) {
      context.handle(
        _lastPushAtMeta,
        lastPushAt.isAcceptableOrUnknown(
          data['last_push_at']!,
          _lastPushAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      serverCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_cursor'],
      )!,
      lastPushAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_push_at'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String deviceId;

  /// 服务端全局递增游标:BigInt 十进制字符串,不得用 int 承载。
  final String serverCursor;
  final DateTime? lastPushAt;
  final DateTime? lastPullAt;
  const SyncStateData({
    required this.deviceId,
    required this.serverCursor,
    this.lastPushAt,
    this.lastPullAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['server_cursor'] = Variable<String>(serverCursor);
    if (!nullToAbsent || lastPushAt != null) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      deviceId: Value(deviceId),
      serverCursor: Value(serverCursor),
      lastPushAt: lastPushAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushAt),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      serverCursor: serializer.fromJson<String>(json['serverCursor']),
      lastPushAt: serializer.fromJson<DateTime?>(json['lastPushAt']),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'serverCursor': serializer.toJson<String>(serverCursor),
      'lastPushAt': serializer.toJson<DateTime?>(lastPushAt),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
    };
  }

  SyncStateData copyWith({
    String? deviceId,
    String? serverCursor,
    Value<DateTime?> lastPushAt = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
  }) => SyncStateData(
    deviceId: deviceId ?? this.deviceId,
    serverCursor: serverCursor ?? this.serverCursor,
    lastPushAt: lastPushAt.present ? lastPushAt.value : this.lastPushAt,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      serverCursor: data.serverCursor.present
          ? data.serverCursor.value
          : this.serverCursor,
      lastPushAt: data.lastPushAt.present
          ? data.lastPushAt.value
          : this.lastPushAt,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('deviceId: $deviceId, ')
          ..write('serverCursor: $serverCursor, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deviceId, serverCursor, lastPushAt, lastPullAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.deviceId == this.deviceId &&
          other.serverCursor == this.serverCursor &&
          other.lastPushAt == this.lastPushAt &&
          other.lastPullAt == this.lastPullAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> deviceId;
  final Value<String> serverCursor;
  final Value<DateTime?> lastPushAt;
  final Value<DateTime?> lastPullAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.deviceId = const Value.absent(),
    this.serverCursor = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String deviceId,
    this.serverCursor = const Value.absent(),
    this.lastPushAt = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncStateData> custom({
    Expression<String>? deviceId,
    Expression<String>? serverCursor,
    Expression<DateTime>? lastPushAt,
    Expression<DateTime>? lastPullAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (serverCursor != null) 'server_cursor': serverCursor,
      if (lastPushAt != null) 'last_push_at': lastPushAt,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? serverCursor,
    Value<DateTime?>? lastPushAt,
    Value<DateTime?>? lastPullAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      deviceId: deviceId ?? this.deviceId,
      serverCursor: serverCursor ?? this.serverCursor,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (serverCursor.present) {
      map['server_cursor'] = Variable<String>(serverCursor.value);
    }
    if (lastPushAt.present) {
      map['last_push_at'] = Variable<DateTime>(lastPushAt.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('serverCursor: $serverCursor, ')
          ..write('lastPushAt: $lastPushAt, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncPullErrorsTable extends SyncPullErrors
    with TableInfo<$SyncPullErrorsTable, SyncPullError> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncPullErrorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawChangeJsonMeta = const VerificationMeta(
    'rawChangeJson',
  );
  @override
  late final GeneratedColumn<String> rawChangeJson = GeneratedColumn<String>(
    'raw_change_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorClassMeta = const VerificationMeta(
    'errorClass',
  );
  @override
  late final GeneratedColumn<String> errorClass = GeneratedColumn<String>(
    'error_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _userActionMeta = const VerificationMeta(
    'userAction',
  );
  @override
  late final GeneratedColumn<String> userAction = GeneratedColumn<String>(
    'user_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    changeId,
    ledgerId,
    entityType,
    entityId,
    action,
    rawChangeJson,
    errorClass,
    errorMessage,
    stackTrace,
    firstSeenAt,
    lastAttemptAt,
    attemptCount,
    userAction,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_pull_errors';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncPullError> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_changeIdMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('raw_change_json')) {
      context.handle(
        _rawChangeJsonMeta,
        rawChangeJson.isAcceptableOrUnknown(
          data['raw_change_json']!,
          _rawChangeJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawChangeJsonMeta);
    }
    if (data.containsKey('error_class')) {
      context.handle(
        _errorClassMeta,
        errorClass.isAcceptableOrUnknown(data['error_class']!, _errorClassMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAttemptAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('user_action')) {
      context.handle(
        _userActionMeta,
        userAction.isAcceptableOrUnknown(data['user_action']!, _userActionMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncPullError map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncPullError(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      rawChangeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_change_json'],
      )!,
      errorClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_class'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      ),
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      userAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_action'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncPullErrorsTable createAlias(String alias) {
    return $SyncPullErrorsTable(attachedDatabase, alias);
  }
}

class SyncPullError extends DataClass implements Insertable<SyncPullError> {
  final int id;

  /// server change_id(BigInt 十进制字符串)。
  final String changeId;
  final String? ledgerId;
  final String entityType;
  final String entityId;
  final String action;
  final String rawChangeJson;
  final String? errorClass;
  final String? errorMessage;
  final String? stackTrace;
  final DateTime firstSeenAt;
  final DateTime lastAttemptAt;
  final int attemptCount;
  final String? userAction;
  final DateTime? resolvedAt;
  const SyncPullError({
    required this.id,
    required this.changeId,
    this.ledgerId,
    required this.entityType,
    required this.entityId,
    required this.action,
    required this.rawChangeJson,
    this.errorClass,
    this.errorMessage,
    this.stackTrace,
    required this.firstSeenAt,
    required this.lastAttemptAt,
    required this.attemptCount,
    this.userAction,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['change_id'] = Variable<String>(changeId);
    if (!nullToAbsent || ledgerId != null) {
      map['ledger_id'] = Variable<String>(ledgerId);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['raw_change_json'] = Variable<String>(rawChangeJson);
    if (!nullToAbsent || errorClass != null) {
      map['error_class'] = Variable<String>(errorClass);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || stackTrace != null) {
      map['stack_trace'] = Variable<String>(stackTrace);
    }
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || userAction != null) {
      map['user_action'] = Variable<String>(userAction);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncPullErrorsCompanion toCompanion(bool nullToAbsent) {
    return SyncPullErrorsCompanion(
      id: Value(id),
      changeId: Value(changeId),
      ledgerId: ledgerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ledgerId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      rawChangeJson: Value(rawChangeJson),
      errorClass: errorClass == null && nullToAbsent
          ? const Value.absent()
          : Value(errorClass),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      stackTrace: stackTrace == null && nullToAbsent
          ? const Value.absent()
          : Value(stackTrace),
      firstSeenAt: Value(firstSeenAt),
      lastAttemptAt: Value(lastAttemptAt),
      attemptCount: Value(attemptCount),
      userAction: userAction == null && nullToAbsent
          ? const Value.absent()
          : Value(userAction),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncPullError.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncPullError(
      id: serializer.fromJson<int>(json['id']),
      changeId: serializer.fromJson<String>(json['changeId']),
      ledgerId: serializer.fromJson<String?>(json['ledgerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      rawChangeJson: serializer.fromJson<String>(json['rawChangeJson']),
      errorClass: serializer.fromJson<String?>(json['errorClass']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      stackTrace: serializer.fromJson<String?>(json['stackTrace']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      lastAttemptAt: serializer.fromJson<DateTime>(json['lastAttemptAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      userAction: serializer.fromJson<String?>(json['userAction']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'changeId': serializer.toJson<String>(changeId),
      'ledgerId': serializer.toJson<String?>(ledgerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'rawChangeJson': serializer.toJson<String>(rawChangeJson),
      'errorClass': serializer.toJson<String?>(errorClass),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'stackTrace': serializer.toJson<String?>(stackTrace),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'lastAttemptAt': serializer.toJson<DateTime>(lastAttemptAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'userAction': serializer.toJson<String?>(userAction),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncPullError copyWith({
    int? id,
    String? changeId,
    Value<String?> ledgerId = const Value.absent(),
    String? entityType,
    String? entityId,
    String? action,
    String? rawChangeJson,
    Value<String?> errorClass = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    Value<String?> stackTrace = const Value.absent(),
    DateTime? firstSeenAt,
    DateTime? lastAttemptAt,
    int? attemptCount,
    Value<String?> userAction = const Value.absent(),
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncPullError(
    id: id ?? this.id,
    changeId: changeId ?? this.changeId,
    ledgerId: ledgerId.present ? ledgerId.value : this.ledgerId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    rawChangeJson: rawChangeJson ?? this.rawChangeJson,
    errorClass: errorClass.present ? errorClass.value : this.errorClass,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    stackTrace: stackTrace.present ? stackTrace.value : this.stackTrace,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    attemptCount: attemptCount ?? this.attemptCount,
    userAction: userAction.present ? userAction.value : this.userAction,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncPullError copyWithCompanion(SyncPullErrorsCompanion data) {
    return SyncPullError(
      id: data.id.present ? data.id.value : this.id,
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      rawChangeJson: data.rawChangeJson.present
          ? data.rawChangeJson.value
          : this.rawChangeJson,
      errorClass: data.errorClass.present
          ? data.errorClass.value
          : this.errorClass,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      stackTrace: data.stackTrace.present
          ? data.stackTrace.value
          : this.stackTrace,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      userAction: data.userAction.present
          ? data.userAction.value
          : this.userAction,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncPullError(')
          ..write('id: $id, ')
          ..write('changeId: $changeId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('rawChangeJson: $rawChangeJson, ')
          ..write('errorClass: $errorClass, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('userAction: $userAction, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    changeId,
    ledgerId,
    entityType,
    entityId,
    action,
    rawChangeJson,
    errorClass,
    errorMessage,
    stackTrace,
    firstSeenAt,
    lastAttemptAt,
    attemptCount,
    userAction,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncPullError &&
          other.id == this.id &&
          other.changeId == this.changeId &&
          other.ledgerId == this.ledgerId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.rawChangeJson == this.rawChangeJson &&
          other.errorClass == this.errorClass &&
          other.errorMessage == this.errorMessage &&
          other.stackTrace == this.stackTrace &&
          other.firstSeenAt == this.firstSeenAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.attemptCount == this.attemptCount &&
          other.userAction == this.userAction &&
          other.resolvedAt == this.resolvedAt);
}

class SyncPullErrorsCompanion extends UpdateCompanion<SyncPullError> {
  final Value<int> id;
  final Value<String> changeId;
  final Value<String?> ledgerId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> rawChangeJson;
  final Value<String?> errorClass;
  final Value<String?> errorMessage;
  final Value<String?> stackTrace;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> lastAttemptAt;
  final Value<int> attemptCount;
  final Value<String?> userAction;
  final Value<DateTime?> resolvedAt;
  const SyncPullErrorsCompanion({
    this.id = const Value.absent(),
    this.changeId = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.rawChangeJson = const Value.absent(),
    this.errorClass = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.userAction = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  });
  SyncPullErrorsCompanion.insert({
    this.id = const Value.absent(),
    required String changeId,
    this.ledgerId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String action,
    required String rawChangeJson,
    this.errorClass = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.stackTrace = const Value.absent(),
    required DateTime firstSeenAt,
    required DateTime lastAttemptAt,
    this.attemptCount = const Value.absent(),
    this.userAction = const Value.absent(),
    this.resolvedAt = const Value.absent(),
  }) : changeId = Value(changeId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       rawChangeJson = Value(rawChangeJson),
       firstSeenAt = Value(firstSeenAt),
       lastAttemptAt = Value(lastAttemptAt);
  static Insertable<SyncPullError> custom({
    Expression<int>? id,
    Expression<String>? changeId,
    Expression<String>? ledgerId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? rawChangeJson,
    Expression<String>? errorClass,
    Expression<String>? errorMessage,
    Expression<String>? stackTrace,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? attemptCount,
    Expression<String>? userAction,
    Expression<DateTime>? resolvedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (changeId != null) 'change_id': changeId,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (rawChangeJson != null) 'raw_change_json': rawChangeJson,
      if (errorClass != null) 'error_class': errorClass,
      if (errorMessage != null) 'error_message': errorMessage,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (userAction != null) 'user_action': userAction,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
    });
  }

  SyncPullErrorsCompanion copyWith({
    Value<int>? id,
    Value<String>? changeId,
    Value<String?>? ledgerId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String>? rawChangeJson,
    Value<String?>? errorClass,
    Value<String?>? errorMessage,
    Value<String?>? stackTrace,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? lastAttemptAt,
    Value<int>? attemptCount,
    Value<String?>? userAction,
    Value<DateTime?>? resolvedAt,
  }) {
    return SyncPullErrorsCompanion(
      id: id ?? this.id,
      changeId: changeId ?? this.changeId,
      ledgerId: ledgerId ?? this.ledgerId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      rawChangeJson: rawChangeJson ?? this.rawChangeJson,
      errorClass: errorClass ?? this.errorClass,
      errorMessage: errorMessage ?? this.errorMessage,
      stackTrace: stackTrace ?? this.stackTrace,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      attemptCount: attemptCount ?? this.attemptCount,
      userAction: userAction ?? this.userAction,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (rawChangeJson.present) {
      map['raw_change_json'] = Variable<String>(rawChangeJson.value);
    }
    if (errorClass.present) {
      map['error_class'] = Variable<String>(errorClass.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (userAction.present) {
      map['user_action'] = Variable<String>(userAction.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncPullErrorsCompanion(')
          ..write('id: $id, ')
          ..write('changeId: $changeId, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('rawChangeJson: $rawChangeJson, ')
          ..write('errorClass: $errorClass, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('userAction: $userAction, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ledgerIdMeta = const VerificationMeta(
    'ledgerId',
  );
  @override
  late final GeneratedColumn<String> ledgerId = GeneratedColumn<String>(
    'ledger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadMeta = const VerificationMeta(
    'localPayload',
  );
  @override
  late final GeneratedColumn<String> localPayload = GeneratedColumn<String>(
    'local_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePayloadMeta = const VerificationMeta(
    'remotePayload',
  );
  @override
  late final GeneratedColumn<String> remotePayload = GeneratedColumn<String>(
    'remote_payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteRevisionMeta = const VerificationMeta(
    'remoteRevision',
  );
  @override
  late final GeneratedColumn<int> remoteRevision = GeneratedColumn<int>(
    'remote_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localMutationIdMeta = const VerificationMeta(
    'localMutationId',
  );
  @override
  late final GeneratedColumn<String> localMutationId = GeneratedColumn<String>(
    'local_mutation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('OPEN'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ledgerId,
    entityType,
    entityId,
    localPayload,
    remotePayload,
    baseRevision,
    remoteRevision,
    localMutationId,
    status,
    createdAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('ledger_id')) {
      context.handle(
        _ledgerIdMeta,
        ledgerId.isAcceptableOrUnknown(data['ledger_id']!, _ledgerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ledgerIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_payload')) {
      context.handle(
        _localPayloadMeta,
        localPayload.isAcceptableOrUnknown(
          data['local_payload']!,
          _localPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localPayloadMeta);
    }
    if (data.containsKey('remote_payload')) {
      context.handle(
        _remotePayloadMeta,
        remotePayload.isAcceptableOrUnknown(
          data['remote_payload']!,
          _remotePayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remotePayloadMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseRevisionMeta);
    }
    if (data.containsKey('remote_revision')) {
      context.handle(
        _remoteRevisionMeta,
        remoteRevision.isAcceptableOrUnknown(
          data['remote_revision']!,
          _remoteRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteRevisionMeta);
    }
    if (data.containsKey('local_mutation_id')) {
      context.handle(
        _localMutationIdMeta,
        localMutationId.isAcceptableOrUnknown(
          data['local_mutation_id']!,
          _localMutationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localMutationIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ledgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ledger_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload'],
      )!,
      remotePayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_payload'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      )!,
      remoteRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_revision'],
      )!,
      localMutationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_mutation_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  /// 冲突记录主键(UUID v4)。
  final String id;

  /// 冲突所属账本(账本级实体冲突;user 级实体暂不产生冲突)。
  final String ledgerId;

  /// 冲突实体类型(当前为 transaction)。
  final String entityType;

  /// 冲突实体 id。
  final String entityId;

  /// 本地版本(实体 JSON):取冲突实体的最新 pending mutation payload。
  final String localPayload;

  /// 云端版本(实体 JSON):push 冲突取服务端 current_entity;
  /// delete 冲突以 {"deleted":true,"revision":N} 表达云端已删除。
  final String remotePayload;

  /// 冲突基线:本地 pending mutation 的 base_revision。
  final int baseRevision;

  /// 冲突时云端 revision。
  final int remoteRevision;

  /// 产生冲突的本地 mutation id(解决后用于清理 pending 队列)。
  final String localMutationId;

  /// 冲突状态: OPEN / RESOLVED_LOCAL / RESOLVED_REMOTE。
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  const SyncConflict({
    required this.id,
    required this.ledgerId,
    required this.entityType,
    required this.entityId,
    required this.localPayload,
    required this.remotePayload,
    required this.baseRevision,
    required this.remoteRevision,
    required this.localMutationId,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['ledger_id'] = Variable<String>(ledgerId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_payload'] = Variable<String>(localPayload);
    map['remote_payload'] = Variable<String>(remotePayload);
    map['base_revision'] = Variable<int>(baseRevision);
    map['remote_revision'] = Variable<int>(remoteRevision);
    map['local_mutation_id'] = Variable<String>(localMutationId);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      id: Value(id),
      ledgerId: Value(ledgerId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localPayload: Value(localPayload),
      remotePayload: Value(remotePayload),
      baseRevision: Value(baseRevision),
      remoteRevision: Value(remoteRevision),
      localMutationId: Value(localMutationId),
      status: Value(status),
      createdAt: Value(createdAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      id: serializer.fromJson<String>(json['id']),
      ledgerId: serializer.fromJson<String>(json['ledgerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localPayload: serializer.fromJson<String>(json['localPayload']),
      remotePayload: serializer.fromJson<String>(json['remotePayload']),
      baseRevision: serializer.fromJson<int>(json['baseRevision']),
      remoteRevision: serializer.fromJson<int>(json['remoteRevision']),
      localMutationId: serializer.fromJson<String>(json['localMutationId']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ledgerId': serializer.toJson<String>(ledgerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localPayload': serializer.toJson<String>(localPayload),
      'remotePayload': serializer.toJson<String>(remotePayload),
      'baseRevision': serializer.toJson<int>(baseRevision),
      'remoteRevision': serializer.toJson<int>(remoteRevision),
      'localMutationId': serializer.toJson<String>(localMutationId),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflict copyWith({
    String? id,
    String? ledgerId,
    String? entityType,
    String? entityId,
    String? localPayload,
    String? remotePayload,
    int? baseRevision,
    int? remoteRevision,
    String? localMutationId,
    String? status,
    DateTime? createdAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflict(
    id: id ?? this.id,
    ledgerId: ledgerId ?? this.ledgerId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localPayload: localPayload ?? this.localPayload,
    remotePayload: remotePayload ?? this.remotePayload,
    baseRevision: baseRevision ?? this.baseRevision,
    remoteRevision: remoteRevision ?? this.remoteRevision,
    localMutationId: localMutationId ?? this.localMutationId,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      id: data.id.present ? data.id.value : this.id,
      ledgerId: data.ledgerId.present ? data.ledgerId.value : this.ledgerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localPayload: data.localPayload.present
          ? data.localPayload.value
          : this.localPayload,
      remotePayload: data.remotePayload.present
          ? data.remotePayload.value
          : this.remotePayload,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      remoteRevision: data.remoteRevision.present
          ? data.remoteRevision.value
          : this.remoteRevision,
      localMutationId: data.localMutationId.present
          ? data.localMutationId.value
          : this.localMutationId,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayload: $localPayload, ')
          ..write('remotePayload: $remotePayload, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('localMutationId: $localMutationId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ledgerId,
    entityType,
    entityId,
    localPayload,
    remotePayload,
    baseRevision,
    remoteRevision,
    localMutationId,
    status,
    createdAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.id == this.id &&
          other.ledgerId == this.ledgerId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localPayload == this.localPayload &&
          other.remotePayload == this.remotePayload &&
          other.baseRevision == this.baseRevision &&
          other.remoteRevision == this.remoteRevision &&
          other.localMutationId == this.localMutationId &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> id;
  final Value<String> ledgerId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localPayload;
  final Value<String> remotePayload;
  final Value<int> baseRevision;
  final Value<int> remoteRevision;
  final Value<String> localMutationId;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.id = const Value.absent(),
    this.ledgerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localPayload = const Value.absent(),
    this.remotePayload = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.remoteRevision = const Value.absent(),
    this.localMutationId = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String id,
    required String ledgerId,
    required String entityType,
    required String entityId,
    required String localPayload,
    required String remotePayload,
    required int baseRevision,
    required int remoteRevision,
    required String localMutationId,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ledgerId = Value(ledgerId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localPayload = Value(localPayload),
       remotePayload = Value(remotePayload),
       baseRevision = Value(baseRevision),
       remoteRevision = Value(remoteRevision),
       localMutationId = Value(localMutationId);
  static Insertable<SyncConflict> custom({
    Expression<String>? id,
    Expression<String>? ledgerId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localPayload,
    Expression<String>? remotePayload,
    Expression<int>? baseRevision,
    Expression<int>? remoteRevision,
    Expression<String>? localMutationId,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ledgerId != null) 'ledger_id': ledgerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localPayload != null) 'local_payload': localPayload,
      if (remotePayload != null) 'remote_payload': remotePayload,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (remoteRevision != null) 'remote_revision': remoteRevision,
      if (localMutationId != null) 'local_mutation_id': localMutationId,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? ledgerId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localPayload,
    Value<String>? remotePayload,
    Value<int>? baseRevision,
    Value<int>? remoteRevision,
    Value<String>? localMutationId,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      id: id ?? this.id,
      ledgerId: ledgerId ?? this.ledgerId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localPayload: localPayload ?? this.localPayload,
      remotePayload: remotePayload ?? this.remotePayload,
      baseRevision: baseRevision ?? this.baseRevision,
      remoteRevision: remoteRevision ?? this.remoteRevision,
      localMutationId: localMutationId ?? this.localMutationId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ledgerId.present) {
      map['ledger_id'] = Variable<String>(ledgerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localPayload.present) {
      map['local_payload'] = Variable<String>(localPayload.value);
    }
    if (remotePayload.present) {
      map['remote_payload'] = Variable<String>(remotePayload.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (remoteRevision.present) {
      map['remote_revision'] = Variable<int>(remoteRevision.value);
    }
    if (localMutationId.present) {
      map['local_mutation_id'] = Variable<String>(localMutationId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('id: $id, ')
          ..write('ledgerId: $ledgerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localPayload: $localPayload, ')
          ..write('remotePayload: $remotePayload, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('remoteRevision: $remoteRevision, ')
          ..write('localMutationId: $localMutationId, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupStateTable extends BackupState
    with TableInfo<$BackupStateTable, BackupStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dirtySinceMeta = const VerificationMeta(
    'dirtySince',
  );
  @override
  late final GeneratedColumn<DateTime> dirtySince = GeneratedColumn<DateTime>(
    'dirty_since',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _currentProviderMeta = const VerificationMeta(
    'currentProvider',
  );
  @override
  late final GeneratedColumn<String> currentProvider = GeneratedColumn<String>(
    'current_provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    dirtySince,
    lastSuccessAt,
    currentProvider,
    id,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dirty_since')) {
      context.handle(
        _dirtySinceMeta,
        dirtySince.isAcceptableOrUnknown(data['dirty_since']!, _dirtySinceMeta),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('current_provider')) {
      context.handle(
        _currentProviderMeta,
        currentProvider.isAcceptableOrUnknown(
          data['current_provider']!,
          _currentProviderMeta,
        ),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupStateData(
      dirtySince: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}dirty_since'],
      ),
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      currentProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_provider'],
      ),
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
    );
  }

  @override
  $BackupStateTable createAlias(String alias) {
    return $BackupStateTable(attachedDatabase, alias);
  }
}

class BackupStateData extends DataClass implements Insertable<BackupStateData> {
  /// 自上次成功备份以来的首次脏时间（null = 无脏数据）。
  final DateTime? dirtySince;

  /// 最近一次成功备份时间（null = 从未成功）。
  final DateTime? lastSuccessAt;

  /// 当前自动备份目标（supabase/webdav/s3，null = 未配置）。
  final String? currentProvider;

  /// 单例哨兵列恒为 0，数据库约束避免并发路径写出多行状态。
  final int id;
  const BackupStateData({
    this.dirtySince,
    this.lastSuccessAt,
    this.currentProvider,
    required this.id,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || dirtySince != null) {
      map['dirty_since'] = Variable<DateTime>(dirtySince);
    }
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || currentProvider != null) {
      map['current_provider'] = Variable<String>(currentProvider);
    }
    map['id'] = Variable<int>(id);
    return map;
  }

  BackupStateCompanion toCompanion(bool nullToAbsent) {
    return BackupStateCompanion(
      dirtySince: dirtySince == null && nullToAbsent
          ? const Value.absent()
          : Value(dirtySince),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      currentProvider: currentProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(currentProvider),
      id: Value(id),
    );
  }

  factory BackupStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupStateData(
      dirtySince: serializer.fromJson<DateTime?>(json['dirtySince']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      currentProvider: serializer.fromJson<String?>(json['currentProvider']),
      id: serializer.fromJson<int>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dirtySince': serializer.toJson<DateTime?>(dirtySince),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'currentProvider': serializer.toJson<String?>(currentProvider),
      'id': serializer.toJson<int>(id),
    };
  }

  BackupStateData copyWith({
    Value<DateTime?> dirtySince = const Value.absent(),
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<String?> currentProvider = const Value.absent(),
    int? id,
  }) => BackupStateData(
    dirtySince: dirtySince.present ? dirtySince.value : this.dirtySince,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    currentProvider: currentProvider.present
        ? currentProvider.value
        : this.currentProvider,
    id: id ?? this.id,
  );
  BackupStateData copyWithCompanion(BackupStateCompanion data) {
    return BackupStateData(
      dirtySince: data.dirtySince.present
          ? data.dirtySince.value
          : this.dirtySince,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      currentProvider: data.currentProvider.present
          ? data.currentProvider.value
          : this.currentProvider,
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupStateData(')
          ..write('dirtySince: $dirtySince, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('currentProvider: $currentProvider, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(dirtySince, lastSuccessAt, currentProvider, id);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupStateData &&
          other.dirtySince == this.dirtySince &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.currentProvider == this.currentProvider &&
          other.id == this.id);
}

class BackupStateCompanion extends UpdateCompanion<BackupStateData> {
  final Value<DateTime?> dirtySince;
  final Value<DateTime?> lastSuccessAt;
  final Value<String?> currentProvider;
  final Value<int> id;
  const BackupStateCompanion({
    this.dirtySince = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.currentProvider = const Value.absent(),
    this.id = const Value.absent(),
  });
  BackupStateCompanion.insert({
    this.dirtySince = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.currentProvider = const Value.absent(),
    this.id = const Value.absent(),
  });
  static Insertable<BackupStateData> custom({
    Expression<DateTime>? dirtySince,
    Expression<DateTime>? lastSuccessAt,
    Expression<String>? currentProvider,
    Expression<int>? id,
  }) {
    return RawValuesInsertable({
      if (dirtySince != null) 'dirty_since': dirtySince,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (currentProvider != null) 'current_provider': currentProvider,
      if (id != null) 'id': id,
    });
  }

  BackupStateCompanion copyWith({
    Value<DateTime?>? dirtySince,
    Value<DateTime?>? lastSuccessAt,
    Value<String?>? currentProvider,
    Value<int>? id,
  }) {
    return BackupStateCompanion(
      dirtySince: dirtySince ?? this.dirtySince,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      currentProvider: currentProvider ?? this.currentProvider,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dirtySince.present) {
      map['dirty_since'] = Variable<DateTime>(dirtySince.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (currentProvider.present) {
      map['current_provider'] = Variable<String>(currentProvider.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupStateCompanion(')
          ..write('dirtySince: $dirtySince, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('currentProvider: $currentProvider, ')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }
}

class $RecoveryLogsTable extends RecoveryLogs
    with TableInfo<$RecoveryLogsTable, RecoveryLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveryLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceBackupNameMeta = const VerificationMeta(
    'sourceBackupName',
  );
  @override
  late final GeneratedColumn<String> sourceBackupName = GeneratedColumn<String>(
    'source_backup_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLedgerIdMeta = const VerificationMeta(
    'targetLedgerId',
  );
  @override
  late final GeneratedColumn<String> targetLedgerId = GeneratedColumn<String>(
    'target_ledger_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    sourceBackupName,
    targetLedgerId,
    action,
    result,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recovery_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('source_backup_name')) {
      context.handle(
        _sourceBackupNameMeta,
        sourceBackupName.isAcceptableOrUnknown(
          data['source_backup_name']!,
          _sourceBackupNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceBackupNameMeta);
    }
    if (data.containsKey('target_ledger_id')) {
      context.handle(
        _targetLedgerIdMeta,
        targetLedgerId.isAcceptableOrUnknown(
          data['target_ledger_id']!,
          _targetLedgerIdMeta,
        ),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sourceBackupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_backup_name'],
      )!,
      targetLedgerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_ledger_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $RecoveryLogsTable createAlias(String alias) {
    return $RecoveryLogsTable(attachedDatabase, alias);
  }
}

class RecoveryLog extends DataClass implements Insertable<RecoveryLog> {
  /// 本地自增行标识。
  final int id;

  /// 恢复执行时间（UTC）。
  final DateTime createdAt;

  /// 来源备份文件名（如 sesame_notes_20260821_021300.snbak）。
  final String sourceBackupName;

  /// 目标账本 id（恢复为本地/Fork 时为新 ledger id；跳过时为空）。
  final String? targetLedgerId;

  /// 动作：restore_local / fork_cloud_to_local / skip / reconnect。
  final String action;

  /// 结果：success / failed。
  final String result;

  /// 附加信息（失败原因、原账本 id 等，仅审计）。
  final String? detail;
  const RecoveryLog({
    required this.id,
    required this.createdAt,
    required this.sourceBackupName,
    this.targetLedgerId,
    required this.action,
    required this.result,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['source_backup_name'] = Variable<String>(sourceBackupName);
    if (!nullToAbsent || targetLedgerId != null) {
      map['target_ledger_id'] = Variable<String>(targetLedgerId);
    }
    map['action'] = Variable<String>(action);
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  RecoveryLogsCompanion toCompanion(bool nullToAbsent) {
    return RecoveryLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      sourceBackupName: Value(sourceBackupName),
      targetLedgerId: targetLedgerId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLedgerId),
      action: Value(action),
      result: Value(result),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory RecoveryLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryLog(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sourceBackupName: serializer.fromJson<String>(json['sourceBackupName']),
      targetLedgerId: serializer.fromJson<String?>(json['targetLedgerId']),
      action: serializer.fromJson<String>(json['action']),
      result: serializer.fromJson<String>(json['result']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sourceBackupName': serializer.toJson<String>(sourceBackupName),
      'targetLedgerId': serializer.toJson<String?>(targetLedgerId),
      'action': serializer.toJson<String>(action),
      'result': serializer.toJson<String>(result),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  RecoveryLog copyWith({
    int? id,
    DateTime? createdAt,
    String? sourceBackupName,
    Value<String?> targetLedgerId = const Value.absent(),
    String? action,
    String? result,
    Value<String?> detail = const Value.absent(),
  }) => RecoveryLog(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    sourceBackupName: sourceBackupName ?? this.sourceBackupName,
    targetLedgerId: targetLedgerId.present
        ? targetLedgerId.value
        : this.targetLedgerId,
    action: action ?? this.action,
    result: result ?? this.result,
    detail: detail.present ? detail.value : this.detail,
  );
  RecoveryLog copyWithCompanion(RecoveryLogsCompanion data) {
    return RecoveryLog(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sourceBackupName: data.sourceBackupName.present
          ? data.sourceBackupName.value
          : this.sourceBackupName,
      targetLedgerId: data.targetLedgerId.present
          ? data.targetLedgerId.value
          : this.targetLedgerId,
      action: data.action.present ? data.action.value : this.action,
      result: data.result.present ? data.result.value : this.result,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryLog(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('sourceBackupName: $sourceBackupName, ')
          ..write('targetLedgerId: $targetLedgerId, ')
          ..write('action: $action, ')
          ..write('result: $result, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    sourceBackupName,
    targetLedgerId,
    action,
    result,
    detail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryLog &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.sourceBackupName == this.sourceBackupName &&
          other.targetLedgerId == this.targetLedgerId &&
          other.action == this.action &&
          other.result == this.result &&
          other.detail == this.detail);
}

class RecoveryLogsCompanion extends UpdateCompanion<RecoveryLog> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<String> sourceBackupName;
  final Value<String?> targetLedgerId;
  final Value<String> action;
  final Value<String> result;
  final Value<String?> detail;
  const RecoveryLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sourceBackupName = const Value.absent(),
    this.targetLedgerId = const Value.absent(),
    this.action = const Value.absent(),
    this.result = const Value.absent(),
    this.detail = const Value.absent(),
  });
  RecoveryLogsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String sourceBackupName,
    this.targetLedgerId = const Value.absent(),
    required String action,
    required String result,
    this.detail = const Value.absent(),
  }) : sourceBackupName = Value(sourceBackupName),
       action = Value(action),
       result = Value(result);
  static Insertable<RecoveryLog> custom({
    Expression<int>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? sourceBackupName,
    Expression<String>? targetLedgerId,
    Expression<String>? action,
    Expression<String>? result,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (sourceBackupName != null) 'source_backup_name': sourceBackupName,
      if (targetLedgerId != null) 'target_ledger_id': targetLedgerId,
      if (action != null) 'action': action,
      if (result != null) 'result': result,
      if (detail != null) 'detail': detail,
    });
  }

  RecoveryLogsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<String>? sourceBackupName,
    Value<String?>? targetLedgerId,
    Value<String>? action,
    Value<String>? result,
    Value<String?>? detail,
  }) {
    return RecoveryLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      sourceBackupName: sourceBackupName ?? this.sourceBackupName,
      targetLedgerId: targetLedgerId ?? this.targetLedgerId,
      action: action ?? this.action,
      result: result ?? this.result,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sourceBackupName.present) {
      map['source_backup_name'] = Variable<String>(sourceBackupName.value);
    }
    if (targetLedgerId.present) {
      map['target_ledger_id'] = Variable<String>(targetLedgerId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('sourceBackupName: $sourceBackupName, ')
          ..write('targetLedgerId: $targetLedgerId, ')
          ..write('action: $action, ')
          ..write('result: $result, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

abstract class _$SesameDatabase extends GeneratedDatabase {
  _$SesameDatabase(QueryExecutor e) : super(e);
  $SesameDatabaseManager get managers => $SesameDatabaseManager(this);
  late final $LedgersTable ledgers = $LedgersTable(this);
  late final $LedgerMembersTable ledgerMembers = $LedgerMembersTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $TransactionSplitsTable transactionSplits =
      $TransactionSplitsTable(this);
  late final $RecordEditHistoriesTable recordEditHistories =
      $RecordEditHistoriesTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final $ExchangeRateOverridesTable exchangeRateOverrides =
      $ExchangeRateOverridesTable(this);
  late final $SharedLedgerCategoriesTable sharedLedgerCategories =
      $SharedLedgerCategoriesTable(this);
  late final $SyncChangesTable syncChanges = $SyncChangesTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $SyncPullErrorsTable syncPullErrors = $SyncPullErrorsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  late final $BackupStateTable backupState = $BackupStateTable(this);
  late final $RecoveryLogsTable recoveryLogs = $RecoveryLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    ledgers,
    ledgerMembers,
    categories,
    recurringTransactions,
    transactions,
    transactionSplits,
    recordEditHistories,
    exchangeRates,
    exchangeRateOverrides,
    sharedLedgerCategories,
    syncChanges,
    syncState,
    syncPullErrors,
    syncConflicts,
    backupState,
    recoveryLogs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledgers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ledger_members', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('categories', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledgers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'ledgers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transaction_splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('record_edit_histories', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LedgersTableCreateCompanionBuilder =
    LedgersCompanion Function({
      required String id,
      required String name,
      Value<String> currency,
      Value<int> monthStartDay,
      Value<bool> aaEnabled,
      Value<String> role,
      Value<int> memberCount,
      Value<String> storageMode,
      Value<String?> scopeAccountId,
      Value<String?> syncId,
      Value<String?> bindingStatus,
      Value<String?> selfMemberId,
      Value<String?> originType,
      Value<String?> originLedgerId,
      Value<String?> originSyncId,
      Value<String?> originAccountId,
      Value<String?> originBackupId,
      Value<int?> originLastRevision,
      Value<DateTime?> detachedAt,
      Value<DateTime> createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LedgersTableUpdateCompanionBuilder =
    LedgersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> currency,
      Value<int> monthStartDay,
      Value<bool> aaEnabled,
      Value<String> role,
      Value<int> memberCount,
      Value<String> storageMode,
      Value<String?> scopeAccountId,
      Value<String?> syncId,
      Value<String?> bindingStatus,
      Value<String?> selfMemberId,
      Value<String?> originType,
      Value<String?> originLedgerId,
      Value<String?> originSyncId,
      Value<String?> originAccountId,
      Value<String?> originBackupId,
      Value<int?> originLastRevision,
      Value<DateTime?> detachedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LedgersTableReferences
    extends BaseReferences<_$SesameDatabase, $LedgersTable, Ledger> {
  $$LedgersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LedgerMembersTable, List<LedgerMember>>
  _ledgerMembersRefsTable(_$SesameDatabase db) => MultiTypedResultKey.fromTable(
    db.ledgerMembers,
    aliasName: 'ledgers__id__ledger_members__ledger_id',
  );

  $$LedgerMembersTableProcessedTableManager get ledgerMembersRefs {
    final manager = $$LedgerMembersTableTableManager(
      $_db,
      $_db.ledgerMembers,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_ledgerMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringTransactionsTable,
    List<RecurringTransaction>
  >
  _recurringTransactionsRefsTable(_$SesameDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: 'ledgers__id__recurring_transactions__ledger_id',
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$SesameDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'ledgers__id__transactions__ledger_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.ledgerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LedgersTableFilterComposer
    extends Composer<_$SesameDatabase, $LedgersTable> {
  $$LedgersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthStartDay => $composableBuilder(
    column: $table.monthStartDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aaEnabled => $composableBuilder(
    column: $table.aaEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bindingStatus => $composableBuilder(
    column: $table.bindingStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selfMemberId => $composableBuilder(
    column: $table.selfMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originType => $composableBuilder(
    column: $table.originType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originLedgerId => $composableBuilder(
    column: $table.originLedgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originSyncId => $composableBuilder(
    column: $table.originSyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originAccountId => $composableBuilder(
    column: $table.originAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originBackupId => $composableBuilder(
    column: $table.originBackupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originLastRevision => $composableBuilder(
    column: $table.originLastRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detachedAt => $composableBuilder(
    column: $table.detachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ledgerMembersRefs(
    Expression<bool> Function($$LedgerMembersTableFilterComposer f) f,
  ) {
    final $$LedgerMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerMembers,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerMembersTableFilterComposer(
            $db: $db,
            $table: $db.ledgerMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringTransactionsRefs(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.ledgerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgersTableOrderingComposer
    extends Composer<_$SesameDatabase, $LedgersTable> {
  $$LedgersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthStartDay => $composableBuilder(
    column: $table.monthStartDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aaEnabled => $composableBuilder(
    column: $table.aaEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bindingStatus => $composableBuilder(
    column: $table.bindingStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selfMemberId => $composableBuilder(
    column: $table.selfMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originType => $composableBuilder(
    column: $table.originType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originLedgerId => $composableBuilder(
    column: $table.originLedgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originSyncId => $composableBuilder(
    column: $table.originSyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originAccountId => $composableBuilder(
    column: $table.originAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originBackupId => $composableBuilder(
    column: $table.originBackupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originLastRevision => $composableBuilder(
    column: $table.originLastRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detachedAt => $composableBuilder(
    column: $table.detachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LedgersTableAnnotationComposer
    extends Composer<_$SesameDatabase, $LedgersTable> {
  $$LedgersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get monthStartDay => $composableBuilder(
    column: $table.monthStartDay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get aaEnabled =>
      $composableBuilder(column: $table.aaEnabled, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get memberCount => $composableBuilder(
    column: $table.memberCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageMode => $composableBuilder(
    column: $table.storageMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get bindingStatus => $composableBuilder(
    column: $table.bindingStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get selfMemberId => $composableBuilder(
    column: $table.selfMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originType => $composableBuilder(
    column: $table.originType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originLedgerId => $composableBuilder(
    column: $table.originLedgerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originSyncId => $composableBuilder(
    column: $table.originSyncId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originAccountId => $composableBuilder(
    column: $table.originAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originBackupId => $composableBuilder(
    column: $table.originBackupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originLastRevision => $composableBuilder(
    column: $table.originLastRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detachedAt => $composableBuilder(
    column: $table.detachedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> ledgerMembersRefs<T extends Object>(
    Expression<T> Function($$LedgerMembersTableAnnotationComposer a) f,
  ) {
    final $$LedgerMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.ledgerMembers,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgerMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgerMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringTransactionsRefs<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.ledgerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.ledgerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LedgersTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $LedgersTable,
          Ledger,
          $$LedgersTableFilterComposer,
          $$LedgersTableOrderingComposer,
          $$LedgersTableAnnotationComposer,
          $$LedgersTableCreateCompanionBuilder,
          $$LedgersTableUpdateCompanionBuilder,
          (Ledger, $$LedgersTableReferences),
          Ledger,
          PrefetchHooks Function({
            bool ledgerMembersRefs,
            bool recurringTransactionsRefs,
            bool transactionsRefs,
          })
        > {
  $$LedgersTableTableManager(_$SesameDatabase db, $LedgersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> monthStartDay = const Value.absent(),
                Value<bool> aaEnabled = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<String> storageMode = const Value.absent(),
                Value<String?> scopeAccountId = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<String?> bindingStatus = const Value.absent(),
                Value<String?> selfMemberId = const Value.absent(),
                Value<String?> originType = const Value.absent(),
                Value<String?> originLedgerId = const Value.absent(),
                Value<String?> originSyncId = const Value.absent(),
                Value<String?> originAccountId = const Value.absent(),
                Value<String?> originBackupId = const Value.absent(),
                Value<int?> originLastRevision = const Value.absent(),
                Value<DateTime?> detachedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgersCompanion(
                id: id,
                name: name,
                currency: currency,
                monthStartDay: monthStartDay,
                aaEnabled: aaEnabled,
                role: role,
                memberCount: memberCount,
                storageMode: storageMode,
                scopeAccountId: scopeAccountId,
                syncId: syncId,
                bindingStatus: bindingStatus,
                selfMemberId: selfMemberId,
                originType: originType,
                originLedgerId: originLedgerId,
                originSyncId: originSyncId,
                originAccountId: originAccountId,
                originBackupId: originBackupId,
                originLastRevision: originLastRevision,
                detachedAt: detachedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> currency = const Value.absent(),
                Value<int> monthStartDay = const Value.absent(),
                Value<bool> aaEnabled = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> memberCount = const Value.absent(),
                Value<String> storageMode = const Value.absent(),
                Value<String?> scopeAccountId = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<String?> bindingStatus = const Value.absent(),
                Value<String?> selfMemberId = const Value.absent(),
                Value<String?> originType = const Value.absent(),
                Value<String?> originLedgerId = const Value.absent(),
                Value<String?> originSyncId = const Value.absent(),
                Value<String?> originAccountId = const Value.absent(),
                Value<String?> originBackupId = const Value.absent(),
                Value<int?> originLastRevision = const Value.absent(),
                Value<DateTime?> detachedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgersCompanion.insert(
                id: id,
                name: name,
                currency: currency,
                monthStartDay: monthStartDay,
                aaEnabled: aaEnabled,
                role: role,
                memberCount: memberCount,
                storageMode: storageMode,
                scopeAccountId: scopeAccountId,
                syncId: syncId,
                bindingStatus: bindingStatus,
                selfMemberId: selfMemberId,
                originType: originType,
                originLedgerId: originLedgerId,
                originSyncId: originSyncId,
                originAccountId: originAccountId,
                originBackupId: originBackupId,
                originLastRevision: originLastRevision,
                detachedAt: detachedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LedgersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ledgerMembersRefs = false,
                recurringTransactionsRefs = false,
                transactionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ledgerMembersRefs) db.ledgerMembers,
                    if (recurringTransactionsRefs) db.recurringTransactions,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ledgerMembersRefs)
                        await $_getPrefetchedData<
                          Ledger,
                          $LedgersTable,
                          LedgerMember
                        >(
                          currentTable: table,
                          referencedTable: $$LedgersTableReferences
                              ._ledgerMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgersTableReferences(
                                db,
                                table,
                                p0,
                              ).ledgerMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ledgerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringTransactionsRefs)
                        await $_getPrefetchedData<
                          Ledger,
                          $LedgersTable,
                          RecurringTransaction
                        >(
                          currentTable: table,
                          referencedTable: $$LedgersTableReferences
                              ._recurringTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgersTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ledgerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          Ledger,
                          $LedgersTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable: $$LedgersTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LedgersTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.ledgerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LedgersTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $LedgersTable,
      Ledger,
      $$LedgersTableFilterComposer,
      $$LedgersTableOrderingComposer,
      $$LedgersTableAnnotationComposer,
      $$LedgersTableCreateCompanionBuilder,
      $$LedgersTableUpdateCompanionBuilder,
      (Ledger, $$LedgersTableReferences),
      Ledger,
      PrefetchHooks Function({
        bool ledgerMembersRefs,
        bool recurringTransactionsRefs,
        bool transactionsRefs,
      })
    >;
typedef $$LedgerMembersTableCreateCompanionBuilder =
    LedgerMembersCompanion Function({
      required String id,
      required String ledgerId,
      required String displayName,
      required String memberType,
      Value<String?> linkedAccountId,
      Value<String?> originMemberId,
      Value<String?> originAccountId,
      Value<String> role,
      Value<String?> avatarUrl,
      Value<int> avatarVersion,
      Value<String> status,
      Value<DateTime> joinedAt,
      Value<DateTime> createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$LedgerMembersTableUpdateCompanionBuilder =
    LedgerMembersCompanion Function({
      Value<String> id,
      Value<String> ledgerId,
      Value<String> displayName,
      Value<String> memberType,
      Value<String?> linkedAccountId,
      Value<String?> originMemberId,
      Value<String?> originAccountId,
      Value<String> role,
      Value<String?> avatarUrl,
      Value<int> avatarVersion,
      Value<String> status,
      Value<DateTime> joinedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$LedgerMembersTableReferences
    extends
        BaseReferences<_$SesameDatabase, $LedgerMembersTable, LedgerMember> {
  $$LedgerMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LedgersTable _ledgerIdTable(_$SesameDatabase db) =>
      db.ledgers.createAlias('ledger_members__ledger_id__ledgers__id');

  $$LedgersTableProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<String>('ledger_id')!;

    final manager = $$LedgersTableTableManager(
      $_db,
      $_db.ledgers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LedgerMembersTableFilterComposer
    extends Composer<_$SesameDatabase, $LedgerMembersTable> {
  $$LedgerMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originMemberId => $composableBuilder(
    column: $table.originMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originAccountId => $composableBuilder(
    column: $table.originAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get avatarVersion => $composableBuilder(
    column: $table.avatarVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgersTableFilterComposer get ledgerId {
    final $$LedgersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableFilterComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerMembersTableOrderingComposer
    extends Composer<_$SesameDatabase, $LedgerMembersTable> {
  $$LedgerMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originMemberId => $composableBuilder(
    column: $table.originMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originAccountId => $composableBuilder(
    column: $table.originAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get avatarVersion => $composableBuilder(
    column: $table.avatarVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgersTableOrderingComposer get ledgerId {
    final $$LedgersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableOrderingComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerMembersTableAnnotationComposer
    extends Composer<_$SesameDatabase, $LedgerMembersTable> {
  $$LedgerMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memberType => $composableBuilder(
    column: $table.memberType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get linkedAccountId => $composableBuilder(
    column: $table.linkedAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originMemberId => $composableBuilder(
    column: $table.originMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originAccountId => $composableBuilder(
    column: $table.originAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get avatarVersion => $composableBuilder(
    column: $table.avatarVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LedgersTableAnnotationComposer get ledgerId {
    final $$LedgersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LedgerMembersTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $LedgerMembersTable,
          LedgerMember,
          $$LedgerMembersTableFilterComposer,
          $$LedgerMembersTableOrderingComposer,
          $$LedgerMembersTableAnnotationComposer,
          $$LedgerMembersTableCreateCompanionBuilder,
          $$LedgerMembersTableUpdateCompanionBuilder,
          (LedgerMember, $$LedgerMembersTableReferences),
          LedgerMember,
          PrefetchHooks Function({bool ledgerId})
        > {
  $$LedgerMembersTableTableManager(
    _$SesameDatabase db,
    $LedgerMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> memberType = const Value.absent(),
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String?> originMemberId = const Value.absent(),
                Value<String?> originAccountId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> avatarVersion = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerMembersCompanion(
                id: id,
                ledgerId: ledgerId,
                displayName: displayName,
                memberType: memberType,
                linkedAccountId: linkedAccountId,
                originMemberId: originMemberId,
                originAccountId: originAccountId,
                role: role,
                avatarUrl: avatarUrl,
                avatarVersion: avatarVersion,
                status: status,
                joinedAt: joinedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerId,
                required String displayName,
                required String memberType,
                Value<String?> linkedAccountId = const Value.absent(),
                Value<String?> originMemberId = const Value.absent(),
                Value<String?> originAccountId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> avatarVersion = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LedgerMembersCompanion.insert(
                id: id,
                ledgerId: ledgerId,
                displayName: displayName,
                memberType: memberType,
                linkedAccountId: linkedAccountId,
                originMemberId: originMemberId,
                originAccountId: originAccountId,
                role: role,
                avatarUrl: avatarUrl,
                avatarVersion: avatarVersion,
                status: status,
                joinedAt: joinedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LedgerMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({ledgerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ledgerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ledgerId,
                                referencedTable: $$LedgerMembersTableReferences
                                    ._ledgerIdTable(db),
                                referencedColumn: $$LedgerMembersTableReferences
                                    ._ledgerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LedgerMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $LedgerMembersTable,
      LedgerMember,
      $$LedgerMembersTableFilterComposer,
      $$LedgerMembersTableOrderingComposer,
      $$LedgerMembersTableAnnotationComposer,
      $$LedgerMembersTableCreateCompanionBuilder,
      $$LedgerMembersTableUpdateCompanionBuilder,
      (LedgerMember, $$LedgerMembersTableReferences),
      LedgerMember,
      PrefetchHooks Function({bool ledgerId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String kind,
      required int level,
      Value<int> sortOrder,
      Value<String?> icon,
      Value<String?> parentId,
      Value<String?> scopeAccountId,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> kind,
      Value<int> level,
      Value<int> sortOrder,
      Value<String?> icon,
      Value<String?> parentId,
      Value<String?> scopeAccountId,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$SesameDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$SesameDatabase db) =>
      db.categories.createAlias('categories__parent_id__categories__id');

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$SesameDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$SesameDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$SesameDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool parentId})
        > {
  $$CategoriesTableTableManager(_$SesameDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> scopeAccountId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                kind: kind,
                level: level,
                sortOrder: sortOrder,
                icon: icon,
                parentId: parentId,
                scopeAccountId: scopeAccountId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String kind,
                required int level,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> scopeAccountId = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                level: level,
                sortOrder: sortOrder,
                icon: icon,
                parentId: parentId,
                scopeAccountId: scopeAccountId,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({parentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (parentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.parentId,
                                referencedTable: $$CategoriesTableReferences
                                    ._parentIdTable(db),
                                referencedColumn: $$CategoriesTableReferences
                                    ._parentIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool parentId})
    >;
typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      required String id,
      required String ledgerId,
      required String txType,
      required String amount,
      required String currencyCode,
      Value<String?> categoryId,
      Value<String?> note,
      required String frequency,
      Value<int> interval,
      Value<int?> dayOfMonth,
      Value<int?> dayOfWeek,
      Value<int?> monthOfYear,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> lastGeneratedDate,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<String> id,
      Value<String> ledgerId,
      Value<String> txType,
      Value<String> amount,
      Value<String> currencyCode,
      Value<String?> categoryId,
      Value<String?> note,
      Value<String> frequency,
      Value<int> interval,
      Value<int?> dayOfMonth,
      Value<int?> dayOfWeek,
      Value<int?> monthOfYear,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<DateTime?> lastGeneratedDate,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$RecurringTransactionsTableReferences
    extends
        BaseReferences<
          _$SesameDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction
        > {
  $$RecurringTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $LedgersTable _ledgerIdTable(_$SesameDatabase db) =>
      db.ledgers.createAlias('recurring_transactions__ledger_id__ledgers__id');

  $$LedgersTableProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<String>('ledger_id')!;

    final manager = $$LedgersTableTableManager(
      $_db,
      $_db.ledgers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<Transaction>>
  _transactionsRefsTable(_$SesameDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'recurring_transactions__id__transactions__recurring_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.recurringId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$SesameDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthOfYear => $composableBuilder(
    column: $table.monthOfYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastGeneratedDate => $composableBuilder(
    column: $table.lastGeneratedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgersTableFilterComposer get ledgerId {
    final $$LedgersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableFilterComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$SesameDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthOfYear => $composableBuilder(
    column: $table.monthOfYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastGeneratedDate => $composableBuilder(
    column: $table.lastGeneratedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgersTableOrderingComposer get ledgerId {
    final $$LedgersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableOrderingComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$SesameDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get monthOfYear => $composableBuilder(
    column: $table.monthOfYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastGeneratedDate => $composableBuilder(
    column: $table.lastGeneratedDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LedgersTableAnnotationComposer get ledgerId {
    final $$LedgersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableAnnotationComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder,
          (RecurringTransaction, $$RecurringTransactionsTableReferences),
          RecurringTransaction,
          PrefetchHooks Function({bool ledgerId, bool transactionsRefs})
        > {
  $$RecurringTransactionsTableTableManager(
    _$SesameDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<String> txType = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<int?> monthOfYear = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> lastGeneratedDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion(
                id: id,
                ledgerId: ledgerId,
                txType: txType,
                amount: amount,
                currencyCode: currencyCode,
                categoryId: categoryId,
                note: note,
                frequency: frequency,
                interval: interval,
                dayOfMonth: dayOfMonth,
                dayOfWeek: dayOfWeek,
                monthOfYear: monthOfYear,
                startDate: startDate,
                endDate: endDate,
                lastGeneratedDate: lastGeneratedDate,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerId,
                required String txType,
                required String amount,
                required String currencyCode,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required String frequency,
                Value<int> interval = const Value.absent(),
                Value<int?> dayOfMonth = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<int?> monthOfYear = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<DateTime?> lastGeneratedDate = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion.insert(
                id: id,
                ledgerId: ledgerId,
                txType: txType,
                amount: amount,
                currencyCode: currencyCode,
                categoryId: categoryId,
                note: note,
                frequency: frequency,
                interval: interval,
                dayOfMonth: dayOfMonth,
                dayOfWeek: dayOfWeek,
                monthOfYear: monthOfYear,
                startDate: startDate,
                endDate: endDate,
                lastGeneratedDate: lastGeneratedDate,
                enabled: enabled,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ledgerId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ledgerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ledgerId,
                                    referencedTable:
                                        $$RecurringTransactionsTableReferences
                                            ._ledgerIdTable(db),
                                    referencedColumn:
                                        $$RecurringTransactionsTableReferences
                                            ._ledgerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          RecurringTransaction,
                          $RecurringTransactionsTable,
                          Transaction
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecurringTransactionsTableReferences
                                  ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $RecurringTransactionsTable,
      RecurringTransaction,
      $$RecurringTransactionsTableFilterComposer,
      $$RecurringTransactionsTableOrderingComposer,
      $$RecurringTransactionsTableAnnotationComposer,
      $$RecurringTransactionsTableCreateCompanionBuilder,
      $$RecurringTransactionsTableUpdateCompanionBuilder,
      (RecurringTransaction, $$RecurringTransactionsTableReferences),
      RecurringTransaction,
      PrefetchHooks Function({bool ledgerId, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required String ledgerId,
      required String txType,
      required String amount,
      required DateTime happenedAt,
      Value<String?> note,
      Value<String?> categoryId,
      Value<bool> excludeFromStats,
      required String currencyCode,
      required String nativeAmount,
      Value<String?> recurringId,
      Value<String?> createdByMemberId,
      Value<String?> lastEditedByMemberId,
      Value<String?> payerMemberId,
      Value<int?> aaMode,
      Value<int> version,
      Value<int?> serverRevision,
      Value<DateTime?> lastEditedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<String> ledgerId,
      Value<String> txType,
      Value<String> amount,
      Value<DateTime> happenedAt,
      Value<String?> note,
      Value<String?> categoryId,
      Value<bool> excludeFromStats,
      Value<String> currencyCode,
      Value<String> nativeAmount,
      Value<String?> recurringId,
      Value<String?> createdByMemberId,
      Value<String?> lastEditedByMemberId,
      Value<String?> payerMemberId,
      Value<int?> aaMode,
      Value<int> version,
      Value<int?> serverRevision,
      Value<DateTime?> lastEditedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TransactionsTableReferences
    extends BaseReferences<_$SesameDatabase, $TransactionsTable, Transaction> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LedgersTable _ledgerIdTable(_$SesameDatabase db) =>
      db.ledgers.createAlias('transactions__ledger_id__ledgers__id');

  $$LedgersTableProcessedTableManager get ledgerId {
    final $_column = $_itemColumn<String>('ledger_id')!;

    final manager = $$LedgersTableTableManager(
      $_db,
      $_db.ledgers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ledgerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringTransactionsTable _recurringIdTable(_$SesameDatabase db) =>
      db.recurringTransactions.createAlias(
        'transactions__recurring_id__recurring_transactions__id',
      );

  $$RecurringTransactionsTableProcessedTableManager? get recurringId {
    final $_column = $_itemColumn<String>('recurring_id');
    if ($_column == null) return null;
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionSplitsTable, List<TransactionSplit>>
  _transactionSplitsRefsTable(_$SesameDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transactionSplits,
        aliasName: 'transactions__id__transaction_splits__transaction_id',
      );

  $$TransactionSplitsTableProcessedTableManager get transactionSplitsRefs {
    final manager = $$TransactionSplitsTableTableManager(
      $_db,
      $_db.transactionSplits,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transactionSplitsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecordEditHistoriesTable, List<RecordEditHistory>>
  _recordEditHistoriesRefsTable(_$SesameDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recordEditHistories,
        aliasName: 'transactions__id__record_edit_histories__record_id',
      );

  $$RecordEditHistoriesTableProcessedTableManager get recordEditHistoriesRefs {
    final manager = $$RecordEditHistoriesTableTableManager(
      $_db,
      $_db.recordEditHistories,
    ).filter((f) => f.recordId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recordEditHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$SesameDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excludeFromStats => $composableBuilder(
    column: $table.excludeFromStats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nativeAmount => $composableBuilder(
    column: $table.nativeAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByMemberId => $composableBuilder(
    column: $table.createdByMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastEditedByMemberId => $composableBuilder(
    column: $table.lastEditedByMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payerMemberId => $composableBuilder(
    column: $table.payerMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aaMode => $composableBuilder(
    column: $table.aaMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastEditedAt => $composableBuilder(
    column: $table.lastEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$LedgersTableFilterComposer get ledgerId {
    final $$LedgersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableFilterComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableFilterComposer get recurringId {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> transactionSplitsRefs(
    Expression<bool> Function($$TransactionSplitsTableFilterComposer f) f,
  ) {
    final $$TransactionSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactionSplits,
      getReferencedColumn: (t) => t.transactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionSplitsTableFilterComposer(
            $db: $db,
            $table: $db.transactionSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recordEditHistoriesRefs(
    Expression<bool> Function($$RecordEditHistoriesTableFilterComposer f) f,
  ) {
    final $$RecordEditHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recordEditHistories,
      getReferencedColumn: (t) => t.recordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecordEditHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.recordEditHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$SesameDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get txType => $composableBuilder(
    column: $table.txType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excludeFromStats => $composableBuilder(
    column: $table.excludeFromStats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nativeAmount => $composableBuilder(
    column: $table.nativeAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByMemberId => $composableBuilder(
    column: $table.createdByMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastEditedByMemberId => $composableBuilder(
    column: $table.lastEditedByMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payerMemberId => $composableBuilder(
    column: $table.payerMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aaMode => $composableBuilder(
    column: $table.aaMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastEditedAt => $composableBuilder(
    column: $table.lastEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$LedgersTableOrderingComposer get ledgerId {
    final $$LedgersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableOrderingComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableOrderingComposer get recurringId {
    final $$RecurringTransactionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableOrderingComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$SesameDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get txType =>
      $composableBuilder(column: $table.txType, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get happenedAt => $composableBuilder(
    column: $table.happenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excludeFromStats => $composableBuilder(
    column: $table.excludeFromStats,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nativeAmount => $composableBuilder(
    column: $table.nativeAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdByMemberId => $composableBuilder(
    column: $table.createdByMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastEditedByMemberId => $composableBuilder(
    column: $table.lastEditedByMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payerMemberId => $composableBuilder(
    column: $table.payerMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aaMode =>
      $composableBuilder(column: $table.aaMode, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get serverRevision => $composableBuilder(
    column: $table.serverRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastEditedAt => $composableBuilder(
    column: $table.lastEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$LedgersTableAnnotationComposer get ledgerId {
    final $$LedgersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ledgerId,
      referencedTable: $db.ledgers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LedgersTableAnnotationComposer(
            $db: $db,
            $table: $db.ledgers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableAnnotationComposer get recurringId {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> transactionSplitsRefs<T extends Object>(
    Expression<T> Function($$TransactionSplitsTableAnnotationComposer a) f,
  ) {
    final $$TransactionSplitsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transactionSplits,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransactionSplitsTableAnnotationComposer(
                $db: $db,
                $table: $db.transactionSplits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recordEditHistoriesRefs<T extends Object>(
    Expression<T> Function($$RecordEditHistoriesTableAnnotationComposer a) f,
  ) {
    final $$RecordEditHistoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recordEditHistories,
          getReferencedColumn: (t) => t.recordId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecordEditHistoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.recordEditHistories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (Transaction, $$TransactionsTableReferences),
          Transaction,
          PrefetchHooks Function({
            bool ledgerId,
            bool recurringId,
            bool transactionSplitsRefs,
            bool recordEditHistoriesRefs,
          })
        > {
  $$TransactionsTableTableManager(_$SesameDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<String> txType = const Value.absent(),
                Value<String> amount = const Value.absent(),
                Value<DateTime> happenedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<bool> excludeFromStats = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> nativeAmount = const Value.absent(),
                Value<String?> recurringId = const Value.absent(),
                Value<String?> createdByMemberId = const Value.absent(),
                Value<String?> lastEditedByMemberId = const Value.absent(),
                Value<String?> payerMemberId = const Value.absent(),
                Value<int?> aaMode = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<DateTime?> lastEditedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                ledgerId: ledgerId,
                txType: txType,
                amount: amount,
                happenedAt: happenedAt,
                note: note,
                categoryId: categoryId,
                excludeFromStats: excludeFromStats,
                currencyCode: currencyCode,
                nativeAmount: nativeAmount,
                recurringId: recurringId,
                createdByMemberId: createdByMemberId,
                lastEditedByMemberId: lastEditedByMemberId,
                payerMemberId: payerMemberId,
                aaMode: aaMode,
                version: version,
                serverRevision: serverRevision,
                lastEditedAt: lastEditedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerId,
                required String txType,
                required String amount,
                required DateTime happenedAt,
                Value<String?> note = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<bool> excludeFromStats = const Value.absent(),
                required String currencyCode,
                required String nativeAmount,
                Value<String?> recurringId = const Value.absent(),
                Value<String?> createdByMemberId = const Value.absent(),
                Value<String?> lastEditedByMemberId = const Value.absent(),
                Value<String?> payerMemberId = const Value.absent(),
                Value<int?> aaMode = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> serverRevision = const Value.absent(),
                Value<DateTime?> lastEditedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                ledgerId: ledgerId,
                txType: txType,
                amount: amount,
                happenedAt: happenedAt,
                note: note,
                categoryId: categoryId,
                excludeFromStats: excludeFromStats,
                currencyCode: currencyCode,
                nativeAmount: nativeAmount,
                recurringId: recurringId,
                createdByMemberId: createdByMemberId,
                lastEditedByMemberId: lastEditedByMemberId,
                payerMemberId: payerMemberId,
                aaMode: aaMode,
                version: version,
                serverRevision: serverRevision,
                lastEditedAt: lastEditedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                ledgerId = false,
                recurringId = false,
                transactionSplitsRefs = false,
                recordEditHistoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionSplitsRefs) db.transactionSplits,
                    if (recordEditHistoriesRefs) db.recordEditHistories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (ledgerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.ledgerId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._ledgerIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._ledgerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (recurringId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recurringId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._recurringIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._recurringIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionSplitsRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          TransactionSplit
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._transactionSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionSplitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.transactionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recordEditHistoriesRefs)
                        await $_getPrefetchedData<
                          Transaction,
                          $TransactionsTable,
                          RecordEditHistory
                        >(
                          currentTable: table,
                          referencedTable: $$TransactionsTableReferences
                              ._recordEditHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).recordEditHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recordId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (Transaction, $$TransactionsTableReferences),
      Transaction,
      PrefetchHooks Function({
        bool ledgerId,
        bool recurringId,
        bool transactionSplitsRefs,
        bool recordEditHistoriesRefs,
      })
    >;
typedef $$TransactionSplitsTableCreateCompanionBuilder =
    TransactionSplitsCompanion Function({
      Value<int> id,
      required String transactionId,
      required String memberId,
      required String amount,
    });
typedef $$TransactionSplitsTableUpdateCompanionBuilder =
    TransactionSplitsCompanion Function({
      Value<int> id,
      Value<String> transactionId,
      Value<String> memberId,
      Value<String> amount,
    });

final class $$TransactionSplitsTableReferences
    extends
        BaseReferences<
          _$SesameDatabase,
          $TransactionSplitsTable,
          TransactionSplit
        > {
  $$TransactionSplitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _transactionIdTable(_$SesameDatabase db) => db
      .transactions
      .createAlias('transaction_splits__transaction_id__transactions__id');

  $$TransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<String>('transaction_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionSplitsTableFilterComposer
    extends Composer<_$SesameDatabase, $TransactionSplitsTable> {
  $$TransactionSplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get transactionId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionSplitsTableOrderingComposer
    extends Composer<_$SesameDatabase, $TransactionSplitsTable> {
  $$TransactionSplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberId => $composableBuilder(
    column: $table.memberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get transactionId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionSplitsTableAnnotationComposer
    extends Composer<_$SesameDatabase, $TransactionSplitsTable> {
  $$TransactionSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberId =>
      $composableBuilder(column: $table.memberId, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get transactionId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionSplitsTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $TransactionSplitsTable,
          TransactionSplit,
          $$TransactionSplitsTableFilterComposer,
          $$TransactionSplitsTableOrderingComposer,
          $$TransactionSplitsTableAnnotationComposer,
          $$TransactionSplitsTableCreateCompanionBuilder,
          $$TransactionSplitsTableUpdateCompanionBuilder,
          (TransactionSplit, $$TransactionSplitsTableReferences),
          TransactionSplit,
          PrefetchHooks Function({bool transactionId})
        > {
  $$TransactionSplitsTableTableManager(
    _$SesameDatabase db,
    $TransactionSplitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionSplitsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> memberId = const Value.absent(),
                Value<String> amount = const Value.absent(),
              }) => TransactionSplitsCompanion(
                id: id,
                transactionId: transactionId,
                memberId: memberId,
                amount: amount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String transactionId,
                required String memberId,
                required String amount,
              }) => TransactionSplitsCompanion.insert(
                id: id,
                transactionId: transactionId,
                memberId: memberId,
                amount: amount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionSplitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.transactionId,
                                referencedTable:
                                    $$TransactionSplitsTableReferences
                                        ._transactionIdTable(db),
                                referencedColumn:
                                    $$TransactionSplitsTableReferences
                                        ._transactionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TransactionSplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $TransactionSplitsTable,
      TransactionSplit,
      $$TransactionSplitsTableFilterComposer,
      $$TransactionSplitsTableOrderingComposer,
      $$TransactionSplitsTableAnnotationComposer,
      $$TransactionSplitsTableCreateCompanionBuilder,
      $$TransactionSplitsTableUpdateCompanionBuilder,
      (TransactionSplit, $$TransactionSplitsTableReferences),
      TransactionSplit,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$RecordEditHistoriesTableCreateCompanionBuilder =
    RecordEditHistoriesCompanion Function({
      Value<int> id,
      required String recordId,
      required int version,
      Value<String?> operatorMemberId,
      required String summary,
      Value<DateTime> createdAt,
    });
typedef $$RecordEditHistoriesTableUpdateCompanionBuilder =
    RecordEditHistoriesCompanion Function({
      Value<int> id,
      Value<String> recordId,
      Value<int> version,
      Value<String?> operatorMemberId,
      Value<String> summary,
      Value<DateTime> createdAt,
    });

final class $$RecordEditHistoriesTableReferences
    extends
        BaseReferences<
          _$SesameDatabase,
          $RecordEditHistoriesTable,
          RecordEditHistory
        > {
  $$RecordEditHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TransactionsTable _recordIdTable(_$SesameDatabase db) => db
      .transactions
      .createAlias('record_edit_histories__record_id__transactions__id');

  $$TransactionsTableProcessedTableManager get recordId {
    final $_column = $_itemColumn<String>('record_id')!;

    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecordEditHistoriesTableFilterComposer
    extends Composer<_$SesameDatabase, $RecordEditHistoriesTable> {
  $$RecordEditHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatorMemberId => $composableBuilder(
    column: $table.operatorMemberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TransactionsTableFilterComposer get recordId {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordEditHistoriesTableOrderingComposer
    extends Composer<_$SesameDatabase, $RecordEditHistoriesTable> {
  $$RecordEditHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatorMemberId => $composableBuilder(
    column: $table.operatorMemberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TransactionsTableOrderingComposer get recordId {
    final $$TransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordEditHistoriesTableAnnotationComposer
    extends Composer<_$SesameDatabase, $RecordEditHistoriesTable> {
  $$RecordEditHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get operatorMemberId => $composableBuilder(
    column: $table.operatorMemberId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TransactionsTableAnnotationComposer get recordId {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recordId,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecordEditHistoriesTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $RecordEditHistoriesTable,
          RecordEditHistory,
          $$RecordEditHistoriesTableFilterComposer,
          $$RecordEditHistoriesTableOrderingComposer,
          $$RecordEditHistoriesTableAnnotationComposer,
          $$RecordEditHistoriesTableCreateCompanionBuilder,
          $$RecordEditHistoriesTableUpdateCompanionBuilder,
          (RecordEditHistory, $$RecordEditHistoriesTableReferences),
          RecordEditHistory,
          PrefetchHooks Function({bool recordId})
        > {
  $$RecordEditHistoriesTableTableManager(
    _$SesameDatabase db,
    $RecordEditHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecordEditHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecordEditHistoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecordEditHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> operatorMemberId = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecordEditHistoriesCompanion(
                id: id,
                recordId: recordId,
                version: version,
                operatorMemberId: operatorMemberId,
                summary: summary,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String recordId,
                required int version,
                Value<String?> operatorMemberId = const Value.absent(),
                required String summary,
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecordEditHistoriesCompanion.insert(
                id: id,
                recordId: recordId,
                version: version,
                operatorMemberId: operatorMemberId,
                summary: summary,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecordEditHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({recordId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (recordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.recordId,
                                referencedTable:
                                    $$RecordEditHistoriesTableReferences
                                        ._recordIdTable(db),
                                referencedColumn:
                                    $$RecordEditHistoriesTableReferences
                                        ._recordIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RecordEditHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $RecordEditHistoriesTable,
      RecordEditHistory,
      $$RecordEditHistoriesTableFilterComposer,
      $$RecordEditHistoriesTableOrderingComposer,
      $$RecordEditHistoriesTableAnnotationComposer,
      $$RecordEditHistoriesTableCreateCompanionBuilder,
      $$RecordEditHistoriesTableUpdateCompanionBuilder,
      (RecordEditHistory, $$RecordEditHistoriesTableReferences),
      RecordEditHistory,
      PrefetchHooks Function({bool recordId})
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      required String baseCurrency,
      required String quoteCurrency,
      required String rateDate,
      required String rate,
      required String source,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<String> baseCurrency,
      Value<String> quoteCurrency,
      Value<String> rateDate,
      Value<String> rate,
      Value<String> source,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$SesameDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$SesameDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$SesameDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $ExchangeRatesTable,
          ExchangeRate,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (
            ExchangeRate,
            BaseReferences<_$SesameDatabase, $ExchangeRatesTable, ExchangeRate>,
          ),
          ExchangeRate,
          PrefetchHooks Function()
        > {
  $$ExchangeRatesTableTableManager(
    _$SesameDatabase db,
    $ExchangeRatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> baseCurrency = const Value.absent(),
                Value<String> quoteCurrency = const Value.absent(),
                Value<String> rateDate = const Value.absent(),
                Value<String> rate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion(
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rateDate: rateDate,
                rate: rate,
                source: source,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String baseCurrency,
                required String quoteCurrency,
                required String rateDate,
                required String rate,
                required String source,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion.insert(
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rateDate: rateDate,
                rate: rate,
                source: source,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $ExchangeRatesTable,
      ExchangeRate,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (
        ExchangeRate,
        BaseReferences<_$SesameDatabase, $ExchangeRatesTable, ExchangeRate>,
      ),
      ExchangeRate,
      PrefetchHooks Function()
    >;
typedef $$ExchangeRateOverridesTableCreateCompanionBuilder =
    ExchangeRateOverridesCompanion Function({
      required String id,
      required String baseCurrency,
      required String quoteCurrency,
      required String rate,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> scopeAccountId,
      Value<int> rowid,
    });
typedef $$ExchangeRateOverridesTableUpdateCompanionBuilder =
    ExchangeRateOverridesCompanion Function({
      Value<String> id,
      Value<String> baseCurrency,
      Value<String> quoteCurrency,
      Value<String> rate,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> scopeAccountId,
      Value<int> rowid,
    });

class $$ExchangeRateOverridesTableFilterComposer
    extends Composer<_$SesameDatabase, $ExchangeRateOverridesTable> {
  $$ExchangeRateOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRateOverridesTableOrderingComposer
    extends Composer<_$SesameDatabase, $ExchangeRateOverridesTable> {
  $$ExchangeRateOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRateOverridesTableAnnotationComposer
    extends Composer<_$SesameDatabase, $ExchangeRateOverridesTable> {
  $$ExchangeRateOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get scopeAccountId => $composableBuilder(
    column: $table.scopeAccountId,
    builder: (column) => column,
  );
}

class $$ExchangeRateOverridesTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $ExchangeRateOverridesTable,
          ExchangeRateOverride,
          $$ExchangeRateOverridesTableFilterComposer,
          $$ExchangeRateOverridesTableOrderingComposer,
          $$ExchangeRateOverridesTableAnnotationComposer,
          $$ExchangeRateOverridesTableCreateCompanionBuilder,
          $$ExchangeRateOverridesTableUpdateCompanionBuilder,
          (
            ExchangeRateOverride,
            BaseReferences<
              _$SesameDatabase,
              $ExchangeRateOverridesTable,
              ExchangeRateOverride
            >,
          ),
          ExchangeRateOverride,
          PrefetchHooks Function()
        > {
  $$ExchangeRateOverridesTableTableManager(
    _$SesameDatabase db,
    $ExchangeRateOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRateOverridesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExchangeRateOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExchangeRateOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> baseCurrency = const Value.absent(),
                Value<String> quoteCurrency = const Value.absent(),
                Value<String> rate = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> scopeAccountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRateOverridesCompanion(
                id: id,
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rate: rate,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                scopeAccountId: scopeAccountId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String baseCurrency,
                required String quoteCurrency,
                required String rate,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> scopeAccountId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRateOverridesCompanion.insert(
                id: id,
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rate: rate,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                scopeAccountId: scopeAccountId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRateOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $ExchangeRateOverridesTable,
      ExchangeRateOverride,
      $$ExchangeRateOverridesTableFilterComposer,
      $$ExchangeRateOverridesTableOrderingComposer,
      $$ExchangeRateOverridesTableAnnotationComposer,
      $$ExchangeRateOverridesTableCreateCompanionBuilder,
      $$ExchangeRateOverridesTableUpdateCompanionBuilder,
      (
        ExchangeRateOverride,
        BaseReferences<
          _$SesameDatabase,
          $ExchangeRateOverridesTable,
          ExchangeRateOverride
        >,
      ),
      ExchangeRateOverride,
      PrefetchHooks Function()
    >;
typedef $$SharedLedgerCategoriesTableCreateCompanionBuilder =
    SharedLedgerCategoriesCompanion Function({
      required String ledgerId,
      required String categoryId,
      required String name,
      required String kind,
      Value<String?> icon,
      Value<int> sortOrder,
      Value<int> level,
      Value<String?> parentId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SharedLedgerCategoriesTableUpdateCompanionBuilder =
    SharedLedgerCategoriesCompanion Function({
      Value<String> ledgerId,
      Value<String> categoryId,
      Value<String> name,
      Value<String> kind,
      Value<String?> icon,
      Value<int> sortOrder,
      Value<int> level,
      Value<String?> parentId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SharedLedgerCategoriesTableFilterComposer
    extends Composer<_$SesameDatabase, $SharedLedgerCategoriesTable> {
  $$SharedLedgerCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SharedLedgerCategoriesTableOrderingComposer
    extends Composer<_$SesameDatabase, $SharedLedgerCategoriesTable> {
  $$SharedLedgerCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SharedLedgerCategoriesTableAnnotationComposer
    extends Composer<_$SesameDatabase, $SharedLedgerCategoriesTable> {
  $$SharedLedgerCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SharedLedgerCategoriesTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $SharedLedgerCategoriesTable,
          SharedLedgerCategory,
          $$SharedLedgerCategoriesTableFilterComposer,
          $$SharedLedgerCategoriesTableOrderingComposer,
          $$SharedLedgerCategoriesTableAnnotationComposer,
          $$SharedLedgerCategoriesTableCreateCompanionBuilder,
          $$SharedLedgerCategoriesTableUpdateCompanionBuilder,
          (
            SharedLedgerCategory,
            BaseReferences<
              _$SesameDatabase,
              $SharedLedgerCategoriesTable,
              SharedLedgerCategory
            >,
          ),
          SharedLedgerCategory,
          PrefetchHooks Function()
        > {
  $$SharedLedgerCategoriesTableTableManager(
    _$SesameDatabase db,
    $SharedLedgerCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedLedgerCategoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SharedLedgerCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SharedLedgerCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> ledgerId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SharedLedgerCategoriesCompanion(
                ledgerId: ledgerId,
                categoryId: categoryId,
                name: name,
                kind: kind,
                icon: icon,
                sortOrder: sortOrder,
                level: level,
                parentId: parentId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ledgerId,
                required String categoryId,
                required String name,
                required String kind,
                Value<String?> icon = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SharedLedgerCategoriesCompanion.insert(
                ledgerId: ledgerId,
                categoryId: categoryId,
                name: name,
                kind: kind,
                icon: icon,
                sortOrder: sortOrder,
                level: level,
                parentId: parentId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SharedLedgerCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $SharedLedgerCategoriesTable,
      SharedLedgerCategory,
      $$SharedLedgerCategoriesTableFilterComposer,
      $$SharedLedgerCategoriesTableOrderingComposer,
      $$SharedLedgerCategoriesTableAnnotationComposer,
      $$SharedLedgerCategoriesTableCreateCompanionBuilder,
      $$SharedLedgerCategoriesTableUpdateCompanionBuilder,
      (
        SharedLedgerCategory,
        BaseReferences<
          _$SesameDatabase,
          $SharedLedgerCategoriesTable,
          SharedLedgerCategory
        >,
      ),
      SharedLedgerCategory,
      PrefetchHooks Function()
    >;
typedef $$SyncChangesTableCreateCompanionBuilder =
    SyncChangesCompanion Function({
      Value<int> id,
      required String entityType,
      required String entityId,
      Value<String?> ledgerId,
      Value<String?> accountId,
      required String action,
      required String payload,
      required DateTime updatedAt,
      Value<DateTime?> pushedAt,
      required String mutationId,
      Value<int?> baseRevision,
    });
typedef $$SyncChangesTableUpdateCompanionBuilder =
    SyncChangesCompanion Function({
      Value<int> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String?> ledgerId,
      Value<String?> accountId,
      Value<String> action,
      Value<String> payload,
      Value<DateTime> updatedAt,
      Value<DateTime?> pushedAt,
      Value<String> mutationId,
      Value<int?> baseRevision,
    });

class $$SyncChangesTableFilterComposer
    extends Composer<_$SesameDatabase, $SyncChangesTable> {
  $$SyncChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pushedAt => $composableBuilder(
    column: $table.pushedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncChangesTableOrderingComposer
    extends Composer<_$SesameDatabase, $SyncChangesTable> {
  $$SyncChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pushedAt => $composableBuilder(
    column: $table.pushedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncChangesTableAnnotationComposer
    extends Composer<_$SesameDatabase, $SyncChangesTable> {
  $$SyncChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get pushedAt =>
      $composableBuilder(column: $table.pushedAt, builder: (column) => column);

  GeneratedColumn<String> get mutationId => $composableBuilder(
    column: $table.mutationId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );
}

class $$SyncChangesTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $SyncChangesTable,
          SyncChange,
          $$SyncChangesTableFilterComposer,
          $$SyncChangesTableOrderingComposer,
          $$SyncChangesTableAnnotationComposer,
          $$SyncChangesTableCreateCompanionBuilder,
          $$SyncChangesTableUpdateCompanionBuilder,
          (
            SyncChange,
            BaseReferences<_$SesameDatabase, $SyncChangesTable, SyncChange>,
          ),
          SyncChange,
          PrefetchHooks Function()
        > {
  $$SyncChangesTableTableManager(_$SesameDatabase db, $SyncChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String?> ledgerId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> pushedAt = const Value.absent(),
                Value<String> mutationId = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
              }) => SyncChangesCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                ledgerId: ledgerId,
                accountId: accountId,
                action: action,
                payload: payload,
                updatedAt: updatedAt,
                pushedAt: pushedAt,
                mutationId: mutationId,
                baseRevision: baseRevision,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String entityType,
                required String entityId,
                Value<String?> ledgerId = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                required String action,
                required String payload,
                required DateTime updatedAt,
                Value<DateTime?> pushedAt = const Value.absent(),
                required String mutationId,
                Value<int?> baseRevision = const Value.absent(),
              }) => SyncChangesCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                ledgerId: ledgerId,
                accountId: accountId,
                action: action,
                payload: payload,
                updatedAt: updatedAt,
                pushedAt: pushedAt,
                mutationId: mutationId,
                baseRevision: baseRevision,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $SyncChangesTable,
      SyncChange,
      $$SyncChangesTableFilterComposer,
      $$SyncChangesTableOrderingComposer,
      $$SyncChangesTableAnnotationComposer,
      $$SyncChangesTableCreateCompanionBuilder,
      $$SyncChangesTableUpdateCompanionBuilder,
      (
        SyncChange,
        BaseReferences<_$SesameDatabase, $SyncChangesTable, SyncChange>,
      ),
      SyncChange,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String deviceId,
      Value<String> serverCursor,
      Value<DateTime?> lastPushAt,
      Value<DateTime?> lastPullAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> deviceId,
      Value<String> serverCursor,
      Value<DateTime?> lastPushAt,
      Value<DateTime?> lastPullAt,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$SesameDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$SesameDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$SesameDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPushAt => $composableBuilder(
    column: $table.lastPushAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$SesameDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$SesameDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> serverCursor = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                deviceId: deviceId,
                serverCursor: serverCursor,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                Value<String> serverCursor = const Value.absent(),
                Value<DateTime?> lastPushAt = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                deviceId: deviceId,
                serverCursor: serverCursor,
                lastPushAt: lastPushAt,
                lastPullAt: lastPullAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$SesameDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$SyncPullErrorsTableCreateCompanionBuilder =
    SyncPullErrorsCompanion Function({
      Value<int> id,
      required String changeId,
      Value<String?> ledgerId,
      required String entityType,
      required String entityId,
      required String action,
      required String rawChangeJson,
      Value<String?> errorClass,
      Value<String?> errorMessage,
      Value<String?> stackTrace,
      required DateTime firstSeenAt,
      required DateTime lastAttemptAt,
      Value<int> attemptCount,
      Value<String?> userAction,
      Value<DateTime?> resolvedAt,
    });
typedef $$SyncPullErrorsTableUpdateCompanionBuilder =
    SyncPullErrorsCompanion Function({
      Value<int> id,
      Value<String> changeId,
      Value<String?> ledgerId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> action,
      Value<String> rawChangeJson,
      Value<String?> errorClass,
      Value<String?> errorMessage,
      Value<String?> stackTrace,
      Value<DateTime> firstSeenAt,
      Value<DateTime> lastAttemptAt,
      Value<int> attemptCount,
      Value<String?> userAction,
      Value<DateTime?> resolvedAt,
    });

class $$SyncPullErrorsTableFilterComposer
    extends Composer<_$SesameDatabase, $SyncPullErrorsTable> {
  $$SyncPullErrorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawChangeJson => $composableBuilder(
    column: $table.rawChangeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorClass => $composableBuilder(
    column: $table.errorClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userAction => $composableBuilder(
    column: $table.userAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncPullErrorsTableOrderingComposer
    extends Composer<_$SesameDatabase, $SyncPullErrorsTable> {
  $$SyncPullErrorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawChangeJson => $composableBuilder(
    column: $table.rawChangeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorClass => $composableBuilder(
    column: $table.errorClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userAction => $composableBuilder(
    column: $table.userAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncPullErrorsTableAnnotationComposer
    extends Composer<_$SesameDatabase, $SyncPullErrorsTable> {
  $$SyncPullErrorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get rawChangeJson => $composableBuilder(
    column: $table.rawChangeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorClass => $composableBuilder(
    column: $table.errorClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userAction => $composableBuilder(
    column: $table.userAction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncPullErrorsTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $SyncPullErrorsTable,
          SyncPullError,
          $$SyncPullErrorsTableFilterComposer,
          $$SyncPullErrorsTableOrderingComposer,
          $$SyncPullErrorsTableAnnotationComposer,
          $$SyncPullErrorsTableCreateCompanionBuilder,
          $$SyncPullErrorsTableUpdateCompanionBuilder,
          (
            SyncPullError,
            BaseReferences<
              _$SesameDatabase,
              $SyncPullErrorsTable,
              SyncPullError
            >,
          ),
          SyncPullError,
          PrefetchHooks Function()
        > {
  $$SyncPullErrorsTableTableManager(
    _$SesameDatabase db,
    $SyncPullErrorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncPullErrorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncPullErrorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncPullErrorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> changeId = const Value.absent(),
                Value<String?> ledgerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> rawChangeJson = const Value.absent(),
                Value<String?> errorClass = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> lastAttemptAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> userAction = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => SyncPullErrorsCompanion(
                id: id,
                changeId: changeId,
                ledgerId: ledgerId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                rawChangeJson: rawChangeJson,
                errorClass: errorClass,
                errorMessage: errorMessage,
                stackTrace: stackTrace,
                firstSeenAt: firstSeenAt,
                lastAttemptAt: lastAttemptAt,
                attemptCount: attemptCount,
                userAction: userAction,
                resolvedAt: resolvedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String changeId,
                Value<String?> ledgerId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String action,
                required String rawChangeJson,
                Value<String?> errorClass = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                required DateTime firstSeenAt,
                required DateTime lastAttemptAt,
                Value<int> attemptCount = const Value.absent(),
                Value<String?> userAction = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
              }) => SyncPullErrorsCompanion.insert(
                id: id,
                changeId: changeId,
                ledgerId: ledgerId,
                entityType: entityType,
                entityId: entityId,
                action: action,
                rawChangeJson: rawChangeJson,
                errorClass: errorClass,
                errorMessage: errorMessage,
                stackTrace: stackTrace,
                firstSeenAt: firstSeenAt,
                lastAttemptAt: lastAttemptAt,
                attemptCount: attemptCount,
                userAction: userAction,
                resolvedAt: resolvedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncPullErrorsTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $SyncPullErrorsTable,
      SyncPullError,
      $$SyncPullErrorsTableFilterComposer,
      $$SyncPullErrorsTableOrderingComposer,
      $$SyncPullErrorsTableAnnotationComposer,
      $$SyncPullErrorsTableCreateCompanionBuilder,
      $$SyncPullErrorsTableUpdateCompanionBuilder,
      (
        SyncPullError,
        BaseReferences<_$SesameDatabase, $SyncPullErrorsTable, SyncPullError>,
      ),
      SyncPullError,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String id,
      required String ledgerId,
      required String entityType,
      required String entityId,
      required String localPayload,
      required String remotePayload,
      required int baseRevision,
      required int remoteRevision,
      required String localMutationId,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> id,
      Value<String> ledgerId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localPayload,
      Value<String> remotePayload,
      Value<int> baseRevision,
      Value<int> remoteRevision,
      Value<String> localMutationId,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$SesameDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePayload => $composableBuilder(
    column: $table.remotePayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localMutationId => $composableBuilder(
    column: $table.localMutationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$SesameDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ledgerId => $composableBuilder(
    column: $table.ledgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePayload => $composableBuilder(
    column: $table.remotePayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localMutationId => $composableBuilder(
    column: $table.localMutationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$SesameDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ledgerId =>
      $composableBuilder(column: $table.ledgerId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localPayload => $composableBuilder(
    column: $table.localPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remotePayload => $composableBuilder(
    column: $table.remotePayload,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteRevision => $composableBuilder(
    column: $table.remoteRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localMutationId => $composableBuilder(
    column: $table.localMutationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$SesameDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(
    _$SesameDatabase db,
    $SyncConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ledgerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localPayload = const Value.absent(),
                Value<String> remotePayload = const Value.absent(),
                Value<int> baseRevision = const Value.absent(),
                Value<int> remoteRevision = const Value.absent(),
                Value<String> localMutationId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                id: id,
                ledgerId: ledgerId,
                entityType: entityType,
                entityId: entityId,
                localPayload: localPayload,
                remotePayload: remotePayload,
                baseRevision: baseRevision,
                remoteRevision: remoteRevision,
                localMutationId: localMutationId,
                status: status,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ledgerId,
                required String entityType,
                required String entityId,
                required String localPayload,
                required String remotePayload,
                required int baseRevision,
                required int remoteRevision,
                required String localMutationId,
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                id: id,
                ledgerId: ledgerId,
                entityType: entityType,
                entityId: entityId,
                localPayload: localPayload,
                remotePayload: remotePayload,
                baseRevision: baseRevision,
                remoteRevision: remoteRevision,
                localMutationId: localMutationId,
                status: status,
                createdAt: createdAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$SesameDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;
typedef $$BackupStateTableCreateCompanionBuilder =
    BackupStateCompanion Function({
      Value<DateTime?> dirtySince,
      Value<DateTime?> lastSuccessAt,
      Value<String?> currentProvider,
      Value<int> id,
    });
typedef $$BackupStateTableUpdateCompanionBuilder =
    BackupStateCompanion Function({
      Value<DateTime?> dirtySince,
      Value<DateTime?> lastSuccessAt,
      Value<String?> currentProvider,
      Value<int> id,
    });

class $$BackupStateTableFilterComposer
    extends Composer<_$SesameDatabase, $BackupStateTable> {
  $$BackupStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get dirtySince => $composableBuilder(
    column: $table.dirtySince,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentProvider => $composableBuilder(
    column: $table.currentProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupStateTableOrderingComposer
    extends Composer<_$SesameDatabase, $BackupStateTable> {
  $$BackupStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get dirtySince => $composableBuilder(
    column: $table.dirtySince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentProvider => $composableBuilder(
    column: $table.currentProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupStateTableAnnotationComposer
    extends Composer<_$SesameDatabase, $BackupStateTable> {
  $$BackupStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get dirtySince => $composableBuilder(
    column: $table.dirtySince,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSuccessAt => $composableBuilder(
    column: $table.lastSuccessAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentProvider => $composableBuilder(
    column: $table.currentProvider,
    builder: (column) => column,
  );

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$BackupStateTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $BackupStateTable,
          BackupStateData,
          $$BackupStateTableFilterComposer,
          $$BackupStateTableOrderingComposer,
          $$BackupStateTableAnnotationComposer,
          $$BackupStateTableCreateCompanionBuilder,
          $$BackupStateTableUpdateCompanionBuilder,
          (
            BackupStateData,
            BaseReferences<
              _$SesameDatabase,
              $BackupStateTable,
              BackupStateData
            >,
          ),
          BackupStateData,
          PrefetchHooks Function()
        > {
  $$BackupStateTableTableManager(_$SesameDatabase db, $BackupStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime?> dirtySince = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> currentProvider = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => BackupStateCompanion(
                dirtySince: dirtySince,
                lastSuccessAt: lastSuccessAt,
                currentProvider: currentProvider,
                id: id,
              ),
          createCompanionCallback:
              ({
                Value<DateTime?> dirtySince = const Value.absent(),
                Value<DateTime?> lastSuccessAt = const Value.absent(),
                Value<String?> currentProvider = const Value.absent(),
                Value<int> id = const Value.absent(),
              }) => BackupStateCompanion.insert(
                dirtySince: dirtySince,
                lastSuccessAt: lastSuccessAt,
                currentProvider: currentProvider,
                id: id,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupStateTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $BackupStateTable,
      BackupStateData,
      $$BackupStateTableFilterComposer,
      $$BackupStateTableOrderingComposer,
      $$BackupStateTableAnnotationComposer,
      $$BackupStateTableCreateCompanionBuilder,
      $$BackupStateTableUpdateCompanionBuilder,
      (
        BackupStateData,
        BaseReferences<_$SesameDatabase, $BackupStateTable, BackupStateData>,
      ),
      BackupStateData,
      PrefetchHooks Function()
    >;
typedef $$RecoveryLogsTableCreateCompanionBuilder =
    RecoveryLogsCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      required String sourceBackupName,
      Value<String?> targetLedgerId,
      required String action,
      required String result,
      Value<String?> detail,
    });
typedef $$RecoveryLogsTableUpdateCompanionBuilder =
    RecoveryLogsCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<String> sourceBackupName,
      Value<String?> targetLedgerId,
      Value<String> action,
      Value<String> result,
      Value<String?> detail,
    });

class $$RecoveryLogsTableFilterComposer
    extends Composer<_$SesameDatabase, $RecoveryLogsTable> {
  $$RecoveryLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceBackupName => $composableBuilder(
    column: $table.sourceBackupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLedgerId => $composableBuilder(
    column: $table.targetLedgerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecoveryLogsTableOrderingComposer
    extends Composer<_$SesameDatabase, $RecoveryLogsTable> {
  $$RecoveryLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceBackupName => $composableBuilder(
    column: $table.sourceBackupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLedgerId => $composableBuilder(
    column: $table.targetLedgerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecoveryLogsTableAnnotationComposer
    extends Composer<_$SesameDatabase, $RecoveryLogsTable> {
  $$RecoveryLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get sourceBackupName => $composableBuilder(
    column: $table.sourceBackupName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetLedgerId => $composableBuilder(
    column: $table.targetLedgerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$RecoveryLogsTableTableManager
    extends
        RootTableManager<
          _$SesameDatabase,
          $RecoveryLogsTable,
          RecoveryLog,
          $$RecoveryLogsTableFilterComposer,
          $$RecoveryLogsTableOrderingComposer,
          $$RecoveryLogsTableAnnotationComposer,
          $$RecoveryLogsTableCreateCompanionBuilder,
          $$RecoveryLogsTableUpdateCompanionBuilder,
          (
            RecoveryLog,
            BaseReferences<_$SesameDatabase, $RecoveryLogsTable, RecoveryLog>,
          ),
          RecoveryLog,
          PrefetchHooks Function()
        > {
  $$RecoveryLogsTableTableManager(_$SesameDatabase db, $RecoveryLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveryLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveryLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveryLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> sourceBackupName = const Value.absent(),
                Value<String?> targetLedgerId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<String?> detail = const Value.absent(),
              }) => RecoveryLogsCompanion(
                id: id,
                createdAt: createdAt,
                sourceBackupName: sourceBackupName,
                targetLedgerId: targetLedgerId,
                action: action,
                result: result,
                detail: detail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String sourceBackupName,
                Value<String?> targetLedgerId = const Value.absent(),
                required String action,
                required String result,
                Value<String?> detail = const Value.absent(),
              }) => RecoveryLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                sourceBackupName: sourceBackupName,
                targetLedgerId: targetLedgerId,
                action: action,
                result: result,
                detail: detail,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecoveryLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$SesameDatabase,
      $RecoveryLogsTable,
      RecoveryLog,
      $$RecoveryLogsTableFilterComposer,
      $$RecoveryLogsTableOrderingComposer,
      $$RecoveryLogsTableAnnotationComposer,
      $$RecoveryLogsTableCreateCompanionBuilder,
      $$RecoveryLogsTableUpdateCompanionBuilder,
      (
        RecoveryLog,
        BaseReferences<_$SesameDatabase, $RecoveryLogsTable, RecoveryLog>,
      ),
      RecoveryLog,
      PrefetchHooks Function()
    >;

class $SesameDatabaseManager {
  final _$SesameDatabase _db;
  $SesameDatabaseManager(this._db);
  $$LedgersTableTableManager get ledgers =>
      $$LedgersTableTableManager(_db, _db.ledgers);
  $$LedgerMembersTableTableManager get ledgerMembers =>
      $$LedgerMembersTableTableManager(_db, _db.ledgerMembers);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$TransactionSplitsTableTableManager get transactionSplits =>
      $$TransactionSplitsTableTableManager(_db, _db.transactionSplits);
  $$RecordEditHistoriesTableTableManager get recordEditHistories =>
      $$RecordEditHistoriesTableTableManager(_db, _db.recordEditHistories);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
  $$ExchangeRateOverridesTableTableManager get exchangeRateOverrides =>
      $$ExchangeRateOverridesTableTableManager(_db, _db.exchangeRateOverrides);
  $$SharedLedgerCategoriesTableTableManager get sharedLedgerCategories =>
      $$SharedLedgerCategoriesTableTableManager(
        _db,
        _db.sharedLedgerCategories,
      );
  $$SyncChangesTableTableManager get syncChanges =>
      $$SyncChangesTableTableManager(_db, _db.syncChanges);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$SyncPullErrorsTableTableManager get syncPullErrors =>
      $$SyncPullErrorsTableTableManager(_db, _db.syncPullErrors);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
  $$BackupStateTableTableManager get backupState =>
      $$BackupStateTableTableManager(_db, _db.backupState);
  $$RecoveryLogsTableTableManager get recoveryLogs =>
      $$RecoveryLogsTableTableManager(_db, _db.recoveryLogs);
}
