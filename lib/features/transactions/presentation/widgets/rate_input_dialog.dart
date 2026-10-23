import 'package:flutter/material.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';

/// 汇率弹窗返回显式保存或恢复自动，关闭与取消返回 null。
typedef RateInputResult = ({bool reset, String rate});

/// 汇率管理与记账编辑共用输入校验、实时倒数及控制器生命周期。
class RateInputDialog extends StatefulWidget {
  /// 调用方只提供业务校验差异，输入控制器随弹窗路由完整销毁。
  const RateInputDialog({
    super.key,
    required this.quote,
    required this.base,
    required this.initialText,
    this.allowReset = false,
    this.title,
    this.confirmLabel,
    this.isValid = isValidRateInput,
  });

  final String quote, base, initialText;
  final bool allowReset;
  final String? title, confirmLabel;
  final bool Function(String) isValid;

  /// 输入资源只属于弹窗状态。
  @override
  State<RateInputDialog> createState() => _RateInputDialogState();
}

class _RateInputDialogState extends State<RateInputDialog> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _controller;

  /// 回填原始精度字符串，不在编辑前重新格式化。
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  /// 路由退场完成后才释放控制器，避免退场中的输入框读取已销毁资源。
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 非法值保留在弹窗内显示错误，快速重复点击不关闭下层页面。
  void _save() {
    if (ModalRoute.of(context)?.isCurrent != true ||
        !_form.currentState!.validate()) {
      return;
    }
    Navigator.pop<RateInputResult>(context, (
      reset: false,
      rate: _controller.text.trim(),
    ));
  }

  /// 每次输入更新反向参考值，保存和取消由弹窗自身上下文返回。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppContentDialog(
      title: widget.title ?? l.rateEditTitle,
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                prefixText: '1 ${widget.quote} = ',
                suffixText: widget.base,
              ),
              onChanged: (_) => setState(() {}),
              validator: (value) => widget.isValid((value ?? '').trim())
                  ? null
                  : l.rateInvalidInput,
              onFieldSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppDimens.p8),
            Text(
              l.rateInverseHint(
                widget.base,
                formatInverseRateHint(_controller.text),
                widget.quote,
              ),
              style: AppTextTokens.label(context),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.allowReset)
          TextButton(
            onPressed: () {
              if (ModalRoute.of(context)?.isCurrent == true) {
                Navigator.pop<RateInputResult>(context, (
                  reset: true,
                  rate: '',
                ));
              }
            },
            child: Text(l.rateResetToAuto),
          ),
        TextButton(
          onPressed: () {
            if (ModalRoute.of(context)?.isCurrent == true) {
              Navigator.pop(context);
            }
          },
          child: Text(l.commonCancel),
        ),
        AppPrimaryButton(
          label: widget.confirmLabel ?? l.commonSave,
          fullWidth: false,
          onPressed: _save,
        ),
      ],
    );
  }
}
