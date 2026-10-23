import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/utils/default_category_ids.dart';
import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';

export 'package:sesame_notes/features/categories/application/category_template_logic.dart'
    show
        CategoryTemplateItem,
        CategoryTemplateGroup,
        CategoryTemplateBlockReason,
        TemplateInsertPlan,
        TemplateInsertResult,
        ExistingCategoryIndex,
        buildFlatTemplateItems,
        buildHierarchicalTemplateGroups,
        toggleFlatSelection,
        computeFlatSelectAll,
        computeHierarchicalSelectAll,
        buildInsertPlan;

/// 确认对话框始终绑定最初账号与仓储，重新登录同账号也不能续用旧意图。
class TemplateInsertSession {
  TemplateInsertSession._(this._repo, this._assertCurrent);
  final CategoryRepository _repo;
  final void Function() _assertCurrent;

  void assertCurrent() => _assertCurrent();
}

/// 页面在第一次执行前捕获，同一恢复确认流程的后续执行传入相同对象。
TemplateInsertSession captureTemplateInsertSession(ProviderReader read) {
  final account = read(currentAccountIdProvider);
  final generation = read(authSessionProvider.notifier).identityGeneration;
  final repo = read(categoryDataAccessProvider);
  return TemplateInsertSession._(repo, () {
    if (read(currentAccountIdProvider) != account ||
        read(authSessionProvider.notifier).identityGeneration != generation ||
        !identical(read(categoryDataAccessProvider), repo)) {
      throw StateError('CATEGORY_TEMPLATE_SCOPE_CHANGED');
    }
  });
}

/// UI 只传计划与确认选择，事务内每次异步边界复核账号身份。
Future<TemplateInsertResult> executeTemplateInsertPlanFromUi(
  ProviderReader read, {
  required TemplateInsertPlan plan,
  required List<db.CategoryDisplay> existingCategories,
  Set<String> restoreLocalDeletedIds = const {},
  TemplateInsertSession? session,
}) {
  final captured = session ?? captureTemplateInsertSession(read);
  captured.assertCurrent();
  return executeTemplateInsertPlan(
    repo: captured._repo,
    plan: plan,
    existingCategories: existingCategories,
    restoreLocalDeletedIds: restoreLocalDeletedIds,
    assertCurrent: captured.assertCurrent,
  );
}

/// 账号级候选及已排队的墓碑恢复意图在页面重新打开后仍保持待确认状态。
/// 活跃分类的普通待同步新增不属于人工确认，不能被误标为候选。
final categoryTemplatePendingIdsProvider = StreamProvider<Set<String>>((ref) {
  final account = ref.watch(currentAccountIdProvider);
  if (account == null) return Stream.value(const <String>{});
  final database = ref.watch(databaseProvider);
  return database
      .customSelect(
        '''
    SELECT entity_id FROM sync_conflicts
      WHERE account_id = ? AND entity_type = 'category' AND status = 'OPEN'
    UNION
    SELECT changes.entity_id FROM sync_changes AS changes
      LEFT JOIN categories AS category
        ON category.id = changes.entity_id
          AND category.scope_account_id = changes.account_id
      WHERE changes.account_id = ? AND changes.entity_type = 'category'
        AND changes.action = 'upsert' AND changes.pushed_at IS NULL
        AND json_extract(changes.payload, '\$.base_token') IS NULL
        AND (category.id IS NULL OR category.deleted_at IS NOT NULL)
    ''',
        variables: [Variable.withString(account), Variable.withString(account)],
        readsFrom: {
          database.syncConflicts,
          database.syncChanges,
          database.categories,
        },
      )
      .watch()
      .map(
        (rows) => {
          for (final row in rows)
            if (officialCategoryIdentities.containsKey(
              row.read<String>('entity_id'),
            ))
              row.read<String>('entity_id'),
        },
      );
});
