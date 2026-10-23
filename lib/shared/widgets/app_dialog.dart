import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'app_content_dialog.dart';
import 'app_primary_button.dart';

/// 弹窗动作只描述内容和主次样式，关闭行为归属于弹窗路由。
typedef AppDialogAction = ({String label, VoidCallback? onTap, bool primary});

/// 确认、通知和选择弹窗共用布局、返回约定与异步反馈。
class AppDialog {
  /// 仅关闭仍处于栈顶的当前弹窗，退场期间的重复点击不能关闭下层页面。
  static void _close<T>(BuildContext context, [T? result]) {
    if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;
    Navigator.of(context).pop<T>(result);
  }

  /// 成功后关闭，失败保留内容；提交期间禁止重复操作和返回。
  static Future<bool> confirmAsync(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
    required String Function(Object) errorMessage,
    String? confirmLabel,
    String? cancelLabel,
  }) async {
    final l10n = AppLocalizations.of(context);
    var busy = false;
    String? error;
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setState) => PopScope(
              canPop: !busy,
              child: _buildDialog(
                title: title,
                confirming: busy,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    if (error != null) ...[
                      const SizedBox(height: AppDimens.p12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          error!,
                          style: TextStyle(color: AppTokens.error(context)),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  (
                    label: cancelLabel ?? l10n.commonCancel,
                    onTap: busy
                        ? null
                        : () {
                            if (!busy) _close(context, false);
                          },
                    primary: false,
                  ),
                  (
                    label: confirmLabel ?? l10n.commonConfirm,
                    primary: true,
                    onTap: busy
                        ? null
                        : () async {
                            if (busy ||
                                ModalRoute.of(context)?.isCurrent != true) {
                              return;
                            }
                            setState(() {
                              busy = true;
                              error = null;
                            });
                            try {
                              await onConfirm();
                              if (context.mounted) _close(context, true);
                            } catch (failure, stackTrace) {
                              logger.error(
                                'AppDialog',
                                '确认操作失败: $title',
                                failure,
                                stackTrace,
                              );
                              String friendlyError;
                              try {
                                friendlyError = errorMessage(failure);
                              } catch (mappingError, mappingStack) {
                                logger.error(
                                  'AppDialog',
                                  '生成错误提示失败',
                                  mappingError,
                                  mappingStack,
                                );
                                friendlyError = l10n.commonOperationFailed;
                              }
                              if (context.mounted) {
                                setState(() => error = friendlyError);
                              }
                            } finally {
                              if (context.mounted) setState(() => busy = false);
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  /// 确认返回 true，取消返回 false，系统返回或遮罩关闭返回 null。
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? cancelLabel,
    String? okLabel,
  }) {
    final l10n = AppLocalizations.of(context);
    return _show<bool>(
      context,
      title: title,
      content: Text(message),
      actions: (dialogContext) => [
        (
          label: cancelLabel ?? l10n.commonCancel,
          onTap: () => _close(dialogContext, false),
          primary: false,
        ),
        (
          label: okLabel ?? l10n.commonConfirm,
          onTap: () => _close(dialogContext, true),
          primary: true,
        ),
      ],
    );
  }

  /// 通知弹窗只等待关闭，不返回无意义的布尔值。
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String? okLabel,
  }) async {
    final l10n = AppLocalizations.of(context);
    await _show<void>(
      context,
      title: title,
      content: Text(message),
      actions: (dialogContext) => [
        (
          label: okLabel ?? l10n.commonOk,
          onTap: () => _close<void>(dialogContext),
          primary: true,
        ),
      ],
    );
  }

  /// 错误通知沿用统一关闭行为，业务提供可理解的错误文案。
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String? okLabel,
  }) => info(context, title: title, message: message, okLabel: okLabel);

  /// 选择确认读取当前结果并回传，取消不提交，调用方不负责关闭路由。
  static Future<T?> select<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    required T Function() onConfirm,
    String? cancelLabel,
    String? okLabel,
  }) {
    final l10n = AppLocalizations.of(context);
    return _show<T>(
      context,
      title: title,
      content: content,
      actions: (dialogContext) => [
        (
          label: cancelLabel ?? l10n.commonCancel,
          onTap: () => _close<T>(dialogContext),
          primary: false,
        ),
        (
          label: okLabel ?? l10n.commonConfirm,
          primary: true,
          onTap: () {
            if (ModalRoute.of(dialogContext)?.isCurrent != true) return;
            _close<T>(dialogContext, onConfirm());
          },
        ),
      ],
    );
  }

  /// 按钮使用弹窗自身上下文，调用页面离开后仍能正确关闭弹窗。
  static Future<T?> _show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    required List<AppDialogAction> Function(BuildContext) actions,
  }) => showDialog<T>(
    context: context,
    builder: (dialogContext) => _buildDialog(
      title: title,
      content: content,
      actions: actions(dialogContext),
    ),
  );

  /// 紧凑主按钮共享页面按钮的忙碌反馈，长文案按可用宽度换行。
  static Widget _buildDialog({
    required String title,
    required Widget content,
    required List<AppDialogAction> actions,
    bool confirming = false,
  }) => AppContentDialog(
    title: title,
    content: content,
    actions: [
      for (final action in actions)
        if (action.primary)
          AppPrimaryButton(
            label: action.label,
            onPressed: action.onTap,
            busy: confirming,
            fullWidth: false,
          )
        else
          OutlinedButton(onPressed: action.onTap, child: Text(action.label)),
    ],
  );
}
