import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/features/categories/application/category_template_logic.dart';

export 'category_template_logic.dart';

/// 页面固定账号、会话与当前账本，旧页面不能把选择提交到新目录。
class TemplateInsertSession {
  TemplateInsertSession._(this._repo, this._assertCurrent);
  final CategoryRepository _repo;
  final void Function() _assertCurrent;

  /// 在所有异步边界复核原会话与数据域。
  void assertCurrent() => _assertCurrent();
}

/// 页面打开时捕获；确认、取消及失败重试均沿用同一会话。
TemplateInsertSession captureTemplateInsertSession(ProviderReader read) {
  final account = read(currentAccountIdProvider);
  final generation = read(authSessionProvider.notifier).identityGeneration;
  final ledgerId = read(currentLedgerIdProvider);
  final repo = read(categoryDataAccessProvider);
  return TemplateInsertSession._(repo, () {
    if (read(currentAccountIdProvider) != account ||
        read(authSessionProvider.notifier).identityGeneration != generation ||
        read(currentLedgerIdProvider) != ledgerId ||
        !identical(read(categoryDataAccessProvider), repo)) {
      throw StateError('CATEGORY_TEMPLATE_SCOPE_CHANGED');
    }
  });
}

/// 将冻结计划提交到捕获的本人分类目录，事务结束前再次复核会话。
Future<int> executeTemplateInsertPlanFromUi({
  required TemplateInsertPlan plan,
  required TemplateInsertSession session,
}) {
  session.assertCurrent();
  return executeTemplateInsertPlan(
    repo: session._repo,
    plan: plan,
    assertCurrent: session.assertCurrent,
  );
}
