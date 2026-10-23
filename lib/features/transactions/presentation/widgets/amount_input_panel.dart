import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/keypad_constants.dart';

import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';

import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/utils/currency/decimal_money.dart';
import 'package:sesame_notes/utils/currency/transaction_amount_rules.dart';
import 'currency_picker_sheet.dart';
import 'rate_input_dialog.dart';
import 'transaction_amount_bar.dart';
import 'transaction_amount_keypad.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 记账金额栏和自定义计算键盘，金额与汇率固定在当前编辑器的账本上下文中。
class AmountInputPanel extends ConsumerStatefulWidget {
  /// 按键仅更新本面板，分类、备注和标题由父编辑器独立持有。
  const AmountInputPanel({
    super.key,
    required this.initialAmount,
    required this.initialCurrencyCode,
    required this.initialNativeAmount,
    required this.categorySelected,
    required this.onSubmit,
    required this.date,
    required this.onPickDate,
    this.errorMessage,
    this.ledgerId,
    this.baseCurrency,
    this.isSubmitting = false,
  });

  final String? initialAmount, initialCurrencyCode, initialNativeAmount;
  final bool categorySelected, isSubmitting;
  final DateTime date;
  final VoidCallback onPickDate;
  final String? errorMessage, ledgerId, baseCurrency;
  final void Function(String total, String txCurrency, String? rate) onSubmit;

  /// 金额草稿仅随编辑器生命周期创建和释放。
  @override
  ConsumerState<AmountInputPanel> createState() => _AmountInputPanelState();
}

class _AmountInputPanelState extends ConsumerState<AmountInputPanel> {
  late String _expression;
  bool _calculated = false;
  VoidCallback? _lastUndo;
  String? _inputError;
  String? _pickedCurrency;
  String? _rateStr;
  bool _rateManuallySet = false;
  bool _fetchingRate = false;
  String? _rateFetchAttemptedFor;

  /// 编辑时保留已有交易币种与隐含汇率，新建从零开始接受数字键输入。
  @override
  void initState() {
    super.initState();
    _pickedCurrency = widget.initialCurrencyCode?.toUpperCase();
    final amount = parseDecimal(widget.initialAmount);
    _expression = amount == null ? '0' : normalizeDecimal(amount, scale: 2);
    final native = parseDecimal(widget.initialNativeAmount);
    if (native != null &&
        amount != null &&
        amount > Decimal.zero &&
        native != amount) {
      _rateStr = normalizeDecimal(
        (native.toRational() / amount.toRational()).toDecimal(
          scaleOnInfinitePrecision: 18,
        ),
        scale: 18,
      );
      _rateManuallySet = true;
    }
  }

  /// 记录按下前后的完整草稿，手指滑出时只撤销仍属于同一次按键的修改。
  void _commit(String next, {bool calculated = false}) {
    if (widget.isSubmitting ||
        !TransactionAmountExpression.acceptsDraft(next)) {
      return;
    }
    try {
      final before = _expression;
      final beforeCalculated = _calculated;
      final beforeError = _inputError;
      if (before == next && beforeCalculated == calculated) return;
      setState(() {
        _expression = next;
        _calculated = calculated;
        _inputError = null;
      });
      HapticFeedback.selectionClick().catchError((
        Object error,
        StackTrace stack,
      ) {
        logger.error('AmountInputPanel', '金额按键触觉反馈失败', error, stack);
      });
      _lastUndo = () {
        if (!mounted || _expression != next || _calculated != calculated) {
          return;
        }
        setState(() {
          _expression = before;
          _calculated = beforeCalculated;
          _inputError = beforeError;
        });
      };
    } catch (error, stackTrace) {
      logger.error('AmountInputPanel', '更新金额草稿失败', error, stackTrace);
      if (mounted) {
        setState(
          () =>
              _inputError = AppLocalizations.of(context).commonOperationFailed,
        );
      }
    }
  }

  /// 数字接在当前操作数后，计算完成后输入数字则开启新的金额。
  void _append(String digit) {
    var source = _calculated ? '0' : _expression;
    final operand = source.split(RegExp(r'[+\-×÷]')).last;
    if (digit == '.') {
      if (operand.contains('.')) return;
      _commit('$source${operand.isEmpty ? '0' : ''}.');
    } else {
      if (operand == '0') source = source.substring(0, source.length - 1);
      _commit('$source$digit');
    }
  }

  /// 连续点击运算符只替换最后一个符号，不把待输入操作数误当成零。
  void _applyOperator(String operation) {
    if (_expression.isEmpty) return;
    final trailing = RegExp(r'[+\-×÷]$').hasMatch(_expression);
    _commit(
      trailing
          ? '${_expression.substring(0, _expression.length - 1)}$operation'
          : '$_expression$operation',
    );
  }

  /// 退格保留算式上下文，删空后返回零；计算结果仍可继续编辑。
  void _backspace() => _commit(
    _expression.length <= 1
        ? '0'
        : _expression.substring(0, _expression.length - 1),
  );

  /// 长按删除清空整个表达式，新的输入从零开始。
  void _clear() => _commit('0');

  /// 滑出取消仅撤销本次按键，后续输入已覆盖的草稿不会被旧手势改写。
  void _rollback() {
    final undo = _lastUndo;
    _lastUndo = null;
    undo?.call();
  }

  /// 等号只计算合法完整算式，负结果保留符号且不允许作为记账金额保存。
  void _equals() {
    if (widget.isSubmitting) return;
    try {
      final result = TransactionAmountExpression.evaluate(_expression);
      if (result.error != null || result.preview == null) {
        setState(() => _inputError = _resultError(result));
        return;
      }
      _commit(result.preview!, calculated: true);
    } catch (error, stackTrace) {
      logger.error('AmountInputPanel', '计算金额表达式失败', error, stackTrace);
      if (mounted) {
        setState(
          () => _inputError = AppLocalizations.of(context).txExpressionInvalid,
        );
      }
    }
  }

  /// 固定账本本位币优先，空本仅用默认币种呈现占位，保存由编辑器可用性控制。
  String get _baseCurrency {
    final String base =
        widget.baseCurrency ?? ref.read(currentLedgerCurrencyProvider);
    return normalizeLedgerCurrency(base);
  }

  /// 用户选中的交易币种始终以编辑器固定账本的本位币兜底。
  String get _txCurrency => _pickedCurrency ?? _baseCurrency;

  /// 本笔汇率：手改/隐含 > 有效汇率（effectiveRatesForLedgerProvider）。
  String? _currentRate() {
    if (_rateManuallySet) return _validRate(_rateStr);
    final rates =
        (widget.baseCurrency == null
                ? ref.read(effectiveRatesForLedgerProvider)
                : ref.read(effectiveRatesForBaseProvider(_baseCurrency)))
            .value;
    final er = rates?[_txCurrency];
    return er == null ? null : _validRate(er.rate);
  }

  /// 汇率仅在 Decimal 可解析且为正数时进入业务计算。
  String? _validRate(String? raw) {
    final value = parseDecimal(raw);
    return value != null && value > Decimal.zero ? raw : null;
  }

  /// 外币且本地无该币种汇率时，自动拉一次。同一币种只自动试一次，
  /// 失败后由用户手填（汇率缺失阻塞仍兜底）。
  Future<void> _maybeAutoFetchRate() async {
    final base = _baseCurrency;
    final txCurrency = _txCurrency;
    if (txCurrency == base || _rateManuallySet || _fetchingRate) return;
    if (_rateFetchAttemptedFor == txCurrency) return;
    final ratesAsync = widget.baseCurrency == null
        ? ref.read(effectiveRatesForLedgerProvider)
        : ref.read(effectiveRatesForBaseProvider(base));
    final rates = ratesAsync.value;
    if (rates == null) return; // provider 尚未解析，等它先出结果
    if (rates.containsKey(txCurrency)) return; // 已有汇率
    _rateFetchAttemptedFor = txCurrency;
    setState(() => _fetchingRate = true);
    try {
      await refreshExchangeRates(
        read: ref.read(applicationReaderProvider),
        force: true,
        extraBases: {base},
      );
    } catch (error, stackTrace) {
      logger.error('AmountInputPanel', '读取本笔交易汇率失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).txRateMissingHint);
      }
    } finally {
      if (mounted) setState(() => _fetchingRate = false);
    }
  }

  /// 币种选择保持金额和备注草稿，只重置依赖币种的本笔汇率。
  Future<void> _pickCurrency() async {
    if (widget.isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    try {
      await prepareForOverlay();
      if (!mounted || widget.isSubmitting) return;
      final base = _baseCurrency;
      final visible = widget.ledgerId == null
          ? ref.read(visibleCurrenciesProvider)
          : await ref.read(
              visibleCurrenciesForLedgerProvider(widget.ledgerId!).future,
            );
      if (!mounted || widget.isSubmitting) return;
      final picked = await showCurrencyPickerSheet(
        context,
        selected: _pickedCurrency ?? base,
        title: l10n.txCurrencyPickerTitle,
        rateBase: base,
        // 挂 sheet 在当前 navigator 上，只 pop 回本 sheet；不显示遮罩
        useRootNavigator: false,
        barrierColor: Colors.transparent,
        // 记账页内调用，符号化显示汇率
        showRateAsBaseLabel: true,
        // 仅显示用户勾选的可见币种；账本本位币(rateBase)与已选币种
        // 由 sheet 内部强制保留，保证折算目标与当前值始终可见
        visibleCurrencies: visible,
      );
      if (picked == null || !mounted || widget.isSubmitting) return;
      setState(() {
        _lastUndo = null;
        _pickedCurrency = picked.toUpperCase() == base
            ? null
            : picked.toUpperCase();
        // 换币种后隐含/手改汇率作废，重新带有效汇率
        _rateStr = null;
        _rateManuallySet = false;
      });
    } catch (error, stackTrace) {
      logger.error('AmountInputPanel', '选择交易币种失败', error, stackTrace);
      if (mounted) showToast(context, l10n.commonOperationFailed);
    }
  }

  /// 汇率输入由共享弹窗管理，校验失败保留内容供修正。
  Future<void> _editRate() async {
    if (widget.isSubmitting) return;
    final l = AppLocalizations.of(context);
    try {
      await prepareForOverlay();
      if (!mounted || widget.isSubmitting) return;
      final result = await showDialog<RateInputResult>(
        context: context,
        builder: (_) => RateInputDialog(
          quote: _txCurrency,
          base: _baseCurrency,
          initialText: _rateStr ?? _currentRate() ?? '',
          title: l.txRateLabel,
          confirmLabel: l.commonConfirm,
          isValid: (value) => _validRate(value) != null,
        ),
      );
      if (result == null || !mounted) return;
      setState(() {
        _lastUndo = null;
        _rateStr = result.rate;
        _rateManuallySet = true;
      });
    } catch (error, stackTrace) {
      logger.error('AmountInputPanel', '编辑交易汇率失败', error, stackTrace);
      if (mounted) showToast(context, l.commonOperationFailed);
    }
  }

  /// 外币预览使用表达式的有效正结果，本位币与汇率仍绑定打开时的账本。
  String? _conversionPreview(AmountExpressionResult result) {
    if (_txCurrency == _baseCurrency) return null;
    final amount = result.positiveAmount;
    final rate = _currentRate();
    if (amount == null || rate == null) return null;
    final preview = multiplyDecimalStrings(amount, rate, scale: 2);
    return preview == null
        ? null
        : '≈ ${Decimal.parse(preview).toStringAsFixed(2)} $_baseCurrency';
  }

  /// 将表达式校验失败映射为友好文本，不显示内部异常或更改原始草稿。
  String _resultError(AmountExpressionResult result) {
    final l = AppLocalizations.of(context);
    return switch (result.error) {
      AmountExpressionError.divisionByZero => l.txDivisionByZero,
      AmountExpressionError.incomplete ||
      AmountExpressionError.invalid => l.txExpressionInvalid,
      _ => l.txAmountInvalid,
    };
  }

  /// 完成键统一校验完整正金额和分类，备注键盘确认不调用保存。
  void _submit() {
    if (widget.isSubmitting) return;
    try {
      final result = TransactionAmountExpression.evaluate(_expression);
      final amount = result.positiveAmount;
      if (amount == null) {
        setState(() => _inputError = _resultError(result));
        return;
      }
      if (!widget.categorySelected) {
        setState(
          () => _inputError =
              widget.errorMessage ?? AppLocalizations.of(context).categoryEmpty,
        );
        return;
      }
      setState(() => _inputError = null);
      widget.onSubmit(amount, _txCurrency, _currentRate());
    } catch (error, stackTrace) {
      logger.error('AmountInputPanel', '提交金额表达式失败', error, stackTrace);
      if (mounted) {
        setState(
          () => _inputError = AppLocalizations.of(context).txExpressionInvalid,
        );
      }
    }
  }

  /// 失败提示不随分类滚动消失，键盘展开时仍处于可用表单区域内。
  Widget _buildError(BuildContext context, String message) => Material(
    color: AppTokens.surfaceSheet(context),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p4,
      ),
      child: Tooltip(
        message: message,
        excludeFromSemantics: true,
        child: Semantics(
          key: const ValueKey('editor_submit_error'),
          liveRegion: true,
          child: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextTokens.label(
              context,
            ).copyWith(color: AppTokens.error(context)),
          ),
        ),
      ),
    ),
  );

  /// 金额栏与四行键盘均分面板高度，按键更新不重建分类和备注。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final String rawBase =
        widget.baseCurrency ?? ref.watch(currentLedgerCurrencyProvider);
    final base = normalizeLedgerCurrency(rawBase);
    if (widget.baseCurrency == null) {
      ref.watch(effectiveRatesForLedgerProvider);
    } else {
      ref.watch(effectiveRatesForBaseProvider(base));
    }
    final currency = _txCurrency;
    final rate = _currentRate();
    if (currency != base && rate == null && !_fetchingRate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeAutoFetchRate();
      });
    }
    final result = TransactionAmountExpression.evaluate(_expression);
    final calculating =
        !_calculated && RegExp(r'[0-9.][+\-×÷]').hasMatch(_expression);
    final canSubmit =
        !widget.isSubmitting &&
        widget.categorySelected &&
        result.positiveAmount != null;
    final error = _inputError ?? widget.errorMessage;
    return LayoutBuilder(
      builder: (context, constraints) {
        // 错误行有独立空间，剩余五行继续均分，避免提示遮住键位。
        final errorStyle = AppTextTokens.label(context);
        final errorHeight = error == null
            ? 0.0
            : MediaQuery.textScalerOf(
                        context,
                      ).scale(errorStyle.fontSize ?? 12) *
                      (errorStyle.height ?? 1.4) +
                  2 * AppDimens.p4;
        final rowHeight =
            ((constraints.maxHeight - errorHeight - 4 * KeypadLayout.rowGap) /
                    5)
                .clamp(0.0, double.infinity);
        return Column(
          children: [
            if (error != null)
              SizedBox(height: errorHeight, child: _buildError(context, error)),
            SizedBox(
              height: rowHeight,
              child: TransactionAmountBar(
                amountStr: _expression,
                resultPreview: calculating ? result.preview : null,
                txCurrency: currency,
                ledgerBase: base,
                conversionPreview: _conversionPreview(result),
                rate: rate,
                rateFetching: _fetchingRate,
                rateMissing: rate == null && !_fetchingRate && currency != base,
                rateMissingHint: l.txRateMissingHint,
                readOnly: widget.isSubmitting,
                onPickCurrency: _pickCurrency,
                onEditRate: _editRate,
                onDeleteOne: _backspace,
                onClearAmount: _clear,
                onRollback: _rollback,
              ),
            ),
            const SizedBox(height: KeypadLayout.rowGap),
            Expanded(
              child: TransactionAmountKeypad(
                date: widget.date,
                calculating: calculating,
                activeOperator:
                    calculating && RegExp(r'[+\-×÷]$').hasMatch(_expression)
                    ? _expression.substring(_expression.length - 1)
                    : null,
                enabled: !widget.isSubmitting,
                isDoneEnabled: canSubmit,
                onAppend: _append,
                onOperator: _applyOperator,
                onEquals: _equals,
                onPickDate: widget.onPickDate,
                onSubmit: _submit,
                onRollback: _rollback,
              ),
            ),
          ],
        );
      },
    );
  }
}
