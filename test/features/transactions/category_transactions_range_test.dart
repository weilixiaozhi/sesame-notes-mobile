import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/transaction_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/transactions/application/transaction_actions.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

/// 使用真实数据库核对范围在仓储读取时生效，页面无需再筛选历史交易。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('分类 provider 按半开区间隔离父子交易，并保留实时更新', () async {
    final database = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repository = LocalRepository(database);
    ProviderContainer? container;
    try {
      final ledger = await repository.createLedger(
        name: '分类详情',
        storageMode: 'local',
      );
      final otherLedger = await repository.createLedger(
        name: '其他账本',
        storageMode: 'local',
      );
      final parent = await repository.createCategory(
        name: '餐饮',
        kind: 'expense',
      );
      final child = await repository.createSubCategory(
        parentId: parent,
        name: '午餐',
        kind: 'expense',
      );
      final otherCategory = await repository.createCategory(
        name: '交通',
        kind: 'expense',
      );
      final start = DateTime(2026, 11, 1);
      final end = DateTime(2026, 12, 1);

      /// 在同一分类目录中构造范围边界、父子分类及跨账本记录。
      Future<String> add(DateTime date, String category, {String? book}) =>
          repository.addTransaction(
            ledgerId: book ?? ledger,
            type: 'expense',
            amount: '10.00',
            categoryId: category,
            happenedAt: date,
          );

      await add(start.subtract(const Duration(seconds: 1)), parent);
      final first = await add(start, parent);
      final last = await add(end.subtract(const Duration(seconds: 1)), child);
      final nextMonth = await add(end, child);
      await add(start, child, book: otherLedger);
      await add(start, otherCategory);
      final deleted = await add(start, parent);
      await repository.deleteTransaction(deleted);

      container = ProviderContainer(
        overrides: [
          categoryQueriesProvider.overrideWithValue(repository.categoryStore),
          currentAccountIdProvider.overrideWith((ref) => null),
          authIdentityGenerationProvider.overrideWith((ref) => 0),
        ],
      );
      final november = categoryTransactionsProvider((
        categoryId: parent,
        ledgerId: ledger,
        start: start,
        end: end,
      ));
      final december = categoryTransactionsProvider((
        categoryId: parent,
        ledgerId: ledger,
        start: end,
        end: DateTime(2027, 1, 1),
      ));
      final refreshed = Completer<List<TransactionDisplay>>();
      var expectedLength = 2;
      final novemberSub = container.listen(november, (_, next) {
        if (expectedLength == 3 &&
            next.value?.length == expectedLength &&
            !refreshed.isCompleted) {
          refreshed.complete(next.value!);
        }
      });
      final decemberSub = container.listen(december, (_, _) {});
      try {
        expect((await container.read(november.future)).map((row) => row.id), [
          last,
          first,
        ], reason: '首日包含、结束日排除，且仅返回指定账本内的父子分类');
        expect((await container.read(december.future)).map((row) => row.id), [
          nextMonth,
        ], reason: '同分类的不同日期区间必须使用各自查询');
        expectedLength = 3;
        final added = await add(DateTime(2026, 11, 15), child);
        expect(
          (await refreshed.future.timeout(
            const Duration(seconds: 2),
          )).map((row) => row.id),
          [last, added, first],
          reason: '范围查询仍应响应本区间新增记录',
        );
        final all = await repository.categoryStore
            .watchTransactionsByCategory(
              parent,
              ledgerId: ledger,
              includeSubCategories: true,
            )
            .first;
        expect(all, hasLength(5), reason: '不传日期时仍可查询全部有效历史');
      } finally {
        novemberSub.close();
        decemberSub.close();
      }
    } catch (error, stackTrace) {
      debugPrint('分类日期范围回归失败：$error\n$stackTrace');
      rethrow;
    } finally {
      container?.dispose();
      await database.close();
    }
  });
}
