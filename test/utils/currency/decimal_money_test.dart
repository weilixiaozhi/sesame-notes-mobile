import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/utils/currency/decimal_money.dart';

/// 规范化 Decimal 字符串工具的红测锚点。
void main() {
  group('roundHalfEven（round-half-even 舍入）', () {
    test('恰好 .5 时舍入到偶数位', () {
      expect(roundHalfEven(Decimal.parse('2.5'), scale: 0).toString(), '2');
      expect(roundHalfEven(Decimal.parse('3.5'), scale: 0).toString(), '4');
      expect(roundHalfEven(Decimal.parse('-2.5'), scale: 0).toString(), '-2');
    });
    test('scale=1 精确到分', () {
      expect(roundHalfEven(Decimal.parse('1.25'), scale: 1).toString(), '1.2');
      expect(roundHalfEven(Decimal.parse('1.35'), scale: 1).toString(), '1.4');
    });
  });

  group('normalizeDecimal（规范化）', () {
    test('去尾零与多余小数点', () {
      expect(normalizeDecimal(Decimal.parse('12.3400'), scale: 10), '12.34');
      expect(normalizeDecimal(Decimal.parse('12.00'), scale: 10), '12');
    });
    test('零固定为 0，禁 -0', () {
      expect(normalizeDecimal(Decimal.parse('0.000'), scale: 10), '0');
      expect(normalizeDecimal(Decimal.parse('-0.000'), scale: 10), '0');
    });
  });

  group('multiplyDecimalStrings（native = amount × rate）', () {
    test('10 × 1.25 = 12.5', () {
      expect(multiplyDecimalStrings('10', '1.25'), '12.5');
    });
    test('非法/非正 rate 返回 null', () {
      expect(multiplyDecimalStrings('10', 'abc'), isNull);
      expect(multiplyDecimalStrings('10', '0'), isNull);
    });
  });

  group('isNormalizedDecimal（写入边界校验）', () {
    test('接受规范写法', () {
      expect(isNormalizedDecimal('12.34'), isTrue);
      expect(isNormalizedDecimal('0'), isTrue);
      expect(isNormalizedDecimal('0.0000000001'), isTrue);
    });
    test('拒绝非规范写法', () {
      expect(isNormalizedDecimal('12.340'), isFalse);
      expect(isNormalizedDecimal('01'), isFalse);
      expect(isNormalizedDecimal('-0'), isFalse);
      expect(isNormalizedDecimal('1e3'), isFalse);
    });
  });
}
