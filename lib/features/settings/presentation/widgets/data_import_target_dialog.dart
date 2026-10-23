import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../../data/models/app_mode.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import '../../../../shared/providers/fitness_space_provider.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../shared/widgets/app_content_dialog.dart';
import '../../../../theme/icons/app_icons.dart';
import '../../../days/application/day_providers.dart';
import '../../../memos/application/memo_providers.dart';
import '../../application/day_file_actions.dart';
import '../../application/fitness_file_actions.dart';
import '../../application/import_actions.dart';
import '../../application/import_target.dart';
import 'import_book_selector.dart';
export '../../application/import_target.dart';

Future<DataImportTarget?> showDataImportTargetDialog(BuildContext context) =>
    showDialog<DataImportTarget>(
      context: context,
      builder: (_) => const _TargetDialog(),
    );

class _TargetDialog extends ConsumerStatefulWidget {
  const _TargetDialog();
  @override
  ConsumerState<_TargetDialog> createState() => _TargetDialogState();
}

class _TargetDialogState extends ConsumerState<_TargetDialog> {
  AppMode? _mode;
  bool _second = false, _busy = false;
  final _selected = <AppMode, String?>{};
  late final String? _account;
  late final int _generation;

  @override
  void initState() {
    super.initState();
    _account = ref.read(currentAccountIdProvider);
    _generation = ref.read(authIdentityGenerationProvider);
  }

  bool get _valid =>
      ref.read(currentAccountIdProvider) == _account &&
      ref.read(authIdentityGenerationProvider) == _generation;

  void _next() {
    if (!_valid) return;
    _selected.putIfAbsent(
      _mode!,
      () => switch (_mode!) {
        AppMode.bookkeeping => ref.read(currentLedgerIdProvider),
        AppMode.days => ref.read(currentDayBookIdProvider).value,
        AppMode.memos => ref.read(currentMemoBookIdProvider).value,
        AppMode.fitness => ref.read(currentFitnessSpaceIdProvider).value,
      },
    );
    setState(() => _second = true);
  }

  Future<void> _confirm() async {
    if (_busy || !_valid) return;
    final id = _selected[_mode]!;
    setState(() => _busy = true);
    try {
      final target = switch (_mode!) {
        AppMode.bookkeeping => DataImportTarget(
          ledgerTarget: await ref.read(importActionsProvider).target(id),
        ),
        AppMode.days => DataImportTarget(
          dayTarget: await ref.read(dayFileActionsProvider).target(id),
        ),
        AppMode.memos => DataImportTarget(
          memoTarget: await ref.read(memoActionsProvider).target(id),
        ),
        AppMode.fitness => DataImportTarget(
          fitnessTarget: await ref.read(fitnessFileActionsProvider).target(id),
        ),
      };
      if (!_valid) throw StateError('导入身份已改变');
      target.checkSession(ref.read(applicationReaderProvider));
      if (mounted) Navigator.pop(context, target);
    } catch (_) {
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.watch(currentAccountIdProvider);
    ref.watch(authIdentityGenerationProvider);
    final labels = {
      AppMode.bookkeeping: l.importContentLedger,
      AppMode.days: l.importContentDays,
      AppMode.memos: l.memosTab,
      AppMode.fitness: l.fitnessTitle,
    };
    return AppContentDialog(
      title: !_second
          ? l.importContentTitle
          : switch (_mode!) {
              AppMode.bookkeeping => l.ledgerSelectTitle,
              AppMode.days => l.daySelectBook,
              AppMode.memos => l.memoSelectBook,
              AppMode.fitness => l.fitnessSelectSpace,
            },
      icon: AppIcons.book,
      minContentHeight: 200,
      content: !_second
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final entry in labels.entries)
                  AppRadioTile(
                    title: entry.value,
                    selected: entry.key == _mode,
                    onTap: _busy || !_valid
                        ? null
                        : () => setState(() => _mode = entry.key),
                  ),
              ],
            )
          : ImportBookSelector(
              key: ValueKey(_mode),
              mode: _mode!,
              selectedId: _selected[_mode],
              enabled: !_busy && _valid,
              onChanged: (id) => setState(() => _selected[_mode!] = id),
            ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () {
                  if (_second) {
                    setState(() => _second = false);
                  } else {
                    Navigator.pop(context);
                  }
                },
          child: Text(_second ? l.commonPrevious : l.commonCancel),
        ),
        AppPrimaryButton(
          fullWidth: false,
          label: _second ? l.commonConfirm : l.commonNext,
          onPressed:
              _busy ||
                  !_valid ||
                  _mode == null ||
                  (_second && _selected[_mode] == null)
              ? null
              : _second
              ? _confirm
              : _next,
        ),
      ],
    );
  }
}
