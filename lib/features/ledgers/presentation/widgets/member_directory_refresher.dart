import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';

/// 进入成员身份页面时触发一次成员目录刷新。
///
/// 在 initState 内为指定账本发起幂等刷新;刷新过程不阻塞页面渲染,
/// 本地快照先展示、刷新成功后经数据变更信号自动重算。
class MemberDirectoryRefresher extends ConsumerStatefulWidget {
  const MemberDirectoryRefresher({
    super.key,
    required this.child,
    required this.ledgerId,
  });

  final Widget child;
  final String ledgerId;

  @override
  ConsumerState<MemberDirectoryRefresher> createState() =>
      _MemberDirectoryRefresherState();
}

class _MemberDirectoryRefresherState
    extends ConsumerState<MemberDirectoryRefresher> {
  /// 进入页面时按指定账本发起幂等刷新。
  @override
  void initState() {
    super.initState();
    final ledgerId = widget.ledgerId;
    if (ledgerId.isNotEmpty && mounted) {
      final container = ProviderScope.containerOf(context, listen: false);
      unawaited(refreshLedgerMemberDirectory(container, ledgerId));
    }
  }

  /// 直接展示内容，目录刷新不阻塞页面。
  @override
  Widget build(BuildContext context) => widget.child;
}
