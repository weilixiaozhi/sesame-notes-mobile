import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'db.g.dart';

// ---------------------------------------------------------------------------
// Drift schema v1（账本成员模型）
//
// 与 API 契约逐字段对齐：
// - 可同步实体统一 UUID v4 字符串主键，离线创建由客户端生成，主键即同步标识
//   （本地与云端同一 id，无独立自增 id）；
// - 金额/汇率为规范化 Decimal 字符串，客户端与 API 同一表示；
// - 时间统一 UTC RFC 3339 毫秒语义存储；
// - 删除走 tombstone：deleted_at 列 + action=delete 同步事件；
// - server_cursor / change_id 为服务端 BigInt 十进制字符串，用 TEXT 承载。
//
// 身份模型（LedgerMember 单轨）：
// - 「人」统一是账本成员 ledger_members（设备身份/云账号/虚拟用户三形态收敛为成员）：
//   * LOCAL      本机本地成员（未绑定云端账号；本地账本的「我」）
//   * REGISTERED 已绑定云端账号的成员（linked_account_id = 云 userId）
//   * PLACEHOLDER 占位成员（虚拟用户形态：AA 分摊中的未注册参与人）
// - 交易三作者列与分摊行全部引用 member_id，与登录账号解耦：
//   登录/退出只改成员行的绑定关系，不改历史业务数据。
// ---------------------------------------------------------------------------

// --- 同步实体表 ---

class Ledgers extends Table {
  /// UUID v4 主键：离线创建时客户端生成，push 后服务端接受同一 id。
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get currency => text().withDefault(const Constant('CNY'))();

  /// 自定义每月起始日(1-28),统计/预算/小部件按 [当月N日, 次月N日) 聚合。
  IntColumn get monthStartDay => integer().withDefault(const Constant(1))();

  /// AA 分摊开关(契约字段 aa_enabled)。
  BoolColumn get aaEnabled => boolean().withDefault(const Constant(false))();

  /// 当前用户在账本中的角色(契约字段 role: owner/editor)。
  TextColumn get role => text().withDefault(const Constant('owner'))();

  /// 成员数(契约字段 member_count)。
  IntColumn get memberCount => integer().withDefault(const Constant(1))();

  /// 账本归属(客户端本地列,不进同步): 'local' = 纯本地账本, 'cloud' = 云端账本。
  TextColumn get storageMode => text().withDefault(const Constant('local'))();

  /// 账号数据域：null = 本地域（LOCAL 账本），非 null = 云账号 user_id。
  /// 登录/登出/换账号按此列隔离，禁止跨账号读取或推送。
  TextColumn get scopeAccountId => text().nullable()();

  /// 云同步时间线身份(3.1): 同一云端账本的所有设备共享同一 sync_id,
  /// 由服务端生成并在绑定/确认时写入; 本地账本恒为 NULL(无同步身份),
  /// Detach/Fork 时清除 binding 而非生成伪 sync_id。
  TextColumn get syncId => text().nullable()();

  /// 同步绑定状态(3.7): NULL/bound = 正常; 'stale' = SYNC_ID_MISMATCH 后
  /// 本地 binding 与云端时间线不一致, 同步暂停等待用户决策(放弃本地/Detach)。
  TextColumn get bindingStatus => text().nullable()();

  /// 本人在该账本中的成员 id（本地账本首次建账本时创建 LOCAL 成员；
  /// 云端账本登录后按 linked_account_id 解析）。身份不随登录变化。
  TextColumn get selfMemberId => text().nullable()();

  /// 溯源:来源类型(CLOUD_BACKUP / LOCAL_BACKUP),仅 provenance,不授予同步语义。
  TextColumn get originType => text().nullable()();

  /// 溯源:来源账本 id(备份里的原始 ledger id)。
  TextColumn get originLedgerId => text().nullable()();

  /// 溯源:备份时来源账本的 sync_id(只读;永不作活跃 sync_id)。
  TextColumn get originSyncId => text().nullable()();

  /// 溯源:来源账号 id(只读;不恢复绑定关系)。
  TextColumn get originAccountId => text().nullable()();

  /// 溯源:来源备份(备份文件 id/名,审计用)。
  TextColumn get originBackupId => text().nullable()();

  /// 溯源:备份时最后服务端 revision(只读;永不作 base_revision)。
  IntColumn get originLastRevision => integer().nullable()();

  /// 溯源:Fork/恢复落盘时间(审计用)。
  DateTimeColumn get detachedAt => dateTime().nullable()();

  /// 本地创建时间(客户端本地列;契约不含 ledger.created_at)。
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 服务端更新时间(同步 LWW 依据)。
  DateTimeColumn get updatedAt => dateTime()();

  /// 本地 tombstone:同步收到 delete 事件时写入,查询默认过滤。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // CHECK 兜底:越界月界值在数据库层直接拒绝。
    'CHECK (month_start_day BETWEEN 1 AND 28)',
  ];

  @override
  List<Set<Column>> get uniqueKeys => [];
}

/// 账本成员（文档 LedgerMember 模型）：账务数据引用的「人」。
///
/// 设计意图：member_id 才是账务数据的引用锚点（created_by / payer / split），
/// linked_account_id 只是「该成员当前由哪个云端账号认证」，两者分离后：
/// - 登录/切换账号只更新绑定，历史账单的记账人/付款人语义不变；
/// - 未注册参与人（原虚拟用户）以 PLACEHOLDER 成员存在，日后可绑定升级。
class LedgerMembers extends Table {
  /// member_id:PLACEHOLDER 复用虚拟用户 v4 id;LOCAL/REGISTERED 用确定性
  /// UUIDv5(ledger_id, 身份键)派生(同账本稳定、跨账本不同)。
  TextColumn get id => text()();

  /// 所属账本;账本删除时成员级联清除。
  TextColumn get ledgerId =>
      text().references(Ledgers, #id, onDelete: KeyAction.cascade)();

  /// 显示名:本地成员由用户维护,云端成员来自服务端成员资料。
  TextColumn get displayName => text()();

  /// 成员类型: LOCAL=本机本地成员, REGISTERED=已绑定云端账号,
  /// PLACEHOLDER=占位成员(原虚拟用户)。
  TextColumn get memberType => text()();

  /// 已绑定的云端账号 userId(REGISTERED 必有;LOCAL 登录后绑定、退出解绑)。
  TextColumn get linkedAccountId => text().nullable()();

  /// 溯源:来源云端成员 id(备份恢复/映射场景保留,不参与认证)。
  TextColumn get originMemberId => text().nullable()();

  /// 溯源:来源云端账号 id(备份恢复/映射场景保留,不参与认证)。
  TextColumn get originAccountId => text().nullable()();

  /// 成员角色(客户端镜像语义,与契约 role 对齐):owner/editor（邀请即编辑，无只读档）。
  TextColumn get role => text().withDefault(const Constant('editor'))();

  /// 云端成员头像(URL + 版本号,version 变化时重新拉取)。
  TextColumn get avatarUrl => text().nullable()();

  IntColumn get avatarVersion => integer().withDefault(const Constant(0))();

  /// 成员生命周期: ACTIVE=正常, LEFT=主动退出, REMOVED=被移出。
  /// 历史账务引用不随状态变化——成员行永不删除。
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();

  /// 加入时间(云端成员取服务端 joined_at)。
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 同步/本地编辑时间(LWW 依据)。
  DateTimeColumn get updatedAt => dateTime()();

  /// 本地 tombstone。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (member_type IN ('LOCAL','REGISTERED','PLACEHOLDER'))",
    "CHECK (role IN ('owner','editor'))",
    "CHECK (status IN ('ACTIVE','LEFT','REMOVED'))",
  ];
}

class Categories extends Table {
  /// UUID v4 主键(user-global 分类,共享账本读取 Owner 的分类)。
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// 契约字段 kind: expense/income/transfer。
  TextColumn get kind => text()();

  /// 层级: 1=一级, 2=二级(契约字段 level)。
  IntColumn get level => integer()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  TextColumn get icon => text().nullable()();

  /// 父分类 UUID(契约字段 parent_id)。
  TextColumn get parentId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 账号数据域：null = 本机域；非 null = 云账号 user_id（每账号一份）。
  TextColumn get scopeAccountId => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  /// 本地 tombstone。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // CHECK:层级只允许 1/2,同步/导入写入非法层级时数据库直接拒绝。
    'CHECK (level IN (1, 2))',
  ];
}

class Transactions extends Table {
  /// UUID v4 主键:离线创建时客户端生成。
  TextColumn get id => text()();

  TextColumn get ledgerId =>
      text().references(Ledgers, #id, onDelete: KeyAction.cascade)();

  /// 契约字段 tx_type: expense/income/transfer。
  TextColumn get txType => text()();

  /// 交易金额:规范化 Decimal 字符串(positive,≤28 位整数 + ≤10 位小数)。
  TextColumn get amount => text()();

  DateTimeColumn get happenedAt => dateTime()();

  TextColumn get note => text().nullable()();

  /// 分类 UUID 弱引用：共享账本可引用仅存在于 Owner 镜像表的分类。
  TextColumn get categoryId => text().nullable()();

  BoolColumn get excludeFromStats =>
      boolean().withDefault(const Constant(false))();

  /// 交易币种(ISO 大写),与 native_amount 成对出现。
  TextColumn get currencyCode => text()();

  /// 折算到账本本位币的金额快照:规范化 Decimal 字符串。
  TextColumn get nativeAmount => text()();

  /// 周期模板 UUID 弱引用。
  TextColumn get recurringId => text().nullable().references(
    RecurringTransactions,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 记账人(创建者)成员 id:引用 ledger_members,与登录账号解耦。
  TextColumn get createdByMemberId => text().nullable()();

  /// 最后编辑人成员 id:引用 ledger_members。
  TextColumn get lastEditedByMemberId => text().nullable()();

  /// 支出人(付款人)成员 id:引用 ledger_members。
  TextColumn get payerMemberId => text().nullable()();

  /// AA 分摊模式: null/0=人均, 1=不分摊, 2=指定金额(契约字段 aa_mode)。
  IntColumn get aaMode => integer().nullable()();

  /// 编辑版本号:创建为 1,每次修改 +1(含删除)。
  IntColumn get version => integer().withDefault(const Constant(1))();

  /// 服务端已知 revision(3.2/3.3):云端账本交易在推送成功后更新,
  /// 本地编辑的 base_revision 与 pull 冲突检测以此为准;本地账本恒为 NULL。
  IntColumn get serverRevision => integer().nullable()();

  DateTimeColumn get lastEditedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  /// 服务端更新时间(同步 LWW 依据)。
  DateTimeColumn get updatedAt => dateTime()();

  /// 本地 tombstone。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // CHECK:仅允许已定义的分摊模式。
    'CHECK (aa_mode IS NULL OR aa_mode IN (0, 1, 2))',
  ];
}

/// AA 指定分摊关系行(契约 transaction_splits 的本地镜像,aa_mode=2 时落行)。
/// 参与人统一引用成员 id(member_id)；真实/虚拟用户均以成员形态参与。
class TransactionSplits extends Table {
  /// 本地自增行标识(纯本地,不参与契约;契约内 splits 以交易内嵌数组传输,无独立 id)。
  IntColumn get id => integer().autoIncrement()();

  /// 所属交易 UUID;交易删除时级联清理。
  TextColumn get transactionId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();

  /// 参与人成员 id:引用 ledger_members。
  TextColumn get memberId => text()();

  /// 分摊金额:规范化 Decimal 字符串(正值,≤28 位整数 + ≤10 位小数)。
  TextColumn get amount => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // 金额不允许空串(规范值校验在 Dart 层,见 decimal 工具)。
    "CHECK (amount <> '')",
  ];
}

/// 记录编辑历史。本地只读历史,不进同步(从属于交易,交易删除时级联清理)。
class RecordEditHistories extends Table {
  /// 本地自增 id(纯本地表,不参与同步契约)。
  IntColumn get id => integer().autoIncrement()();

  TextColumn get recordId =>
      text().references(Transactions, #id, onDelete: KeyAction.cascade)();

  IntColumn get version => integer()();

  /// 操作者成员 id:引用 ledger_members。
  TextColumn get operatorMemberId => text().nullable()();

  TextColumn get summary => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class RecurringTransactions extends Table {
  /// UUID v4 主键(仅经 sync push 创建,客户端生成)。
  TextColumn get id => text()();

  TextColumn get ledgerId =>
      text().references(Ledgers, #id, onDelete: KeyAction.cascade)();

  TextColumn get txType => text()();

  /// 模板金额:规范化 Decimal 字符串。
  TextColumn get amount => text()();

  /// 模板原记账币种。
  TextColumn get currencyCode => text()();

  TextColumn get categoryId => text().nullable()();

  TextColumn get note => text().nullable()();

  /// 重复规则: daily/weekly/monthly/yearly。
  TextColumn get frequency => text()();

  IntColumn get interval => integer().withDefault(const Constant(1))();

  IntColumn get dayOfMonth => integer().nullable()();

  IntColumn get dayOfWeek => integer().nullable()();

  IntColumn get monthOfYear => integer().nullable()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();

  DateTimeColumn get lastGeneratedDate => dateTime().nullable()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime()();

  /// 本地 tombstone。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (interval >= 1)',
    'CHECK (day_of_month IS NULL OR day_of_month BETWEEN 1 AND 31)',
    'CHECK (day_of_week IS NULL OR day_of_week BETWEEN 1 AND 7)',
    'CHECK (month_of_year IS NULL OR month_of_year BETWEEN 1 AND 12)',
  ];
}

/// 自动汇率本地缓存。日期键 append-only;可随时整表重建 → 不进同步。
/// 方向:1 quote = rate base(与后端汇率源一致)。
class ExchangeRates extends Table {
  TextColumn get baseCurrency => text()();

  TextColumn get quoteCurrency => text()();

  TextColumn get rateDate => text()(); // 'YYYY-MM-DD',取源数据自带日期

  TextColumn get rate => text()();

  TextColumn get source => text()(); // 'server'|'fawazahmed0'|'frankfurter'

  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {baseCurrency, quoteCurrency, rateDate};
}

/// 手动汇率覆盖:固定生效直到删除。user-global 同步实体(确定性 UUIDv5 主键)。
/// 方向:1 base_currency = rate quote_currency。
class ExchangeRateOverrides extends Table {
  /// 确定性 UUIDv5 主键:uuidV5(exchangeRateNamespace, `'<账号id>:<BASE>:<QUOTE>'`)
  /// 派生(与服务端 entity-id.ts 同算法),同账号同币对收敛同一实体。
  TextColumn get id => text()();

  @override
  Set<Column> get primaryKey => {id};

  TextColumn get baseCurrency => text()();

  TextColumn get quoteCurrency => text()();

  /// 汇率:规范化 Decimal 字符串(≤20 位整数 + ≤18 位小数)。
  TextColumn get rate => text()();

  DateTimeColumn get updatedAt => dateTime()();

  /// 本地 tombstone。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// 账号数据域：null = 本机域；非 null = 云账号 user_id（每账号一份）。
  TextColumn get scopeAccountId => text().nullable()();
}

/// 共享账本里 Owner 的 user-global 分类镜像。
class SharedLedgerCategories extends Table {
  TextColumn get ledgerId => text()();

  /// Owner 的分类 UUID(契约 category_id)。
  TextColumn get categoryId => text()();

  TextColumn get name => text()();

  TextColumn get kind => text()();

  TextColumn get icon => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  IntColumn get level => integer().withDefault(const Constant(1))();

  /// 父分类 UUID(共享镜像内的父子链)。
  TextColumn get parentId => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ledgerId, categoryId};
}

// --- 同步基础设施表 ---

/// 本地待推送变更队列(契约 Push change 形状)。
class SyncChanges extends Table {
  /// 本地自增队列序号(纯本地)。
  IntColumn get id => integer().autoIncrement()();

  /// 契约 entity_type: ledger/transaction/category/recurring_transaction/
  /// exchange_rate_override/virtual_user。
  TextColumn get entityType => text()();

  /// 契约 entity_id: UUID。
  TextColumn get entityId => text()();

  /// 契约 ledger_id: user-global 实体为 null。
  TextColumn get ledgerId => text().nullable()();

  /// 归属账号（数据域）：null = 无法归属的旧数据（禁止推送）；
  /// 非 null 时只有当前账号的 SyncService 能读取/推送。
  TextColumn get accountId => text().nullable()();

  /// 契约 action: upsert/delete。
  TextColumn get action => text()();

  /// 完整实体 JSON(契约 payload)。
  TextColumn get payload => text()();

  /// 变更时间(UTC,契约 updated_at)。
  DateTimeColumn get updatedAt => dateTime()();

  /// 非 null 表示已推送(服务端确认后清除或标记)。
  DateTimeColumn get pushedAt => dateTime().nullable()();

  /// 幂等键(UUID,契约 mutation_id):离线创建时生成,推送重试复用同一值,
  /// 服务端按 (device_id, mutation_id) 去重,防止网络重试重复落库。
  TextColumn get mutationId => text()();

  /// 乐观并发基线(3.3):该 mutation 基于的服务端 revision。
  /// 同实体链式递增(前序 base+1),服务端据此做 CAS 冲突检测。
  IntColumn get baseRevision => integer().nullable()();
}

/// 同步状态表:单设备一行(仅 Sesame Notes Cloud 一个正式同步协议)。
class SyncState extends Table {
  TextColumn get deviceId => text()();

  /// 服务端全局递增游标:BigInt 十进制字符串,不得用 int 承载。
  TextColumn get serverCursor => text().withDefault(const Constant('0'))();

  DateTimeColumn get lastPushAt => dateTime().nullable()();

  DateTimeColumn get lastPullAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

/// sync pull 下发的 change 在本地 apply 抛错时的持久化记录(诊断/重试/跳过)。
class SyncPullErrors extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// server change_id(BigInt 十进制字符串)。
  TextColumn get changeId => text().unique()();

  TextColumn get ledgerId => text().nullable()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get action => text()(); // upsert / delete

  TextColumn get rawChangeJson => text()();

  TextColumn get errorClass => text().nullable()();

  TextColumn get errorMessage => text().nullable()();

  TextColumn get stackTrace => text().nullable()();

  DateTimeColumn get firstSeenAt => dateTime()();

  DateTimeColumn get lastAttemptAt => dateTime()();

  IntColumn get attemptCount => integer().withDefault(const Constant(1))();

  TextColumn get userAction =>
      text().nullable()(); // null / 'skip' / 'retry_requested'

  DateTimeColumn get resolvedAt => dateTime().nullable()();
}

/// 显式冲突存储(3.3):push 返回 CONFLICT 或 pull 发现远端版本超前时落库,
/// 保留本地/云端两版 payload 与双方 revision,供冲突 UI 决策(3.7)。
class SyncConflicts extends Table {
  /// 冲突记录主键(UUID v4)。
  TextColumn get id => text()();

  /// 冲突所属账本(账本级实体冲突;user 级实体暂不产生冲突)。
  TextColumn get ledgerId => text()();

  /// 冲突实体类型(当前为 transaction)。
  TextColumn get entityType => text()();

  /// 冲突实体 id。
  TextColumn get entityId => text()();

  /// 本地版本(实体 JSON):取冲突实体的最新 pending mutation payload。
  TextColumn get localPayload => text()();

  /// 云端版本(实体 JSON):push 冲突取服务端 current_entity;
  /// delete 冲突以 {"deleted":true,"revision":N} 表达云端已删除。
  TextColumn get remotePayload => text()();

  /// 冲突基线:本地 pending mutation 的 base_revision。
  IntColumn get baseRevision => integer()();

  /// 冲突时云端 revision。
  IntColumn get remoteRevision => integer()();

  /// 产生冲突的本地 mutation id(解决后用于清理 pending 队列)。
  TextColumn get localMutationId => text()();

  /// 冲突状态: OPEN / RESOLVED_LOCAL / RESOLVED_REMOTE。
  TextColumn get status => text().withDefault(const Constant('OPEN'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (status IN ('OPEN','RESOLVED_LOCAL','RESOLVED_REMOTE'))",
  ];
}

/// 恢复审计日志（本地持久化，不依赖云端；每次恢复写一行，供审计）。
class RecoveryLogs extends Table {
  /// 本地自增行标识。
  IntColumn get id => integer().autoIncrement()();

  /// 恢复执行时间（UTC）。
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 来源备份文件名（如 sesame_notes_20260821_021300.snbak）。
  TextColumn get sourceBackupName => text()();

  /// 目标账本 id（恢复为本地/Fork 时为新 ledger id；跳过时为空）。
  TextColumn get targetLedgerId => text().nullable()();

  /// 动作：restore_local / fork_cloud_to_local / skip / reconnect。
  TextColumn get action => text()();

  /// 结果：success / failed。
  TextColumn get result => text()();

  /// 附加信息（失败原因、原账本 id 等，仅审计）。
  TextColumn get detail => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 自动备份的单例状态。
class BackupState extends Table {
  /// 自上次成功备份以来的首次脏时间（null = 无脏数据）。
  DateTimeColumn get dirtySince => dateTime().nullable()();

  /// 最近一次成功备份时间（null = 从未成功）。
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();

  /// 当前自动备份目标（supabase/webdav/s3，null = 未配置）。
  TextColumn get currentProvider => text().nullable()();

  /// 单例哨兵列恒为 0，数据库约束避免并发路径写出多行状态。
  IntColumn get id => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (id = 0)'];
}

@DriftDatabase(
  tables: [
    Ledgers,
    LedgerMembers,
    Categories,
    Transactions,
    TransactionSplits,
    RecordEditHistories,
    RecurringTransactions,
    ExchangeRates,
    ExchangeRateOverrides,
    SharedLedgerCategories,
    SyncChanges,
    SyncState,
    SyncPullErrors,
    SyncConflicts,
    BackupState,
    RecoveryLogs,
  ],
)
class SesameDatabase extends _$SesameDatabase {
  SesameDatabase() : super(_openConnection());

  /// 测试专用:直接注入 [QueryExecutor](通常是 NativeDatabase.memory())。
  SesameDatabase.forTesting(super.executor);

  /// 完整初始 schema：成员单轨、账本溯源与恢复审计均直接建入 v1。
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      // SQLite 外键默认关闭,每次连接打开时显式开启,
      // 否则 REFERENCES/ON DELETE 约束不会生效。
      await customStatement('PRAGMA foreign_keys = ON');
      // 索引收敛对所有存量库幂等生效（IF NOT EXISTS / DROP IF EXISTS）：
      // 旧版全局唯一汇率索引与账号域隔离冲突，必须替换为分域 partial unique。
      await _ensureIndexes();
    },
    onCreate: (m) async {
      await m.createAll();
      await _ensureIndexes();
    },
  );

  /// 高频查询索引（与表定义配套，建库即就绪；beforeOpen 对存量库幂等补齐）。
  ///
  /// 账号域索引（10.5）：
  /// - ledgers(scope_account_id, storage_mode, deleted_at)：列表按账号域+归属+删除过滤；
  /// - sync_changes(account_id, pushed_at, id)：push 队列按账号+未推送+顺序扫描；
  /// - categories(scope_account_id, parent_id)：分类父子树按账号域查询；
  /// - 手工汇率分域 partial unique：「本地域一份、每账号域各一份」，
  ///   SQLite 对 NULL 的普通唯一语义无法表达（NULL 互不相等），必须用 WHERE 子句。
  Future<void> _ensureIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_ledger_happened '
      'ON transactions (ledger_id, happened_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_transactions_deleted_at '
      'ON transactions (deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_record_edit_histories_record_id '
      'ON record_edit_histories (record_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_recurring_transactions_ledger_id '
      'ON recurring_transactions (ledger_id);',
    );
    // 旧版全局唯一汇率索引（base+quote 全库唯一）与「每账号域各一份」冲突：
    // 不同账号的同币对覆盖会被它误拒，先删后建分域 partial unique。
    await customStatement('DROP INDEX IF EXISTS idx_rate_override_pair;');
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_rate_overrides_local_pair '
      'ON exchange_rate_overrides (base_currency, quote_currency) '
      'WHERE scope_account_id IS NULL;',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_rate_overrides_account_pair '
      'ON exchange_rate_overrides (scope_account_id, base_currency, quote_currency) '
      'WHERE scope_account_id IS NOT NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_changes_pushed_at '
      'ON sync_changes (pushed_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_changes_account_pushed '
      'ON sync_changes (account_id, pushed_at, id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_categories_parent_id '
      'ON categories (parent_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_categories_scope_parent '
      'ON categories (scope_account_id, parent_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ledgers_scope_mode '
      'ON ledgers (scope_account_id, storage_mode, deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ledger_members_ledger '
      'ON ledger_members (ledger_id, deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ledger_members_linked_account '
      'ON ledger_members (ledger_id, linked_account_id);',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_transaction_splits_member '
      'ON transaction_splits (transaction_id, member_id);',
    );
    // 同一实体的 OPEN 冲突唯一（部分索引）：解决前不重复创建冲突记录
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_conflicts_open '
      "ON sync_conflicts (entity_type, entity_id) WHERE status = 'OPEN';",
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'sesame_notes.sqlite'));

    // WAL 模式下 -wal/-shm 文件在连接关闭后仍会存在，属正常现象；
    // 数据库仍打开时删除会销毁 WAL 里未落盘的数据。
    return NativeDatabase.createInBackground(file);
  });
}
