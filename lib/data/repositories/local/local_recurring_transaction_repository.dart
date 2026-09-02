import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';

const _uuid = Uuid();

/// 本地周期记账Repository实现
/// 基于 Drift 数据库实现
class LocalRecurringTransactionRepository {
  final SesameDatabase db;

  /// 写事务中获取变更登记器，避免构造顺序形成循环依赖（与账本仓储同模式）。
  final ChangeRecorder? Function()? trackerGetter;

  LocalRecurringTransactionRepository(this.db, {this.trackerGetter});

  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    return await (db.select(
      db.recurringTransactions,
    )..where((row) => row.deletedAt.isNull())).get();
  }

  Future<List<RecurringTransaction>> getRecurringTransactionsByLedger(
    String ledgerId,
  ) async {
    return await (db.select(
      db.recurringTransactions,
    )..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull())).get();
  }

  Future<List<RecurringTransaction>> getEnabledRecurringTransactions(
    String ledgerId,
  ) async {
    return await (db.select(db.recurringTransactions)..where(
          (t) =>
              t.ledgerId.equals(ledgerId) &
              t.deletedAt.isNull() &
              t.enabled.equals(true),
        ))
        .get();
  }

  /// 新建周期模板，并固化金额的原记账币种。
  ///
  /// 未指定 [currencyCode] 时取创建时的账本本位币，确保账本以后换币时模板金额
  /// 仍保持原单位；显式币种供配置导入等跨账本恢复场景使用。
  Future<String> addRecurringTransaction({
    required String ledgerId,
    required String type,
    required String amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    required String frequency,
    required int interval,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    required DateTime startDate,
    DateTime? endDate,
    bool enabled = true,
  }) async {
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(ledgerId))).getSingleOrNull();
    if (ledger == null) {
      throw StateError('账本不存在: $ledgerId');
    }
    // 新建模板默认沿用当时的账本本位币；显式传入则用于配置导入等
    // 跨账本场景，之后即使模板归属或账本本位币变化也不改金额单位。
    final normalizedCurrencyCode = currencyCode?.trim().toUpperCase();
    final resolvedCurrencyCode = normalizedCurrencyCode?.isNotEmpty == true
        ? normalizedCurrencyCode!
        : ledger.currency.trim().toUpperCase();
    // UUID 主键由客户端离线生成，本地与云端始终同一 id；
    // updated_at 为同步 LWW 依据，统一 UTC 时间。
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    // 写库与变更登记同一事务：登记失败整体回滚，避免本地落库但云端推不出去。
    await db.transaction(() async {
      await db
          .into(db.recurringTransactions)
          .insert(
            RecurringTransactionsCompanion.insert(
              id: id,
              ledgerId: ledgerId,
              txType: type,
              amount: amount,
              currencyCode: resolvedCurrencyCode,
              categoryId: d.Value(categoryId),
              note: d.Value(note),
              frequency: frequency,
              interval: d.Value(interval),
              dayOfMonth: d.Value(dayOfMonth),
              dayOfWeek: d.Value(dayOfWeek),
              monthOfYear: d.Value(monthOfYear),
              startDate: startDate,
              endDate: d.Value(endDate),
              enabled: d.Value(enabled),
              updatedAt: now,
            ),
          );
      // 仅云端账本登记（上方已读取 ledger，直接复用其归属判定）。
      final tracker = trackerGetter?.call();
      if (tracker != null && ledger.storageMode == 'cloud') {
        final row = await _getById(id);
        if (row != null) {
          await _recordChange(row: row, action: 'upsert');
        }
      }
    });
    return id;
  }

  /// 更新周期模板，未指定 [currencyCode] 时保留已固化的原记账币种。
  ///
  /// 归属账本与金额币种是两个独立维度：同账本编辑只改字段；跨账本移动时
  /// 服务端禁止同一实体 UUID 跨账本 upsert（ENTITY_SCOPE_CONFLICT），
  /// 必须删除旧实体并以新 UUID 在目标账本重建，才能被云同步接受。
  Future<void> updateRecurringTransaction({
    required String id,
    required String ledgerId,
    required String type,
    required String amount,
    String? currencyCode,
    String? categoryId,
    String? note,
    required String frequency,
    required int interval,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    required DateTime startDate,
    DateTime? endDate,
    bool? enabled,
    bool clearLastGeneratedDate = false,
  }) async {
    final normalizedCurrencyCode = currencyCode?.trim().toUpperCase();
    try {
      // 更新与变更登记同一事务：登记失败整体回滚。
      await db.transaction(() async {
        final existing = await _getById(id);
        if (existing == null) {
          throw StateError('周期模板不存在，无法更新: $id');
        }
        final now = DateTime.now().toUtc();

        if (existing.ledgerId != ledgerId) {
          // 跨账本移动：旧 UUID 在旧账本登记 delete（服务端校验可通过），
          // 再以新 UUID 在目标账本 upsert（create 路径必然通过）；两者与
          // 本地重建同一事务，避免本地已移走而云端仍持旧投影。
          final targetLedger = await (db.select(
            db.ledgers,
          )..where((ledger) => ledger.id.equals(ledgerId))).getSingleOrNull();
          if (targetLedger == null) {
            throw StateError('目标账本不存在，无法移动周期模板: $ledgerId');
          }
          await _recordChange(
            row: existing.copyWith(updatedAt: now),
            action: 'delete',
          );
          final newId = _uuid.v4();
          await (db.delete(
            db.recurringTransactions,
          )..where((row) => row.id.equals(id))).go();
          await db
              .into(db.recurringTransactions)
              .insert(
                RecurringTransactionsCompanion.insert(
                  id: newId,
                  ledgerId: ledgerId,
                  txType: type,
                  amount: amount,
                  // 未显式传币种时保留模板原币种，避免相同金额被解释成另一单位。
                  currencyCode: normalizedCurrencyCode?.isNotEmpty == true
                      ? normalizedCurrencyCode!
                      : existing.currencyCode,
                  categoryId: d.Value(categoryId),
                  note: d.Value(note),
                  frequency: frequency,
                  interval: d.Value(interval),
                  dayOfMonth: d.Value(dayOfMonth),
                  dayOfWeek: d.Value(dayOfWeek),
                  monthOfYear: d.Value(monthOfYear),
                  startDate: startDate,
                  endDate: d.Value(endDate),
                  // 保留生成锚点避免移动后重复生成，只有显式重置才清空。
                  lastGeneratedDate: d.Value(
                    clearLastGeneratedDate ? null : existing.lastGeneratedDate,
                  ),
                  enabled: d.Value(enabled ?? existing.enabled),
                  createdAt: d.Value(existing.createdAt),
                  updatedAt: now,
                ),
              );
          final moved = await _getById(newId);
          if (moved == null) {
            throw StateError('周期模板移动失败，请重试');
          }
          await _recordChange(row: moved, action: 'upsert');
          return;
        }

        await (db.update(
          db.recurringTransactions,
        )..where((t) => t.id.equals(id))).write(
          RecurringTransactionsCompanion(
            ledgerId: d.Value(ledgerId),
            txType: d.Value(type),
            amount: d.Value(amount),
            // 未显式传币种时保留模板原币种；编辑页面跨账本只改变归属，
            // 否则相同数值会被静默改成目标账本的金额单位。
            currencyCode:
                normalizedCurrencyCode != null &&
                    normalizedCurrencyCode.isNotEmpty
                ? d.Value(normalizedCurrencyCode)
                : const d.Value.absent(),
            categoryId: d.Value(categoryId),
            note: d.Value(note),
            frequency: d.Value(frequency),
            interval: d.Value(interval),
            dayOfMonth: d.Value(dayOfMonth),
            dayOfWeek: d.Value(dayOfWeek),
            monthOfYear: d.Value(monthOfYear),
            startDate: d.Value(startDate),
            endDate: d.Value(endDate),
            enabled: enabled != null
                ? d.Value(enabled)
                : const d.Value.absent(),
            // 普通编辑保持 lastGeneratedDate 不变；只有显式重置时才清空，
            // 否则用户改一次模板就会丢掉"已生成到哪天"的锚点，触发重复生成。
            lastGeneratedDate: clearLastGeneratedDate
                ? d.Value<DateTime?>(null)
                : const d.Value.absent(),
            updatedAt: d.Value(now),
          ),
        );
        // payload 以变更后的完整实体构造（契约：payload 为完整实体 JSON）。
        final updated = await _getById(id);
        if (updated != null) {
          await _recordChange(row: updated, action: 'upsert');
        }
      });
    } catch (error, stackTrace) {
      logger.error(
        'LocalRecurringTransactionRepository',
        '更新周期模板失败 id=$id ledgerId=$ledgerId',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> deleteRecurringTransaction(String id) async {
    // 删除与登记 delete 变更同一事务：登记失败回滚，避免本地已删但云端仍持有。
    await db.transaction(() async {
      final row = await _getById(id);
      if (row == null) return;
      await (db.delete(
        db.recurringTransactions,
      )..where((t) => t.id.equals(id))).go();
      // tombstone 语义：payload 带删除时刻 updatedAt，云端按事件时间裁决。
      await _recordChange(
        row: row.copyWith(updatedAt: DateTime.now().toUtc()),
        action: 'delete',
      );
    });
  }

  Future<void> toggleRecurringTransaction(String id, bool enabled) async {
    // 启停也是模板内容变更，与登记同一事务。
    await db.transaction(() async {
      await (db.update(
        db.recurringTransactions,
      )..where((t) => t.id.equals(id))).write(
        RecurringTransactionsCompanion(
          enabled: d.Value(enabled),
          updatedAt: d.Value(DateTime.now().toUtc()),
        ),
      );
      final row = await _getById(id);
      if (row != null) {
        await _recordChange(row: row, action: 'upsert');
      }
    });
  }

  // ---------------------------------------------------------------
  // 变更登记（data 层端口依赖倒置：实现由 cloud/sync 注入）
  // ---------------------------------------------------------------

  Future<RecurringTransaction?> _getById(String id) async {
    return (db.select(
      db.recurringTransactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 登记单条周期模板变更：仅云端账本进同步通道（本地账本永不产生同步事件）。
  Future<void> _recordChange({
    required RecurringTransaction row,
    required String action,
  }) async {
    final tracker = trackerGetter?.call();
    if (tracker == null) return;
    final ledger = await (db.select(
      db.ledgers,
    )..where((l) => l.id.equals(row.ledgerId))).getSingleOrNull();
    if (ledger == null || ledger.storageMode != 'cloud') return;
    await tracker.recordLedgerChange(
      entityType: 'recurring_transaction',
      entityId: row.id,
      ledgerId: row.ledgerId,
      action: action,
      payload: recurringTransactionPayload(row),
      updatedAt: row.updatedAt,
    );
  }

  /// 推进周期模板的最后生成锚点，并登记最终模板快照。
  ///
  /// 锚点与生成出的交易必须在同一外层事务内提交，否则其他设备
  /// 会继续使用旧锚点重复生成账单。
  Future<void> updateLastGeneratedDate(String id, DateTime date) async {
    await db.transaction(() async {
      final existing = await _getById(id);
      if (existing == null) {
        throw StateError('周期模板不存在，无法更新生成锚点: $id');
      }
      await (db.update(
        db.recurringTransactions,
      )..where((t) => t.id.equals(id))).write(
        RecurringTransactionsCompanion(
          lastGeneratedDate: d.Value(date),
          updatedAt: d.Value(DateTime.now().toUtc()),
        ),
      );
      final updated = await _getById(id);
      if (updated == null) {
        throw StateError('周期模板生成锚点更新失败，请重试: $id');
      }
      await _recordChange(row: updated, action: 'upsert');
    });
  }

  Stream<List<RecurringTransaction>> watchAllRecurringTransactions() {
    return (db.select(
      db.recurringTransactions,
    )..where((row) => row.deletedAt.isNull())).watch();
  }

  Stream<List<RecurringTransaction>> watchRecurringTransactionsByLedger(
    String ledgerId,
  ) {
    return (db.select(db.recurringTransactions)
          ..where((t) => t.ledgerId.equals(ledgerId) & t.deletedAt.isNull()))
        .watch();
  }

  /// 批量插入周期模板，并按 [recordChanges] 登记云账本的最终 upsert 快照。
  ///
  /// 恢复远端快照时传 false，避免回填产生反向 mutation；数据库写入本身仍会
  /// 发出 Drift 表变更信号，首页和各汇总照常自动重算。
  Future<void> batchInsertRecurringTransactions(
    List<RecurringTransactionsCompanion> items, {
    bool recordChanges = true,
  }) async {
    if (items.isEmpty) return;
    try {
      await db.transaction(() async {
        await db.batch((batch) {
          batch.insertAll(db.recurringTransactions, items);
        });
        if (recordChanges) {
          final ids = [for (final item in items) item.id.value];
          final rows = await (db.select(
            db.recurringTransactions,
          )..where((row) => row.id.isIn(ids))).get();
          for (final row in rows) {
            await _recordChange(row: row, action: 'upsert');
          }
        }
      });
    } catch (error, stackTrace) {
      logger.error(
        'LocalRecurringTransactionRepository',
        '批量导入周期模板失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}

/// 构造契约形状的 recurring_transaction payload（snake_case 键，与 push 侧
/// 生成模型 wire name 对齐，保证 SyncService.push 反序列化即消费成功）。
String recurringTransactionPayload(RecurringTransaction r) {
  return jsonEncode({
    'tx_type': r.txType,
    'amount': r.amount,
    'currency_code': r.currencyCode,
    'category_id': r.categoryId,
    'note': r.note,
    'frequency': r.frequency,
    'interval': r.interval,
    'day_of_month': r.dayOfMonth,
    'day_of_week': r.dayOfWeek,
    'month_of_year': r.monthOfYear,
    'start_date': r.startDate.toUtc().toIso8601String(),
    'end_date': r.endDate?.toUtc().toIso8601String(),
    'last_generated_date': r.lastGeneratedDate?.toUtc().toIso8601String(),
    'enabled': r.enabled,
    // updated_at 供服务端沿用 pull 契约的时间语义（生成模型不消费该键，无害）。
    'updated_at': r.updatedAt.toUtc().toIso8601String(),
  });
}
