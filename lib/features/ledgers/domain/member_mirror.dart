/// 账本成员镜像的展示口径。
library;

import 'package:sesame_notes/data/models/ledger_member_display.dart';

/// 真实成员区展示的成员列表。
///
/// 有成员镜像(云账本)时只展示 REGISTERED 成员:虚拟成员由专用区块渲染,
/// 遗留 LOCAL 镜像行不进入真实成员区,本人不会同时出现本地身份与云昵称两行;
/// 无镜像(新建态/本地账本)时展示由当前设备身份合成的所有者行。
List<LedgerMemberDisplay> visibleMemberDisplays(
  List<LedgerMemberDisplay> members, {
  required bool hasMirror,
}) => hasMirror
    ? members.where((member) => member.memberType == 'REGISTERED').toList()
    : members;
