/// 加入共享账本页：邀请码 → 预览 → 接受。
///
/// 设计意图：接受邀请是「把别人的云端资源绑到本机」的明确动作，必须先查询
/// 预览（账本名/角色/过期）让用户看清再接受；接受成功后本地落云端绑定行
/// （storage_mode='cloud'），账本数据由同步流程拉取。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

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
  String? _queryError;
  String? _acceptError;
  String? _previewCode;
  LedgerInvitePreview? _preview;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// 按邀请码查询预览；失败保留输入和同一邀请码的已有预览。
  Future<void> _doPreview() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _queryError = null;
      _acceptError = null;
    });
    try {
      final preview = await ref.read(ledgerActionsProvider).queryInvite(code);
      if (!mounted) return;
      setState(() {
        _preview = preview;
        _previewCode = code;
      });
    } catch (error, stackTrace) {
      logger.error(
        'JoinSharedLedger',
        '查询邀请失败',
        safeErrorSummary(error),
        stackTrace,
      );
      if (!mounted) return;
      setState(
        () => _queryError = cloudOperationErrorMessage(
          error,
          fallback: AppLocalizations.of(context).joinSharedQueryFailed,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 接受邀请：服务端接受 + 本地落云端绑定行 + 触发同步拉取账本数据；
  /// 只提示加入结果；历史数据可用性由账本页面表达。
  Future<void> _doAccept() async {
    final code = _previewCode;
    if (code == null || _preview == null || _busy) return;
    setState(() {
      _busy = true;
      _queryError = null;
      _acceptError = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(ledgerActionsProvider).acceptInvite(code);
      if (!mounted) return;
      showToast(context, l10n.joinSharedSuccess);
      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      logger.error('JoinSharedLedger', '接受邀请失败', error, stackTrace);
      if (!mounted) return;
      // 业务拒绝与网络故障分别表达，错误留在当前预览表单中。
      setState(
        () =>
            _acceptError = mapApiError(error) == ApiErrorKind.alreadyLedgerOwner
            ? l10n.joinSharedAlreadyOwner
            : cloudOperationErrorMessage(
                error,
                fallback: l10n.joinSharedQueryFailed,
              ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 输入其他邀请码时清除旧预览，接受操作只能使用已核对的同一码。
  void _codeChanged(String value) {
    if (value.trim().toUpperCase() == _previewCode) return;
    setState(() {
      _preview = null;
      _previewCode = null;
      _queryError = null;
      _acceptError = null;
    });
  }

  /// 使用统一的账本角色名称。
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
                        style: AppTextTokens.body(
                          context,
                        ).copyWith(color: AppTokens.textSecondary(context)),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppDimens.p16),
                    children: [
                      // 邀请码输入卡片
                      SectionCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(AppDimens.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _codeController,
                              enabled: !_busy,
                              onChanged: _codeChanged,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: l10n.joinSharedCodeHint,
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: AppDimens.p12),
                            SizedBox(
                              width: double.infinity,
                              child: AppPrimaryButton(
                                fullWidth: false,
                                label: l10n.joinSharedQuery,
                                onPressed: _busy ? null : _doPreview,
                              ),
                            ),
                            if (_queryError != null) ...[
                              const SizedBox(height: AppDimens.p8),
                              Text(
                                _queryError!,
                                style: AppTextTokens.label(
                                  context,
                                ).copyWith(color: AppTokens.error(context)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // 查询成功后的邀请预览 + 接受
                      if (preview != null) ...[
                        const SizedBox(height: AppDimens.p16),
                        SectionCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(AppDimens.p16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.joinSharedPreviewTitle,
                                style: AppTextTokens.strongTitle(context),
                              ),
                              const SizedBox(height: AppDimens.p8),
                              Text(
                                preview.ledgerName,
                                style: AppTextTokens.boldTitle(context),
                              ),
                              const SizedBox(height: AppDimens.p4),
                              Text(
                                _roleLabel(l10n, preview.role),
                                style: AppTextTokens.label(context).copyWith(
                                  color: AppTokens.textSecondary(context),
                                ),
                              ),
                              const SizedBox(height: AppDimens.p12),
                              SizedBox(
                                width: double.infinity,
                                child: AppPrimaryButton(
                                  fullWidth: false,
                                  label: l10n.joinSharedAccept,
                                  onPressed: _busy ? null : _doAccept,
                                ),
                              ),
                              if (_acceptError != null) ...[
                                const SizedBox(height: AppDimens.p8),
                                Text(
                                  _acceptError!,
                                  style: AppTextTokens.label(
                                    context,
                                  ).copyWith(color: AppTokens.error(context)),
                                ),
                              ],
                            ],
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
