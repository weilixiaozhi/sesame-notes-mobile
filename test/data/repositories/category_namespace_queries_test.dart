import 'package:drift/drift.dart' as d;
import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/support/category_owner_guard.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_statistics_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _id = '11111111-1111-5111-8111-111111111111';

/// 只创建内存合成数据：登录者自己的分类与共享账本所有者分类使用相同模板身份。
Future<void> _seed(SesameDatabase db, {bool privateDeleted = false}) async {
  try {
    final now = DateTime.utc(2026, 10, 11);
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: _id,
            name: '登录者私有名称',
            kind: 'expense',
            level: 1,
            scopeAccountId: const d.Value('viewer'),
            updatedAt: now,
            deletedAt: d.Value(privateDeleted ? now : null),
          ),
        );
    for (final book in [
      (id: 'own', role: 'owner'),
      (id: 'shared', role: 'editor'),
    ]) {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: book.id,
              name: book.id,
              role: d.Value(book.role),
              memberCount: d.Value(book.role == 'editor' ? 2 : 1),
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('viewer'),
              ownerAccountId: d.Value(
                book.role == 'owner' ? 'viewer' : 'shared-owner',
              ),
              updatedAt: now,
            ),
          );
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 'transaction-${book.id}',
              ledgerId: book.id,
              txType: 'expense',
              amount: '10',
              happenedAt: now,
              categoryId: const d.Value(_id),
              currencyCode: 'CNY',
              nativeAmount: '10',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    await db
        .into(db.sharedLedgerCategories)
        .insert(
          SharedLedgerCategoriesCompanion.insert(
            ledgerId: 'shared',
            categoryId: _id,
            name: '共享账本所有者名称',
            kind: 'expense',
            updatedAt: now,
          ),
        );
  } catch (error, stackTrace) {
    logger.error('CategoryNamespaceAudit', '内存分类归属夹具创建失败', error, stackTrace);
    rethrow;
  }
}

/// 真实内存仓储验证账号与共享所有者的完整分类身份，所有变更只影响合成夹具。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  late SesameDatabase db;
  setUp(() => db = SesameDatabase.withExecutor(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('共享交易必须显示该账本所有者分类，不能被本人相同UUID分类覆盖', () async {
    try {
      await _seed(db);
      final rows = await LocalTransactionRepository(
        db,
      ).transactionsWithCategoryAll(ledgerId: 'shared');
      expect(rows.single.category?.name, '共享账本所有者名称');
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '共享交易分类身份验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('本人分类墓碑不能隐藏其他Owner相同UUID的共享分类', () async {
    try {
      await _seed(db, privateDeleted: true);
      final repository = LocalCategoryRepository(
        db,
        accountIdGetter: () => 'viewer',
      );
      final rows = await repository.filterCategoriesForLedgerPicker(
        await repository.getAllCategories(),
        ledgerId: 'shared',
        kind: 'expense',
      );
      expect(rows.map((category) => category.name), ['共享账本所有者名称']);
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '共享分类墓碑隔离验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('个人分类管理计数不能把其他Owner的同UUID共享交易算进来', () async {
    try {
      await _seed(db);
      final repository = LocalCategoryRepository(
        db,
        accountIdGetter: () => 'viewer',
      );
      expect(await repository.getTransactionCountByCategory(_id), 1);
    } catch (error, stackTrace) {
      logger.error(
        'CategoryNamespaceAudit',
        '个人分类关联计数归属验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('旧缓存role错误标成Owner时仍按真实Owner读取镜像', () async {
    try {
      await _seed(db);
      await (db.update(db.ledgers)..where((row) => row.id.equals('shared')))
          .write(const LedgersCompanion(role: d.Value('owner')));
      final rows = await LocalTransactionRepository(
        db,
      ).transactionsWithCategoryAll(ledgerId: 'shared');
      expect(rows.single.category?.name, '共享账本所有者名称');
      final mirrored = await LocalStatisticsRepository(
        db,
      ).getSharedSyntheticCategoriesForLedger('shared');
      expect(mirrored[_id]?.name, '共享账本所有者名称');
      final categories = LocalCategoryRepository(
        db,
        accountIdGetter: () => 'viewer',
      );
      expect(
        (await categories.getAllCategories(ledgerId: 'shared')).single.name,
        '共享账本所有者名称',
      );
    } catch (error, stackTrace) {
      logger.error(
        'CategoryNamespaceAudit',
        '真实所有者与旧角色区分验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('Cloud缺少真实Owner时要求先同步，不把镜像猜成本地域分类', () async {
    try {
      await _seed(db);
      await (db.update(db.ledgers)..where((row) => row.id.equals('shared')))
          .write(const LedgersCompanion(ownerAccountId: d.Value(null)));
      await expectLater(
        LocalTransactionRepository(
          db,
        ).transactionsWithCategoryAll(ledgerId: 'shared'),
        throwsStateError,
      );
      await expectLater(
        LocalStatisticsRepository(
          db,
        ).getSharedSyntheticCategoriesForLedger('shared'),
        throwsStateError,
      );
    } catch (error, stackTrace) {
      logger.error(
        'CategoryNamespaceAudit',
        '缺失Owner分类查询关闭验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('共享镜像缺失时交易不能回退显示本人同UUID的分类', () async {
    try {
      await _seed(db);
      await db.delete(db.sharedLedgerCategories).go();
      final rows = await LocalTransactionRepository(
        db,
      ).transactionsWithCategoryAll(ledgerId: 'shared');
      expect(rows.single.category, isNull);
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '共享分类缺失处理验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('不同账号及本地域相同UUID共存时每笔交易只解析所属目录一次', () async {
    try {
      await _seed(db);
      final now = DateTime.utc(2026, 10, 11);
      for (final source in [
        (scope: 'shared-owner', name: '账号A私有名称', ledger: 'owner-a'),
        (scope: null, name: '本地分类名称', ledger: 'local'),
      ]) {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: _id,
                name: source.name,
                kind: 'expense',
                level: 1,
                scopeAccountId: d.Value(source.scope),
                updatedAt: now,
              ),
            );
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: source.ledger,
                name: source.ledger,
                storageMode: d.Value(source.scope == null ? 'local' : 'cloud'),
                scopeAccountId: d.Value(source.scope),
                ownerAccountId: d.Value(source.scope),
                updatedAt: now,
              ),
            );
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: source.ledger,
                ledgerId: source.ledger,
                txType: 'expense',
                amount: '10',
                happenedAt: now,
                categoryId: const d.Value(_id),
                currencyCode: 'CNY',
                nativeAmount: '10',
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      final rows = await LocalTransactionRepository(
        db,
      ).transactionsWithCategoryAll();
      expect(rows, hasLength(4));
      expect(
        {for (final row in rows) row.t.ledgerId: row.category?.name},
        {
          'own': '登录者私有名称',
          'shared': '共享账本所有者名称',
          'owner-a': '账号A私有名称',
          'local': '本地分类名称',
        },
      );
      for (var read = 0; read < 3; read++) {
        final again = await LocalTransactionRepository(
          db,
        ).transactionsWithCategoryAll();
        expect(
          again.map((row) => row.t.id).toSet(),
          rows.map((row) => row.t.id).toSet(),
        );
        expect(again, hasLength(4));
      }
      expect(await db.select(db.transactions).get(), hasLength(4));
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '复合分类身份解析验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('共享统计读取Owner镜像且不受本人墓碑影响', () async {
    try {
      await _seed(db, privateDeleted: true);
      final totals = await LocalStatisticsRepository(db)
          .totalsByCategoryWithHierarchy(
            ledgerId: 'shared',
            type: 'expense',
            start: DateTime.utc(2026, 10, 1),
            end: DateTime.utc(2026, 11, 1),
          );
      expect(totals.single.name, '共享账本所有者名称');
      expect(totals.single.total, 10);
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '共享分类统计归属验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('同UUID不同Owner名称统计按固定账本分别输出且每笔交易仅计一次', () async {
    try {
      await _seed(db);
      final statistics = LocalStatisticsRepository(db);
      final byLedger =
          <
            String,
            List<
              ({
                String? id,
                String name,
                String? icon,
                String? parentId,
                int level,
                double total,
              })
            >
          >{};
      for (final ledger in ['own', 'shared']) {
        byLedger[ledger] = await statistics.totalsByCategoryWithHierarchy(
          ledgerId: ledger,
          type: 'expense',
          start: DateTime.utc(2026, 10, 1),
          end: DateTime.utc(2026, 11, 1),
        );
      }
      expect(byLedger['own']!.single.id, _id);
      expect(byLedger['shared']!.single.id, _id);
      expect(byLedger['own']!.single.name, '登录者私有名称');
      expect(byLedger['shared']!.single.name, '共享账本所有者名称');
      expect(
        byLedger.values.expand((rows) => rows).map((row) => row.total).toList(),
        [10.0, 10.0],
      );
      expect(await db.select(db.transactions).get(), hasLength(2));
    } catch (error, stackTrace) {
      logger.error(
        'CategoryNamespaceAudit',
        '统计所有者身份分离验证失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  });

  test('共享镜像自己的墓碑不可选择，也不能回退复活本人同UUID分类', () async {
    try {
      await _seed(db);
      await (db.update(
        db.sharedLedgerCategories,
      )..where((row) => row.ledgerId.equals('shared'))).write(
        SharedLedgerCategoriesCompanion(
          deletedAt: d.Value(DateTime.utc(2026, 10, 12)),
        ),
      );
      final rows = await LocalTransactionRepository(
        db,
      ).transactionsWithCategoryAll(ledgerId: 'shared');
      expect(rows.single.category, isNull);
      final own = await LocalTransactionRepository(
        db,
      ).transactionsWithCategoryAll(ledgerId: 'own');
      expect(own.single.category?.name, '登录者私有名称');
      final repository = LocalCategoryRepository(
        db,
        accountIdGetter: () => 'viewer',
      );
      expect(
        await repository.filterCategoriesForLedgerPicker(
          await repository.getAllCategories(),
          ledgerId: 'shared',
        ),
        isEmpty,
      );
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '共享墓碑目录隔离验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('同名但不同父分类的真实分类保持独立统计，不按显示名称合并记录', () async {
    try {
      await _seed(db);
      final now = DateTime.utc(2026, 10, 11);
      for (final parent in [
        (id: 'parent-a', name: '餐饮'),
        (id: 'parent-b', name: '商务'),
      ]) {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: parent.id,
                name: parent.name,
                kind: 'expense',
                level: 1,
                scopeAccountId: const d.Value('viewer'),
                updatedAt: now,
              ),
            );
      }
      for (final child in [
        (id: 'child-a', parent: 'parent-a', amount: '20'),
        (id: 'child-b', parent: 'parent-b', amount: '30'),
      ]) {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                id: child.id,
                name: '咖啡',
                kind: 'expense',
                level: 2,
                parentId: d.Value(child.parent),
                scopeAccountId: const d.Value('viewer'),
                updatedAt: now,
              ),
            );
        await db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: child.id,
                ledgerId: 'own',
                txType: 'expense',
                amount: child.amount,
                happenedAt: now,
                categoryId: d.Value(child.id),
                currencyCode: 'CNY',
                nativeAmount: child.amount,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
      final totals = await LocalStatisticsRepository(db)
          .totalsByCategoryWithHierarchy(
            ledgerId: 'own',
            type: 'expense',
            start: DateTime.utc(2026, 10, 1),
            end: DateTime.utc(2026, 11, 1),
          );
      final coffees = totals.where((row) => row.name == '咖啡').toList();
      expect(coffees, hasLength(2));
      expect(coffees.map((row) => (row.id, row.parentId, row.total)).toSet(), {
        ('child-a', 'parent-a', 20.0),
        ('child-b', 'parent-b', 30.0),
      });
      expect(totals.fold<double>(0, (sum, row) => sum + row.total), 60);
      expect(await db.select(db.transactions).get(), hasLength(4));
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '真实分类独立统计验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('交易流监听镜像改名后仍按共享Owner输出', () async {
    StreamIterator<List<({Transaction t, Category? category})>>? iterator;
    try {
      await _seed(db);
      iterator = StreamIterator(
        LocalTransactionRepository(
          db,
        ).watchTransactionsWithCategoryAll(ledgerId: 'shared'),
      );
      expect(await iterator.moveNext(), isTrue);
      expect(iterator.current.single.category?.name, '共享账本所有者名称');
      await (db.update(
        db.sharedLedgerCategories,
      )..where((row) => row.ledgerId.equals('shared'))).write(
        const SharedLedgerCategoriesCompanion(name: d.Value('所有者更新名称')),
      );
      do {
        expect(
          await iterator.moveNext().timeout(const Duration(seconds: 3)),
          isTrue,
        );
      } while (iterator.current.single.category?.name != '所有者更新名称');
    } catch (error, stackTrace) {
      logger.error(
        'CategoryNamespaceAudit',
        '共享镜像分类流刷新验证失败',
        error,
        stackTrace,
      );
      rethrow;
    } finally {
      await iterator?.cancel();
    }
  });

  test('分类批量删除遇到相关未知Owner账本时提示同步且所有交易及队列不变', () async {
    try {
      await _seed(db);
      await (db.update(db.ledgers)..where((l) => l.id.equals('own'))).write(
        const LedgersCompanion(ownerAccountId: d.Value(null)),
      );
      final transactions = await db.select(db.transactions).get();
      final queue = await db.select(db.syncChanges).get();
      final repository = LocalRepository(
        db,
        accountIdGetter: () => 'viewer',
        changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'viewer'),
      );
      await expectLater(
        repository.deleteTransactionsByCategoryIds([_id]),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            '用户可操作的错误说明',
            categoryOwnerUnconfirmedMessage,
          ),
        ),
      );
      expect(await db.select(db.transactions).get(), transactions);
      expect(await db.select(db.syncChanges).get(), queue);
    } catch (error, stack) {
      logger.error('CategoryNamespaceAudit', '未知归属分类批量删除验证失败', error, stack);
      rethrow;
    }
  });

  test('个人分类批量删交易仅删除自己的Owner账本并只登记该账本', () async {
    try {
      await _seed(db);
      final recorder = ChangeRecorderImpl(db, accountIdGetter: () => 'viewer');
      final repository = LocalRepository(
        db,
        accountIdGetter: () => 'viewer',
        changeTracker: recorder,
      );
      expect(await repository.deleteTransactionsByCategoryIds([_id]), 1);
      final shared = await (db.select(
        db.transactions,
      )..where((row) => row.ledgerId.equals('shared'))).get();
      expect(shared, hasLength(1));
      expect(shared.single.deletedAt, isNull);
      final queued = await db.select(db.syncChanges).get();
      expect(queued.map((row) => row.ledgerId).toSet(), {'own'});
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '个人分类删除范围验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('个人分类迁移不能修改共享Owner同UUID交易', () async {
    try {
      await _seed(db);
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'target-category',
              name: '个人迁移目标',
              kind: 'expense',
              level: 1,
              scopeAccountId: const d.Value('viewer'),
              updatedAt: DateTime.utc(2026, 10, 11),
            ),
          );
      final recorder = ChangeRecorderImpl(db, accountIdGetter: () => 'viewer');
      final repository = LocalRepository(
        db,
        accountIdGetter: () => 'viewer',
        changeTracker: recorder,
      );
      expect(
        await repository.migrateCategoryTransactions(
          fromCategoryId: _id,
          toCategoryId: 'target-category',
        ),
        1,
      );
      final transactions = {
        for (final row in await db.select(db.transactions).get())
          row.ledgerId: row,
      };
      expect(transactions['own']?.categoryId, 'target-category');
      expect(transactions['shared']?.categoryId, _id);
      final queued = await db.select(db.syncChanges).get();
      expect(queued.map((row) => row.ledgerId).toSet(), {'own'});
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '个人分类迁移范围验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('清理私有分类只清自己周期规则，保留共享Owner同UUID引用', () async {
    try {
      await _seed(db);
      final now = DateTime.utc(2026, 10, 11);
      final recorder = ChangeRecorderImpl(db, accountIdGetter: () => 'viewer');
      final recurring = LocalRecurringTransactionRepository(
        db,
        trackerGetter: () => recorder,
      );
      for (final ledger in ['own', 'shared']) {
        await recurring.addRecurringTransaction(
          ledgerId: ledger,
          type: 'expense',
          amount: '10',
          categoryId: _id,
          frequency: 'monthly',
          interval: 1,
          startDate: now,
          timeZone: 'Asia/Shanghai',
        );
      }
      await recurring.clearCategoryReferences([_id], categoryScope: 'viewer');
      final rows = {
        for (final row in await db.select(db.recurringTransactions).get())
          row.ledgerId: row,
      };
      expect(rows['own']?.categoryId, isNull);
      expect(rows['shared']?.categoryId, _id);
      expect(rows['own']?.protocolVersion, recurringProtocolVersion);
    } catch (error, stackTrace) {
      logger.error('CategoryNamespaceAudit', '周期分类引用归属验证失败', error, stackTrace);
      rethrow;
    }
  });
}
