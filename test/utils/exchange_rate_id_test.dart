// 汇率覆盖确定性 UUID 派生工具测试。
//
// 与服务端（apps/api/src/modules/accounting/entity-id.ts）同字节级算法：
// uuidV5(EXCHANGE_RATE_NAMESPACE, '<ownerId>:<BASE>:<QUOTE>')，两端必须产出
// 相同 id（同步零映射前提）。golden 值直接取自服务端 entity-id.test.ts，
// 不从待测 helper 动态生成期望。
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/utils/exchange_rate_id.dart';

void main() {
  test('命名空间冻结：与服务端 EXCHANGE_RATE_NAMESPACE 一致', () {
    expect(exchangeRateNamespace, 'cefe9382-b932-5eb7-827d-18944198fbb9');
  });

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

  test('输出为标准 UUID v5 格式（第 3 段以 5 开头）', () {
    final id = exchangeRateOverrideId(
      '018f7f95-4b8a-4f5e-8d0c-2ebf4682c761',
      'CNY',
      'USD',
    );
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
