import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/ledgers/domain/pending_virtual_users.dart';

/// 与界面同源的默认名生成：虚拟用户{编号}。
String _defaultName(int index) => '虚拟用户$index';

void main() {
  test('连续添加：默认名按现有成员数递增，不重名', () {
    var pending = <PendingVirtualUser>[];
    pending = addPendingVirtualUser(pending, _defaultName);
    expect(pending.single.name, '虚拟用户1');

    pending = addPendingVirtualUser(pending, _defaultName);
    pending = addPendingVirtualUser(pending, _defaultName);

    expect(pending.map((user) => user.name), [
      '虚拟用户1',
      '虚拟用户2',
      '虚拟用户3',
    ], reason: '默认名编号取现有数量 + 1，连续添加不得重名');
  });

  test('默认名编号以现有成员数为基数', () {
    expect(nextVirtualUserIndex(0), 1);
    expect(nextVirtualUserIndex(2), 3);
  });

  test('改名：去首尾空白后写入同一下标成员，原列表不被就地修改', () {
    final pending = [
      PendingVirtualUser(name: '虚拟用户1'),
      PendingVirtualUser(name: '虚拟用户2'),
    ];

    final updated = renamePendingVirtualUser(pending, 1, '  家人  ');

    expect(updated.map((user) => user.name), ['虚拟用户1', '家人']);
    expect(pending.map((user) => user.name), ['虚拟用户1', '虚拟用户2']);
  });

  test('改名：空白名称不覆盖已保存的名称', () {
    final pending = [PendingVirtualUser(name: '旅行同伴')];

    final updated = renamePendingVirtualUser(pending, 0, '   ');

    expect(identical(updated, pending), isTrue, reason: '空白名不产生任何变化');
    expect(pending.single.name, '旅行同伴', reason: '空白名不得覆盖已保存的名称');
  });

  test('改名与删除：越界下标不改动列表', () {
    final pending = [PendingVirtualUser(name: '同伴')];

    expect(
      identical(renamePendingVirtualUser(pending, 3, '朋友'), pending),
      isTrue,
    );
    expect(identical(removePendingVirtualUserAt(pending, -1), pending), isTrue);
    expect(pending.single.name, '同伴');
  });

  test('删除前一行后，剩余成员与其名称保持一一对应', () {
    final pending = [
      PendingVirtualUser(name: '旅行同伴'),
      PendingVirtualUser(name: '家人'),
    ];

    final updated = removePendingVirtualUserAt(pending, 0);

    expect(updated, hasLength(1));
    expect(updated.single.name, '家人', reason: '删行后剩余成员与名称不得串行');
  });
}
