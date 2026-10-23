import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';

import '../../helpers/test_isolation.dart';

/// 用真实 SQLite 检查完整周期副本和普通副本的身份、历史及墓碑边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalRepository repo;
  late LocalLedgerRepository ledgers;
  late String sourceId;
  late String targetId;
  late String memberId;
  late String categoryId;
  final created = DateTime.utc(2024, 1, 1);
  final deleted = DateTime.utc(2024, 4, 1);

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = LocalRepository(db);
    ledgers = LocalLedgerRepository(db);
    sourceId = await repo.createLedger(name: '源本', storageMode: 'local');
    targetId = await repo.createLedger(name: '副本', storageMode: 'local');
    memberId = await repo.createPlaceholderMember(
      ledgerId: sourceId,
      name: '参与人',
    );
    categoryId = await repo.createCategory(name: '周期分类', kind: 'expense');
  });
  tearDown(() => db.close());

  /// 历史快照包含暂停、删除和人工修改，避免生成器替夹具抹平这些状态。
  Future<void> seedHistory() async {
    for (final state in ['active', 'paused', 'deleted']) {
      await db
          .into(db.recurringTransactions)
          .insert(
            RecurringTransactionsCompanion.insert(
              id: 'rule-$state',
              ledgerId: sourceId,
              txType: 'expense',
              amount: '10.1234567890',
              currencyCode: 'CNY',
              categoryId: d.Value(categoryId),
              note: d.Value(state),
              frequency: state == 'active'
                  ? 'monthly'
                  : state == 'paused'
                  ? 'weekly'
                  : 'yearly',
              protocolVersion: const d.Value(1),
              timeZone: d.Value(
                state == 'paused' ? 'Asia/Shanghai' : 'America/New_York',
              ),
              interval: const d.Value(2),
              dayOfMonth: d.Value(state == 'paused' ? null : 10),
              dayOfWeek: d.Value(state == 'paused' ? 3 : null),
              monthOfYear: d.Value(state == 'deleted' ? 3 : null),
              startDate: DateTime.utc(2024, 1, 1),
              endDate: d.Value(DateTime.utc(2028, 12, 31)),
              lastGeneratedDate: d.Value(DateTime.utc(2024, 3, 10)),
              enabled: d.Value(state != 'paused'),
              createdAt: d.Value(created),
              updatedAt: created,
              deletedAt: d.Value(state == 'deleted' ? deleted : null),
            ),
          );
    }
    for (final spec in [
      (rule: 'rule-active', day: '2024-01-10', gone: false, note: '人工修正'),
      (rule: 'rule-active', day: '2024-03-10', gone: true, note: '发生墓碑'),
      (rule: 'rule-deleted', day: '2024-03-10', gone: false, note: '已删规则的历史'),
      (rule: null, day: null, gone: false, note: '普通交易'),
      (rule: null, day: null, gone: true, note: '普通墓碑'),
    ]) {
      final id = spec.rule == null
          ? 'ordinary-${spec.gone}'
          : recurringOccurrenceId(sourceId, spec.rule!, spec.day!);
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              ledgerId: sourceId,
              txType: 'expense',
              amount: spec.note == '人工修正' ? '99.1234567890' : '10',
              currencyCode: 'CNY',
              nativeAmount: spec.note == '人工修正' ? '99.1234567890' : '10',
              happenedAt: DateTime.utc(2024, 3, 10, 5),
              note: d.Value(spec.note),
              categoryId: d.Value(categoryId),
              recurringId: d.Value(spec.rule),
              occurrenceDate: d.Value(spec.day),
              createdByMemberId: d.Value(memberId),
              lastEditedByMemberId: d.Value(memberId),
              payerMemberId: d.Value(memberId),
              aaMode: const d.Value(2),
              version: const d.Value(3),
              serverRevision: const d.Value(42),
              lastEditedAt: d.Value(DateTime.utc(2024, 3, 12)),
              createdAt: created,
              updatedAt: created,
              deletedAt: d.Value(spec.gone ? deleted : null),
            ),
          );
      await db
          .into(db.transactionSplits)
          .insert(
            TransactionSplitsCompanion.insert(
              transactionId: id,
              memberId: memberId,
              amount: spec.note == '人工修正' ? '99.1234567890' : '10',
            ),
          );
      await db
          .into(db.recordEditHistories)
          .insert(
            RecordEditHistoriesCompanion.insert(
              recordId: id,
              version: 3,
              operatorMemberId: d.Value(memberId),
              summary: '历史-${spec.note}',
              createdAt: d.Value(created),
            ),
          );
    }
  }

  Future<List<RecurringTransaction>> rules(String ledgerId) => (db.select(
    db.recurringTransactions,
  )..where((r) => r.ledgerId.equals(ledgerId))).get();
  Future<List<Transaction>> transactions(String ledgerId) => (db.select(
    db.transactions,
  )..where((t) => t.ledgerId.equals(ledgerId))).get();

  test('完整副本保留三种规则状态、发生墓碑及人工修改，并重映射所有关系', () async {
    await seedHistory();
    final originalRules = await rules(sourceId);
    final originalTransactions = await transactions(sourceId);
    await ledgers.copyLedgerData(
      sourceLedgerId: sourceId,
      targetLedgerId: targetId,
      copyRecurring: true,
    );
    final copiedRules = await rules(targetId);
    expect(copiedRules, hasLength(3));
    for (final old in originalRules) {
      final copy = copiedRules.singleWhere((r) => r.note == old.note);
      expect(copy.id, isNot(old.id));
      expect(copy.ledgerId, targetId);
      expect(copy.amount, old.amount);
      expect(copy.currencyCode, old.currencyCode);
      expect(copy.categoryId, old.categoryId);
      expect(copy.frequency, old.frequency);
      expect(copy.interval, old.interval);
      expect(copy.dayOfMonth, old.dayOfMonth);
      expect(copy.dayOfWeek, old.dayOfWeek);
      expect(copy.monthOfYear, old.monthOfYear);
      expect(copy.timeZone, old.timeZone);
      expect(copy.protocolVersion, old.protocolVersion);
      expect(copy.startDate, old.startDate);
      expect(copy.endDate, old.endDate);
      expect(copy.lastGeneratedDate, old.lastGeneratedDate);
      expect(copy.enabled, old.enabled);
      expect(copy.deletedAt, old.deletedAt);
      expect(copy.createdAt, old.createdAt);
    }
    final mappedMember =
        (await (db.select(db.ledgerMembers)..where(
                  (m) =>
                      m.ledgerId.equals(targetId) & m.displayName.equals('参与人'),
                ))
                .get())
            .single;
    expect(mappedMember.id, isNot(memberId));
    final copiedTransactions = await transactions(targetId);
    expect(copiedTransactions, hasLength(4), reason: '完整副本保留发生墓碑，普通墓碑不复制');
    for (final copy in copiedTransactions) {
      final old = originalTransactions.singleWhere((t) => t.note == copy.note);
      expect(copy.id, isNot(old.id));
      if (old.recurringId != null) {
        final oldRule = originalRules.singleWhere(
          (r) => r.id == old.recurringId,
        );
        final newRule = copiedRules.singleWhere((r) => r.note == oldRule.note);
        expect(copy.recurringId, newRule.id);
        expect(copy.occurrenceDate, old.occurrenceDate);
        expect(
          copy.id,
          recurringOccurrenceId(targetId, newRule.id, old.occurrenceDate!),
        );
      } else {
        expect(copy.recurringId, isNull);
        expect(copy.occurrenceDate, isNull);
      }
      expect(copy.amount, old.amount);
      expect(copy.nativeAmount, old.nativeAmount);
      expect(copy.currencyCode, old.currencyCode);
      expect(copy.happenedAt, old.happenedAt);
      expect(copy.categoryId, old.categoryId);
      expect(copy.version, old.version);
      expect(copy.lastEditedAt, old.lastEditedAt);
      expect(copy.deletedAt, old.deletedAt);
      expect(copy.serverRevision, isNull, reason: '新实体不能继承旧云端 revision');
      expect(copy.createdByMemberId, mappedMember.id);
      expect(copy.lastEditedByMemberId, mappedMember.id);
      expect(copy.payerMemberId, mappedMember.id);
      final split = await (db.select(
        db.transactionSplits,
      )..where((s) => s.transactionId.equals(copy.id))).getSingle();
      expect(split.memberId, mappedMember.id);
      expect(split.amount, copy.amount);
      final history = await (db.select(
        db.recordEditHistories,
      )..where((h) => h.recordId.equals(copy.id))).getSingle();
      expect(history.operatorMemberId, mappedMember.id);
      expect(history.version, 3);
      expect(history.summary, '历史-${copy.note}');
      expect(history.createdAt.toUtc(), created);
    }
    expect(await rules(sourceId), originalRules, reason: '复制不能改写源规则');
    expect(
      await transactions(sourceId),
      originalTransactions,
      reason: '复制不能复活或改写源交易',
    );
    expect(await repo.getRecurringTransactionsByLedger(targetId), hasLength(2));
  });

  test('普通副本仅复制活跃交易，清除两项周期来源，不携带规则或墓碑', () async {
    await seedHistory();
    await ledgers.copyLedgerData(
      sourceLedgerId: sourceId,
      targetLedgerId: targetId,
      copyRecurring: false,
    );
    expect(await rules(targetId), isEmpty);
    final copies = await transactions(targetId);
    expect(copies, hasLength(3));
    expect(
      copies.map((t) => t.note),
      unorderedEquals(['人工修正', '已删规则的历史', '普通交易']),
    );
    for (final copy in copies) {
      expect(copy.recurringId, isNull);
      expect(copy.occurrenceDate, isNull);
      expect(copy.deletedAt, isNull);
      expect(copy.serverRevision, isNull);
    }
    expect(copies.singleWhere((t) => t.note == '人工修正').amount, '99.1234567890');
  });

  test('规则写入失败时复制的交易、成员、分摊与历史一起回滚', () async {
    await seedHistory();
    final beforeMembers = await db.select(db.ledgerMembers).get();
    final beforeSplits = await db.select(db.transactionSplits).get();
    final beforeHistory = await db.select(db.recordEditHistories).get();
    await db.customStatement(
      "CREATE TRIGGER reject_copied_rule BEFORE INSERT ON recurring_transactions "
      "BEGIN SELECT RAISE(ABORT, 'injected copy failure'); END",
    );
    await expectLater(
      ledgers.copyLedgerData(
        sourceLedgerId: sourceId,
        targetLedgerId: targetId,
        copyRecurring: true,
      ),
      throwsA(anything),
    );
    expect(await rules(targetId), isEmpty);
    expect(await transactions(targetId), isEmpty);
    expect(await db.select(db.ledgerMembers).get(), beforeMembers);
    expect(await db.select(db.transactionSplits).get(), beforeSplits);
    expect(await db.select(db.recordEditHistories).get(), beforeHistory);
  });

  test('删除规则保留墓碑与历史，重复删除幂等，旧编辑与启停不能复活', () async {
    await seedHistory();
    final historyBefore = await transactions(sourceId);
    await repo.deleteRecurringTransaction('rule-active');
    final tombstone = (await rules(
      sourceId,
    )).singleWhere((r) => r.id == 'rule-active');
    expect(tombstone.deletedAt, isNotNull);
    expect((await repo.getAllRecurringTransactions()).map((r) => r.id), [
      'rule-paused',
    ]);
    await repo.deleteRecurringTransaction('rule-active');
    expect(
      (await rules(sourceId)).singleWhere((r) => r.id == 'rule-active'),
      tombstone,
    );
    await expectLater(
      repo.toggleRecurringTransaction('rule-active', false),
      throwsA(anything),
    );
    await expectLater(
      repo.updateRecurringTransaction(
        id: tombstone.id,
        ledgerId: sourceId,
        type: tombstone.txType,
        amount: '999',
        frequency: tombstone.frequency,
        interval: tombstone.interval,
        dayOfMonth: tombstone.dayOfMonth,
        startDate: tombstone.startDate.toUtc(),
      ),
      throwsA(anything),
    );
    expect(
      (await rules(sourceId)).singleWhere((r) => r.id == 'rule-active'),
      tombstone,
    );
    expect(await transactions(sourceId), historyBefore);
  });
}
