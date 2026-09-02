import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';

import '../../helpers/test_isolation.dart';

const _accountId = 'account-a';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => _accountId),
      accountIdGetter: () => _accountId,
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('云账本与同步分类写入时立即绑定当前账号域', () async {
    final cloudLedgerId = await repo.createLedger(
      name: '云账本',
      storageMode: 'cloud',
    );
    final localLedgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
    );
    await repo.createBoundLedger(id: 'bound-ledger', name: '已绑定账本');
    final categoryId = await repo.createCategory(name: '餐饮', kind: 'expense');
    final subcategoryId = await repo.createSubCategory(
      parentId: categoryId,
      name: '早餐',
      kind: 'expense',
    );
    final restoredCategoryId = await repo.createCategory(
      name: '恢复分类',
      kind: 'expense',
      recordChanges: false,
    );

    final ledgers = {
      for (final row in await db.select(db.ledgers).get()) row.id: row,
    };
    final categories = {
      for (final row in await db.select(db.categories).get()) row.id: row,
    };

    expect(ledgers[cloudLedgerId]?.scopeAccountId, _accountId);
    expect(ledgers['bound-ledger']?.scopeAccountId, _accountId);
    expect(ledgers[localLedgerId]?.scopeAccountId, isNull);
    expect(categories[categoryId]?.scopeAccountId, _accountId);
    expect(categories[subcategoryId]?.scopeAccountId, _accountId);
    expect(
      categories[restoredCategoryId]?.scopeAccountId,
      isNull,
      reason: 'recordChanges=false 的恢复数据不得被认领为当前账号云数据',
    );

    final changes = await db.select(db.syncChanges).get();
    expect(changes, isNotEmpty);
    expect(changes.every((change) => change.accountId == _accountId), isTrue);
  });

  test('编辑遗留 null-scope 云实体时认领账号域并推进账本 LWW 时间', () async {
    final oldUpdatedAt = DateTime.utc(2020);
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: 'legacy-ledger',
            name: '旧账本',
            storageMode: const d.Value('cloud'),
            updatedAt: oldUpdatedAt,
          ),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'legacy-category',
            name: '旧分类',
            kind: 'expense',
            level: 1,
            updatedAt: oldUpdatedAt,
          ),
        );

    await repo.updateLedger(id: 'legacy-ledger', name: '新账本');
    await repo.updateCategory('legacy-category', name: '新分类');

    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals('legacy-ledger'))).getSingle();
    final category = await (db.select(
      db.categories,
    )..where((row) => row.id.equals('legacy-category'))).getSingle();
    final changes =
        await (db.select(db.syncChanges)..where(
              (change) =>
                  change.entityId.isIn(['legacy-ledger', 'legacy-category']),
            ))
            .get();

    expect(ledger.scopeAccountId, _accountId);
    expect(category.scopeAccountId, _accountId);
    expect(ledger.updatedAt.isAfter(oldUpdatedAt), isTrue);
    expect(changes, hasLength(2));
    expect(changes.every((change) => change.accountId == _accountId), isTrue);
    expect(
      changes.singleWhere((change) => change.entityType == 'ledger').updatedAt,
      ledger.updatedAt,
      reason: '账本行与 mutation 必须共享同一 LWW 时间',
    );
  });

  test('云账本断联转本地时清除账号域，避免登出清理误删本地副本', () async {
    final ledgerId = await repo.createLedger(
      name: '断联账本',
      storageMode: 'cloud',
    );

    await repo.detachFromCloud(ledgerId);

    final ledger = await (db.select(
      db.ledgers,
    )..where((row) => row.id.equals(ledgerId))).getSingle();
    expect(ledger.storageMode, 'local');
    expect(ledger.scopeAccountId, isNull);
    expect(ledger.syncId, isNull);
  });
}
