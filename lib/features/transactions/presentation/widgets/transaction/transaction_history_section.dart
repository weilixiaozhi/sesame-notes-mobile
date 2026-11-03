import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/statistics/application/cloud_record_history_provider.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 本机编辑序号与云端修订历史独立展示，分页错误保留已加载内容。
class TransactionHistorySection extends ConsumerWidget {
  const TransactionHistorySection({
    super.key,
    required this.ledgerId,
    required this.recordId,
    required this.isCloud,
    required this.displayNameOf,
  });
  final String ledgerId;
  final String recordId;
  final bool isCloud;
  final String Function(String?) displayNameOf;

  /// 使用原详情页文字、标签与间距 token，读取失败有独立文案和重试。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final local = ref.watch(recordEditHistoryProvider(recordId));
    final query = (ledgerId: ledgerId, recordId: recordId);
    final cloud = isCloud ? ref.watch(cloudRecordHistoryProvider(query)) : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cloud != null) ...[
          _title(
            context,
            l10n.recordHistoryCloud,
            action: TextButton(
              onPressed: () =>
                  ref.invalidate(cloudRecordHistoryProvider(query)),
              child: Text(l10n.recordHistoryRefresh),
            ),
          ),
          _message(context, l10n.recordHistoryCloudHint),
          cloud.when(
            skipLoadingOnReload: false,
            skipLoadingOnRefresh: false,
            data: (value) {
              if (value.context.awaitingUpload) {
                return _message(context, l10n.recordHistoryAwaitingUpload);
              }
              if (!value.context.isCloud) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (value.items.isEmpty)
                    _message(context, l10n.homeDetailNoHistory),
                  for (final item in value.items)
                    _HistoryRow(
                      version: item.version,
                      operatorName:
                          item.operatorDisplayName?.trim().isNotEmpty == true
                          ? item.operatorDisplayName!
                          : displayNameOf(item.operatorMemberId),
                      summary: describeCloudHistoryChanges(item.changes, l10n),
                      createdAt: item.createdAt,
                    ),
                  if (value.pageFailed)
                    _message(context, l10n.recordHistoryLoadFailed),
                  if (value.nextCursor != null)
                    TextButton(
                      onPressed: value.loadingMore
                          ? null
                          : () => ref
                                .read(
                                  cloudRecordHistoryProvider(query).notifier,
                                )
                                .loadMore(),
                      child: value.loadingMore
                          ? _loading()
                          : Text(
                              value.pageFailed
                                  ? l10n.commonRetry
                                  : l10n.recordHistoryLoadMore,
                            ),
                    ),
                ],
              );
            },
            loading: _loading,
            error: (_, _) => _error(
              context,
              () => ref.invalidate(cloudRecordHistoryProvider(query)),
            ),
          ),
          const SizedBox(height: AppDimens.p8),
          _title(context, l10n.recordHistoryLocal),
          _message(context, l10n.recordHistoryLocalHint),
        ],
        local.when(
          skipLoadingOnReload: false,
          skipLoadingOnRefresh: false,
          data: (items) => items.isEmpty
              ? _message(context, l10n.homeDetailNoHistory)
              : Column(
                  children: [
                    for (final item in items)
                      _HistoryRow(
                        version: item.version,
                        operatorName: displayNameOf(item.operatorMemberId),
                        summary: item.summary,
                        createdAt: item.createdAt,
                      ),
                  ],
                ),
          loading: _loading,
          error: (_, _) => _error(
            context,
            () => ref.invalidate(recordEditHistoryProvider(recordId)),
          ),
        ),
      ],
    );
  }

  /// 分组标题使用来源名称，避免将两类版本序号误认为同一条时间线。
  Widget _title(BuildContext context, String title, {Widget? action}) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: AppTextTokens.label(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      ?action,
    ],
  );

  /// 说明不包含服务器原始错误或账号标识。
  Widget _message(BuildContext context, String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
    child: Text(
      message,
      style: AppTextTokens.caption(
        context,
      ).copyWith(color: AppTokens.textSecondary(context)),
    ),
  );

  /// 空记录与读取失败分开显示，失败可以重新请求。
  Widget _error(BuildContext context, VoidCallback retry) => Row(
    children: [
      Expanded(
        child: _message(
          context,
          AppLocalizations.of(context).recordHistoryLoadFailed,
        ),
      ),
      TextButton(
        onPressed: retry,
        child: Text(AppLocalizations.of(context).commonRetry),
      ),
    ],
  );

  /// 加载指示沿用详情页的图标尺寸与进度线宽。
  Widget _loading() => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppDimens.p8),
    child: Center(
      child: SizedBox(
        width: AppDimens.icon16,
        height: AppDimens.icon16,
        child: CircularProgressIndicator(
          strokeWidth: AppDimens.progressStrokeWidth,
        ),
      ),
    ),
  );
}

/// 按服务端实际保存的字段显示记录内容，不推测未提供的修改前值。
String describeCloudHistoryChanges(Object? changes, AppLocalizations l10n) {
  if (changes is! Map) return l10n.recordHistoryUpdated;
  if (changes['action'] == 'delete') return l10n.recordHistoryDeleted;
  if (changes['action'] == 'category-migration') {
    return l10n.recordHistoryCategoryMoved;
  }
  final values = <String>[];
  if (changes['operation'] == 'change-ledger-currency') {
    values.add(l10n.recordHistoryCurrencyChanged);
  }
  for (final (key, label) in [
    ('amount', l10n.homeDetailAmount),
    ('currency_code', l10n.homeDetailCurrency),
    ('native_amount', l10n.homeDetailNativeAmount),
    ('note', l10n.importFieldNote),
    ('category_name', l10n.homeDetailCategory),
  ]) {
    if (!changes.containsKey(key)) continue;
    final value = changes[key];
    // 金额和汇率不经过 double；直接保留服务端记录的十进制文本。
    if (value is String || value is num) {
      values.add('$label: ${value.toString().isEmpty ? '—' : value}');
    } else if (value == null && key == 'note') {
      values.add('$label: —');
    }
  }
  if (changes['happened_at'] is String) {
    final time = DateTime.tryParse(changes['happened_at'] as String);
    if (time != null) {
      values.add('${l10n.homeDetailDate}: ${_historyDate(time)}');
    }
  }
  if (changes.containsKey('category_id') &&
      !changes.containsKey('category_name')) {
    values.add(l10n.homeDetailCategory);
  }
  if ([
    'aa_mode',
    'aa_participants',
    'splits',
    'payer_member_id',
  ].any(changes.containsKey)) {
    values.add(l10n.recordHistorySharingValues);
  }
  return values.isEmpty ? l10n.recordHistoryUpdated : values.join('\n');
}

/// 带年份显示本地时间，跨年历史不会混淆。
String _historyDate(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

/// 历史原文可完整换行，保留金额精度和长备注的可读性。
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.version,
    required this.operatorName,
    required this.summary,
    required this.createdAt,
  });
  final int version;
  final String operatorName;
  final String summary;
  final DateTime createdAt;

  /// 成员不存在时显示未知用户，不向页面裸露成员标识。
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetailListTag(
          label: 'v$version',
          foregroundColor: AppTokens.primary(context),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p4,
            vertical: AppDimens.p4,
          ),
          emphasized: true,
        ),
        const SizedBox(width: AppDimens.p8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary,
                style: AppTextTokens.label(
                  context,
                ).copyWith(color: AppTokens.textPrimary(context)),
              ),
              const SizedBox(height: AppDimens.p4),
              Text(
                '${operatorName.trim().isEmpty ? AppLocalizations.of(context).aaUnknownUser : operatorName} · ${_historyDate(createdAt)}',
                style: AppTextTokens.caption(
                  context,
                ).copyWith(color: AppTokens.textTertiary(context)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
