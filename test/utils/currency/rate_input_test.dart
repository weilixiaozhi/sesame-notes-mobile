import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/utils/currency/rate_math.dart';

/// 验证汇率输入的有限正数边界，非法文本不能进入写入流程。
void main() {
  group('汇率输入校验 isValidRateInput', () {
    test('非法输入全部拒绝：0 / NaN / Infinity / -Infinity / 1e999', () {
      for (final invalid in ['0', 'NaN', 'Infinity', '-Infinity', '1e999']) {
        expect(isValidRateInput(invalid), isFalse, reason: invalid);
      }
    });

    test('负数、负数无穷、空串、非数字也拒绝', () {
      for (final invalid in ['-1', '-Infinity', '', '   ', 'abc', '1.2.3']) {
        expect(isValidRateInput(invalid), isFalse, reason: invalid);
      }
    });

    test('有限正数通过（含前后空格与极小值）', () {
      for (final valid in ['7.5', '0.048', '1', ' 7.5 ']) {
        expect(isValidRateInput(valid), isTrue, reason: valid);
      }
      // 极小正数本身可落库，只是反向参考不可用（倒数溢出）。
      expect(isValidRateInput('5e-324'), isTrue);
    });
  });
}
