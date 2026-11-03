import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/features/statistics/application/cloud_record_history_provider.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 已读取的编辑历史按记录时间统一展示，来源内部序号仅用于同一时间的稳定排序。
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

  /// 只使用当前读取成功的内容；重新校验身份时不展示上一次请求携带的缓存值。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final local = ref.watch(recordEditHistoryProvider(recordId));
    final query = (ledgerId: ledgerId, recordId: recordId);
    final cloud = isCloud ? ref.watch(cloudRecordHistoryProvider(query)) : null;
    final localItems = !local.isLoading && !local.hasError
        ? local.asData?.value ?? const <RecordEditHistoryDisplay>[]
        : const <RecordEditHistoryDisplay>[];
    final cloudValue = cloud != null && !cloud.isLoading && !cloud.hasError
        ? cloud.asData?.value
        : null;
    final cloudItems = cloudValue?.context.isCloud == true
        ? cloudValue!.items
        : const <CloudRecordHistoryEntry>[];
    final items = _mergeHistoryRows(
      localItems,
      cloudItems,
      l10n,
      displayNameOf,
    );
    final loading = local.isLoading || (cloud?.isLoading ?? false);
    final failed = local.hasError || (cloud?.hasError ?? false);
    final pageFailed = cloudValue?.pageFailed ?? false;

    /// 仅重试失败的读取，成功的另一部分和已加载页面保持可见。
    void retry() {
      if (local.hasError) ref.invalidate(recordEditHistoryProvider(recordId));
      if (cloud?.hasError ?? false) {
        ref.invalidate(cloudRecordHistoryProvider(query));
      } else if (pageFailed) {
        ref.read(cloudRecordHistoryProvider(query).notifier).loadMore();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          _HistoryRow(
            version: item.version,
            operatorName: item.operatorName,
            summary: item.summary,
            createdAt: item.createdAt,
          ),
        if (items.isEmpty && !loading && !failed && !pageFailed)
          _message(context, l10n.homeDetailNoHistory),
        if (loading) _loading(),
        if (failed) _error(context, retry),
        if (pageFailed && !failed)
          _message(context, l10n.recordHistoryLoadFailed),
        if (cloudValue?.nextCursor != null && !(failed && pageFailed))
          TextButton(
            onPressed: cloudValue!.loadingMore
                ? null
                : () => ref
                      .read(cloudRecordHistoryProvider(query).notifier)
                      .loadMore(),
            child: cloudValue.loadingMore
                ? _loading()
                : Text(
                    pageFailed ? l10n.commonRetry : l10n.recordHistoryLoadMore,
                  ),
          ),
      ],
    );
  }

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

/// 排序信息仅在页面内使用，不改写来源版本号，也不把相似记录当作同一事件删除。
class _HistoryEntry {
  const _HistoryEntry({
    required this.createdAt,
    required this.operatorName,
    required this.summary,
    required this.sourceOrder,
    required this.version,
    required this.index,
  });
  final DateTime createdAt;
  final String operatorName;
  final String summary;
  final int sourceOrder;
  final int version;
  final int index;
}

/// 合并全部已读条目，先按时间倒序，再以内部来源、序号和原位置保证相同时刻顺序稳定。
List<_HistoryEntry> _mergeHistoryRows(
  List<RecordEditHistoryDisplay> local,
  List<CloudRecordHistoryEntry> cloud,
  AppLocalizations l10n,
  String Function(String?) displayNameOf,
) {
  try {
    final result = <_HistoryEntry>[
      for (var i = 0; i < cloud.length; i++)
        _HistoryEntry(
          createdAt: cloud[i].createdAt,
          operatorName: cloud[i].operatorDisplayName?.trim().isNotEmpty == true
              ? cloud[i].operatorDisplayName!
              : displayNameOf(cloud[i].operatorMemberId),
          summary: describeCloudHistoryChanges(cloud[i].changes, l10n),
          sourceOrder: 0,
          version: cloud[i].version,
          index: i,
        ),
      for (var i = 0; i < local.length; i++)
        _HistoryEntry(
          createdAt: local[i].createdAt,
          operatorName: displayNameOf(local[i].operatorMemberId),
          summary: local[i].summary,
          sourceOrder: 1,
          version: local[i].version,
          index: i,
        ),
    ];
    result.sort((a, b) {
      final time = b.createdAt.compareTo(a.createdAt);
      if (time != 0) return time;
      final source = a.sourceOrder.compareTo(b.sourceOrder);
      if (source != 0) return source;
      final version = b.version.compareTo(a.version);
      return version != 0 ? version : a.index.compareTo(b.index);
    });
    return result;
  } catch (error, stack) {
    logger.error('RecordHistory', '整理编辑历史失败', safeErrorSummary(error), stack);
    rethrow;
  }
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
