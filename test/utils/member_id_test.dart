/// member_id 派生算法 golden 测试。
///
/// 锚点（跨端一致性规范）：
/// - registeredMemberId(L, U) = uuidV5(L, 'user:' + U)，与 Node 端
///   member-id.ts、PostgreSQL uuid_generate_v5 完全一致；
/// - 固定输入 → 固定输出（golden 值由 RFC 4122 向量验证过算法后固化，
///   两端必须产出相同值，任何一端改动即测试失败）；
/// - userId 输入统一按小写规范化（canonicalization）：同一账号的不同
///   大小写表示必须派生出同一个 member_id。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/utils/member_id.dart';

void main() {
  const ledgerId = '11111111-1111-4111-8111-111111111111';
  const userId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

  group('golden 值（与 Node/PostgreSQL 对齐）', () {
    test('registeredMemberId 固定用例', () {
      expect(
        registeredMemberId(ledgerId, userId),
        '056cf10d-2d59-599c-9d97-6749e866aa52',
      );
    });

    test('localSelfMemberId 固定用例', () {
      expect(
        localSelfMemberId(ledgerId, 'device-1234'),
        '9a65b5ae-b52e-5280-85af-99f0ffdf2a1b',
      );
    });
  });

  group('规范化（canonicalization）', () {
    test('userId 大小写不敏感：大写输入产出同一 id', () {
      expect(
        registeredMemberId(ledgerId, userId.toUpperCase()),
        registeredMemberId(ledgerId, userId),
      );
    });

    test('UUID 格式输出（8-4-4-4-12，版本 5）', () {
      final id = registeredMemberId(ledgerId, userId);
      expect(
        id,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });
}
