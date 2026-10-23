import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/expense_type.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/data/repositories/support/category_field_validation.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/sync/support/lww_conflict.dart';
import 'package:sesame_notes/data/db.dart'
    hide Transaction, Category, RecurringTransaction, ExchangeRateOverride;
import 'sync_runtime.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/sync/storage/category_cloud_state.dart';

/// 记账远端实体到本地表的版本化投影。
class AccountingProjection {
  // 与云端 AnyUuidSchema 保持一致，只校验 UUID 形状，兼容随机和确定性成员 ID。
  static final _memberIdPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  /// 显式注入当前域使用的基础上下文、协作能力和仓储。
  AccountingProjection(this._runtime, this._ports);
  final SyncRuntime _runtime;
  final AccountingProjectionPorts _ports;

  /// 更新云端账本交易的 server_revision（推送成功后服务端权威值）。
  Future<void> updateServerRevision(String entityId, int revision) async {
    await (_runtime.db.update(_runtime.db.transactions)..where(
          (t) =>
              t.id.equals(entityId) &
              (t.serverRevision.isNull() |
                  t.serverRevision.isSmallerThanValue(revision)),
        ))
        .write(TransactionsCompanion(serverRevision: d.Value(revision)));
  }

  /// pull 侧冲突落库：远端修订超前于本地 pending 基线时，
  /// 保留本地最新修改（链尾 payload）与远端版本，禁止直接覆盖。
  Future<void> upsertPullConflict(
    String id,
    List<SyncChange> chain,
    Map<String, dynamic> remotePayload,
    int remoteRevision,
    String action,
  ) async {
    final head = chain.first; // 链首：base 起点（解决冲突的基线）
    final tail = chain.last; // 链尾：本地最新修改
    await _runtime.upsertConflict(
      ledgerId: tail.ledgerId ?? '',
      entityType: 'transaction',
      entityId: id,
      localPayload: tail.action == 'delete'
          ? jsonEncode({
              ...jsonDecode(tail.payload) as Map<String, dynamic>,
              'deleted': true,
            })
          : tail.payload,
      baseRevision: head.baseRevision,
      remoteRevision: remoteRevision,
      remotePayload: action == 'delete'
          ? jsonEncode({'deleted': true, 'revision': remoteRevision})
          : jsonEncode(remotePayload),
      localMutationId: head.mutationId,
    );
  }

  /// 执行applyChange对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyChange(GetSyncPull200ResponseChangesInner change) async {
    // 生成客户端的 Dart 枚举名使用 camelCase，而同步队列与分派契约使用
    // 服务端 wire snake_case；入口统一规范化，避免事件被计数却未实际落库。
    final type = switch (change.entityType.name) {
      'ledgerArchive' => 'ledger_archive',
      'recurringTransaction' => 'recurring_transaction',
      'exchangeRateOverride' => 'exchange_rate_override',
      final name => name,
    };
    final action = change.action.name;
    final entityId = change.entityId;
    // JsonObject 载荷转回普通 Map 供各实体落库方法使用。
    final payload = <String, dynamic>{
      for (final e in change.payload.entries) e.key: e.value?.value,
    };
    if (action == 'delete') {
      // 远端墓碑使用协议时间，设备时钟和传输延迟不能改变历史事实。
      final deletedAt =
          DateTime.tryParse(payload['deleted_at']?.toString() ?? '')?.toUtc() ??
          change.updatedAt.toUtc();
      payload['deleted_at'] = deletedAt.toIso8601String();
    }
    if (type == 'category') {
      await applyCategory(
        entityId,
        action,
        payload,
        eventUpdatedAt: change.updatedAt,
      );
      return;
    }
    if (type == 'ledger') {
      final account = _runtime.currentAccountIdForCloudOperation('确认云账本所有者');
      final owner = payload['owner_id'];
      if (owner is! String || owner.isEmpty) {
        throw SyncOperationFailure(
          code: 'CLOUD_OWNERSHIP_MISSING',
          message: '云端账本的归属信息不完整，请重新同步账本后再试',
          target: SyncTarget('ledger', entityId),
        );
      }
      // 权威所有者独立于编辑时钟；删除先确认目录归属，保护副本才能读取正确的分类来源。
      await (_runtime.db.update(_runtime.db.ledgers)..where(
            (l) =>
                l.id.equals(entityId) &
                l.scopeAccountId.equals(account) &
                l.storageMode.equals('cloud'),
          ))
          .write(
            LedgersCompanion(
              ownerAccountId: d.Value(owner),
              role: d.Value(owner == account ? 'owner' : 'editor'),
            ),
          );
    }
    if (type == 'ledger' && action == 'delete') {
      await _ports.operationsQuarantineLedger(
        entityId,
        _runtime.currentAccountIdForCloudOperation('处理云端删除'),
        deleted: true,
        remoteDeletedAt: _ports.payloadDeleteTime(payload),
      );
      return;
    }
    if (type == 'ledger_archive') {
      if (action != 'upsert' || payload['ledger_id'] != entityId) {
        throw const FormatException('账本归档同步数据无效');
      }
      if ((await _ports.accountingBlockedLedgerIds([
        entityId,
      ])).contains(entityId)) {
        return;
      }
      await applyLedgerArchive(
        entityId,
        archivedAt: payload['archived_at'] == null
            ? null
            : DateTime.parse(payload['archived_at'] as String),
        updatedAt: change.updatedAt,
        remoteDeviceId: change.deviceId,
        serverCursor: change.changeId,
      );
      return;
    }
    // 交易按服务端 revision 裁决；客户端时钟与设备排序不能阻断已提交的新版本。
    if (type == 'transaction') {
      if (action == 'upsert' && payload['ledger_id'] != change.ledgerId) {
        throw const FormatException('交易同步载荷与事件所属账本不一致');
      }
      await applyTransaction(entityId, action, payload);
      return;
    }
    if (type == 'recurring_transaction' && action == 'delete') {
      // 规则删除是服务端确认的终态；历史迁入保留原删除时间，不能按较新的元数据时钟拒绝墓碑。
      // 原规则内容、发生游标和待推送编辑仍保留，后续同步负责确认队列，展示与生成立即遵循墓碑。
      await applyRecurring(entityId, action, payload);
      return;
    }
    // 类型校验先于合并与冲突记录，非法远端数据不能进入任何本地业务分支。
    if (action == 'upsert') {
      switch (type) {
        case 'category':
          requireExpenseType(payload['kind']);
        case 'recurring_transaction':
          requireExpenseType(payload['tx_type']);
          _requireRecurringFormat(payload);
      }
    }

    // LWW 实体存在未推送修改时，交给各实体的应用规则处理本地分支。
    final hasPending = await hasPendingChange(type, entityId);
    if (type == 'recurring_transaction' && action == 'upsert') {
      // 游标是独立的连续发生事实，不能因较旧元数据的 LWW 时间而丢失。
      final incoming = DateTime.tryParse(
        payload['last_generated_date']?.toString() ?? '',
      )?.toUtc();
      final local = await (_runtime.db.select(
        _runtime.db.recurringTransactions,
      )..where((row) => row.id.equals(entityId))).getSingleOrNull();
      if (local != null &&
          incoming != null &&
          (local.lastGeneratedDate == null ||
              incoming.isAfter(local.lastGeneratedDate!))) {
        await (_runtime.db.update(
          _runtime.db.recurringTransactions,
        )..where((row) => row.id.equals(entityId))).write(
          RecurringTransactionsCompanion(lastGeneratedDate: d.Value(incoming)),
        );
      }
      // 未上传的人工编辑保持原副本，游标合并不会把整条远端旧快照覆盖上来。
      if (hasPending) return;
    }
    if (hasPending) {
      final accountId = _runtime.currentAccountIdForCloudOperation('读取未上传记录');
      final rejected =
          await (_runtime.db.select(_runtime.db.syncChanges)
                ..where(
                  (c) =>
                      c.entityType.equals(type) &
                      c.entityId.equals(entityId) &
                      c.pushedAt.isNull() &
                      c.rejectionReason.isNotNull() &
                      c.accountId.equals(accountId),
                )
                ..limit(1))
              .getSingleOrNull();
      // 确定拒绝的本地内容必须留给用户修正，远端 LWW 事件不能覆盖待处理副本。
      if (rejected != null) return;
    }
    final localUpdatedAt = await this.localUpdatedAt(type, entityId);
    // 周期游标事件可晚于元数据修改，LWW 必须比较规则自身的元数据时间。
    final remoteUpdatedAt =
        type == 'recurring_transaction' && action == 'upsert'
        ? DateTime.parse(payload['updated_at'] as String).toUtc()
        : change.updatedAt;
    final shouldApply =
        hasPending ||
        localUpdatedAt == null ||
        !remoteUpdatedAt.isBefore(localUpdatedAt);
    // 增量已经过服务端以真实写入设备完成 LWW 裁决，并按 change_id 顺序投影。
    // 没有待上传编辑时，同毫秒的后续事件就是已接受的新状态；当前读取设备
    // 并非本地行的最后写入者，不能拿它的编号拒绝另一设备的权威事件。
    // 旧页由域游标过滤，更旧的元数据时间仍不能覆盖已观察的本地版本。
    if (!shouldApply) return;

    switch (type) {
      case 'ledger':
        await applyLedger(entityId, action, payload, change.updatedAt);
      case 'exchange_rate_override':
        await applyOverride(entityId, action, payload);
      case 'member':
        await applyMember(
          entityId,
          action,
          payload,
          ledgerId: change.ledgerId ?? '',
          eventUpdatedAt: change.updatedAt,
        );
      case 'recurring_transaction':
        await applyRecurring(entityId, action, payload);
    }
  }

  /// 个人归档独立比较版本，仅更新当前账号已有且仍可见的云账本。
  Future<void> applyLedgerArchive(
    String ledgerId, {
    required DateTime? archivedAt,
    required DateTime? updatedAt,
    required String? remoteDeviceId,
    required String serverCursor,
    bool confirmed = false,
  }) async {
    try {
      if (archivedAt != null && updatedAt == null) {
        throw const FormatException('账本归档版本缺失');
      }
      final accountId = _runtime.currentAccountIdForCloudOperation('同步账本归档');
      final ledger = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((row) => row.id.equals(ledgerId))).getSingleOrNull();
      if (ledger == null ||
          ledger.deletedAt != null ||
          ledger.storageMode != 'cloud' ||
          ledger.scopeAccountId != accountId) {
        return;
      }
      if (!confirmed && await hasPendingChange('ledger_archive', ledgerId)) {
        return;
      }
      final cursor = BigInt.parse(serverCursor);
      if (cursor.isNegative) throw const FormatException('账本归档游标无效');
      final previousCursor = ledger.archiveServerCursor == null
          ? null
          : BigInt.parse(ledger.archiveServerCursor!);
      // 快照和确认都记住已投影的事件位置，分页中断也不能重放旧状态。
      if (!confirmed && previousCursor != null && cursor <= previousCursor) {
        return;
      }
      // 公共账本更新时间及共享成员变更均不参与个人归档的版本裁决。
      // 本地时间列按秒保存，同设备同秒的连续操作由服务端游标顺序决定。
      final sameVersion =
          updatedAt != null &&
          ledger.archiveUpdatedAt?.isAtSameMomentAs(updatedAt) == true &&
          ledger.archiveDeviceId == remoteDeviceId;
      if (!confirmed &&
          updatedAt != null &&
          !sameVersion &&
          !lwwShouldApply(
            localUpdatedAt: ledger.archiveUpdatedAt,
            localDeviceId: ledger.archiveDeviceId,
            remoteUpdatedAt: updatedAt,
            remoteDeviceId: remoteDeviceId,
          )) {
        return;
      }
      await (_runtime.db.update(
        _runtime.db.ledgers,
      )..where((row) => row.id.equals(ledgerId))).write(
        LedgersCompanion(
          archivedAt: d.Value(archivedAt),
          archiveUpdatedAt: d.Value(updatedAt),
          archiveDeviceId: d.Value(remoteDeviceId),
          // full 的全局水位可能较高；确认仍收敛乐观状态，水位保持单调。
          archiveServerCursor: d.Value(
            previousCursor != null && previousCursor > cursor
                ? previousCursor.toString()
                : cursor.toString(),
          ),
        ),
      );
    } catch (error) {
      // 中间层只保留账本上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error(
        'SyncService',
        '同步账本归档失败: $ledgerId',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  /// 该实体是否存在未推送的本地变更（pending 链非空）。
  Future<bool> hasPendingChange(String type, String entityId) async {
    try {
      final accountId = _runtime.currentAccountIdForCloudOperation('读取本地变更状态');
      return await _runtime.pendingChange(type, entityId, accountId) != null;
    } catch (error) {
      // 中间层只保留"哪个实体"的上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error(
        'SyncService',
        '读取本地变更状态失败: $type/$entityId',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  /// 读本地实体行的 updated_at（无行返回 null）。
  Future<DateTime?> localUpdatedAt(String type, String entityId) {
    switch (type) {
      case 'ledger':
        return (_runtime.db.select(_runtime.db.ledgers)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'category':
        return (_runtime.db.select(_runtime.db.categories)..where(
              (t) =>
                  t.id.equals(entityId) &
                  categoryScopePredicate(
                    t,
                    _runtime.currentAccountIdForCloudOperation('读取云分类版本'),
                  ),
            ))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'exchange_rate_override':
        return (_runtime.db.select(_runtime.db.exchangeRateOverrides)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'member':
        // 成员实体以 LedgerMembers 行落库（PLACEHOLDER 同 id）。
        return (_runtime.db.select(_runtime.db.ledgerMembers)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      case 'recurring_transaction':
        return (_runtime.db.select(_runtime.db.recurringTransactions)
              ..where((t) => t.id.equals(entityId)))
            .getSingleOrNull()
            .then((r) => r?.updatedAt);
      default:
        return Future.value(null);
    }
  }

  /// 账本增量携带完整业务字段，确认格式后才覆盖本地投影。
  Future<void> applyLedger(
    String id,
    String action,
    Map<String, dynamic> p,
    DateTime eventUpdatedAt,
  ) async {
    try {
      if (action == 'delete') {
        // tombstone 软删：契约删除走 deleted_at，不靠缺失推断（避免离线副本误复活）。
        await (_runtime.db.update(
          _runtime.db.ledgers,
        )..where((t) => t.id.equals(id))).write(
          LedgersCompanion(deletedAt: d.Value(_ports.payloadDeleteTime(p))),
        );
        return;
      }
      final accountId = _runtime.currentAccountIdForCloudOperation('应用云账本增量');
      final ownerId = p['owner_id'];
      if (ownerId is! String || ownerId.isEmpty) {
        throw SyncOperationFailure(
          code: 'CLOUD_OWNERSHIP_MISSING',
          message: '云端账本的归属信息不完整，请重新同步账本后再试',
          target: SyncTarget('ledger', id),
        );
      }
      final syncId = p['sync_id'];
      if (syncId is! String || syncId.isEmpty) {
        throw const FormatException('账本同步事件缺少有效 sync_id');
      }
      // 创建请求的缺省值由服务端建立；权威快照中的缺失不能当作新的账本设置。
      final name = p['name'];
      if (name is! String || !isValidName(name)) {
        throw const FormatException('账本同步事件缺少有效名称');
      }
      final currency = p['currency'];
      if (currency is! String || !RegExp(r'^[A-Z]{3}$').hasMatch(currency)) {
        throw const FormatException('账本同步事件缺少有效币种');
      }
      final aaEnabled = p['aa_enabled'];
      if (aaEnabled is! bool) {
        throw const FormatException('账本同步事件缺少有效 AA 开关');
      }
      final monthStartDay = p['month_start_day'];
      if (monthStartDay is! num ||
          !monthStartDay.isFinite ||
          monthStartDay % 1 != 0 ||
          monthStartDay < 1 ||
          monthStartDay > 31) {
        throw const FormatException('账本同步事件 month_start_day 必须是 1 到 31 的整数');
      }
      final existing = await (_runtime.db.select(
        _runtime.db.ledgers,
      )..where((ledger) => ledger.id.equals(id))).getSingleOrNull();
      await _runtime.db
          .into(_runtime.db.ledgers)
          .insertOnConflictUpdate(
            LedgersCompanion.insert(
              id: id,
              name: name,
              currency: d.Value(currency),
              monthStartDay: d.Value(monthStartDay.toInt()),
              aaEnabled: d.Value(aaEnabled),
              // 实际所有者决定当前查看者权限，成员数沿用已有缓存值。
              role: d.Value(ownerId == accountId ? 'owner' : 'editor'),
              memberCount: d.Value(existing?.memberCount ?? 1),
              storageMode: const d.Value('cloud'),
              scopeAccountId: d.Value(accountId),
              ownerAccountId: d.Value(ownerId),
              syncId: d.Value(syncId),
              updatedAt: eventUpdatedAt.toUtc(),
              deletedAt: const d.Value(null),
            ),
          );
    } on FormatException catch (error, stackTrace) {
      // 只补充稳定实体身份；事务和同步边界负责回滚、记录与用户提示。
      Error.throwWithStackTrace(
        FormatException('账本同步字段无效：entity=$id；${error.message}'),
        stackTrace,
      );
    }
  }

  /// 解析权威交易快照后按 revision 合并；与完整快照共用原子落库路径。
  Future<void> applyTransaction(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    // 契约交易事件载荷恒携带权威 revision；缺失或非法即拒绝，不做兼容猜测。
    if (action == 'upsert') requireExpenseType(p['tx_type']);
    final rawRevision = p['revision'];
    if (rawRevision is! int || rawRevision < 1) {
      throw const FormatException('交易同步事件 revision 必须是正整数');
    }
    final remoteRevision = rawRevision;
    // 自由形态事件载荷必须先通过交易模型解析，才能参与合并或进入冲突记录。
    // 生成模型会给集合创建空 builder，因此此处显式区分缺失集合与合法空集合。
    final Transaction? transaction;
    if (action == 'upsert') {
      if (p['splits'] is! List) {
        throw const FormatException('交易同步事件缺少 splits 集合');
      }
      transaction = _runtime.deser<Transaction>(
        jsonEncode(p),
        Transaction.serializer,
      );
      if (transaction.id != id) {
        throw const FormatException('交易同步载荷与事件身份不一致');
      }
      validateSplitMembers(transaction);
    } else {
      transaction = null;
    }
    final accountId = _runtime.currentAccountIdForCloudOperation('读取交易变更链');
    // 存在 pending 本地修改的实体遇到更高 remote revision，
    // 不得直接覆盖本地（本地编辑会丢），必须进入 conflict 供 UI 决策。
    final pendingChain =
        await (_runtime.db.select(_runtime.db.syncChanges)
              ..where(
                (c) =>
                    c.entityType.equals('transaction') &
                    c.entityId.equals(id) &
                    c.pushedAt.isNull() &
                    c.accountId.equals(accountId),
              )
              ..orderBy([(t) => d.OrderingTerm.asc(t.id)]))
            .get();
    if (pendingChain.isNotEmpty) {
      final chainHeadBase = pendingChain.first.baseRevision;
      // create 语义（base 为 null，期望实体不存在）：远端已存在即冲突
      if (chainHeadBase == null) {
        if (remoteRevision > 0) {
          await upsertPullConflict(id, pendingChain, p, remoteRevision, action);
        }
        return;
      }
      if (remoteRevision > chainHeadBase) {
        await upsertPullConflict(id, pendingChain, p, remoteRevision, action);
        return;
      }
      // remoteRevision <= 本地基线：该事件已包含在本地修改的基线内，跳过
      return;
    }
    // 无 pending：按 revision 单调应用，旧事件跳过
    final local = await (_runtime.db.select(
      _runtime.db.transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (local?.serverRevision != null &&
        remoteRevision <= local!.serverRevision!) {
      return;
    }
    if (action == 'delete') {
      // tombstone 软删：deleted_at 用事件时间（payload 优先，回退事件 updated_at）。
      await (_runtime.db.update(
        _runtime.db.transactions,
      )..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          deletedAt: d.Value(_ports.payloadDeleteTime(p)),
          serverRevision: d.Value(remoteRevision),
        ),
      );
      return;
    }
    await upsertTransaction(transaction!);
  }

  /// 执行applyCategory对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyCategory(
    String id,
    String action,
    Map<String, dynamic> p, {
    DateTime? eventUpdatedAt,
  }) async {
    final accountId = _runtime.currentAccountIdForCloudOperation('应用云分类增量');
    final ownerId = p['owner_id'];
    if (ownerId is! String || ownerId.isEmpty) {
      throw SyncOperationFailure(
        code: 'CLOUD_OWNERSHIP_MISSING',
        message: '云端分类的归属信息不完整，请重新同步账本后再试',
        target: SyncTarget('category', id),
      );
    }
    if (ownerId != accountId) {
      await _applySharedCategory(
        id,
        action,
        p,
        accountId,
        ownerId,
        eventUpdatedAt,
      );
      return;
    }
    final pending = await _runtime.pendingChange('category', id, accountId);
    if (pending?.rejectionReason != null) return;
    final local =
        await (_runtime.db.select(_runtime.db.categories)..where(
              (c) => c.id.equals(id) & categoryScopePredicate(c, accountId),
            ))
            .getSingleOrNull();
    final incomingAt =
        DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
        eventUpdatedAt;
    if (pending == null &&
        local != null &&
        incomingAt != null &&
        local.updatedAt.isAfter(incomingAt)) {
      return;
    }
    if (action == 'delete' && p['name'] == null) {
      final deletedAt =
          DateTime.tryParse(p['deleted_at']?.toString() ?? '')?.toUtc() ??
          eventUpdatedAt ??
          _ports.payloadDeleteTime(p);
      await _runtime.inAccountTransaction(accountId, () async {
        final current =
            await (_runtime.db.select(_runtime.db.categories)..where(
                  (c) => c.id.equals(id) & categoryScopePredicate(c, accountId),
                ))
                .getSingleOrNull();
        final prior = decodeCategoryCloudState(
          current?.observedCloudState,
          id: id,
          account: accountId,
        );
        if (prior != null &&
            DateTime.parse(prior['updated_at'] as String).isAfter(deletedAt)) {
          return;
        }
        final observed = jsonEncode({
          if (current != null) ...{
            'name': current.name,
            'kind': current.kind,
            'level': current.level.toString(),
            'sort_order': current.sortOrder,
            'icon': current.icon,
            'parent_id': current.parentId,
          },
          ...?prior,
          'id': id,
          'owner_id': accountId,
          'updated_at': deletedAt.toIso8601String(),
          'deleted_at': deletedAt.toIso8601String(),
          'version_token': p['version_token'],
        });
        if (await _hasUnsettledCategoryIntent(id, accountId)) {
          await _markCategoryRegistered(id, accountId, observed);
          return;
        }
        await (_runtime.db.update(_runtime.db.categories)..where(
              (t) => t.id.equals(id) & categoryScopePredicate(t, accountId),
            ))
            .write(
              CategoriesCompanion(
                deletedAt: d.Value(deletedAt),
                updatedAt: d.Value(deletedAt),
                serverVersionToken: d.Value(p['version_token'] as String?),
                cloudRegistered: const d.Value(true),
                observedCloudState: d.Value(observed),
              ),
            );
      });
      return;
    }
    final sortOrder = p['sort_order'];
    if (sortOrder is! num) {
      throw const FormatException('分类同步事件缺少 sort_order');
    }
    // 复用分类写边界的整数及存储范围校验，转换不能改写远端原值。
    validateCategoryFields(sortOrder: sortOrder);
    await _persistCategory(
      CategoriesCompanion.insert(
        id: id,
        cloudRegistered: const d.Value(true),
        name: p['name']?.toString() ?? '',
        kind: requireExpenseType(p['kind']),
        level: _ports.payloadCategoryLevel(p['level']),
        sortOrder: d.Value(sortOrder.toInt()),
        icon: d.Value(p['icon']?.toString()),
        parentId: d.Value(p['parent_id']?.toString()),
        scopeAccountId: d.Value(accountId),
        serverVersionToken: d.Value(p['version_token'] as String?),
        updatedAt:
            DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
            DateTime.now().toUtc(),
        deletedAt: d.Value(
          DateTime.tryParse(p['deleted_at']?.toString() ?? ''),
        ),
      ),
      accountId: accountId,
    );
  }

  /// 所有者目录更新只进入当前账号已下载的共享本镜像，不改动私有分类或其拒收队列。
  Future<void> _applySharedCategory(
    String id,
    String action,
    Map<String, dynamic> payload,
    String account,
    String owner,
    DateTime? eventUpdatedAt,
  ) async {
    try {
      final ledgers =
          await (_runtime.db.select(_runtime.db.ledgers)..where(
                (l) =>
                    l.storageMode.equals('cloud') &
                    l.scopeAccountId.equals(account) &
                    l.ownerAccountId.equals(owner) &
                    l.deletedAt.isNull(),
              ))
              .get();
      final updatedAt =
          DateTime.tryParse(payload['updated_at']?.toString() ?? '')?.toUtc() ??
          eventUpdatedAt;
      if (updatedAt == null) throw const FormatException('共享分类缺少权威版本时间');
      final deletedAt = action == 'delete'
          ? DateTime.tryParse(
                  payload['deleted_at']?.toString() ?? '',
                )?.toUtc() ??
                updatedAt
          : DateTime.tryParse(payload['deleted_at']?.toString() ?? '')?.toUtc();
      for (final ledger in ledgers) {
        final existing =
            await (_runtime.db.select(_runtime.db.sharedLedgerCategories)
                  ..where(
                    (c) =>
                        c.ledgerId.equals(ledger.id) & c.categoryId.equals(id),
                  ))
                .getSingleOrNull();
        if (existing != null && existing.updatedAt.isAfter(updatedAt)) continue;
        if (payload['name'] == null && deletedAt != null) {
          await (_runtime.db.update(_runtime.db.sharedLedgerCategories)..where(
                (c) => c.ledgerId.equals(ledger.id) & c.categoryId.equals(id),
              ))
              .write(
                SharedLedgerCategoriesCompanion(
                  deletedAt: d.Value(deletedAt),
                  updatedAt: d.Value(updatedAt),
                ),
              );
          continue;
        }
        validateCategoryFields(
          sortOrder: payload['sort_order'] as num?,
          icon: payload['icon'] as String?,
        );
        await _runtime.db
            .into(_runtime.db.sharedLedgerCategories)
            .insertOnConflictUpdate(
              SharedLedgerCategoriesCompanion.insert(
                ledgerId: ledger.id,
                categoryId: id,
                name: payload['name'] as String,
                kind: requireExpenseType(payload['kind']),
                level: d.Value(_ports.payloadCategoryLevel(payload['level'])),
                sortOrder: d.Value(payload['sort_order'] as int),
                icon: d.Value(payload['icon'] as String?),
                parentId: d.Value(payload['parent_id'] as String?),
                updatedAt: updatedAt,
                deletedAt: d.Value(deletedAt),
              ),
            );
        if (deletedAt == null) {
          await _runtime.rejectionRecovery.sharedCategoryAvailable(
            id,
            ledger.id,
            account,
          );
        }
      }
    } catch (error, stack) {
      logger.error(
        'SyncService',
        '共享分类镜像应用失败: category=$id',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 执行applyOverride对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyOverride(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    if (action == 'delete') {
      await (_runtime.db.update(
        _runtime.db.exchangeRateOverrides,
      )..where((t) => t.id.equals(id))).write(
        ExchangeRateOverridesCompanion(
          deletedAt: d.Value(_ports.payloadDeleteTime(p)),
        ),
      );
      return;
    }
    final accountId = _runtime.currentAccountIdForCloudOperation('应用云汇率增量');
    await _runtime.db
        .into(_runtime.db.exchangeRateOverrides)
        .insertOnConflictUpdate(
          ExchangeRateOverridesCompanion.insert(
            id: id,
            baseCurrency: p['base_currency']?.toString() ?? '',
            quoteCurrency: p['quote_currency']?.toString() ?? '',
            rate: p['rate']?.toString() ?? '0',
            scopeAccountId: d.Value(accountId),
            updatedAt:
                DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 执行applyMember对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyMember(
    String id,
    String action,
    Map<String, dynamic> p, {
    required String ledgerId,
    required DateTime eventUpdatedAt,
  }) async {
    // 成员实体以 LedgerMembers 行落库（member id 直用）；REST 生命周期事件的
    // member_type/status 是服务端权威快照，缺省值仅兼容占位成员 push 事件。
    if (action == 'delete') {
      try {
        // 历史成员保留原行及引用，权威快照与删除版本一起落库，阻止旧事件复活。
        await (_runtime.db.update(
          _runtime.db.ledgerMembers,
        )..where((t) => t.id.equals(id) & t.ledgerId.equals(ledgerId))).write(
          LedgerMembersCompanion(
            displayName: p['display_name'] == null
                ? const d.Value.absent()
                : d.Value(p['display_name'].toString()),
            memberType: p['member_type'] == null
                ? const d.Value.absent()
                : d.Value(p['member_type'].toString()),
            // 显式 null 表示服务端已清空绑定，缺少字段才保留本地值。
            linkedAccountId: p.containsKey('linked_account_id')
                ? d.Value(p['linked_account_id']?.toString())
                : const d.Value.absent(),
            role: p['role'] == null
                ? const d.Value.absent()
                : d.Value(p['role'].toString()),
            status: d.Value(p['status']?.toString() ?? 'REMOVED'),
            updatedAt: d.Value(
              DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                  eventUpdatedAt.toUtc(),
            ),
          ),
        );
      } catch (error) {
        logger.error('SyncService', '同步成员删除失败: $id', safeErrorSummary(error));
        rethrow;
      }
      return;
    }
    final existing = await (_runtime.db.select(
      _runtime.db.ledgerMembers,
    )..where((member) => member.id.equals(id))).getSingleOrNull();
    final memberType =
        p['member_type']?.toString() ?? existing?.memberType ?? 'PLACEHOLDER';
    final linkedAccountId = p.containsKey('linked_account_id')
        ? p['linked_account_id']?.toString()
        : existing?.linkedAccountId;
    final role = p['role']?.toString() ?? existing?.role ?? 'editor';
    final status = p['status']?.toString() ?? 'ACTIVE';
    final updatedAt =
        DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
        eventUpdatedAt.toUtc();
    await _runtime.db
        .into(_runtime.db.ledgerMembers)
        .insertOnConflictUpdate(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName:
                p['display_name']?.toString() ?? existing?.displayName ?? '',
            memberType: memberType,
            linkedAccountId: d.Value(linkedAccountId),
            role: d.Value(role),
            status: d.Value(status),
            updatedAt: updatedAt,
            // 远端 upsert 表示该成员当前存在，必须清除此前 full 缺失留下的墓碑。
            deletedAt: const d.Value(null),
          ),
        );
    final accountId = _runtime.currentAccountIdForCloudOperation('应用云成员增量');
    if (linkedAccountId == accountId) {
      // 本人生命周期就是本设备的账本访问状态：撤权只隐藏云账本并保留离线
      // 数据，重新受邀 ACTIVE 时同一事件链可恢复显示。
      await (_runtime.db.update(
        _runtime.db.ledgers,
      )..where((ledger) => ledger.id.equals(ledgerId))).write(
        LedgersCompanion(
          selfMemberId: d.Value(id),
          role: d.Value(role),
          deletedAt: status == 'ACTIVE'
              ? const d.Value(null)
              : d.Value(updatedAt),
        ),
      );
    }
  }

  /// 合并游标或元数据前核验格式，不替缺失的协议或时区猜测默认值。
  String _requireRecurringFormat(Map<String, dynamic> payload) {
    final timeZone = payload['time_zone'];
    if (payload['protocol_version'] != recurringProtocolVersion ||
        timeZone is! String) {
      throw const FormatException('周期规则的协议格式无效。');
    }
    recurringLocation(timeZone);
    return timeZone;
  }

  /// 执行applyRecurring对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> applyRecurring(
    String id,
    String action,
    Map<String, dynamic> p,
  ) async {
    if (action == 'delete') {
      await (_runtime.db.update(
        _runtime.db.recurringTransactions,
      )..where((t) => t.id.equals(id))).write(
        RecurringTransactionsCompanion(
          deletedAt: d.Value(_ports.payloadDeleteTime(p)),
        ),
      );
      return;
    }
    final timeZone = _requireRecurringFormat(p);
    final existing = await (_runtime.db.select(
      _runtime.db.recurringTransactions,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    final incomingCursor = DateTime.tryParse(
      p['last_generated_date']?.toString() ?? '',
    )?.toUtc();
    final localCursor = existing?.lastGeneratedDate?.toUtc();
    final cursor =
        localCursor != null &&
            (incomingCursor == null || localCursor.isAfter(incomingCursor))
        ? localCursor
        : incomingCursor;
    await _runtime.db
        .into(_runtime.db.recurringTransactions)
        .insertOnConflictUpdate(
          RecurringTransactionsCompanion.insert(
            id: id,
            ledgerId: p['ledger_id']?.toString() ?? '',
            txType: requireExpenseType(p['tx_type']),
            amount: p['amount']?.toString() ?? '0',
            currencyCode: p['currency_code']?.toString() ?? 'CNY',
            categoryId: d.Value(p['category_id']?.toString()),
            note: d.Value(p['note']?.toString()),
            frequency: p['frequency']?.toString() ?? 'monthly',
            protocolVersion: const d.Value(recurringProtocolVersion),
            timeZone: d.Value(timeZone),
            interval: d.Value((p['interval'] as num?)?.toInt() ?? 1),
            dayOfMonth: d.Value((p['day_of_month'] as num?)?.toInt()),
            dayOfWeek: d.Value((p['day_of_week'] as num?)?.toInt()),
            monthOfYear: d.Value((p['month_of_year'] as num?)?.toInt()),
            startDate:
                DateTime.tryParse(p['start_date']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            endDate: d.Value(
              DateTime.tryParse(p['end_date']?.toString() ?? '')?.toUtc(),
            ),
            lastGeneratedDate: d.Value(cursor),
            enabled: d.Value(p['enabled'] != false),
            updatedAt:
                DateTime.tryParse(p['updated_at']?.toString() ?? '')?.toUtc() ??
                DateTime.now().toUtc(),
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 原子写入权威交易快照与分摊，并对齐服务端 revision。
  Future<void> upsertTransaction(Transaction tx) async {
    try {
      // 全量快照与增量、冲突采用共用同一边界，写入前必须验证全部分摊。
      validateSplitMembers(tx);
      await _runtime.db.transaction(() async {
        // 成员引用直接使用 full 快照输出的 member_id。
        final createdByMemberId = tx.createdByMemberId;
        final lastEditedByMemberId = tx.lastEditedByMemberId;
        final payerMemberId = tx.payerMemberId;
        await _runtime.db
            .into(_runtime.db.transactions)
            .insertOnConflictUpdate(
              TransactionsCompanion.insert(
                id: tx.id,
                ledgerId: tx.ledgerId,
                txType: tx.txType.name,
                amount: tx.amount,
                happenedAt: tx.happenedAt,
                note: d.Value(tx.note),
                categoryId: d.Value(tx.categoryId),
                currencyCode: tx.currencyCode,
                nativeAmount: tx.nativeAmount,
                recurringId: d.Value(tx.recurringId),
                occurrenceDate: d.Value(tx.occurrenceDate?.toString()),
                createdByMemberId: d.Value(createdByMemberId),
                lastEditedByMemberId: d.Value(lastEditedByMemberId),
                payerMemberId: d.Value(payerMemberId),
                // 枚举名是 n0/n1/n2（生成器对数值枚举的 Dart 命名），
                // wire 值才是 0/1/2：按枚举身份映射，不能解析枚举名；
                // 通配分支同时覆盖 null 与未来新增的未知枚举值。
                aaMode: d.Value(switch (tx.aaMode) {
                  TransactionAaModeEnum.n0 => 0,
                  TransactionAaModeEnum.n1 => 1,
                  TransactionAaModeEnum.n2 => 2,
                  _ => null,
                }),
                // 本地编辑计数列：全量快照以服务端 revision 对齐
                version: d.Value(tx.revision),
                serverRevision: d.Value(tx.revision),
                lastEditedAt: d.Value(tx.lastEditedAt),
                createdAt: tx.createdAt,
                updatedAt: tx.updatedAt,
                deletedAt: const d.Value(null),
              ),
            );
        // 指定分摊整批替换:客户端模型 tx.splits 即契约 TransactionSplit 列表。
        await (_runtime.db.delete(
          _runtime.db.transactionSplits,
        )..where((s) => s.transactionId.equals(tx.id))).go();
        if (tx.splits.isNotEmpty) {
          final splitRows = [
            for (final s in tx.splits)
              TransactionSplitsCompanion.insert(
                transactionId: tx.id,
                memberId: s.memberId,
                amount: s.amount,
              ),
          ];
          await _runtime.db.batch(
            (b) => b.insertAll(_runtime.db.transactionSplits, splitRows),
          );
        }
      });
    } catch (error) {
      // 中间层只保留交易上下文与脱敏摘要，堆栈由承载异常的源头记录。
      logger.error('SyncService', '交易落库失败: ${tx.id}', safeErrorSummary(error));
      rethrow;
    }
  }

  /// 校验分摊的成员身份；成员资料可稍后同步，合法引用必须完整保留。
  void validateSplitMembers(Transaction tx) {
    try {
      for (var index = 0; index < tx.splits.length; index++) {
        if (!_memberIdPattern.hasMatch(tx.splits[index].memberId)) {
          throw FormatException('交易分摊 splits[$index].member_id 必须是有效 UUID');
        }
      }
    } catch (error) {
      logger.error(
        'SyncService',
        '交易分摊校验失败: ${tx.id}',
        safeErrorSummary(error),
      );
      rethrow;
    }
  }

  /// 执行upsertCategory对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> upsertCategory(Category cat, {required String accountId}) async {
    if (cat.ownerId != accountId) {
      throw SyncOperationFailure(
        code: 'CLOUD_OWNERSHIP_MISMATCH',
        message: '云端分类归属与当前账号不一致，请确认账号并重新同步',
        target: SyncTarget('category', cat.id),
      );
    }
    await _persistCategory(
      CategoriesCompanion.insert(
        id: cat.id,
        cloudRegistered: const d.Value(true),
        name: cat.name,
        kind: requireExpenseType(cat.kind.name),
        // 生成客户端用 n1/n2 作为 Dart enum 名，wire value 才是 1/2。
        level: cat.level == CategoryLevelEnum.n1 ? 1 : 2,
        sortOrder: d.Value(cat.sortOrder),
        icon: d.Value(cat.icon),
        parentId: d.Value(cat.parentId),
        scopeAccountId: d.Value(accountId),
        updatedAt: cat.updatedAt,
        serverVersionToken: d.Value(cat.versionToken),
        deletedAt: d.Value(cat.deletedAt),
      ),
      accountId: accountId,
    );
  }

  /// 增量、完整快照与确认回执共用原子分类写入及依赖恢复，墓碑保持拒绝状态。
  Future<void> _persistCategory(
    CategoriesCompanion category, {
    required String accountId,
  }) async {
    try {
      await _runtime.inAccountTransaction(accountId, () async {
        // 网络返回期间仍允许本机编辑，落库前必须在同一事务复核待传意图和人工确认。
        // 未确认的本机正文与原并发基线保持可见，云端登记事实单独维护。
        final observed = jsonEncode({
          'id': category.id.value,
          'owner_id': accountId,
          'name': category.name.value,
          'kind': category.kind.value,
          'level': category.level.value.toString(),
          'sort_order': category.sortOrder.value,
          'icon': category.icon.value,
          'parent_id': category.parentId.value,
          'updated_at': category.updatedAt.value.toUtc().toIso8601String(),
          'deleted_at': category.deletedAt.value?.toUtc().toIso8601String(),
          'version_token': category.serverVersionToken.value,
        });
        final current =
            await (_runtime.db.select(_runtime.db.categories)..where(
                  (c) =>
                      c.id.equals(category.id.value) &
                      categoryScopePredicate(c, accountId),
                ))
                .getSingleOrNull();
        final prior = decodeCategoryCloudState(
          current?.observedCloudState,
          id: category.id.value,
          account: accountId,
        );
        if (prior != null &&
            DateTime.parse(
              prior['updated_at'] as String,
            ).isAfter(category.updatedAt.value)) {
          if (!await _hasUnsettledCategoryIntent(
            category.id.value,
            accountId,
          )) {
            // 原来源已确认且没有本机后继时，界面采用已观测的新云态，不能留下已确认草稿。
            await upsertCategory(
              _runtime.deser(jsonEncode(prior), Category.serializer),
              accountId: accountId,
            );
          }
          return;
        }
        if (current != null &&
            await _hasUnsettledCategoryIntent(category.id.value, accountId)) {
          await _markCategoryRegistered(category.id.value, accountId, observed);
          return;
        }
        await _runtime.db
            .into(_runtime.db.categories)
            .insertOnConflictUpdate(
              category.copyWith(observedCloudState: d.Value(observed)),
            );
        if (category.deletedAt.value == null) {
          await _runtime.rejectionRecovery.categoryAvailable(
            category.id.value,
            accountId,
          );
        }
      });
    } catch (error, stack) {
      logger.error(
        'SyncService',
        '写入权威分类失败: category=${category.id.value}',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 在分类落库事务内读取未确认正文和人工决策，账号外的同编号意图不能阻断当前投影。
  Future<bool> _hasUnsettledCategoryIntent(String id, String accountId) async {
    if (await _runtime.pendingChange('category', id, accountId) != null) {
      return true;
    }
    final conflict =
        await (_runtime.db.select(_runtime.db.syncConflicts)
              ..where(
                (c) =>
                    c.accountId.equals(accountId) &
                    c.entityType.equals('category') &
                    c.entityId.equals(id) &
                    c.status.equals('OPEN'),
              )
              ..limit(1))
            .getSingleOrNull();
    return conflict != null;
  }

  /// 云端已确认分类身份时仅维护登记事实，保留未确认的本机正文、墓碑和并发基线。
  Future<void> _markCategoryRegistered(
    String id,
    String accountId,
    String observed,
  ) =>
      (_runtime.db.update(_runtime.db.categories)..where(
            (c) => c.id.equals(id) & categoryScopePredicate(c, accountId),
          ))
          .write(
            CategoriesCompanion(
              cloudRegistered: const d.Value(true),
              observedCloudState: d.Value(observed),
            ),
          );

  /// 执行upsertRecurring对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> upsertRecurring(RecurringTransaction rt) async {
    final existing = await (_runtime.db.select(
      _runtime.db.recurringTransactions,
    )..where((row) => row.id.equals(rt.id))).getSingleOrNull();
    final localCursor = existing?.lastGeneratedDate?.toUtc();
    final remoteCursor = rt.lastGeneratedDate?.toUtc();
    final cursor =
        localCursor != null &&
            (remoteCursor == null || localCursor.isAfter(remoteCursor))
        ? localCursor
        : remoteCursor;
    await _runtime.db
        .into(_runtime.db.recurringTransactions)
        .insertOnConflictUpdate(
          RecurringTransactionsCompanion.insert(
            id: rt.id,
            ledgerId: rt.ledgerId,
            txType: requireExpenseType(rt.txType.name),
            amount: rt.amount,
            currencyCode: rt.currencyCode,
            categoryId: d.Value(rt.categoryId),
            note: d.Value(rt.note),
            frequency: rt.frequency.name,
            protocolVersion: d.Value(rt.protocolVersion),
            timeZone: d.Value(rt.timeZone),
            interval: d.Value(rt.interval),
            dayOfMonth: d.Value(rt.dayOfMonth),
            dayOfWeek: d.Value(rt.dayOfWeek),
            monthOfYear: d.Value(rt.monthOfYear),
            startDate: rt.startDate,
            endDate: d.Value(rt.endDate),
            lastGeneratedDate: d.Value(cursor),
            enabled: d.Value(rt.enabled),
            updatedAt: rt.updatedAt,
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 执行upsertMember对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> upsertMember(Member m) async {
    // full 快照成员单轨落库：REGISTERED/PLACEHOLDER 统一 LedgerMembers 行，
    // status（ACTIVE/LEFT/REMOVED）随快照权威更新，行保留以解释历史账务。
    await _runtime.db
        .into(_runtime.db.ledgerMembers)
        .insertOnConflictUpdate(
          LedgerMembersCompanion.insert(
            id: m.id,
            ledgerId: m.ledgerId,
            displayName: m.displayName,
            memberType: m.memberType.name,
            status: d.Value(m.status.name),
            updatedAt: m.updatedAt,
            // full 快照中存在的成员是当前权威实体，允许同主键成员重新加入。
            deletedAt: const d.Value(null),
          ),
        );
  }

  /// 执行upsertOverride对应的同步步骤，沿用所属域的身份与事务规则。
  Future<void> upsertOverride(
    ExchangeRateOverride ov, {
    required String accountId,
  }) async {
    await _runtime.db
        .into(_runtime.db.exchangeRateOverrides)
        .insertOnConflictUpdate(
          ExchangeRateOverridesCompanion.insert(
            id: ov.id,
            baseCurrency: ov.baseCurrency,
            quoteCurrency: ov.quoteCurrency,
            rate: ov.rate,
            scopeAccountId: d.Value(accountId),
            updatedAt: ov.updatedAt,
            deletedAt: const d.Value(null),
          ),
        );
  }
}

/// 记账远端实体到本地表的版本化投影所需的外部协作端口。
class AccountingProjectionPorts {
  /// 每项依赖独立声明，处理器不能访问其他域的任意内部成员。
  const AccountingProjectionPorts({
    required this.accountingBlockedLedgerIds,
    required this.operationsQuarantineLedger,
    required this.payloadCategoryLevel,
    required this.payloadDeleteTime,
  });

  /// 委托accounting域执行blockedLedgerIds。
  final Future<Set<String>> Function(Iterable<String?> candidateIds)
  accountingBlockedLedgerIds;

  /// 委托operations域执行quarantineLedger。
  final Future<void> Function(
    String id,
    String? account, {
    bool stale,
    bool deleted,
    DateTime? remoteDeletedAt,
  })
  operationsQuarantineLedger;

  /// 委托payload域执行categoryLevel。
  final int Function(Object? value) payloadCategoryLevel;

  /// 委托payload域执行deleteTime。
  final DateTime Function(Map<String, dynamic> p) payloadDeleteTime;
}
