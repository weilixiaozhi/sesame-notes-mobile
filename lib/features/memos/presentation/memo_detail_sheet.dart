import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/features/memos/presentation/memo_entry_actions.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../data/models/memo.dart';
import '../../../l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/widgets/app_detail.dart';
import '../../../shared/widgets/app_empty.dart';
import '../../../shared/widgets/app_sheet.dart';
import '../../../shared/widgets/toast.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';
import '../../../theme/typography.dart';
import '../application/memo_providers.dart';
import 'package:sesame_notes/theme/colors.dart';

/// 打开内容前后复核同一固定目标，弹层期间的账号或绑定变化会使请求失效。
Future<void> openMemoEntry(
  BuildContext context,
  WidgetRef ref,
  MemoEntry summary,
) async {
  final analyticsContext = ref
      .read(productAnalyticsControllerProvider)
      .beginFlow();
  try {
    trackProductEntryAction(
      context,
      ref.read,
      fallbackPageId: summary.isCard ? 'credentials' : 'memos',
      action: summary.isCard
          ? ProductAction.credentialsOpenClick
          : ProductAction.memosNoteOpenClick,
      context: analyticsContext,
    );
    final actions = ref.read(memoActionsProvider);
    final snapshot = await actions.prepareEditor(
      summary.memoBookId,
      entryId: summary.id,
    );
    final entry = snapshot.entry!;
    if (!context.mounted) return;
    final edit =
        !entry.isCard ||
        await showAppSheet<bool>(
              context: context,
              heightFactor: 1,
              child: productAnalyticsPresentation(
                context: context,
                read: ref.read,
                pageId: 'credentials.detail',
                analyticsContext: analyticsContext,
                child: MemoDetailSheet(
                  book: snapshot.book,
                  target: snapshot.target,
                  entry: entry,
                ),
              ),
            ) ==
            true;
    if (!edit || !context.mounted) return;
    final fresh = await actions.prepareEditor(
      summary.memoBookId,
      entryId: summary.id,
      fixedTarget: snapshot.target,
    );
    if (!context.mounted) return;
    await context.pushNamed(
      Routes.memoEditor,
      extra: ProductAnalyticsNavigation(
        context: analyticsContext,
        arguments: (
          book: fresh.book,
          target: fresh.target,
          entryId: entry.id,
          entry: fresh.entry!,
        ),
      ),
    );
  } catch (_) {
    if (context.mounted) {
      showToast(context, AppLocalizations.of(context).memoUnavailable);
    }
  }
}

/// 账号密码详情可拖到安全区顶部。
class MemoDetailSheet extends ConsumerStatefulWidget {
  final MemoBook book;
  final PrivateBookTarget target;
  final MemoEntry entry;
  const MemoDetailSheet({
    super.key,
    required this.book,
    required this.target,
    required this.entry,
  });
  @override
  ConsumerState<MemoDetailSheet> createState() => _MemoDetailSheetState();
}

class _MemoDetailSheetState extends ConsumerState<MemoDetailSheet> {
  /// 详情与列表共用确认流程，删除后的内容状态决定是否返回。
  Future<void> _delete() async {
    final actions = ref.read(memoActionsProvider);
    await confirmMemoEntryDeletion(
      context,
      ref,
      widget.entry,
      target: widget.target,
      pageId: 'credentials.detail',
    );
    if (!mounted) return;
    try {
      if (await actions.getEntry(widget.entry.id, widget.target) == null &&
          mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  /// 复制只接受当前会话；平台拒绝时显示失败提示，日志不包含字段值。
  Future<void> _copy(String value) async {
    if (ref.read(currentAccountIdProvider) != widget.target.accountId ||
        ref.read(authIdentityGenerationProvider) != widget.target.generation) {
      return;
    }
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (mounted) showToast(context, AppLocalizations.of(context).memoCopied);
    } catch (error, stackTrace) {
      logger.error('MemoDetail', '复制字段失败', error.runtimeType, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final account = ref.watch(currentAccountIdProvider);
    final generation = ref.watch(authIdentityGenerationProvider);
    final books = ref.watch(memoBooksProvider);
    final valid =
        account == widget.target.accountId &&
        generation == widget.target.generation &&
        books.when(
          data: (books) => books.any(
            (b) => b.id == widget.book.id && !b.isStale && b.isComplete,
          ),
          error: (_, _) => false,
          loading: () => true,
        );
    if (!valid) return AppSheet(child: AppEmpty(text: l.memoUnavailable));
    final entry = widget.entry;
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 1,
      expand: false,
      builder: (context, scrollController) => AppSheet(
        footer: AppPrimaryButton(
          label: l.memoEditCard,
          onPressed: () => Navigator.pop(context, true),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            AppDetailHeader(
              icon: Icon(AppIcons.lock, size: AppDimens.icon20),
              title: entry.title.isEmpty ? l.memoUntitled : entry.title,
              subtitle: widget.book.name,
              onDelete: _delete,
            ),
            const SizedBox(height: AppDimens.p12),
            AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
            // 字段名由数据给出，任何字段都允许整行复制。
            for (final (label, value, copyable) in [
              (l.memoName, entry.title, false),
              for (final field in entry.fields)
                (field.label, field.value, true),
            ])
              Tooltip(
                message: copyable ? '${l.memoCopy}$label' : '',
                child: InkWell(
                  onTap: copyable && value.isNotEmpty
                      ? () => _copy(value)
                      : null,
                  // 所有字段使用同一行高，整行复制保留足够的点击区域。
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: kMinInteractiveDimension,
                    ),
                    child: Center(
                      child: AppDetailInfoRow(
                        label: label,
                        value: value,
                        valueWidget: copyable
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      value.isNotEmpty ? value : '—',
                                      style: AppTextTokens.body(context),
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.p4),
                                  Icon(
                                    AppIcons.copy,
                                    size: MediaQuery.textScalerOf(context)
                                        .scale(
                                          AppTextTokens.body(context).fontSize!,
                                        ),
                                  ),
                                ],
                              )
                            : SelectableText(
                                value.isNotEmpty ? value : '—',
                                style: AppTextTokens.body(context),
                                textAlign: TextAlign.right,
                                maxLines: 1,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
