import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/features/ledgers/domain/member_mirror.dart';

/// 构造成员展示行，只填展示过滤关心的字段。
LedgerMemberDisplay _member(String id, String type, String name) =>
    LedgerMemberDisplay(
      id: id,
      ledgerId: 'ledger-1',
      displayName: name,
      memberType: type,
      role: 'editor',
      avatarVersion: 0,
      status: 'ACTIVE',
      joinedAt: DateTime.utc(2026, 1, 1),
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );

void main() {
  test('云账本镜像只展示 REGISTERED 成员：遗留 LOCAL 行与占位行都不进入真实成员区', () {
    final members = [
      _member('m-registered', 'REGISTERED', '云昵称'),
      _member('m-local', 'LOCAL', '单机芝麻仔'),
      _member('m-placeholder', 'PLACEHOLDER', '虚拟用户1'),
    ];

    final visible = visibleMemberDisplays(members, hasMirror: true);

    expect(visible.map((member) => member.id), ['m-registered']);
    expect(
      visible.where((member) => member.displayName == '单机芝麻仔'),
      isEmpty,
      reason: '云账本成员镜像不得渲染遗留 LOCAL 行',
    );
    expect(
      visible.where((member) => member.memberType == 'PLACEHOLDER'),
      isEmpty,
      reason: '虚拟成员由专用区块渲染，不混入真实成员区',
    );
  });

  test('无成员镜像（新建态/本地账本）展示合成的所有者行', () {
    final owner = _member('m-local', 'LOCAL', '单机芝麻仔');

    expect(
      visibleMemberDisplays([
        owner,
      ], hasMirror: false).map((member) => member.id),
      ['m-local'],
    );
  });
}
