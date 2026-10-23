import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 恢复闸门：登录后的首次全量收敛（reconnect / bootstrap）期间置起。
///
/// 与退出登录的 syncGateProvider 语义分离：syncGate 是「账号域清理期间
/// 暂停同步」，本闸门是「全量快照收敛期间暂停增量同步」。置起期间
/// push/pull 必须降级等待，防止 cursor 0 的时间线重放与 full 全量快照
/// 并发交错写库——重放会先把历史数据逐条恢复给用户看，随后历史删除
/// 事件又把它清掉，造成「数据丢失」的假象。
final restoreGateProvider = NotifierProvider<RestoreGateNotifier, bool>(
  RestoreGateNotifier.new,
);

/// 恢复闸门状态：true = 全量收敛进行中（增量同步降级等待）。
class RestoreGateNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// 置闸：暂停增量同步（reconnect/bootstrap 开始前调用）。
  void hold() => state = true;

  /// 开闸只检查闸门自身生命周期，编排器提前销毁时仍释放存活的闸门。
  void release() {
    if (!ref.mounted) return;
    state = false;
  }
}
