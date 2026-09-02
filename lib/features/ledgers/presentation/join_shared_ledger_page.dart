/// 加入共享账本页（P1：邀请码 → 预览 → 接受）。
///
/// 设计意图：接受邀请是「把别人的云端资源绑到本机」的明确动作，必须先查询
/// 预览（账本名/角色/过期）让用户看清再接受；接受成功后本地落云端绑定行
/// （storage_mode='cloud'），账本数据由后续 full 同步拉取，本页不阻塞等待。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

/// 加入共享账本页：输入邀请码查询预览，确认后接受。
class JoinSharedLedgerPage extends ConsumerStatefulWidget {
  const JoinSharedLedgerPage({super.key});

  @override
  ConsumerState<JoinSharedLedgerPage> createState() =>
      _JoinSharedLedgerPageState();
}

class _JoinSharedLedgerPageState extends ConsumerState<JoinSharedLedgerPage> {
  final _codeController = TextEditingController();
  bool _busy = false;
  bool _queryFailed = false;
  LedgerInvitePreview? _preview;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 按邀请码查询预览；失败置错误态并清掉旧预览。
  Future<void> _doPreview() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _queryFailed = false;
      _preview = null;
    });
    try {
      final preview = await ref.read(ledgerActionsProvider).queryInvite(code);
      if (!mounted) return;
      setState(() => _preview = preview);
    } catch (error, stackTrace) {
      logger.error('JoinSharedLedger', '查询邀请失败: $code', error, stackTrace);
      if (!mounted) return;
      setState(() => _queryFailed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 接受邀请：服务端接受 + 本地落云端绑定行 + 触发同步拉取账本数据；
  /// 首批历史数据未拉取成功时提示待同步（账本已加入，不回滚）。
  Future<void> _doAccept() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || _preview == null) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      final result = await ref.read(ledgerActionsProvider).acceptInvite(code);
      if (!mounted) return;
      showToast(
        context,
        result.historySyncDeferred
            ? l10n.joinSharedSyncDeferred
            : l10n.joinSharedSuccess,
      );
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      logger.error('JoinSharedLedger', '接受邀请失败', error, stackTrace);
      if (!mounted) return;
      showToast(context, l10n.joinSharedQueryFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _roleLabel(AppLocalizations l10n, String role) {
    if (role == 'editor') return l10n.sharedRoleEditor;
    return l10n.sharedRoleOwner;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final loggedIn = ref.watch(currentLedgerAccountIdProvider) != null;
    final preview = _preview;

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.joinSharedTitle, showBack: true),
          Expanded(
            child: !loggedIn
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.p20),
                      child: Text(
                        l10n.joinSharedNeedLogin,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTokens.textSecondary(context),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppDimens.p16),
                    children: [
                      // 邀请码输入卡片
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimens.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _codeController,
                                enabled: !_busy,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: l10n.joinSharedCodeHint,
                                  counterText: '',
                                ),
                              ),
                              const SizedBox(height: AppDimens.p12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _busy ? null : _doPreview,
                                  child: Text(l10n.joinSharedQuery),
                                ),
                              ),
                              if (_queryFailed) ...[
                                const SizedBox(height: AppDimens.p8),
                                Text(
                                  l10n.joinSharedQueryFailed,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTokens.error(context),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // 查询成功后的邀请预览 + 接受
                      if (preview != null) ...[
                        const SizedBox(height: AppDimens.p16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppDimens.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.joinSharedPreviewTitle,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: AppDimens.p8),
                                Text(
                                  preview.ledgerName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: AppDimens.p4),
                                Text(
                                  _roleLabel(l10n, preview.role),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTokens.textSecondary(context),
                                      ),
                                ),
                                const SizedBox(height: AppDimens.p12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: _busy ? null : _doAccept,
                                    child: Text(l10n.joinSharedAccept),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
