import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/utils/currency/transaction_amount_rules.dart';

/// 验证金额表达式的运算精度、舍入规则和非法输入边界。
void main() {
  test('Decimal优先级、half-even、大金额和不完整前缀保持安全边界', () {
    for (final example in <String, String>{
      '0.1+0.2': '0.3',
      '2+3×4': '14',
      '10-2-3': '5',
      '8÷2÷2': '2',
      '1--2': '3',
      '1+-2': '-1',
      '-1+2': '1',
      '1/8': '0.12',
      '3/8': '0.38',
      '1/3*3': '1',
      '.5+.25': '0.75',
      '9999999999999999999999999998+1': '9999999999999999999999999999',
    }.entries) {
      expect(
        TransactionAmountExpression.evaluate(example.key).preview,
        example.value,
        reason: example.key,
      );
    }
    expect(TransactionAmountExpression.evaluate('30+2×').preview, '32');
    expect(
      TransactionAmountExpression.evaluate('30+2×').positiveAmount,
      isNull,
    );
    for (final source in ['1/0', '1÷0.00']) {
      expect(
        TransactionAmountExpression.evaluate(source).error,
        AmountExpressionError.divisionByZero,
      );
    }
    for (final source in [
      '0',
      '1-1',
      '-1',
      '1-2',
      '1**2',
      '9999999999999999999999999999+1',
    ]) {
      expect(
        TransactionAmountExpression.evaluate(source).positiveAmount,
        isNull,
        reason: source,
      );
    }
    for (final source in [
      '1e3',
      '1a2',
      '12\n34',
      '12.345',
      '1+2.345',
      'NaN',
      '１２',
      '1' * 513,
    ]) {
      expect(
        TransactionAmountExpression.acceptsDraft(source),
        isFalse,
        reason: source,
      );
    }
  });
}
