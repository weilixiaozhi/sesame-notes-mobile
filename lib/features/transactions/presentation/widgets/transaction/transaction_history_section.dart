import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
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
    this.fallbackCategoryName,
    this.fallbackAmount,
    this.fallbackHappenedAt,
  });
  final String recordId;
  final String Function(String?) displayNameOf;

  /// 老云端历史缺少展示快照时，用当前交易/分类补足旧格式摘要。
  final String? fallbackCategoryName;
  final String? fallbackAmount;
  final DateTime? fallbackHappenedAt;

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

  /// 本机历史保存的是已生成摘要，云端历史使用服务端展示快照。
  String _summary(RecordEditHistoryDisplay item, AppLocalizations l10n) {
    if (item.isCloud) return _cloudSummary(item.changes, l10n);
    final summary = item.summary?.trim() ?? '';
    return summary.isEmpty ? l10n.recordHistoryUpdated : summary;
  }

  /// 云端历史统一显示旧格式：分类 · 金额 · 发生时间，必要时追加变化提示。
  String _cloudSummary(Object? changes, AppLocalizations l10n) {
    if (changes is! Map) return l10n.recordHistoryUpdated;
    final display = changes['display'];
    final source = display is Map ? display : changes;
    final action =
        source['action'] ??
        (changes['operation'] == 'change-ledger-currency'
            ? 'ledger-currency'
            : null);
    if (action == 'delete') return l10n.recordHistoryDeleted;
    if (action == 'category-migration') {
      return l10n.recordHistoryCategoryMoved;
    }
    if (action == 'ledger-currency') {
      return l10n.recordHistoryCurrencyChanged;
    }

    final category =
        _nonEmpty(source['category_name']) ??
        _nonEmpty(changes['category_name']) ??
        _nonEmpty(fallbackCategoryName) ??
        l10n.commonUncategorized;
    final amount =
        _amountText(source['amount'] ?? changes['amount']) ??
        _amountText(fallbackAmount);
    final happenedAt =
        _dateTime(source['happened_at'] ?? changes['happened_at']) ??
        fallbackHappenedAt;
    // 旧数据缺金额和发生时间时无法组成旧格式，退回明确的安全文案。
    if (amount == null && happenedAt == null) {
      return l10n.recordHistoryUpdated;
    }
    var summary = [
      category,
      ?amount,
      if (happenedAt != null) _historyDate(happenedAt),
    ].join(' · ');
    if (display is Map) {
      if (display['note_changed'] == true) {
        summary = '$summary · ${l10n.recordHistoryNoteUpdated}';
      }
      if (display['sharing_changed'] == true) {
        summary = '$summary · ${l10n.recordHistorySharingUpdated}';
      }
    }
    return summary;
  }

  /// 旧历史只保留金额文本；统一按两位小数展示，避免暴露数据库精度。
  String? _amountText(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final amount = Decimal.tryParse(text);
    return amount == null ? text : amount.toStringAsFixed(2);
  }

  /// 历史时间只接受可解析的服务端 ISO 文本，损坏时退回当前交易时间。
  DateTime? _dateTime(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  /// 空字符串不能作为分类名或操作者名展示。
  String? _nonEmpty(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
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

/// 带年份显示本地时间，跨年历史不会混淆。
String _historyDate(DateTime time) {
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

/// 历史摘要可完整换行，不再显示内部版本号。
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.operatorName,
    required this.summary,
    required this.createdAt,
  });
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
