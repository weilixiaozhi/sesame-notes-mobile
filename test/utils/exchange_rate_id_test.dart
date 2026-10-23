import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/utils/exchange_rate_id.dart';

void main() {
  test('golden 值（与 Node/PostgreSQL 对齐）：固定输入必须产出固定 id', () {
    expect(
      exchangeRateOverrideId(
        '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761',
        'cny',
        'usd',
      ),
      '1527ffc3-6087-5b6b-99c6-c6837a5db1b6',
    );
  });

  test('币种大小写规范化：同一用户与币种对始终收敛为同一 ID', () {
    const ownerId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';
    expect(
      exchangeRateOverrideId(ownerId, 'CNY', 'USD'),
      exchangeRateOverrideId(ownerId, 'cny', 'usd'),
    );
  });

  test('方向敏感：CNY/USD 与 USD/CNY 产出不同 ID', () {
    const ownerId = '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761';
    expect(
      exchangeRateOverrideId(ownerId, 'CNY', 'USD'),
      isNot(exchangeRateOverrideId(ownerId, 'USD', 'CNY')),
    );
  });

  test('不同账号对同一币对派生不同 ID（账号是身份键的一部分）', () {
    expect(
      exchangeRateOverrideId(
        'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        'CNY',
        'USD',
      ),
      isNot(
        exchangeRateOverrideId(
          'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
          'CNY',
          'USD',
        ),
      ),
    );
  });
}
