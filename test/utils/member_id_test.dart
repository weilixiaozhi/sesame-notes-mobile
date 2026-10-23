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
  });
}
