import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 账号提醒各自确认清理结果，防止一个业务提前消费另一个业务的待办。
enum AccountReminderKind { days, fitness }

/// 保存本进程已确认的身份失效事件，以及各提醒业务成功处理到的代次。
class AccountReminderInvalidationState {
  final int generation;
  final Map<AccountReminderKind, int> _handled;

  /// 状态仅由事件记录器构造，已处理代次使用不可变映射。
  const AccountReminderInvalidationState._(this.generation, this._handled);

  /// 返回指定业务已成功清理的最新代次。
  int handledGeneration(AccountReminderKind kind) => _handled[kind] ?? 0;

  /// 未完成的失效事件必须保留，供首次订阅或清理失败后的重试处理。
  bool isPending(AccountReminderKind kind) =>
      handledGeneration(kind) < generation;
}

/// 记录明确身份失效事件，不推断首次未登录或普通令牌刷新代表退出。
class AccountReminderInvalidationNotifier
    extends Notifier<AccountReminderInvalidationState> {
  /// 状态与容器同寿命，提醒监听器重新装配也不会重复消费已完成事件。
  @override
  AccountReminderInvalidationState build() =>
      const AccountReminderInvalidationState._(0, {});

  /// 身份从已认证变为本机时递增，监听器尚未启动也能读取到待清理事件。
  void invalidateReminders() {
    state = AccountReminderInvalidationState._(
      state.generation + 1,
      state._handled,
    );
  }

  /// 只确认调用方实际完成的代次，迟到回执不能吞掉后续身份失效事件。
  void acknowledge(AccountReminderKind kind, int generation) {
    if (generation <= state.handledGeneration(kind) ||
        generation > state.generation) {
      return;
    }
    state = AccountReminderInvalidationState._(
      state.generation,
      Map.unmodifiable({...state._handled, kind: generation}),
    );
  }
}

/// 启动身份桥与各业务提醒共用的进程内失效记录。
final accountReminderInvalidationProvider =
    NotifierProvider<
      AccountReminderInvalidationNotifier,
      AccountReminderInvalidationState
    >(AccountReminderInvalidationNotifier.new);
