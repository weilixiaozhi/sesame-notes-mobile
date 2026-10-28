import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';

/// 验证应用支持的币种集合及其唯一性。
void main() {
  group('应用支持的币种', () {
    test('支持币种包含主流与长尾币种，排除区域货币', () {
      expect(kCurrencyCodes, contains('KES'));
      // 区域货币不在支持列表中
      for (final code in ['XAF', 'XOF', 'XCD', 'XPF', 'ANG']) {
        expect(kCurrencyCodes, isNot(contains(code)));
      }
      // 主流币种必须可用于账本与交易。
      expect(kCurrencyCodes, containsAll(['CNY', 'USD', 'EUR', 'JPY', 'GBP']));
    });

    test('code 无重复', () {
      expect(kCurrencyCodes.toSet().length, kCurrencyCodes.length);
    });
  });
}
