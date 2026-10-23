import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/infrastructure/api/api_error_mapper.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/shared/widgets/section_card.dart';
import 'package:sesame_notes/shared/widgets/detail_list_item.dart';

/// 成员页面持有邀请状态，使面板关闭后仍能保存有效期与生成结果。
class LedgerInviteController extends ChangeNotifier {
  /// 注入生成用例，邀请状态不持有页面或面板的刷新回调。
  LedgerInviteController({
    required this._ledgerId,
    required this._ledgerName,
    required this._isReadOnly,
    required this._createInvite,
  });

  static const expiryOptions = <int>[24, 72, 168];
  final Future<LedgerInvite> Function(String ledgerId, int expiresInHours)
  _createInvite;
  String? _ledgerId;
  String _ledgerName;
  bool _isReadOnly;
  int _expiresInHours = 24;
  LedgerInvite? _invite;
  Object? _error;
  bool _isBusy = false;
  bool _disposed = false;
  int _generation = 0;

  /// 当前邀请所属的云端账本。
  String? get ledgerId => _ledgerId;

  /// 分享文案使用的最新账本名称。
  String get ledgerName => _ledgerName;

  /// 只读账本隐藏邀请生成和分享操作。
  bool get isReadOnly => _isReadOnly;

  /// 再次打开表单时继续使用选定的有效期。
  int get expiresInHours => _expiresInHours;

  /// 最近一次成功生成的邀请，重新生成失败时仍予保留。
  LedgerInvite? get invite => _invite;

  /// 请求失败原因由面板转换为本地化的友好提示。
  Object? get error => _error;

  /// 在途请求期间禁止重复提交和修改有效期。
  bool get isBusy => _isBusy;

  /// 同步账本与权限；切换账本时丢弃旧请求的响应和旧邀请码。
  void updateLedger({
    required String? ledgerId,
    required String ledgerName,
    required bool isReadOnly,
  }) {
    if (_disposed) return;
    if (_ledgerId == ledgerId &&
        _ledgerName == ledgerName &&
        _isReadOnly == isReadOnly) {
      return;
    }
    if (_ledgerId != ledgerId) {
      _generation++;
      _invite = null;
      _error = null;
      _isBusy = false;
      _expiresInHours = 24;
    }
    _ledgerId = ledgerId;
    _ledgerName = ledgerName;
    _isReadOnly = isReadOnly;
    notifyListeners();
  }

  /// 只允许在空闲、可编辑时选择服务端支持的有效期。
  void selectExpiry(int hours) {
    if (_disposed || _isBusy || _isReadOnly || !expiryOptions.contains(hours)) {
      return;
    }
    if (_expiresInHours == hours) return;
    _expiresInHours = hours;
    notifyListeners();
  }

  /// 对同一邀请会话串行生成，响应只更新仍存在且属于同一账本的状态。
  Future<void> generate() async {
    final ledgerId = _ledgerId;
    if (_disposed ||
        _isBusy ||
        _isReadOnly ||
        ledgerId == null ||
        ledgerId.isEmpty) {
      return;
    }
    final generation = ++_generation;
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      final invite = await _createInvite(ledgerId, _expiresInHours);
      if (_disposed || generation != _generation) return;
      _invite = invite;
    } catch (error, stackTrace) {
      logger.error(
        'LedgerInvite',
        '生成邀请失败 ledger=$ledgerId',
        error,
        stackTrace,
      );
      if (_disposed || generation != _generation) return;
      _error = error;
    } finally {
      if (!_disposed && generation == _generation) {
        _isBusy = false;
        notifyListeners();
      }
    }
  }

  /// 页面销毁后使在途响应失效，面板无需保存父页面的 StateSetter。
  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}

/// 独立订阅邀请状态，负责表单、结果与系统复制分享交互。
class LedgerInviteSheet extends StatelessWidget {
  /// 使用页面持有的控制器，重新打开面板时继续展示同一邀请。
  const LedgerInviteSheet({super.key, required this.controller});

  final LedgerInviteController controller;

  /// 权限变化立即切换面板内容，隐藏不可执行的生成与分享入口。
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      if (controller.isReadOnly) {
        return AppSheet(child: Text(l10n.ledgersArchivedRestoreRequired));
      }
      final invite = controller.invite;
      return SafeArea(
        top: false,
        child: AppSheet(
          title: l10n.ledgerInviteMembers,
          subtitle: invite == null
              ? l10n.ledgerInviteDescription(controller.ledgerName)
              : null,
          child: SingleChildScrollView(
            child: invite == null
                ? _buildInviteForm(context, l10n)
                : _buildShareView(context, invite, l10n),
          ),
        ),
      );
    },
  );

  /// 邀请表单 — 角色(固定编辑者,邀请即编辑)+ 有效期选择 + 生成按钮。
  Widget _buildInviteForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.sharedInviteFormRole,
                style: AppTextTokens.body(context),
              ),
            ),
            DetailListTag(
              label: l10n.sharedRoleEditor,
              foregroundColor: AppTokens.primary(context),
              backgroundColor: AppTokens.surfaceSelected(context),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p8,
                vertical: AppDimens.p4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p8),
        Text(
          l10n.ledgerInviteRoleDescription,
          style: AppTextTokens.label(context),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimens.p16),
          child: AppTokens.cardDivider(
            context,
            indent: 0,
            verticalGap: 0,
            height: 1,
          ),
        ),
        Text(l10n.sharedInviteFormExpiry, style: AppTextTokens.body(context)),
        const SizedBox(height: AppDimens.p8),
        Wrap(
          spacing: AppDimens.p8,
          runSpacing: AppDimens.p8,
          children: [
            for (final h in LedgerInviteController.expiryOptions)
              ChoiceChip(
                label: Text(_expiryLabel(h, l10n)),
                selected: controller.expiresInHours == h,
                onSelected: controller.isBusy
                    ? null
                    : (sel) {
                        if (sel) controller.selectExpiry(h);
                      },
              ),
          ],
        ),
        const SizedBox(height: AppDimens.p20),
        FilledButton.icon(
          onPressed: controller.isBusy ? null : () => _generate(context, l10n),
          icon: const Icon(AppIcons.qrCode),
          label: controller.isBusy
              ? const SizedBox(
                  width: AppDimens.icon18,
                  height: AppDimens.icon18,
                  child: CircularProgressIndicator(
                    strokeWidth: AppDimens.progressStrokeWidth,
                  ),
                )
              : Text(l10n.sharedInviteGenerate),
        ),
        if (controller.error != null) ...[
          const SizedBox(height: AppDimens.p12),
          Text(
            cloudOperationErrorMessage(
              controller.error!,
              fallback: l10n.commonFailed,
            ),
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.error(context)),
          ),
        ],
        const SizedBox(height: AppDimens.p16),
        Text(
          l10n.sharedInviteWarning,
          style: AppTextTokens.label(
            context,
          ).copyWith(color: AppTokens.textTertiary(context)),
        ),
      ],
    );
  }

  /// 邀请码分享视图 — 大号邀请码 + 有效期 + 复制 / 分享操作。
  Widget _buildShareView(
    BuildContext context,
    LedgerInvite invite,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p12,
            vertical: AppDimens.p20,
          ),
          color: AppTokens.surfaceInput(context),
          showShadow: false,
          child: Center(
            child: SelectableText(
              invite.code,
              style: AppTextTokens.display3(context).copyWith(letterSpacing: 6),
            ),
          ),
        ),
        // 生成响应必带 expires_at,展示失效时间。
        const SizedBox(height: AppDimens.p8),
        Center(
          child: Text(
            l10n.sharedInviteExpiresAt(
              invite.expiresAt.toLocal().toString().split('.').first,
            ),
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.textTertiary(context)),
          ),
        ),
        const SizedBox(height: AppDimens.p20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(AppIcons.copy),
                label: Text(l10n.sharedInviteCopyCode),
                onPressed: () => _copyInviteCode(context, invite, l10n),
              ),
            ),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(AppIcons.share),
                label: Text(l10n.sharedInviteShareCode),
                onPressed: () => _share(context, invite, l10n),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p20),
        Text(
          l10n.sharedInviteInstruction,
          style: AppTextTokens.body(
            context,
          ).copyWith(color: AppTokens.textSecondary(context)),
        ),
        const SizedBox(height: AppDimens.p16),
        TextButton(
          onPressed: controller.isBusy ? null : () => _generate(context, l10n),
          child: Text(l10n.sharedInviteGenerateAnother),
        ),
        if (controller.error != null)
          Text(
            cloudOperationErrorMessage(
              controller.error!,
              fallback: l10n.commonFailed,
            ),
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.error(context)),
          ),
      ],
    );
  }

  /// 生成前校验面板权限与账本身份，具体请求状态由控制器管理。
  Future<void> _generate(BuildContext context, AppLocalizations l10n) async {
    if (controller.isReadOnly) {
      showToast(context, l10n.ledgersArchivedRestoreRequired);
      return;
    }
    if (controller.ledgerId == null || controller.ledgerId!.isEmpty) {
      showToast(context, l10n.sharedMembersSaveFirst);
      return;
    }
    await controller.generate();
  }

  /// 剪贴板确认写入后才提示成功，平台失败记录日志并允许重试。
  Future<void> _copyInviteCode(
    BuildContext context,
    LedgerInvite invite,
    AppLocalizations l10n,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: invite.code));
      if (context.mounted) showToast(context, l10n.commonCopied);
    } catch (error, stackTrace) {
      logger.error('LedgerInvite', '复制邀请码失败', error, stackTrace);
      if (context.mounted) showToast(context, l10n.commonFailed);
    }
  }

  /// 调起系统分享，面板关闭后的平台响应不再访问已销毁的界面。
  Future<void> _share(
    BuildContext context,
    LedgerInvite invite,
    AppLocalizations l10n,
  ) async {
    try {
      final message = l10n.sharedInviteShareText(
        controller.ledgerName,
        invite.code,
      );
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (error, stackTrace) {
      logger.error('LedgerInvite', '分享邀请码失败', error, stackTrace);
      if (context.mounted) showToast(context, l10n.commonFailed);
    }
  }

  /// 可选有效期均为整天，使用统一的本地化天数标签。
  String _expiryLabel(int hours, AppLocalizations l10n) =>
      l10n.sharedInviteExpiryDays(hours ~/ 24);
}
