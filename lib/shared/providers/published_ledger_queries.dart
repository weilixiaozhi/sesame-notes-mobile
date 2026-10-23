import 'package:flutter_riverpod/misc.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/support/ledger_kind.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/application/support/account_snapshot_query.dart';
import 'account_state_provider.dart';
import 'accounting_repositories.dart';
import 'cloud_ledger_download_providers.dart';

/// 展示与选本共用的查询边界，异步结果只属于发起时的账号和会话。
Future<T> _publishedQuery<T>(
  TRead Function<TRead>(ProviderListenable<TRead>) read,
  Future<T> Function(String? account, Set<String> unpublished) query,
) {
  final account = read(currentAccountIdProvider);
  return readAccountSnapshot(
    area: 'PublishedLedgers',
    accountId: account,
    currentAccountId: () => read(currentAccountIdProvider),
    currentGeneration: () => read(authIdentityGenerationProvider),
    read: () async =>
        query(account, await read(unpublishedCloudLedgersProvider.future)),
  );
}

/// 读取已发布账本；归档过滤为空时供编辑、导出等入口读取任意归档状态。
Future<List<LedgerSnapshot>> readPublishedLedgers(
  T Function<T>(ProviderListenable<T>) read, {
  bool? archived = false,
}) => _publishedQuery(read, (account, unpublished) async {
  final rows = await read(ledgerDataAccessProvider).getAllLedgers();
  return [
    for (final row in rows)
      if (row.isPublishedTo(account, unpublished) &&
          (archived == null || (row.archivedAt != null) == archived))
        row,
  ];
});

/// 按标识复核已发布账本，阻止旧页面持有的候选绕过当前账号或首次下载状态。
Future<LedgerSnapshot?> readPublishedLedger(
  T Function<T>(ProviderListenable<T>) read,
  String id, {
  bool includeArchived = true,
}) => _publishedQuery(read, (account, unpublished) async {
  final row = await read(ledgerDataAccessProvider).getLedgerById(id);
  return row != null &&
          row.isPublishedTo(account, unpublished) &&
          (includeArchived || row.archivedAt == null)
      ? row
      : null;
});
