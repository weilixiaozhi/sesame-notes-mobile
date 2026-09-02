// UserDisplayNameResolver 展示名解析器测试。
//
// 覆盖展示名解析优先级:
//   1. 共享账本成员表(displayName)
//   2. 本人(selfMemberId → 本地昵称 → 「未设置昵称」)
//   3. 虚拟用户名
//   4. 兜底原始 id(未知 id 不套用本地昵称,避免张冠李戴)
// 「我」= 当前账本 self member id,与设备 localSelfId 是两个不同的值。

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/shared/providers/user_display_name_resolver.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  UserDisplayNameResolver buildResolver({
    Map<String, LedgerMemberDisplay> memberDisplayMap = const {},
    String? localOwnerDisplayName,
    String selfMemberId = 'self-member-1',
    Map<String, String> virtualNames = const {},
  }) {
    return UserDisplayNameResolver(
      memberDisplayMap: memberDisplayMap,
      localOwnerDisplayName: localOwnerDisplayName,
      selfMemberId: selfMemberId,
      virtualNames: virtualNames,
      l10n: l10n,
    );
  }

  /// 构造成员实例（填充必填字段）。
  LedgerMemberDisplay mkMember({
    required String userId,
    required String account,
    String? displayName,
  }) => LedgerMemberDisplay(
    id: 'member-$userId',
    ledgerId: 'ledger-1',
    displayName: displayName ?? '',
    memberType: 'REGISTERED',
    linkedAccountId: userId,
    role: 'owner',
    avatarVersion: 0,
    status: 'ACTIVE',
    joinedAt: DateTime.utc(2026, 1, 1),
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  group('resolve 优先级', () {
    test('1. 成员表昵称优先', () {
      final r = buildResolver(
        memberDisplayMap: {
          'u1': mkMember(
            userId: 'u1',
            account: 'alice@example.com',
            displayName: 'Alice',
          ),
        },
      );
      expect(r.resolve('u1'), 'Alice');
    });

    test('1b. 成员表无昵称时回退原始 id（单轨模型无账号字段）', () {
      final r = buildResolver(
        memberDisplayMap: {
          'u1': mkMember(
            userId: 'u1',
            account: 'alice@example.com',
            displayName: null,
          ),
        },
      );
      expect(r.resolve('u1'), 'u1');
    });

    test('2. selfMemberId 映射为本地昵称', () {
      final r = buildResolver(
        localOwnerDisplayName: '本地昵称',
        selfMemberId: 'self-uuid',
      );
      expect(r.resolve('self-uuid'), '本地昵称');
    });

    test('2b. selfMemberId 无昵称时回退「未设置昵称」', () {
      final r = buildResolver(selfMemberId: 'self-uuid');
      // 仅纯名,后缀由 UI 层渲染。
      expect(r.resolve('self-uuid'), l10n.mineSlogan);
    });

    test('3. 虚拟用户名', () {
      final r = buildResolver(virtualNames: {'vu_1': '虚拟成员A'});
      expect(r.resolve('vu_1'), '虚拟成员A');
    });

    test('4. 未知 id 不套用本地昵称,直接兜底原始 id', () {
      final r = buildResolver(localOwnerDisplayName: '本地昵称');
      expect(r.resolve('unknown-id'), 'unknown-id');
    });

    test('4b. 虚拟用户名优先于未知 id 兜底', () {
      final r = buildResolver(
        localOwnerDisplayName: '本地昵称',
        virtualNames: {'vu_1': '虚拟成员A'},
      );
      expect(r.resolve('vu_1'), '虚拟成员A');
    });

    test('5. 无任何名称可用时兜底原始 id', () {
      final r = buildResolver();
      expect(r.resolve('unknown-id'), 'unknown-id');
    });

    test('null/空 userId 返回空串', () {
      final r = buildResolver();
      expect(r.resolve(null), '');
      expect(r.resolve(''), '');
    });

    test('成员表优先于本人(成员表有此成员时用成员表)', () {
      final r = buildResolver(
        memberDisplayMap: {
          'self-member-1': mkMember(
            userId: 'self-member-1',
            account: 'me@example.com',
            displayName: '成员昵称',
          ),
        },
        localOwnerDisplayName: '本地昵称',
      );
      expect(r.resolve('self-member-1'), '成员昵称');
    });
  });

  group('isSelf 本人判定', () {
    test('selfMemberId 命中为本人', () {
      final r = buildResolver(selfMemberId: 'self-uuid');
      expect(r.isSelf('self-uuid'), isTrue);
    });

    test('设备 localSelfId 不等于本人成员 id(单轨模型成员 id 与设备身份分离)', () {
      final r = buildResolver(selfMemberId: 'self-uuid');
      expect(r.isSelf('device-1'), isFalse);
    });

    test('他人 id 非本人', () {
      final r = buildResolver(selfMemberId: 'self-uuid');
      expect(r.isSelf('someone-else'), isFalse);
    });

    test('null/空 memberId 非本人', () {
      final r = buildResolver();
      expect(r.isSelf(null), isFalse);
      expect(r.isSelf(''), isFalse);
    });
  });
}
