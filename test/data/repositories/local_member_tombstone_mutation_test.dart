import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_member_repository.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

/// 测试用成员 mutation 记录器，用于检查仓储登记的同步载荷。
class _MemberChangeRecorder extends ChangeRecorder {
  final records =
      <
        ({
          String entityType,
          String entityId,
          String ledgerId,
          String action,
          String payload,
        })
      >[];

  /// 记录账本域变更，供断言逐项核对成员和载荷。
  @override
  Future<void> recordLedgerChange({
    required String entityType,
    required String entityId,
    required String ledgerId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) async {
    records.add((
      entityType: entityType,
      entityId: entityId,
      ledgerId: ledgerId,
      action: action,
      payload: payload,
    ));
  }

  /// 本测试只覆盖账本域成员，调用 user-global 登记即表示实现走错通道。
  @override
  Future<void> recordUserGlobalChange({
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime updatedAt,
  }) => throw UnsupportedError('成员不得登记 user-global mutation');

  /// 本测试不使用批量账本域登记。
  @override
  Future<void> recordLedgerChanges({required List<SyncChangeRecord> changes}) =>
      throw UnsupportedError('成员 CRUD 应逐条登记 mutation');

  /// 本测试不使用批量 user-global 登记。
  @override
  Future<void> recordUserGlobalChanges({
    required List<SyncChangeRecord> changes,
  }) => throw UnsupportedError('成员不得登记 user-global mutation');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// 创建测试账本，云/本地模式用于验证 mutation 通道边界。
  Future<void> seedLedger(String id, String storageMode) async {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: id,
            storageMode: d.Value(storageMode),
            updatedAt: DateTime.utc(2026, 8, 24),
          ),
        );
  }

  /// 直接插入成员镜像，便于构造远端 tombstone 与生命周期状态。
  Future<void> seedMember({
    required String id,
    required String ledgerId,
    required String memberType,
    String status = 'ACTIVE',
    DateTime? deletedAt,
    String? linkedAccountId,
  }) async {
    await db
        .into(db.ledgerMembers)
        .insert(
          LedgerMembersCompanion.insert(
            id: id,
            ledgerId: ledgerId,
            displayName: id,
            memberType: memberType,
            linkedAccountId: d.Value(linkedAccountId),
            status: d.Value(status),
            updatedAt: DateTime.utc(2026, 8, 24),
            deletedAt: d.Value(deletedAt),
          ),
        );
  }

  test('成员 tombstone：get/watch/getById/getByLinkedAccount 隐藏，底层行仍保留', () async {
    await seedLedger('cloud-ledger', 'cloud');
    await seedMember(
      id: 'active-member',
      ledgerId: 'cloud-ledger',
      memberType: 'REGISTERED',
      linkedAccountId: 'active-account',
    );
    await seedMember(
      id: 'removed-member',
      ledgerId: 'cloud-ledger',
      memberType: 'REGISTERED',
      status: 'REMOVED',
      linkedAccountId: 'removed-account',
    );
    await seedMember(
      id: 'deleted-member',
      ledgerId: 'cloud-ledger',
      memberType: 'PLACEHOLDER',
      deletedAt: DateTime.utc(2026, 8, 24, 12),
      linkedAccountId: 'deleted-account',
    );
    final repo = LocalLedgerMemberRepository(db);

    expect(
      (await repo.getByLedger('cloud-ledger')).map((member) => member.id),
      ['active-member', 'removed-member'],
      reason: '非 tombstone 的历史成员仍需保留，供旧账解释名称与头像',
    );
    expect(
      (await repo.watchByLedger('cloud-ledger').first).map(
        (member) => member.id,
      ),
      ['active-member', 'removed-member'],
    );
    expect(await repo.getById('deleted-member'), isNull);
    expect(
      await repo.getByLinkedAccount('cloud-ledger', 'deleted-account'),
      isNull,
    );

    final raw = await (db.select(
      db.ledgerMembers,
    )..where((member) => member.id.equals('deleted-member'))).getSingle();
    expect(raw.deletedAt, isNotNull, reason: '同步层仍需保留 tombstone 防止回潮');
  });

  test('PLACEHOLDER 云账本 C/U/D 逐步登记准确 member mutation，本地账本不登记', () async {
    await seedLedger('cloud-ledger', 'cloud');
    await seedLedger('local-ledger', 'local');
    final recorder = _MemberChangeRecorder();
    final repo = LocalLedgerMemberRepository(db, trackerGetter: () => recorder);

    await repo.createPlaceholder(
      ledgerId: 'cloud-ledger',
      name: '云成员',
      id: 'cloud-member',
    );
    await repo.rename(id: 'cloud-member', name: '云成员新名');
    expect(await repo.delete('cloud-member'), isTrue);

    await repo.createPlaceholder(
      ledgerId: 'local-ledger',
      name: '本地成员',
      id: 'local-member',
    );
    await repo.rename(id: 'local-member', name: '本地成员新名');
    expect(await repo.delete('local-member'), isTrue);

    expect(recorder.records.map((record) => record.action), [
      'upsert',
      'upsert',
      'delete',
    ]);
    expect(
      recorder.records.every(
        (record) =>
            record.entityType == 'member' &&
            record.entityId == 'cloud-member' &&
            record.ledgerId == 'cloud-ledger',
      ),
      isTrue,
    );
    expect(
      recorder.records.map(
        (record) => jsonDecode(record.payload)['display_name'],
      ),
      ['云成员', '云成员新名', '云成员新名'],
    );
  });

  test('PLACEHOLDER mutation 登记失败时 create/rename/delete 均原子回滚', () async {
    await seedLedger('cloud-ledger', 'cloud');
    // 让真实 SQLite 拒绝队列写入，验证成员写入与实际登记器共用事务。
    await db.customStatement('''
      CREATE TEMP TRIGGER reject_member_change BEFORE INSERT ON sync_changes
      WHEN NEW.entity_type = 'member'
      BEGIN SELECT RAISE(ABORT, 'outbox unavailable'); END
    ''');
    final repo = LocalLedgerMemberRepository(
      db,
      trackerGetter: () =>
          ChangeRecorderImpl(db, accountIdGetter: () => 'cloud-account'),
    );

    await expectLater(
      repo.createPlaceholder(
        ledgerId: 'cloud-ledger',
        name: '创建失败',
        id: 'create-failed',
      ),
      throwsA(isA<SqliteException>()),
    );
    expect(
      await (db.select(db.ledgerMembers)
            ..where((member) => member.id.equals('create-failed')))
          .getSingleOrNull(),
      isNull,
    );

    await seedMember(
      id: 'rename-failed',
      ledgerId: 'cloud-ledger',
      memberType: 'PLACEHOLDER',
    );
    await expectLater(
      repo.rename(id: 'rename-failed', name: '不应落库'),
      throwsA(isA<SqliteException>()),
    );
    expect(
      await (db.select(
        db.ledgerMembers,
      )..where((member) => member.id.equals('rename-failed'))).getSingle(),
      predicate<LedgerMember>(
        (member) => member.displayName == 'rename-failed',
      ),
    );

    await seedMember(
      id: 'delete-failed',
      ledgerId: 'cloud-ledger',
      memberType: 'PLACEHOLDER',
    );
    await expectLater(
      repo.delete('delete-failed'),
      throwsA(isA<SqliteException>()),
    );
    expect(
      await (db.select(db.ledgerMembers)
            ..where((member) => member.id.equals('delete-failed')))
          .getSingleOrNull(),
      isNotNull,
    );
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('云账本离线创建成员后，重开数据库保留成员及同账号待同步任务', () async {
    final tempRoot = await Directory('Temp').create(recursive: true);
    final temp = await tempRoot.createTemp('offline_member_');
    final file = File('${temp.path}/member.sqlite');
    SesameDatabase? persisted;
    try {
      persisted = SesameDatabase.withExecutor(NativeDatabase(file));
      await persisted
          .into(persisted.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: 'offline-cloud',
              name: '离线云账本',
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('cloud-account'),
              updatedAt: DateTime.utc(2026, 9, 6),
            ),
          );
      final recorder = ChangeRecorderImpl(
        persisted,
        accountIdGetter: () => 'cloud-account',
      );
      await LocalLedgerMemberRepository(
        persisted,
        trackerGetter: () => recorder,
      ).createPlaceholder(
        ledgerId: 'offline-cloud',
        name: '离线成员',
        id: 'offline-member',
      );
      final originalPayload =
          (await persisted.select(persisted.syncChanges).getSingle()).payload;
      await persisted.close();
      persisted = null;

      // 使用新的磁盘连接验证持久化结果，不依赖原连接的查询缓存。
      persisted = SesameDatabase.withExecutor(NativeDatabase(file));
      final member = await persisted
          .select(persisted.ledgerMembers)
          .getSingle();
      final pending = await persisted.select(persisted.syncChanges).getSingle();
      expect(member.id, 'offline-member');
      expect(member.displayName, '离线成员');
      expect(pending.entityType, 'member');
      expect(pending.entityId, member.id);
      expect(pending.ledgerId, 'offline-cloud');
      expect(pending.accountId, 'cloud-account');
      expect(pending.action, 'upsert');
      expect(pending.payload, originalPayload, reason: '重开后精确时间和正文都必须保留');
      final payload = jsonDecode(pending.payload) as Map<String, dynamic>;
      expect(payload.keys, unorderedEquals(['display_name', 'updated_at']));
      expect(payload['display_name'], '离线成员');
      expect(
        DateTime.parse(
          payload['updated_at'] as String,
        ).difference(member.updatedAt).inMicroseconds,
        inInclusiveRange(0, 999999),
        reason: 'JSON 保留被 SQLite 秒列截去的真实子秒精度',
      );
      expect(pending.mutationId, isNotEmpty);
      expect(pending.pushedAt, isNull);
      expect(pending.rejectionReason, isNull);
    } finally {
      await persisted?.close();
      await temp.delete(recursive: true);
    }
  });

  test('PLACEHOLDER 活跃付款人引用受保护，普通交易墓碑允许删除成员', () async {
    await seedLedger('cloud-ledger', 'cloud');
    await seedMember(
      id: 'active-payer',
      ledgerId: 'cloud-ledger',
      memberType: 'PLACEHOLDER',
    );
    await seedMember(
      id: 'deleted-tx-member',
      ledgerId: 'cloud-ledger',
      memberType: 'PLACEHOLDER',
    );
    final activeAt = DateTime.utc(2026, 8, 24, 10);
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'active-tx',
            ledgerId: 'cloud-ledger',
            txType: 'expense',
            amount: '10',
            happenedAt: activeAt,
            currencyCode: 'CNY',
            nativeAmount: '10',
            payerMemberId: const d.Value('active-payer'),
            createdAt: activeAt,
            updatedAt: activeAt,
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 'deleted-tx',
            ledgerId: 'cloud-ledger',
            txType: 'expense',
            amount: '20',
            happenedAt: activeAt,
            currencyCode: 'CNY',
            nativeAmount: '20',
            payerMemberId: const d.Value('deleted-tx-member'),
            createdAt: activeAt,
            updatedAt: activeAt,
            deletedAt: d.Value(DateTime.utc(2026, 8, 24, 11)),
          ),
        );
    await db
        .into(db.transactionSplits)
        .insert(
          TransactionSplitsCompanion.insert(
            transactionId: 'deleted-tx',
            memberId: 'deleted-tx-member',
            amount: '20',
          ),
        );
    final repo = LocalLedgerMemberRepository(db);

    expect(await repo.isReferencedByAnyTransaction('active-payer'), isTrue);
    await expectLater(repo.delete('active-payer'), throwsA(isA<StateError>()));
    expect(
      await repo.isReferencedByAnyTransaction('deleted-tx-member'),
      isFalse,
      reason: '交易 tombstone 不得永久阻止已无活跃账务引用的占位成员删除',
    );
    expect(await repo.delete('deleted-tx-member'), isTrue);
  });
}
