import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'local_transaction_repository.dart';
import 'local_recurring_transaction_repository.dart';
import '../support/ledger_category_catalog.dart';

/// 转云前验证并冻结周期历史，失败时调用方必须保留本地账本和原队列。
///
/// 返回的是本地 outbox 的 JSON 数据；HTTP 类型仍由 OpenAPI 生成客户端反序列化。
/// 已删除行是已发生事实，和活记录一起参与进度佐证，不得截断或先复活再删除。
Future<Map<String, Map<String, Object?>>> prepareRecurringInitialStates(
  SesameDatabase db,
  String ledgerId,
) async {
  final rules = await (db.select(
    db.recurringTransactions,
  )..where((row) => row.ledgerId.equals(ledgerId))).get();
  final occurrences =
      await (db.select(db.transactions)
            ..where(
              (row) =>
                  row.ledgerId.equals(ledgerId) & row.recurringId.isNotNull(),
            )
            ..orderBy([(row) => d.OrderingTerm.asc(row.id)]))
          .get();
  final occurrenceCounts = <String, int>{};
  for (final occurrence in occurrences) {
    final ruleId = occurrence.recurringId!;
    occurrenceCounts[ruleId] = (occurrenceCounts[ruleId] ?? 0) + 1;
    if (occurrenceCounts[ruleId]! > 10000) {
      throw StateError('单条周期规则历史超过 10000 条原子迁入上限，账本仍保留在本地，未截断任何数据。');
    }
  }
  final byId = {for (final rule in rules) rule.id: rule};
  for (final rule in rules) {
    if (rule.protocolVersion != recurringProtocolVersion) {
      throw StateError('周期规则的协议格式无效，原账本和历史未修改。');
    }
    validateRecurringDateRange(rule.startDate.toUtc(), rule.endDate?.toUtc());
    recurringLocation(rule.timeZone);
  }
  final splits =
      await (db.select(db.transactionSplits)..where(
            (row) => row.transactionId.isInQuery(
              db.selectOnly(db.transactions)
                ..addColumns([db.transactions.id])
                ..where(
                  db.transactions.ledgerId.equals(ledgerId) &
                      db.transactions.recurringId.isNotNull(),
                ),
            ),
          ))
          .get();
  final byTransaction = <String, List<ContractSplit>>{};
  final members = await (db.select(
    db.ledgerMembers,
  )..where((row) => row.ledgerId.equals(ledgerId))).get();
  final availableMemberIds = {
    for (final member in members)
      if (member.deletedAt == null) member.id,
  };
  final referencedCategories = <String>{
    for (final rule in rules)
      if (rule.categoryId != null) rule.categoryId!,
    for (final occurrence in occurrences)
      if (occurrence.categoryId != null) occurrence.categoryId!,
  };
  // 历史弱引用必须在切换存储前验证，不能上传到一半才发现依赖已被删除。
  final categories = await readLedgerCategoryCatalog(
    db,
    ledgerId,
    categoryIds: referencedCategories,
  );
  final availableCategoryIds = categories.keys.toSet();
  if (!availableCategoryIds.containsAll(referencedCategories)) {
    throw StateError('周期历史引用的分类已缺失或删除，账本仍保留本地；请恢复分类后重试');
  }
  for (final split in splits) {
    if (!availableMemberIds.contains(split.memberId)) {
      throw StateError('周期历史引用的分摊成员已缺失或删除，账本仍保留本地；请恢复成员后重试');
    }
    (byTransaction[split.transactionId] ??= []).add((
      memberId: split.memberId,
      amount: split.amount,
    ));
  }
  final states = <String, Map<String, Object?>>{
    for (final rule in rules)
      rule.id: {
        'last_generated_date': rule.lastGeneratedDate
            ?.toUtc()
            .toIso8601String(),
        'deleted_at': rule.deletedAt?.toUtc().toIso8601String(),
        'occurrences': <Map<String, Object?>>[],
      },
  };
  for (final occurrence in occurrences) {
    if (occurrence.payerMemberId != null &&
        !availableMemberIds.contains(occurrence.payerMemberId)) {
      throw StateError('周期历史引用的付款成员已缺失或删除，账本仍保留本地；请恢复成员后重试');
    }
    final rule = byId[occurrence.recurringId];
    final date = occurrence.occurrenceDate;
    final parsed = date == null ? null : DateTime.tryParse('${date}T00:00:00Z');
    if (rule == null ||
        date == null ||
        parsed == null ||
        parsed.year < 1000 ||
        parsed.year > 9999 ||
        recurringDateKey(parsed) != date ||
        occurrence.id.toLowerCase() !=
            recurringOccurrenceId(ledgerId, rule.id, date)) {
      throw StateError('周期历史缺少可验证的来源或发生日期，原账本已保留，未切换到云端。');
    }
    if (parsed.isAfter(recurringToday(rule.timeZone, DateTime.now().toUtc()))) {
      throw StateError('周期历史含未来发生日期，原账本已保留，请核对设备时间和原记录。');
    }
    (states[rule.id]!['occurrences']! as List<Map<String, Object?>>).add({
      'id': occurrence.id,
      'deleted_at': occurrence.deletedAt?.toUtc().toIso8601String(),
      'payload': jsonDecode(
        transactionPayload(
          occurrence,
          byTransaction[occurrence.id] ?? const [],
          payerMemberId: occurrence.payerMemberId,
        ),
      ),
    });
  }
  for (final rule in rules) {
    final cursor = rule.lastGeneratedDate?.toUtc();
    if (cursor != null &&
        !occurrences.any(
          (row) =>
              row.recurringId == rule.id &&
              row.occurrenceDate == recurringDateKey(cursor),
        )) {
      throw StateError('周期进度缺少对应发生或墓碑，原账本已保留，不能跳过未验证的历史。');
    }
  }
  // 为外层规则及 mutation 信封预留空间；超限在存储模式改变前明确失败。
  for (final rule in rules) {
    final completePayload = {
      ...jsonDecode(recurringTransactionPayload(rule)) as Map<String, dynamic>,
      'initial_state': states[rule.id]!,
    };
    if (utf8.encode(jsonEncode(completePayload)).length > 63 * 1024 * 1024) {
      throw StateError('单条周期规则历史超过单批 64 MiB 请求容量，账本仍保留在本地，未截断任何数据。');
    }
  }
  return states;
}
