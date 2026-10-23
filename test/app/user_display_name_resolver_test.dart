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

  /// 按真实成员目录与当前身份装配展示名解析器。
  UserDisplayNameResolver buildResolver({
    Map<String, LedgerMemberDisplay> memberDisplayMap = const {},
    String selfMemberId = 'self-member-1',
    String? cloudSelfUserId,
    String? cloudSelfDisplayName,
  }) {
    return UserDisplayNameResolver(
      memberDisplayMap: memberDisplayMap,
      selfMemberId: selfMemberId,
      localSelfDisplayName: l10n.mineLocalName,
      cloudSelfUserId: cloudSelfUserId,
      cloudSelfDisplayName: cloudSelfDisplayName,
    );
  }

  /// 构造成员实例（填充必填字段）。
  LedgerMemberDisplay mkMember({
    required String id,
    String? displayName,
    String memberType = 'REGISTERED',
    String? linkedAccountId,
  }) => LedgerMemberDisplay(
    id: id,
    ledgerId: 'ledger-1',
    displayName: displayName ?? '',
    memberType: memberType,
    linkedAccountId: linkedAccountId,
    role: 'owner',
    avatarVersion: 0,
    status: 'ACTIVE',
    joinedAt: DateTime.utc(2026, 1, 1),
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  group('resolve 优先级', () {
    test('1. 成员表昵称优先(其他 REGISTERED 成员)', () {
      final r = buildResolver(
        memberDisplayMap: {'u1': mkMember(id: 'u1', displayName: 'Alice')},
      );
      expect(r.resolve('u1'), 'Alice');
    });

    test('1b. 成员表昵称为空时返回空串,由调用方统一映射「未知」,不回退原始 id', () {
      final r = buildResolver(
        memberDisplayMap: {'u1': mkMember(id: 'u1', displayName: null)},
      );
      // 解析器契约:无法解析返回空串,调用方(UI/身份上下文)统一映射「未知」。
      expect(r.resolve('u1'), '');
      expect(r.resolve('u1'), isNot('u1'));
    });

    test('2. 本地账本本人(LOCAL)恒显固定本地身份,即使登录且有云昵称', () {
      final r = buildResolver(
        memberDisplayMap: {
          'self-member-1': mkMember(
            id: 'self-member-1',
            memberType: 'LOCAL',
            displayName: '',
          ),
        },
        cloudSelfUserId: 'cloud-user-1',
        cloudSelfDisplayName: '云昵称',
      );
      expect(r.resolve('self-member-1'), l10n.mineLocalName);
      expect(r.resolve('self-member-1'), isNot('云昵称'));
    });

    test('2b. 云账本本人(REGISTERED 且绑定当前账号)显示云 Profile 昵称', () {
      final r = buildResolver(
        memberDisplayMap: {
          'self-member-1': mkMember(
            id: 'self-member-1',
            memberType: 'REGISTERED',
            linkedAccountId: 'cloud-user-1',
            displayName: '旧快照昵称',
          ),
        },
        cloudSelfUserId: 'cloud-user-1',
        cloudSelfDisplayName: '最新云昵称',
      );
      expect(r.resolve('self-member-1'), '最新云昵称');
    });

    test('2c. 云账本本人 Profile 昵称缺失时回退成员行昵称', () {
      final r = buildResolver(
        memberDisplayMap: {
          'self-member-1': mkMember(
            id: 'self-member-1',
            memberType: 'REGISTERED',
            linkedAccountId: 'cloud-user-1',
            displayName: '成员行昵称',
          ),
        },
        cloudSelfUserId: 'cloud-user-1',
      );
      expect(r.resolve('self-member-1'), '成员行昵称');
    });

    test('2d. 本人成员行缺失:云账本回退云昵称,本地账本回退固定本地身份', () {
      final cloud = buildResolver(
        cloudSelfUserId: 'cloud-user-1',
        cloudSelfDisplayName: '云昵称',
      );
      expect(cloud.resolve('self-member-1'), '云昵称');

      final local = buildResolver();
      expect(local.resolve('self-member-1'), l10n.mineLocalName);
    });

    test('3. 占位成员使用成员目录中的展示名', () {
      final r = buildResolver(
        memberDisplayMap: {
          'vu_1': mkMember(
            id: 'vu_1',
            memberType: 'PLACEHOLDER',
            displayName: '虚拟成员A',
          ),
        },
      );
      expect(r.resolve('vu_1'), '虚拟成员A');
    });

    test('4. 未知 id 返回空串(UI 映射「未知」),不套用本地昵称也不裸显 id', () {
      final r = buildResolver(cloudSelfDisplayName: '云昵称');
      expect(r.resolve('unknown-id'), '');
      expect(r.resolve('unknown-id'), isNot('unknown-id'));
      expect(r.resolve('unknown-id'), isNot('云昵称'));
    });

    test('null/空 memberId 返回空串', () {
      final r = buildResolver();
      expect(r.resolve(null), '');
      expect(r.resolve(''), '');
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
