import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 已缓存的编辑历史按记录时间统一展示。
///
/// 本机历史与云端历史缓存都来自本机数据库，不在此发起网络请求，
/// 因此没有加载、重试或错误态：读不到时按“暂无编辑历史”展示。
class TransactionHistorySection extends ConsumerWidget {
  const TransactionHistorySection({
    super.key,
    required this.recordId,
    required this.displayNameOf,
  });
  final String recordId;
  final String Function(String?) displayNameOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final history = ref.watch(recordEditHistoryProvider(recordId));
    final items = history.value ?? const <RecordEditHistoryDisplay>[];
    // 首次本机查询期间不占位、不转圈，数据到达后直接替换为空态或历史行。
    if (history.isLoading && !history.hasValue) return const SizedBox.shrink();
    if (items.isEmpty) return _message(context, l10n.homeDetailNoHistory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          _HistoryRow(
            version: item.version,
            operatorName: _operatorName(item),
            summary: _summary(item, l10n),
            createdAt: item.createdAt,
          ),
      ],
    );
  }

  /// 优先使用本机成员目录的当前名称，成员已不存在时回退缓存的云端名称。
  String _operatorName(RecordEditHistoryDisplay item) {
    final local = displayNameOf(item.operatorMemberId).trim();
    if (local.isNotEmpty) return local;
    return item.operatorDisplayName?.trim() ?? '';
  }

  /// 本机历史保存的是已生成摘要，云端历史保留原始变更正文。
  String _summary(RecordEditHistoryDisplay item, AppLocalizations l10n) {
    if (item.isCloud) return describeCloudHistoryChanges(item.changes, l10n);
    final summary = item.summary?.trim() ?? '';
    return summary.isEmpty ? l10n.recordHistoryUpdated : summary;
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
