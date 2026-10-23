import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/utils/member_id.dart';

import '../../helpers/test_isolation.dart';

const _sourceId = '91b8e2e3-1c44-457b-a1b0-90efc589f701';
const _targetId = '96568a19-e849-4704-91c6-ab3116db27d9';
const _accountId = '59475960-acf4-4d24-8c76-d8ce971daf75';
const _otherAccountId = 'cc802a4b-e436-48c6-813f-19bd014de52f';
const _removedAccountId = '8322a060-44bc-41e5-923a-7649a399ac9e';
const _placeholderId = 'fd712c49-33e9-49ea-9086-74580872041e';
const _missingId = 'ab09a686-7347-45c7-b0b4-315cce9fdb25';
const _ruleId = '19b7d127-2001-424a-93d4-476fef74318f';
const _localSelf = 'copy-test-device';
final _created = DateTime.utc(2025, 1, 1);
final _deleted = DateTime.utc(2025, 3, 2);

/// 用真实 SQLite 验证 full 成员无账号关联时的复制身份与事务完整性。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late LocalLedgerRepository ledgers;
  final selfId = registeredMemberId(_sourceId, _accountId);
  final leftId = registeredMemberId(_sourceId, _otherAccountId);
  final removedId = registeredMemberId(_sourceId, _removedAccountId);

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    ledgers = LocalLedgerRepository(db);
  });
  tearDown(() => db.close());

  /// 直接插入 full 可提供的字段，不替同步快照补充缺失的 linkedAccountId。
  Future<void> seed({bool aaEnabled = false}) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _sourceId,
            name: '共享源本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_accountId),
            ownerAccountId: const d.Value(_otherAccountId),
            syncId: const d.Value('b5cce168-3f38-4ee2-a34c-7809f670806a'),
            selfMemberId: d.Value(selfId),
            role: const d.Value('editor'),
            aaEnabled: d.Value(aaEnabled),
            updatedAt: _created,
          ),
        );
    for (final spec in [
      (id: selfId, type: 'REGISTERED', role: 'editor', status: 'ACTIVE'),
      (id: leftId, type: 'REGISTERED', role: 'owner', status: 'LEFT'),
      (id: removedId, type: 'REGISTERED', role: 'editor', status: 'REMOVED'),
      (
        id: _placeholderId,
        type: 'PLACEHOLDER',
        role: 'editor',
        status: 'ACTIVE',
      ),
    ]) {
      await db
          .into(db.ledgerMembers)
          .insert(
            LedgerMembersCompanion.insert(
              id: spec.id,
              ledgerId: _sourceId,
              displayName: '同名成员',
              memberType: spec.type,
              role: d.Value(spec.role),
              status: d.Value(spec.status),
              updatedAt: _created,
            ),
          );
    }
    await db
        .into(db.recurringTransactions)
        .insert(
          RecurringTransactionsCompanion.insert(
            id: _ruleId,
            ledgerId: _sourceId,
            txType: 'expense',
            amount: '10.1234567891',
            currencyCode: 'USD',
            frequency: 'monthly',
            protocolVersion: const d.Value(1),
            timeZone: const d.Value('Asia/Shanghai'),
            dayOfMonth: const d.Value(1),
            startDate: DateTime.utc(2025, 1, 1),
            lastGeneratedDate: d.Value(DateTime.utc(2025, 3, 1)),
            enabled: const d.Value(false),
            createdAt: d.Value(_created),
            updatedAt: _created,
            deletedAt: d.Value(_deleted),
          ),
        );
    for (final spec in [
      (
        id: 'ordinary',
        note: '普通支出',
        day: null,
        deleted: false,
        payer: selfId,
        creator: leftId,
        editor: removedId,
        aaMode: null,
      ),
      (
        id: 'aa',
        note: '历史分摊',
        day: null,
        deleted: false,
        payer: leftId,
        creator: selfId,
        editor: removedId,
        aaMode: 2,
      ),
      (
        id: 'unknown-legacy',
        note: '未记录成员的历史',
        day: null,
        deleted: false,
        payer: null,
        creator: null,
        editor: null,
        aaMode: null,
      ),
      (
        id: 'occurrence',
        note: '周期历史',
        day: '2025-02-01',
        deleted: false,
        payer: removedId,
        creator: selfId,
        editor: leftId,
        aaMode: 2,
      ),
      (
        id: 'tombstone',
        note: '已删除的周期发生',
        day: '2025-03-01',
        deleted: true,
        payer: _placeholderId,
        creator: leftId,
        editor: selfId,
        aaMode: 2,
      ),
    ]) {
      final id = spec.day == null
          ? spec.id
          : recurringOccurrenceId(_sourceId, _ruleId, spec.day!);
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              ledgerId: _sourceId,
              txType: 'expense',
              amount: '10.1234567891',
              currencyCode: 'USD',
              nativeAmount: '72.9876543219',
              happenedAt: DateTime.utc(2025, 2, 1, 5),
              note: d.Value(spec.note),
              recurringId: d.Value(spec.day == null ? null : _ruleId),
              occurrenceDate: d.Value(spec.day),
              payerMemberId: d.Value(spec.payer),
              createdByMemberId: d.Value(spec.creator),
              lastEditedByMemberId: d.Value(spec.editor),
              aaMode: d.Value(spec.aaMode),
              version: const d.Value(3),
              serverRevision: const d.Value(42),
              lastEditedAt: d.Value(DateTime.utc(2025, 2, 2)),
              createdAt: _created,
              updatedAt: _created,
              deletedAt: d.Value(spec.deleted ? _deleted : null),
            ),
          );
      if (spec.aaMode != null) {
        for (final split in [
          (member: selfId, amount: '40'),
          (member: leftId, amount: '20'),
          (member: _placeholderId, amount: '12.9876543219'),
        ]) {
          await db
              .into(db.transactionSplits)
              .insert(
                TransactionSplitsCompanion.insert(
                  transactionId: id,
                  memberId: split.member,
                  amount: split.amount,
                ),
              );
        }
      }
      await db
          .into(db.recordEditHistories)
          .insert(
            RecordEditHistoriesCompanion.insert(
              recordId: id,
              version: 3,
              operatorMemberId: d.Value(spec.editor),
              summary: '修改 ${spec.note}',
              createdAt: d.Value(_created),
            ),
          );
    }
  }

  /// 从全表快照证明失败复制不留下账本、成员、周期或其他附属写入。
  Future<Map<String, Object>> snapshot() async => {
    'ledgers': await db.select(db.ledgers).get(),
    'members': await db.select(db.ledgerMembers).get(),
    'transactions': await db.select(db.transactions).get(),
    'splits': await db.select(db.transactionSplits).get(),
    'history': await db.select(db.recordEditHistories).get(),
    'rules': await db.select(db.recurringTransactions).get(),
    'categories': await db.select(db.categories).get(),
    'queue': await db.select(db.syncChanges).get(),
  };

  /// 走对外复制入口，同时覆盖可见副本与待确认云删除的隐藏副本。
  Future<String> copy({bool move = false}) => move
      ? ledgers.forkCloudLedgerToLocalPendingMove(
          sourceLedgerId: _sourceId,
          newLedgerId: _targetId,
          localSelfId: _localSelf,
          currentAccountId: _accountId,
        )
      : ledgers.copyCloudLedgerToLocal(
          sourceLedgerId: _sourceId,
          newLedgerId: _targetId,
          localSelfId: _localSelf,
          currentAccountId: _accountId,
        );

  for (final move in [false, true]) {
    test('${move ? '隐藏移动副本' : '非 AA 云账本复制'}保留所有身份、金额和历史引用', () async {
      await seed(aaEnabled: move);
      final before = await snapshot();
      final oldTransactions = before['transactions']! as List<Transaction>;
      final oldMembers = before['members']! as List<LedgerMember>;
      expect(oldMembers.every((m) => m.linkedAccountId == null), isTrue);
      expect(await copy(move: move), _targetId);
      final target = await (db.select(
        db.ledgers,
      )..where((row) => row.id.equals(_targetId))).getSingle();
      final members = await (db.select(
        db.ledgerMembers,
      )..where((row) => row.ledgerId.equals(_targetId))).get();
      expect(target.storageMode, 'local');
      expect(target.scopeAccountId, isNull);
      expect(target.syncId, isNull);
      expect(target.bindingStatus, move ? 'pending_local_move' : isNull);
      expect(target.aaEnabled, move);
      final localId = localSelfMemberId(_targetId, _localSelf);
      expect(target.selfMemberId, localId);
      expect(members, hasLength(4), reason: '同名历史成员不能合并或丢失');
      final own = members.singleWhere((m) => m.memberType == 'LOCAL');
      expect(own.id, localId);
      expect(own.role, 'owner', reason: '源本编辑者在本地副本中仍然是本人');
      expect(own.originMemberId, selfId);
      final left = members.singleWhere((m) => m.status == 'LEFT');
      final removed = members.singleWhere((m) => m.status == 'REMOVED');
      final placeholder = members.singleWhere(
        (m) => m.memberType == 'PLACEHOLDER' && m.status == 'ACTIVE',
      );
      expect(left.memberType, 'PLACEHOLDER');
      expect(removed.memberType, 'PLACEHOLDER');
      final mapping = {
        selfId: localId,
        leftId: left.id,
        removedId: removed.id,
        _placeholderId: placeholder.id,
      };
      expect(mapping.values.toSet(), hasLength(4));
      expect(
        mapping.keys.toSet().intersection(mapping.values.toSet()),
        isEmpty,
      );
      final rules = await (db.select(
        db.recurringTransactions,
      )..where((r) => r.ledgerId.equals(_targetId))).get();
      expect(rules, hasLength(1));
      expect(rules.single.deletedAt?.toUtc(), _deleted);
      expect(rules.single.enabled, isFalse);
      expect(rules.single.protocolVersion, 1);
      expect(rules.single.timeZone, 'Asia/Shanghai');
      expect(rules.single.lastGeneratedDate?.toUtc(), DateTime.utc(2025, 3, 1));
      final transactions = await (db.select(
        db.transactions,
      )..where((t) => t.ledgerId.equals(_targetId))).get();
      expect(transactions, hasLength(5));
      for (final tx in transactions) {
        final old = oldTransactions.singleWhere((t) => t.note == tx.note);
        expect(tx.id, isNot(old.id));
        expect(tx.payerMemberId, mapping[old.payerMemberId]);
        expect(tx.createdByMemberId, mapping[old.createdByMemberId]);
        expect(tx.lastEditedByMemberId, mapping[old.lastEditedByMemberId]);
        expect(tx.amount, old.amount);
        expect(tx.nativeAmount, old.nativeAmount);
        expect(tx.currencyCode, old.currencyCode);
        expect(tx.aaMode, old.aaMode);
        expect(tx.happenedAt, old.happenedAt);
        expect(tx.createdAt, old.createdAt);
        expect(tx.lastEditedAt, old.lastEditedAt);
        expect(tx.version, old.version);
        expect(tx.serverRevision, isNull);
        expect(tx.deletedAt, old.deletedAt);
        expect(tx.occurrenceDate, old.occurrenceDate);
        if (old.recurringId != null) {
          expect(tx.recurringId, rules.single.id);
          expect(
            tx.id,
            recurringOccurrenceId(
              _targetId,
              rules.single.id,
              old.occurrenceDate!,
            ),
          );
        } else {
          expect(tx.recurringId, isNull);
        }
        final splits = await (db.select(
          db.transactionSplits,
        )..where((s) => s.transactionId.equals(tx.id))).get();
        final oldSplits = (before['splits']! as List<TransactionSplit>).where(
          (s) => s.transactionId == old.id,
        );
        expect(splits, hasLength(oldSplits.length));
        for (final original in oldSplits) {
          final split = splits.singleWhere(
            (s) => s.memberId == mapping[original.memberId],
          );
          expect(split.amount, original.amount);
        }
        final history = await (db.select(
          db.recordEditHistories,
        )..where((h) => h.recordId.equals(tx.id))).getSingle();
        final oldHistory = (before['history']! as List<RecordEditHistory>)
            .singleWhere((h) => h.recordId == old.id);
        expect(history.operatorMemberId, mapping[oldHistory.operatorMemberId]);
        expect(history.summary, oldHistory.summary);
        expect(history.version, oldHistory.version);
        expect(history.createdAt, oldHistory.createdAt);
      }
      expect(
        await (db.select(
          db.ledgers,
        )..where((l) => l.id.equals(_sourceId))).get(),
        unorderedEquals(before['ledgers']! as Iterable<Object>),
      );
      expect(
        await (db.select(
          db.ledgerMembers,
        )..where((m) => m.ledgerId.equals(_sourceId))).get(),
        unorderedEquals(before['members']! as Iterable<Object>),
      );
      expect(
        await (db.select(
          db.transactions,
        )..where((t) => t.ledgerId.equals(_sourceId))).get(),
        unorderedEquals(before['transactions']! as Iterable<Object>),
      );
      expect(
        await (db.select(
          db.recurringTransactions,
        )..where((r) => r.ledgerId.equals(_sourceId))).get(),
        unorderedEquals(before['rules']! as Iterable<Object>),
      );
      final sourceIds = oldTransactions.map((t) => t.id).toList();
      expect(
        await (db.select(
          db.transactionSplits,
        )..where((s) => s.transactionId.isIn(sourceIds))).get(),
        unorderedEquals(before['splits']! as Iterable<Object>),
      );
      expect(
        await (db.select(
          db.recordEditHistories,
        )..where((h) => h.recordId.isIn(sourceIds))).get(),
        unorderedEquals(before['history']! as Iterable<Object>),
      );
      expect(
        await db.select(db.syncChanges).get(),
        unorderedEquals(before['queue']! as Iterable<Object>),
      );
    });
  }

  for (final reference in [
    'payer',
    'creator',
    'editor',
    'split',
    'history',
    'tombstone',
  ]) {
    test('缺失的 $reference 成员引用必须使完整副本原子回滚', () async {
      await seed(aaEnabled: true);
      switch (reference) {
        case 'payer':
          await (db.update(
            db.transactions,
          )..where((t) => t.id.equals('ordinary'))).write(
            const TransactionsCompanion(payerMemberId: d.Value(_missingId)),
          );
        case 'creator':
          await (db.update(
            db.transactions,
          )..where((t) => t.id.equals('ordinary'))).write(
            const TransactionsCompanion(createdByMemberId: d.Value(_missingId)),
          );
        case 'editor':
          await (db.update(
            db.transactions,
          )..where((t) => t.id.equals('ordinary'))).write(
            const TransactionsCompanion(
              lastEditedByMemberId: d.Value(_missingId),
            ),
          );
        case 'split':
          await (db.update(db.transactionSplits)..where(
                (s) => s.transactionId.equals('aa') & s.memberId.equals(selfId),
              ))
              .write(
                const TransactionSplitsCompanion(memberId: d.Value(_missingId)),
              );
        case 'history':
          await (db.update(
            db.recordEditHistories,
          )..where((h) => h.recordId.equals('ordinary'))).write(
            const RecordEditHistoriesCompanion(
              operatorMemberId: d.Value(_missingId),
            ),
          );
        case 'tombstone':
          await (db.update(
            db.transactions,
          )..where((t) => t.deletedAt.isNotNull())).write(
            const TransactionsCompanion(payerMemberId: d.Value(_missingId)),
          );
      }
      final before = await snapshot();
      await expectLater(copy(), throwsStateError);
      expect(await snapshot(), before, reason: '复制失败不得修改源数据或留下部分副本');
    });
  }
}
