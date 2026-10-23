import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';

import '../helpers/test_isolation.dart';

const _viewer = '10000000-0000-4000-8000-000000000001';
const _owner = '10000000-0000-4000-8000-000000000002';
const _sourceBook = '20000000-0000-4000-8000-000000000001';
const _targetBook = '20000000-0000-4000-8000-000000000002';
const _category = '30000000-0000-4000-8000-000000000001';
const _transaction = '40000000-0000-4000-8000-000000000001';
final _stamp = DateTime.utc(2026, 10, 11, 1, 2, 3, 980);

/// 隔离恢复源与在线缓存遵循相同所有者证据，role或查看者账号不能认领分类目录。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late SesameDatabase backup;
  late LocalLedgerRepository repository;
  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    backup = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = LocalLedgerRepository(db, accountIdGetter: () => _viewer);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _targetBook,
            name: '目标本地副本',
            storageMode: const d.Value('local'),
            updatedAt: _stamp,
          ),
        );
  });
  tearDown(() async {
    await backup.close();
    await db.close();
  });

  /// 模拟真实云源；旧role默认owner可与实际共享所有者不同。
  Future<void> sourceLedger(SesameDatabase source, String? owner) async {
    await source
        .into(source.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: _sourceBook,
            name: '源云账本',
            storageMode: const d.Value('cloud'),
            scopeAccountId: const d.Value(_viewer),
            ownerAccountId: d.Value(owner),
            role: const d.Value('owner'),
            updatedAt: _stamp,
          ),
        );
    await source
        .into(source.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: _transaction,
            ledgerId: _sourceBook,
            txType: 'expense',
            amount: '10',
            nativeAmount: '10',
            currencyCode: 'CNY',
            categoryId: const d.Value(_category),
            happenedAt: _stamp,
            createdAt: _stamp,
            updatedAt: _stamp,
          ),
        );
  }

  /// 主表相同UUID的缓存不参与共享来源目录；明确本人源才读取本人的私有行。
  Future<void> category(SesameDatabase source, String scope, String name) =>
      source
          .into(source.categories)
          .insert(
            CategoriesCompanion.insert(
              id: _category,
              name: name,
              kind: 'expense',
              level: 1,
              scopeAccountId: d.Value(scope),
              cloudRegistered: const d.Value(true),
              updatedAt: _stamp,
            ),
          );

  for (final isolatedBackup in [false, true]) {
    test(
      '${isolatedBackup ? '隔离备份' : '在线缓存'}源缺Owner时不能以旧roleowner或查看者同UUID类别猜测来源',
      () async {
        final source = isolatedBackup ? backup : db;
        await sourceLedger(source, null);
        await category(source, _viewer, '查看者私人分类');
        await category(source, _owner, '其他账号私人分类');
        final targetBefore = await db.select(db.categories).get();
        final txBefore = await db.select(db.transactions).get();
        final sourceBefore = await source.select(source.categories).get();
        await expectLater(
          repository.copyLedgerData(
            sourceLedgerId: _sourceBook,
            targetLedgerId: _targetBook,
            sourceDb: isolatedBackup ? backup : null,
          ),
          throwsStateError,
        );
        expect(await db.select(db.categories).get(), targetBefore);
        expect(await db.select(db.transactions).get(), txBefore);
        expect(await source.select(source.categories).get(), sourceBefore);
      },
    );
  }

  test('实际Owner不同于查看者时只复制准确账本镜像，旧roleowner和同UUID私有缓存都不能影响结果', () async {
    await sourceLedger(backup, _owner);
    await category(backup, _viewer, '查看者私人分类');
    await category(backup, _owner, '其他账号私人分类');
    await backup
        .into(backup.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: _sourceBook,
            categoryId: _category,
            name: '账本权威分类',
            kind: 'expense',
            updatedAt: _stamp,
          ),
        );
    final before = await backup.select(backup.categories).get();
    await repository.copyLedgerData(
      sourceLedgerId: _sourceBook,
      targetLedgerId: _targetBook,
      sourceDb: backup,
    );
    final local = await (db.select(
      db.categories,
    )..where((c) => categoryScopePredicate(c, null))).getSingle();
    expect(
      (local.id, local.name, local.cloudRegistered),
      (_category, '账本权威分类', false),
    );
    expect(local.updatedAt.millisecond, 980);
    expect(
      (await db.select(db.transactions).getSingle()).categoryId,
      _category,
    );
    expect(await backup.select(backup.categories).get(), before);
  });

  test('隔离源具有明确Owner证据时可复制自己的分类原身份，目标独立本地目录不带云登记事实', () async {
    await sourceLedger(backup, _viewer);
    await category(backup, _viewer, '本人权威分类');
    await category(backup, _owner, '其他账号私人分类');
    await repository.copyLedgerData(
      sourceLedgerId: _sourceBook,
      targetLedgerId: _targetBook,
      sourceDb: backup,
    );
    final local = await db.select(db.categories).getSingle();
    expect(
      (local.id, local.name, local.scopeAccountId, local.cloudRegistered),
      (_category, '本人权威分类', null, false),
    );
    expect(
      (await db.select(db.transactions).getSingle()).categoryId,
      _category,
    );
  });

  test('目标云账本缺实际Owner时拒绝迁入，查看者scope不构成所有者证据', () async {
    await sourceLedger(backup, _viewer);
    await category(backup, _viewer, '本人权威分类');
    await (db.update(db.ledgers)..where((l) => l.id.equals(_targetBook))).write(
      const LedgersCompanion(
        storageMode: d.Value('cloud'),
        scopeAccountId: d.Value(_viewer),
        role: d.Value('owner'),
      ),
    );
    await expectLater(
      repository.copyLedgerData(
        sourceLedgerId: _sourceBook,
        targetLedgerId: _targetBook,
        sourceDb: backup,
      ),
      throwsStateError,
    );
    expect(await db.select(db.categories).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
  });
}
