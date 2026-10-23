import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/category_display.dart';
import 'package:sesame_notes/data/mappers/category_display_mapper.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'account_state_provider.dart';
import 'accounting_repositories.dart';
import 'database_signals.dart';

/// 当前账号分类目录，身份代次变化时重新读取。
final categoriesProvider = FutureProvider<List<CategoryDisplay>>((ref) async {
  ref.watch(currentAccountIdProvider);
  ref.watch(authIdentityGenerationProvider);
  ref.watch(accountingDataChangeSignalProvider);
  final repo = ref.watch(categoryQueriesProvider);
  return (await repo.getAllCategories())
      .map((row) => row.toDisplay())
      .toList(growable: false);
});

/// 当前账号分类与交易笔数流，身份变化时建立独立订阅。
final categoriesWithCountProvider =
    StreamProvider.autoDispose<
      List<({CategoryDisplay category, int transactionCount})>
    >((ref) {
      ref.watch(currentAccountIdProvider);
      ref.watch(authIdentityGenerationProvider);
      final repo = ref.watch(categoryQueriesProvider);
      return repo.watchCategoriesWithCount().map(
        (rows) => rows
            .map(
              (row) => (
                category: row.category.toDisplay(),
                transactionCount: row.transactionCount,
              ),
            )
            .toList(growable: false),
      );
    });

/// 按 id 缓存的分类查询（UUID）。
final categoryByIdProvider = FutureProvider.autoDispose
    .family<CategoryDisplay?, String>((ref, categoryId) async {
      ref.watch(currentAccountIdProvider);
      ref.watch(authIdentityGenerationProvider);
      ref.watch(accountingDataChangeSignalProvider);
      final repo = ref.watch(categoryQueriesProvider);
      return (await repo.getCategoryById(categoryId))?.toDisplay();
    });
