import 'package:decimal/decimal.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'decimal_money.dart';

/// 记账金额的显示与提交边界，计算和保存共用同一十进制精度规则。
class TransactionAmountRules {
  /// 纯校验工具不持有编辑状态。
  const TransactionAmountRules._();

  static final _unsigned = RegExp(r'^\d{1,28}(?:\.\d{0,2})?$');

  /// 保存只接受合法正金额，负结果、零、指数与超精度值不会转换成其他金额。
  static Decimal? positiveAmount(String text) {
    if (_unsigned.stringMatch(text) != text) return null;
    final value = parseDecimal(text.endsWith('.') ? '${text}0' : text);
    if (value == null || value <= Decimal.zero) return null;
    final normalized = normalizeDecimal(value, scale: 2);
    return isNormalizedDecimal(normalized, fracDigits: 2) ? value : null;
  }
}

/// 区分表达式编辑中间态、语法错误和除零，界面据此显示友好提示。
enum AmountExpressionError { incomplete, invalid, divisionByZero, amountLimit }

/// 计算结果保持十进制文本，负数或零可预览但不能作为交易保存。
class AmountExpressionResult {
  /// 完整结果或当前完整前缀值用于预览；失败原因存在时仍禁止提交。
  const AmountExpressionResult({this.value, this.error});

  final Decimal? value;
  final AmountExpressionError? error;

  /// 仅规范的合法正金额允许进入保存流程。
  String? get positiveAmount {
    final result = value;
    if (result == null || error != null) return null;
    final amount = normalizeDecimal(result, scale: 2);
    return TransactionAmountRules.positiveAmount(amount) == null
        ? null
        : amount;
  }

  /// 预览只来自当前草稿已完整的操作数，不使用历史缓存或double。
  String? get preview =>
      value == null ? null : normalizeDecimal(value!, scale: 2);
}

/// 只解析数字和四则运算符，不执行代码，不读取任何外部数据。
class TransactionAmountExpression {
  /// 纯表达式工具不持有UI状态。
  const TransactionAmountExpression._();

  static const maxLength = 512;
  static final _characters = RegExp(r'^[0-9.+\-×÷*/]*$');
  static final _operand = RegExp(r'^\d{0,28}(?:\.\d{0,2})?$');
  static final _operators = RegExp(r'[+\-×÷*/]');

  /// 非法字符或超精度操作数整次拒绝；空值、符号及不完整式可留作编辑草稿。
  static bool acceptsDraft(String text) =>
      text.length <= maxLength &&
      _characters.stringMatch(text) == text &&
      text
          .split(_operators)
          .every((operand) => _operand.stringMatch(operand) == operand);

  /// 按通常算式优先级安全求值，乘除中间值以有理数保持精度，最终half-even两位。
  static AmountExpressionResult evaluate(String source) {
    if (!acceptsDraft(source)) {
      return const AmountExpressionResult(error: AmountExpressionError.invalid);
    }
    if (source.isEmpty) {
      return const AmountExpressionResult(
        error: AmountExpressionError.incomplete,
      );
    }
    try {
      final values = <Decimal>[];
      final operations = <String>[];
      var cursor = 0;
      while (cursor < source.length) {
        var negative = false;
        if (source[cursor] == '+' || source[cursor] == '-') {
          negative = source[cursor] == '-';
          cursor++;
        }
        if (cursor == source.length) {
          return _evaluateValues(values, operations, incomplete: true);
        }
        final start = cursor;
        while (cursor < source.length && !_operators.hasMatch(source[cursor])) {
          cursor++;
        }
        var operand = source.substring(start, cursor);
        if (operand.isEmpty || operand == '.') {
          return cursor == source.length
              ? _evaluateValues(values, operations, incomplete: true)
              : const AmountExpressionResult(
                  error: AmountExpressionError.invalid,
                );
        }
        if (operand.startsWith('.')) operand = '0$operand';
        if (operand.endsWith('.')) operand = '${operand}0';
        final value = Decimal.tryParse(operand);
        if (value == null) {
          return const AmountExpressionResult(
            error: AmountExpressionError.invalid,
          );
        }
        values.add(negative ? -value : value);
        if (cursor == source.length) break;
        operations.add(source[cursor]);
        cursor++;
        if (cursor == source.length) {
          return _evaluateValues(values, operations, incomplete: true);
        }
      }
      return _evaluateValues(values, operations);
    } catch (error, stackTrace) {
      logger.error(
        'TransactionAmountExpression',
        '金额表达式解析失败',
        error,
        stackTrace,
      );
      return const AmountExpressionResult(error: AmountExpressionError.invalid);
    }
  }

  /// 只计算已完整的操作数与对应运算符，末尾待输入运算符不参与求值。
  /// 例如30+2*的当前完整前缀是30+2；除零、超限等错误不能产生备用预览。
  static AmountExpressionResult _evaluateValues(
    List<Decimal> values,
    List<String> operations, {
    bool incomplete = false,
  }) {
    if (values.isEmpty) {
      return const AmountExpressionResult(
        error: AmountExpressionError.incomplete,
      );
    }
    // 一次扫描汇总加减项，每个项内部完成乘除，不对中间结果提前做金额舍入。
    var total = Decimal.zero.toRational();
    var term = values.first.toRational();
    for (var index = 0; index < values.length - 1; index++) {
      final operation = operations[index];
      final next = values[index + 1].toRational();
      if (operation == '×' || operation == '*') {
        term *= next;
      } else if (operation == '÷' || operation == '/') {
        if (values[index + 1] == Decimal.zero) {
          return const AmountExpressionResult(
            error: AmountExpressionError.divisionByZero,
          );
        }
        term /= next;
      } else {
        total += term;
        term = operation == '-' ? -next : next;
      }
    }
    final rounded = roundHalfEven(
      (total + term).toDecimal(scaleOnInfinitePrecision: 18),
      scale: 2,
    );
    final amount = normalizeDecimal(rounded, scale: 2);
    if (!isNormalizedDecimal(amount, fracDigits: 2)) {
      return const AmountExpressionResult(
        error: AmountExpressionError.amountLimit,
      );
    }
    return AmountExpressionResult(
      value: rounded,
      error: incomplete ? AmountExpressionError.incomplete : null,
    );
  }
}
