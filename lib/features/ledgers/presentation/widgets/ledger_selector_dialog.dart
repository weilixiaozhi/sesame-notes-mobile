import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/data/models/ledger_display_item.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 显示账本选择器
///
/// [currentLedgerId] 当前选中的账本ID（可选，用于高亮显示）
/// Returns: 选中的账本ID，如果取消则返回null
Future<String?> showLedgerSelector(
  BuildContext context, {
  String? currentLedgerId,
}) async {
  return showDialog<String>(
    context: context,
    builder: (dialogContext) =>
        LedgerSelectorDialog(currentLedgerId: currentLedgerId),
  );
}

class LedgerSelectorDialog extends ConsumerStatefulWidget {
  final String? currentLedgerId;

  const LedgerSelectorDialog({super.key, this.currentLedgerId});

  @override
  ConsumerState<LedgerSelectorDialog> createState() =>
      _LedgerSelectorDialogState();
}

class _LedgerSelectorDialogState extends ConsumerState<LedgerSelectorDialog> {
  /// 账本列表 future 缓存：弹窗生命周期内只查一次，重建不重复读 DB。
  late final Future<List<LedgerDisplayItem>> _ledgersFuture;

  @override
  void initState() {
    super.initState();
    _ledgersFuture = ref.read(ledgerActionsProvider).getAll();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<List<LedgerDisplayItem>>(
      future: _ledgersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final ledgers = snapshot.data!;
        if (ledgers.isEmpty) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radius16),
            ),
            title: Text(l10n.ledgerSelectTitle),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimens.p16),
                child: Text(l10n.ledgersEmpty),
              ),
            ],
          );
        }

        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radius16),
          ),
          title: Text(l10n.ledgerSelectTitle),
          children: ledgers.map((ledger) {
            final isSelected = ledger.id == widget.currentLedgerId;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, ledger.id),
              child: Row(
                children: [
                  Icon(
                    isSelected ? AppIcons.checkCircle : AppIcons.radioUnchecked,
                    color: isSelected ? primaryColor : null,
                  ),
                  const SizedBox(width: AppDimens.p8),
                  Expanded(
                    child: Text(
                      ledger.name,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? primaryColor : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
