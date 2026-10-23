import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart' show DayLimits;
import 'sync_queue_time_migration.dart';

part 'db.g.dart';
part 'database_migration.dart';

/// 同步版本及其墓碑以 UTC 毫秒存储，保留权威时间在持久化往返中的精度。
class MillisecondTimestampConverter extends TypeConverter<DateTime, int> {
  const MillisecondTimestampConverter();
  @override
  DateTime fromSql(int value) {
    try {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    } catch (error, stack) {
      logger.error('Database', '读取毫秒时间失败', safeErrorSummary(error), stack);
      Error.throwWithStackTrace(const FormatException('记录时间格式无效'), stack);
    }
  }

  @override
  int toSql(DateTime value) => value.millisecondsSinceEpoch;
}

/// 分类账号在 SQL 中使用非空键，本地域用空串表示；业务快照仍以 null 表示本地。
class CategoryAccountScopeConverter extends TypeConverter<String?, String> {
  const CategoryAccountScopeConverter();

  @override
  String? fromSql(String value) => value.isEmpty ? null : value;

  @override
  String toSql(String? value) => value ?? '';
}

// ---------------------------------------------------------------------------
// Drift 数据结构（账本成员模型）
//
// 与 API 契约逐字段对齐：
// - 可同步实体使用 UUID 字符串主键，随机或确定性身份按实体契约生成，主键即同步标识
//   （本地与云端同一 id，无独立自增 id）；
// - 金额/汇率为规范化 Decimal 字符串，客户端与 API 同一表示；
// - 协议时间使用 UTC RFC 3339；同步版本以毫秒整数保存，其他日期列按各字段定义存储；
// - 同步删除通过 tombstone 或成员生命周期状态表达；
// - server_cursor / change_id 为服务端 BigInt 十进制字符串，用 TEXT 承载。
//
// 身份模型（LedgerMember 单轨）：
// - 「人」统一是账本成员 ledger_members（设备身份/云账号/虚拟用户三形态收敛为成员）：
//   * LOCAL      本机本地成员（未绑定云端账号；本地账本的「我」）
//   * REGISTERED 云端账号成员（linked_account_id 是可选的本机账号关联缓存）
//   * PLACEHOLDER 占位成员（虚拟用户形态：AA 分摊中的未注册参与人）
// - 交易三作者列与分摊行全部引用 member_id，与登录账号解耦：
//   登录与退出不重写本地账本的历史成员身份。
// ---------------------------------------------------------------------------

// --- 同步实体表 ---

@DataClassName('Ledger', implementing: [LedgerSnapshot])
class Ledgers extends Table {
  /// UUID v4 主键：离线创建时客户端生成，push 后服务端接受同一 id。
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get currency => text().withDefault(const Constant('CNY'))();

  /// 每月起始日为 1–31；当月无该日期时使用当月最后一天。
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

  /// 云账本所有者与当前查看账号分别保存，共享账本的分类始终归所有者。
  TextColumn get ownerAccountId => text().nullable()();

  /// 本人归档时间；为空时账本可从日常入口使用。
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// 本人归档或恢复的更新时间，用于独立同步。
  DateTimeColumn get archiveUpdatedAt => dateTime().nullable()();

  /// 最后修改本人归档状态的设备，用于同时间戳的确定性同步。
  TextColumn get archiveDeviceId => text().nullable()();

  /// 已应用的服务端个人归档游标；以文本保存大整数，随云同步时间线失效。
  TextColumn get archiveServerCursor => text().nullable()();

  /// 云同步时间线身份：同一云端账本的所有设备共享同一 sync_id,
  /// 由服务端生成并在绑定/确认时写入; 本地账本恒为 NULL(无同步身份),
  /// Detach/Fork 时清除 binding 而非生成伪 sync_id。
  TextColumn get syncId => text().nullable()();

  /// 同步绑定状态：NULL/bound = 正常; 'stale' = SYNC_ID_MISMATCH 后
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
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

  /// 本地 tombstone:同步收到 delete 事件时写入,查询默认过滤。
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // CHECK 兜底:越界月界值在数据库层直接拒绝。
    'CHECK (month_start_day BETWEEN 1 AND 31)',
  ];

  @override
  List<Set<Column>> get uniqueKeys => [];
}

/// 账本成员：账务数据引用的「人」。
///
/// 设计意图：member_id 才是账务数据的引用锚点（created_by / payer / split），
/// linked_account_id 只是「该成员当前由哪个云端账号认证」，两者分离后：
/// - 登录/切换账号只更新绑定，历史账单的记账人/付款人语义不变；
/// - 未注册参与人以 PLACEHOLDER 成员存在，日后可绑定账号。
@DataClassName('LedgerMember', implementing: [LedgerMemberSnapshot])
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
  /// PLACEHOLDER=占位成员。
  TextColumn get memberType => text()();

  /// 本机已知的云账号关联；完整同步快照可不含此字段，成员身份仍由 id 保持。
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

  /// 同步与本地编辑使用 UTC 毫秒版本，远端同秒内的先后顺序必须完整保留。
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

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

@DataClassName('Category', implementing: [CategorySnapshot])
class Categories extends Table {
  /// 分类编号只在所属账号内唯一，默认模板可在各账号保存独立内容。
  TextColumn get id => text()();

  TextColumn get name => text()();

  /// 分类类型，固定为 expense。
  TextColumn get kind => text()();

  /// 层级: 1=一级, 2=二级(契约字段 level)。
  IntColumn get level => integer()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  TextColumn get icon => text().nullable()();

  /// 父分类 UUID(契约字段 parent_id)。
  /// 父编号只在同一账号解析，分页尚未到达的父节点保留为待确认关系。
  TextColumn get parentId => text().nullable()();

  /// 账号数据域：null = 本机域；非 null = 云账号 user_id（每账号一份）。
  TextColumn get scopeAccountId => text()
      .map(const CategoryAccountScopeConverter())
      .withDefault(const Constant(''))();

  /// 云端精确版本凭证；离线种子没有凭证，不能冒充已读取云端基线。
  TextColumn get serverVersionToken => text().nullable()();

  /// 当前账号的分类已由云端确认，登记状态与用于并发校验的版本凭证分别维护。
  BoolColumn get cloudRegistered =>
      boolean().withDefault(const Constant(false))();

  /// 已观测的云端状态独立于本机草稿，历史确认回执不能覆盖后来收到的云版本。
  TextColumn get observedCloudState => text().nullable()();

  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

  /// 本地 tombstone。
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id, scopeAccountId};

  @override
  List<String> get customConstraints => [
    "CHECK (kind = 'expense')",
    // CHECK:层级只允许 1/2,同步/导入写入非法层级时数据库直接拒绝。
    'CHECK (level IN (1, 2))',
  ];
}

@DataClassName('Transaction', implementing: [TransactionSnapshot])
class Transactions extends Table {
  /// UUID v4 主键:离线创建时客户端生成。
  TextColumn get id => text()();

  TextColumn get ledgerId =>
      text().references(Ledgers, #id, onDelete: KeyAction.cascade)();

  /// 交易类型，固定为 expense。
  TextColumn get txType => text()();

  /// 交易金额:规范化 Decimal 字符串(positive,≤28 位整数 + ≤10 位小数)。
  TextColumn get amount => text()();

  DateTimeColumn get happenedAt => dateTime()();

  TextColumn get note => text().nullable()();

  /// 分类 UUID 弱引用：共享账本可引用仅存在于 Owner 镜像表的分类。
  TextColumn get categoryId => text().nullable()();

  /// 交易币种(ISO 大写),与 native_amount 成对出现。
  TextColumn get currencyCode => text()();

  /// 折算到账本本位币的金额快照:规范化 Decimal 字符串。
  TextColumn get nativeAmount => text()();

  /// 周期来源保留为弱引用，删除规则不能抹掉历史发生身份。
  TextColumn get recurringId => text().nullable()();

  /// 规则时区的 YYYY-MM-DD，与 recurringId 一起用于跨端发生去重。
  TextColumn get occurrenceDate => text().nullable()();

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

  /// 服务端已知 revision：云端账本交易在推送成功后更新,
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
    "CHECK (tx_type = 'expense')",
    // CHECK:仅允许已定义的分摊模式。
    'CHECK (aa_mode IS NULL OR aa_mode IN (0, 1, 2))',
  ];
}

/// AA 指定分摊关系行(契约 transaction_splits 的本地镜像,aa_mode=2 时落行)。
/// 参与人统一引用成员 id(member_id)；真实/虚拟用户均以成员形态参与。
@DataClassName('TransactionSplit', implementing: [TransactionSplitSnapshot])
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
  List<String> get customConstraints => [
    // 金额不允许空串(规范值校验在 Dart 层,见 decimal 工具)。
    "CHECK (amount <> '')",
  ];
}

/// 记录编辑历史。本地只读历史,不进同步(从属于交易,交易删除时级联清理)。
@DataClassName('RecordEditHistory', implementing: [RecordEditHistorySnapshot])
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

@DataClassName(
  'RecurringTransaction',
  implementing: [RecurringTransactionSnapshot],
)
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

  /// 周期规则统一使用确定性发生协议。
  IntColumn get protocolVersion => integer().withDefault(const Constant(1))();

  /// 持久化 IANA 时区，不随设备旅行或时区切换改变发生日期。
  TextColumn get timeZone => text().withDefault(const Constant('UTC'))();

  IntColumn get interval => integer().withDefault(const Constant(1))();

  IntColumn get dayOfMonth => integer().nullable()();

  IntColumn get dayOfWeek => integer().nullable()();

  IntColumn get monthOfYear => integer().nullable()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();

  DateTimeColumn get lastGeneratedDate => dateTime().nullable()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 规则的 LWW 版本保留服务端毫秒精度，作为下一次人工编辑的时钟基线。
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

  /// 本地 tombstone。
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    "CHECK (tx_type = 'expense')",
    'CHECK (interval >= 1)',
    'CHECK (day_of_month IS NULL OR day_of_month BETWEEN 1 AND 31)',
    'CHECK (day_of_week IS NULL OR day_of_week BETWEEN 1 AND 7)',
    'CHECK (month_of_year IS NULL OR month_of_year BETWEEN 1 AND 12)',
  ];
}

/// 自动汇率本地缓存。日期键 append-only;可随时整表重建 → 不进同步。
/// 方向:1 quote = rate base(与后端汇率源一致)。
@DataClassName('ExchangeRate', implementing: [ExchangeRateSnapshot])
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
/// 方向：1 quote_currency = rate base_currency。
@DataClassName(
  'ExchangeRateOverride',
  implementing: [ExchangeRateOverrideSnapshot],
)
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

  /// 手动汇率版本与同步载荷使用相同的 UTC 毫秒精度。
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

  /// 本地 tombstone。
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();

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

  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

  /// 所有者分类的权威墓碑保留历史内容，选择目录只读取存活镜像。
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();

  @override
  Set<Column> get primaryKey => {ledgerId, categoryId};

  @override
  List<String> get customConstraints => ["CHECK (kind = 'expense')"];
}

/// 日子本与其他私有本共用父本列定义：账号、同步绑定与毫秒审计时间只在私有本父容器维护。
@DataClassName('DayBookRow')
class DayBooks extends PrivateBooks {
  TextColumn get sourceDayBookId => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {sourceDayBookId, sourceOperationId},
  ];

  @override
  List<String> get customConstraints => [
    ...super.customConstraints,
    _dayNameConstraint(),
  ];
}

/// 日子记录保存原始历法定义及校验后的公历投影，不保存派生实例。
@DataClassName('DayEventRow')
class DayEvents extends Table {
  TextColumn get id => text()();
  TextColumn get dayBookId =>
      text().references(DayBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get category => text()();
  TextColumn get name => text()();
  TextColumn get countdownMode => text().nullable()();
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get repeatType => text()();
  TextColumn get statisticType => text()();
  TextColumn get eventCalendarType => text().nullable()();
  IntColumn get eventOriginalYear => integer().nullable()();
  IntColumn get eventOriginalMonth => integer().nullable()();
  IntColumn get eventOriginalDay => integer().nullable()();
  BoolColumn get eventIsLeapMonth => boolean().nullable()();
  TextColumn get eventSolarDate => text().nullable()();
  TextColumn get startCalendarType => text().nullable()();
  IntColumn get startOriginalYear => integer().nullable()();
  IntColumn get startOriginalMonth => integer().nullable()();
  IntColumn get startOriginalDay => integer().nullable()();
  BoolColumn get startIsLeapMonth => boolean().nullable()();
  TextColumn get startSolarDate => text().nullable()();
  TextColumn get endCalendarType => text().nullable()();
  IntColumn get endOriginalYear => integer().nullable()();
  IntColumn get endOriginalMonth => integer().nullable()();
  IntColumn get endOriginalDay => integer().nullable()();
  BoolColumn get endIsLeapMonth => boolean().nullable()();
  TextColumn get endSolarDate => text().nullable()();
  IntColumn get serverRevision => integer().nullable()();
  // 与私有本及其他业务共用毫秒时间语义，CSV/备份往返不被秒精度截断。
  IntColumn get createdAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();
  TextColumn get sourceEventId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    _dayNameConstraint(),
    'CHECK (server_revision IS NULL OR server_revision >= 0)',
    for (final prefix in ['event', 'start', 'end'])
      _dayDateGroupConstraint(prefix),
    "CHECK ((category = 'birthday' AND repeat_type = 'yearly' AND statistic_type IN ('year','day') AND countdown_mode IS NULL AND interval_days IS NULL AND event_solar_date IS NOT NULL AND start_solar_date IS NULL AND end_solar_date IS NULL) OR "
        "(category = 'anniversary' AND repeat_type = 'yearly' AND statistic_type IN ('year','day') AND countdown_mode IS NULL AND interval_days IS NULL AND event_solar_date IS NOT NULL AND start_solar_date IS NULL AND end_solar_date IS NULL) OR "
        "(category = 'countdown' AND countdown_mode IS NOT NULL AND countdown_mode = 'fixed_date' AND repeat_type = 'none' AND statistic_type IN ('day','year') AND interval_days IS NULL AND event_solar_date IS NOT NULL AND start_solar_date IS NULL AND end_solar_date IS NULL) OR "
        "(category = 'countdown' AND countdown_mode IS NOT NULL AND countdown_mode = 'interval_days' AND repeat_type = 'none' AND statistic_type IN ('day','year') AND interval_days IS NOT NULL AND interval_days BETWEEN 1 AND 36500 AND event_solar_date IS NULL AND start_solar_date IS NOT NULL AND end_solar_date IS NULL AND date(start_solar_date, '+' || (interval_days - 1) || ' days') <= '2100-12-31') OR "
        "(category = 'stage' AND repeat_type = 'none' AND statistic_type IN ('year','day') AND countdown_mode IS NULL AND interval_days IS NULL AND event_solar_date IS NULL AND start_solar_date IS NOT NULL AND (end_solar_date IS NULL OR end_solar_date >= start_solar_date)))",
  ];
}

/// 本名与记录名统一限制码点数和边缘空白，保留内部空白。
String _dayNameConstraint() =>
    'CHECK (length(name) BETWEEN 1 AND $maxNameLength AND '
    'name = trim(name, char(${nameWhitespace.runes.join(',')})))';

/// 每个端点整组存在或为空，真实公历及投影匹配显式排除 SQL NULL 放行。
String _dayDateGroupConstraint(String prefix) {
  final columns = [
    'calendar_type',
    'original_year',
    'original_month',
    'original_day',
    'is_leap_month',
    'solar_date',
  ];
  final empty = columns
      .map((field) => '${prefix}_$field IS NULL')
      .join(' AND ');
  final present = columns
      .map((field) => '${prefix}_$field IS NOT NULL')
      .join(' AND ');
  return 'CHECK (($empty) OR ($present AND '
      "${prefix}_calendar_type IN ('solar','lunar') AND "
      '${prefix}_original_year BETWEEN ${DayLimits.minLunarYear} AND ${DayLimits.maxYear} AND '
      '${prefix}_original_month BETWEEN 1 AND 12 AND '
      '${prefix}_original_day BETWEEN 1 AND 31 AND '
      "${prefix}_solar_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]' AND "
      "${prefix}_solar_date BETWEEN '${DayLimits.minYear}-01-01' AND '${DayLimits.maxYear}-12-31' AND "
      "date(${prefix}_solar_date, '+0 days') IS NOT NULL AND "
      "date(${prefix}_solar_date, '+0 days') = ${prefix}_solar_date AND "
      "((${prefix}_calendar_type = 'lunar' AND ${prefix}_original_day <= 30) OR "
      "(${prefix}_calendar_type = 'solar' AND ${prefix}_is_leap_month = 0 AND "
      '${prefix}_original_year >= ${DayLimits.minYear} AND '
      "${prefix}_solar_date = printf('%04d-%02d-%02d', ${prefix}_original_year, ${prefix}_original_month, ${prefix}_original_day)))))";
}

/// CSV 导入事实随目标本保存，删除记录后仍阻止同一文件重新引入。
class DayImportReceipts extends Table {
  TextColumn get targetDayBookId =>
      text().references(DayBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get exportId => text()();
  TextColumn get sourceEntryId => text()();

  /// 记录删除后仍保留去重事实，副本恢复按本内映射转换此身份。
  TextColumn get localEventId => text().nullable()();
  IntColumn get importedAt =>
      integer().map(const MillisecondTimestampConverter())();

  @override
  Set<Column> get primaryKey => {targetDayBookId, exportId, sourceEntryId};
}

// --- 同步基础设施表 ---

abstract class PrivateBooks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get storageMode => text().withDefault(const Constant('local'))();
  TextColumn get scopeAccountId => text().nullable()();
  TextColumn get syncId => text().nullable()();
  IntColumn get serverRevision => integer().nullable()();
  TextColumn get fullCursor => text().nullable()();
  BoolColumn get pendingLocalDelete =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isStale => boolean().withDefault(const Constant(false))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
  TextColumn get sourceAccountId => text().nullable()();
  TextColumn get sourceOperationId => text().nullable()();
  IntColumn get createdAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    "CHECK (length(CAST(name AS BLOB)) > 0)",
    "CHECK ((storage_mode = 'local' AND scope_account_id IS NULL AND sync_id IS NULL AND server_revision IS NULL AND full_cursor IS NULL) OR (storage_mode = 'cloud' AND scope_account_id IS NOT NULL AND server_revision IS NOT NULL AND server_revision >= 0 AND ((sync_id IS NULL AND server_revision = 0 AND full_cursor IS NULL) OR (sync_id IS NOT NULL AND server_revision >= 1))))",
  ];
}

@DataClassName('MemoBookRow')
class MemoBooks extends PrivateBooks {
  TextColumn get type => text()();
  TextColumn get sourceMemoBookId => text().nullable()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {id, type},
    {sourceMemoBookId, sourceOperationId},
  ];
  @override
  List<String> get customConstraints => [
    ...super.customConstraints,
    "CHECK (type IN ('normal','credentials'))",
  ];
}

@DataClassName('FitnessSpaceRow')
class FitnessSpaces extends PrivateBooks {
  TextColumn get sourceFitnessSpaceId => text().nullable()();
  @override
  List<Set<Column>> get uniqueKeys => [
    {sourceFitnessSpaceId, sourceOperationId},
  ];
}

@DataClassName('MemoEntryRow')
class MemoEntries extends Table {
  TextColumn get id => text()();
  TextColumn get memoBookId => text()();
  TextColumn get bookType => text()();
  TextColumn get title => text()();
  TextColumn get bodyFormat => text().nullable()();
  TextColumn get body => text().nullable()();
  IntColumn get orderKey => integer().nullable()();
  IntColumn get serverRevision => integer().nullable()();
  IntColumn get createdAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();
  TextColumn get sourceEntryId => text().nullable()();
  TextColumn get sourceConflictId => text().nullable().unique()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (memo_book_id,book_type) REFERENCES memo_books(id,type) ON DELETE CASCADE',
    'CHECK (server_revision IS NULL OR server_revision >= 0)',
    // 正文按格式互斥：普通笔记是 delta_v1，账号密码卡片的字段列表是 fields_v1。
    "CHECK ((book_type='normal' AND body_format IS NOT NULL AND body_format = 'delta_v1' AND body IS NOT NULL AND json_valid(body) AND order_key IS NULL) OR (book_type='credentials' AND body_format IS NOT NULL AND body_format = 'fields_v1' AND body IS NOT NULL AND json_valid(body) AND order_key IS NOT NULL AND order_key >= 0))",
  ];
}

class MemoImportReceipts extends Table {
  TextColumn get targetMemoBookId =>
      text().references(MemoBooks, #id, onDelete: KeyAction.cascade)();
  TextColumn get exportId => text()();
  TextColumn get sourceBookId => text()();

  /// 空字符串表示源本收据，使空本重导也有幂等事实。
  TextColumn get sourceEntryId => text()();
  TextColumn get fingerprint => text()();
  TextColumn get localEntryId => text().nullable()();
  DateTimeColumn get importedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {
    targetMemoBookId,
    exportId,
    sourceBookId,
    sourceEntryId,
  };
}

// 健身内容始终归属空间；内容快照保持原有训练规则。
@DataClassName('FitnessEntityRow')
class FitnessEntities extends Table {
  TextColumn get id => text()();
  TextColumn get fitnessSpaceId =>
      text().references(FitnessSpaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => text()();
  TextColumn get scopeAccountId => text().nullable()();
  TextColumn get storageMode => text().withDefault(const Constant('local'))();
  TextColumn get syncId => text().nullable()();
  IntColumn get serverRevision => integer().nullable()();
  TextColumn get payload => text()();
  BoolColumn get isStale => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();
  IntColumn get deletedAt =>
      integer().map(const MillisecondTimestampConverter()).nullable()();
  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    "CHECK (entity_type IN ('fitness_template','fitness_plan','fitness_workout','fitness_preferences'))",
    'CHECK (json_valid(payload))',
    "CHECK ((storage_mode='local' AND scope_account_id IS NULL AND sync_id IS NULL AND server_revision IS NULL) OR (storage_mode='cloud' AND scope_account_id IS NOT NULL AND server_revision IS NOT NULL AND server_revision>=0))",
  ];
}

class FitnessImportReceipts extends Table {
  TextColumn get fitnessSpaceId =>
      text().references(FitnessSpaces, #id, onDelete: KeyAction.cascade)();
  TextColumn get exportId => text()();
  TextColumn get entityType => text()();
  TextColumn get sourceId => text()();
  TextColumn get targetId => text()();
  IntColumn get importedAt =>
      integer().map(const MillisecondTimestampConverter())();
  @override
  Set<Column> get primaryKey => {
    fitnessSpaceId,
    exportId,
    entityType,
    sourceId,
  };
}

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

  /// 日子父本边界，与财务 ledger_id 互斥。
  TextColumn get dayBookId => text().nullable()();

  TextColumn get memoBookId => text().nullable()();
  TextColumn get fitnessSpaceId => text().nullable()();

  /// 首次发送前持久化完整请求；未知结果重试只能重放该快照。
  TextColumn get frozenRequest => text().nullable()();

  /// 归属账号（数据域）：未登录时的本地 mutation 为 null，不参与任何账号的推送；
  /// 非 null 时只有该账号的 SyncService 能读取/推送。
  TextColumn get accountId => text().nullable()();

  /// 契约 action: upsert/delete。
  TextColumn get action => text()();

  /// 完整实体 JSON(契约 payload)。
  TextColumn get payload => text()();

  /// 未冻结请求的唯一编辑时间，按 UTC 毫秒保存，正文不承载队列时钟。
  IntColumn get updatedAt =>
      integer().map(const MillisecondTimestampConverter())();

  /// 非 null 表示已推送(服务端确认后清除或标记)。
  DateTimeColumn get pushedAt => dateTime().nullable()();

  /// 服务端确定拒绝后的脱敏原因；非空时保留本地变更，等待修正后重新登记。
  TextColumn get rejectionReason => text().nullable()();

  /// 服务端稳定拒绝码；同步恢复使用错误类别，展示文案只用于向用户解释。
  TextColumn get rejectionCode => text().nullable()();

  /// 幂等键(UUID,契约 mutation_id):离线创建时生成,推送重试复用同一值,
  /// 服务端按 (device_id, mutation_id) 去重,防止网络重试重复落库。
  TextColumn get mutationId => text()();

  /// 乐观并发基线：该 mutation 基于的服务端 revision。
  /// 同实体链式递增(前序 base+1),服务端据此做 CAS 冲突检测。
  IntColumn get baseRevision => integer().nullable()();
}

/// 同步状态表:单设备一行(仅云端一个正式同步协议)。
class SyncState extends Table {
  TextColumn get accountId => text().withDefault(const Constant(''))();
  TextColumn get deviceId => text()();

  /// 服务端全局递增游标；空值表示记账域尚未完成完整快照，合法零水位保存为字符串 0。
  TextColumn get serverCursor => text().nullable()();

  /// 日子域已完整消费的水位；空值表示尚未完成目录屏障。
  TextColumn get dayEventsCursor => text().nullable()();

  TextColumn get memosCursor => text().nullable()();

  TextColumn get fitnessCursor => text().nullable()();

  DateTimeColumn get lastPushAt => dateTime().nullable()();

  DateTimeColumn get lastPullAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {accountId, deviceId};
}

/// sync pull 下发的 change 在本地 apply 抛错时的持久化记录(诊断/重试/跳过)。
class SyncPullErrors extends Table {
  /// 产生该错误的同步账号；未登录或本机私有本拉取失败时为 NULL。；
  TextColumn get accountId => text().nullable()();
  TextColumn get dayBookId => text().nullable()();
  TextColumn get memoBookId => text().nullable()();
  TextColumn get fitnessSpaceId => text().nullable()();
  IntColumn get id => integer().autoIncrement()();

  /// server change_id(BigInt 十进制字符串)。
  TextColumn get changeId => text()();

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

/// 显式冲突存储：push 返回 CONFLICT 或 pull 发现远端版本超前时落库,
/// 保留本地/云端两版 payload 与双方 revision，供冲突 UI 决策。
class SyncConflicts extends Table {
  /// 冲突所属账号；本机私有本的未确认分支没有账号归属，此时为 NULL。
  TextColumn get accountId => text().nullable()();
  TextColumn get dayBookId => text().nullable()();
  TextColumn get memoBookId => text().nullable()();
  TextColumn get fitnessSpaceId => text().nullable()();

  /// 冲突记录主键；分类沿用服务端候选 ID，其他领域使用本地 UUID。
  TextColumn get id => text()();

  /// 冲突所属账本；账号级分类冲突为空。
  TextColumn get ledgerId => text().nullable()();

  /// 冲突实体类型，包含账号级分类及各业务域实体。
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

  /// 分类确认的冻结请求；回执未知时只重放原始决策与幂等身份。
  TextColumn get resolutionRequest => text().nullable()();

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

/// 活动数据库和备份恢复共用的目标版本，已知历史结构由同一迁移流程升级。
const currentSchemaVersion = 10;

/// 结构不完整的数据库拒绝打开，原文件和业务内容保持不变。
const incompleteSchemaMessage = '本机数据库结构不完整，请先保留原文件并从备份恢复；当前数据未修改。';

@DriftDatabase(
  tables: [
    Ledgers,
    DayBooks,
    DayEvents,
    DayImportReceipts,
    MemoBooks,
    MemoEntries,
    MemoImportReceipts,
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
    FitnessEntities,
    FitnessSpaces,
    FitnessImportReceipts,
  ],
)
class SesameDatabase extends _$SesameDatabase {
  SesameDatabase() : super(_openConnection());

  /// 注入数据库执行器，供备份隔离连接和内存测试共用；仍执行同一结构与外键校验。
  SesameDatabase.withExecutor(super.executor);

  /// 活动数据库与备份校验共用当前版本。
  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (!details.wasCreated) await _requireCurrentSchema();
      // SQLite 外键默认关闭,每次连接打开时显式开启,
      // 否则 REFERENCES/ON DELETE 约束不会生效。
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (m) async {
      try {
        // 新建仅接受空库，未标版本但已有业务表的文件必须保留并拒绝打开。
        final existing = await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
        ).get();
        if (existing.isNotEmpty) {
          throw StateError(incompleteSchemaMessage);
        }
        await m.createAll();
        await _createIndexes();
      } catch (error, stackTrace) {
        logger.error(
          'Database',
          '本机数据库创建失败',
          safeErrorSummary(error),
          stackTrace,
        );
        rethrow;
      }
    },
    onUpgrade: (m, from, to) async {
      await _migrateKnownDatabase(m, from, to);
    },
  );

  /// 分类父子查询使用同一账号域索引，编号重复不会跨账号匹配。
  Future<void> _createCategoryIndexes() async {
    await customStatement(
      'CREATE INDEX idx_categories_parent_id ON categories(parent_id)',
    );
    await customStatement(
      'CREATE INDEX idx_categories_scope_parent ON categories(scope_account_id,parent_id)',
    );
  }

  /// 墓碑同样占用发生身份，删除一笔自动交易不能让另一设备重新创建。
  Future<void> _createRecurringOccurrenceIndex() => customStatement(
    'CREATE UNIQUE INDEX idx_transactions_recurring_occurrence '
    'ON transactions(recurring_id, occurrence_date) '
    'WHERE recurring_id IS NOT NULL AND occurrence_date IS NOT NULL',
  );

  /// 活动数据库只接受当前初始结构；不完整结构直接拒绝，不自动修补或清空。
  Future<void> _requireCurrentSchema() async {
    try {
      for (final table in allTables) {
        final columns = await customSelect(
          'PRAGMA table_info("${table.actualTableName}")',
        ).get();
        final names = columns.map((row) => row.read<String>('name')).toSet();
        if (names.length != table.$columns.length ||
            !table.$columns.every((column) => names.contains(column.$name))) {
          throw StateError(incompleteSchemaMessage);
        }
      }
    } catch (error, stackTrace) {
      logger.error('Database', '活动数据库结构检查失败', error, stackTrace);
      rethrow;
    }
  }

  /// 备忘录的查询索引与父本身份不可变触发器。
  static const _memoEntryObjects = [
    'CREATE INDEX idx_memo_entries_created ON memo_entries (memo_book_id,deleted_at,created_at DESC,id)',
    'CREATE INDEX idx_memo_entries_updated ON memo_entries (memo_book_id,deleted_at,updated_at DESC,id)',
    'CREATE INDEX idx_memo_entries_order ON memo_entries (memo_book_id,deleted_at,order_key,id)',
    "CREATE TRIGGER memo_entry_parent_immutable BEFORE UPDATE OF memo_book_id,book_type ON memo_entries WHEN NEW.memo_book_id != OLD.memo_book_id OR NEW.book_type != OLD.book_type BEGIN SELECT RAISE(ABORT,'MEMO_PARENT_IMMUTABLE'); END",
  ];

  /// 首次建库时创建与表定义配套的高频查询索引。
  ///
  /// 账号域索引：
  /// - ledgers(scope_account_id, storage_mode, deleted_at)：列表按账号域+归属+删除过滤；
  /// - sync_changes(account_id, pushed_at, id)：push 队列按账号+未推送+顺序扫描；
  /// - categories(scope_account_id, parent_id)：分类父子树按账号域查询；
  /// - 手工汇率分域 partial unique：「本地域一份、每账号域各一份」，
  ///   SQLite 对 NULL 的普通唯一语义无法表达（NULL 互不相等），必须用 WHERE 子句。
  Future<void> _createIndexes() async {
    await _createRecurringOccurrenceIndex();
    for (final statement in [
      'CREATE INDEX idx_fitness_spaces_scope ON fitness_spaces(scope_account_id,storage_mode,deleted_at,updated_at DESC,id)',
      'CREATE INDEX idx_fitness_changes ON sync_changes(account_id,fitness_space_id,entity_type,entity_id)',
      "CREATE TRIGGER fitness_parent_immutable BEFORE UPDATE OF fitness_space_id ON fitness_entities WHEN NEW.fitness_space_id != OLD.fitness_space_id BEGIN SELECT RAISE(ABORT,'FITNESS_PARENT_IMMUTABLE'); END",
      for (final action in ['INSERT', 'UPDATE'])
        "CREATE TRIGGER fitness_parent_scope_${action.toLowerCase()} BEFORE $action ON fitness_entities WHEN NOT EXISTS (SELECT 1 FROM fitness_spaces b WHERE b.id=NEW.fitness_space_id AND b.storage_mode=NEW.storage_mode AND b.scope_account_id IS NEW.scope_account_id AND (NEW.sync_id IS NULL OR b.sync_id IS NEW.sync_id)) BEGIN SELECT RAISE(ABORT,'FITNESS_PARENT_SCOPE'); END",
      'CREATE INDEX idx_fitness_scope ON fitness_entities(fitness_space_id,entity_type,deleted_at)',
      "CREATE UNIQUE INDEX idx_fitness_running ON fitness_entities(fitness_space_id) WHERE entity_type='fitness_workout' AND deleted_at IS NULL AND json_extract(payload,'\$.status')='in_progress'",
      "CREATE UNIQUE INDEX idx_fitness_occurrence ON fitness_entities(fitness_space_id,json_extract(payload,'\$.occurrence_key')) WHERE entity_type='fitness_workout' AND json_extract(payload,'\$.occurrence_key') IS NOT NULL",
      "CREATE UNIQUE INDEX idx_fitness_preferences ON fitness_entities(fitness_space_id) WHERE entity_type='fitness_preferences' AND deleted_at IS NULL",
      'CREATE INDEX idx_memo_books_scope ON memo_books (scope_account_id,storage_mode,deleted_at,updated_at DESC,id)',
      'CREATE INDEX idx_memo_changes ON sync_changes (account_id,memo_book_id,entity_type,entity_id)',
      "CREATE TRIGGER memo_book_type_immutable BEFORE UPDATE OF type ON memo_books WHEN NEW.type != OLD.type BEGIN SELECT RAISE(ABORT,'MEMO_TYPE_IMMUTABLE'); END",
      ..._memoEntryObjects,
    ]) {
      await customStatement(statement);
    }
    await customStatement(
      "CREATE UNIQUE INDEX idx_sync_pull_errors_account_change ON sync_pull_errors (COALESCE(account_id, ''), change_id)",
    );
    await customStatement(
      'CREATE INDEX idx_day_books_scope_mode ON day_books (scope_account_id, storage_mode, deleted_at)',
    );
    await customStatement(
      'CREATE INDEX idx_day_events_book_category ON day_events (day_book_id, deleted_at, category)',
    );
    await customStatement(
      'CREATE INDEX idx_day_changes_account_book ON sync_changes (account_id, day_book_id, entity_type, entity_id)',
    );
    await customStatement(
      'CREATE INDEX idx_transactions_ledger_happened '
      'ON transactions (ledger_id, happened_at);',
    );
    await customStatement(
      'CREATE INDEX idx_transactions_deleted_at '
      'ON transactions (deleted_at);',
    );
    await customStatement(
      'CREATE INDEX idx_record_edit_histories_record_id '
      'ON record_edit_histories (record_id);',
    );
    await customStatement(
      'CREATE INDEX idx_recurring_transactions_ledger_id '
      'ON recurring_transactions (ledger_id);',
    );
    await customStatement(
      'CREATE UNIQUE INDEX idx_rate_overrides_local_pair '
      'ON exchange_rate_overrides (base_currency, quote_currency) '
      'WHERE scope_account_id IS NULL;',
    );
    await customStatement(
      'CREATE UNIQUE INDEX idx_rate_overrides_account_pair '
      'ON exchange_rate_overrides (scope_account_id, base_currency, quote_currency) '
      'WHERE scope_account_id IS NOT NULL;',
    );
    await customStatement(
      'CREATE INDEX idx_sync_changes_pushed_at '
      'ON sync_changes (pushed_at);',
    );
    await customStatement(
      'CREATE INDEX idx_sync_changes_account_pushed '
      'ON sync_changes (account_id, pushed_at, id);',
    );
    await _createCategoryIndexes();
    await customStatement(
      'CREATE INDEX idx_ledgers_scope_mode '
      'ON ledgers (scope_account_id, storage_mode, deleted_at);',
    );
    await customStatement(
      'CREATE INDEX idx_ledger_members_ledger '
      'ON ledger_members (ledger_id, deleted_at);',
    );
    await customStatement(
      'CREATE INDEX idx_ledger_members_linked_account '
      'ON ledger_members (ledger_id, linked_account_id);',
    );
    await customStatement(
      'CREATE UNIQUE INDEX idx_transaction_splits_member '
      'ON transaction_splits (transaction_id, member_id);',
    );
    await _createOpenConflictIndex();
  }

  /// 分类按来源请求保留独立候选；其他领域仍维持单实体唯一未解决冲突。
  Future<void> _createOpenConflictIndex() async {
    await customStatement(
      'CREATE UNIQUE INDEX idx_sync_conflicts_open '
      "ON sync_conflicts (COALESCE(account_id, ''), entity_type, entity_id) "
      "WHERE status = 'OPEN' AND entity_type <> 'category';",
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
