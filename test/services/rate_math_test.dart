import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/utils/currency/rate_math.dart';

void main() {
  // ===========================================================================
  // invertRate
  // ===========================================================================
  group('invertRate', () {
    test('正常正值:返回 12 位有效数字的倒数', () {
      expect(invertRate(7.2), '0.138888888889');
      expect(invertRate(1), '1.00000000000');
      expect(invertRate(0.5), '2.00000000000');
      expect(invertRate(0.1477), '6.77048070413');
    });

    test('极大值:不溢出,返回极小正数', () {
      final result = double.parse(invertRate(1e15));
      expect(result, closeTo(1e-15, 1e-27));
    });

    test('极小正值:返回极大数', () {
      final result = double.parse(invertRate(1e-10));
      expect(result, closeTo(1e10, 1));
    });

    test('零值:抛 ArgumentError', () {
      expect(() => invertRate(0), throwsArgumentError);
    });

    test('负值:抛 ArgumentError', () {
      expect(() => invertRate(-7.2), throwsArgumentError);
      expect(() => invertRate(-1), throwsArgumentError);
    });

    test('NaN 与正负无穷都不是有效汇率，必须拒绝', () {
      for (final value in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(() => invertRate(value), throwsArgumentError, reason: '$value');
      }
    });

    test('有限正数取倒数溢出时必须拒绝，不能产生无穷汇率', () {
      expect(() => invertRate(double.minPositive), throwsArgumentError);
    });
  });

  // ===========================================================================
  // mergeEffectiveRates
  // ===========================================================================
  group('mergeEffectiveRates', () {
    test('空输入:返回空 Map', () {
      final m = mergeEffectiveRates(autoRates: [], overrides: []);
      expect(m, isEmpty);
    });

    test('仅有自动汇率:全部标记 manual=false', () {
      final m = mergeEffectiveRates(
        autoRates: [(quote: 'USD', rate: '7.2', rateDate: '2026-07-20')],
        overrides: [],
      );
      expect(m['USD']!.rate, '7.2');
      expect(m['USD']!.manual, isFalse);
      expect(m['USD']!.rateDate, '2026-07-20');
    });

    test('仅有手动汇率:全部标记 manual=true,rateDate=null', () {
      final m = mergeEffectiveRates(
        autoRates: [],
        overrides: [(quote: 'USD', rate: '7.5')],
      );
      expect(m['USD']!.rate, '7.5');
      expect(m['USD']!.manual, isTrue);
      expect(m['USD']!.rateDate, isNull);
    });

    test('手动覆盖自动:同 quote 手动优先，缺失币种不补值', () {
      for (final (autoRate, manualRate) in [('7.2', '7.5'), ('7.20', '7.50')]) {
        final m = mergeEffectiveRates(
          autoRates: [
            (quote: 'USD', rate: autoRate, rateDate: '2026-06-10'),
            (quote: 'JPY', rate: '0.048', rateDate: '2026-06-09'),
          ],
          overrides: [(quote: 'USD', rate: manualRate)],
        );
        expect(m['USD']!.rate, manualRate);
        expect(m['USD']!.manual, isTrue);
        expect(m['JPY']!.manual, isFalse);
        expect(m['JPY']!.rateDate, '2026-06-09');
        expect(m.containsKey('KRW'), isFalse);
      }
    });

    test('大小写归一:小写 quote 统一转大写', () {
      final m = mergeEffectiveRates(
        autoRates: [(quote: 'usd', rate: '7.2', rateDate: '2026-07-20')],
        overrides: [(quote: 'Usd', rate: '7.5')],
      );
      // 两个都归一到 'USD',手动覆盖自动
      expect(m['USD']!.rate, '7.5');
      expect(m['USD']!.manual, isTrue);
    });

    test('不同 quote:各自独立保留', () {
      final m = mergeEffectiveRates(
        autoRates: [
          (quote: 'USD', rate: '7.2', rateDate: '2026-07-20'),
          (quote: 'JPY', rate: '0.048', rateDate: '2026-07-19'),
        ],
        overrides: [(quote: 'KRW', rate: '0.005')],
      );
      expect(m.length, 3);
      expect(m['USD']!.manual, isFalse);
      expect(m['JPY']!.manual, isFalse);
      expect(m['KRW']!.manual, isTrue);
    });
  });
}
