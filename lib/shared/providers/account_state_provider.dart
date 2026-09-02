import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/shared/providers/realtime_providers.dart';

/// 账号状态：只有 local 与 authenticated 两种，无登录失效中间态。
enum AccountStatus { local, authenticated }

/// 账号状态：决定「我的」页与身份语义，可由本地缓存恢复。
class AccountState {
  final AccountStatus status;
  final CloudProfile? profile;

  const AccountState({required this.status, this.profile});

  static const local = AccountState(status: AccountStatus.local);

  bool get isAuthenticated => status == AccountStatus.authenticated;
}

/// 账号状态 Notifier：启动恢复、登录提交、凭证失效清除的唯一入口。
class AccountStateNotifier extends Notifier<AccountState> {
  @override
  AccountState build() {
    // 会话清空（登出/认证 401）时账号状态同步回到未登录
    ref.listen<AuthSession?>(authSessionProvider, (previous, next) {
      if (next == null && state.status == AccountStatus.authenticated) {
        state = AccountState.local;
      }
      // 会话建立即启动实时通知、清空即停止：WS 只触发 pull 提示，不承载状态；
      // 启停内部已做失败降级与幂等守卫，不阻塞登录主流程。
      if (next != null) {
        unawaited(ref.read(realtimeCoordinatorProvider).start());
      } else {
        unawaited(ref.read(realtimeCoordinatorProvider).stop());
      }
    });
    return AccountState.local;
  }

  /// 提交已登录账号（会话 + 凭证束 + 资料缓存同时生效）。
  void signIn({
    required AuthSession session,
    required ActiveCredential credential,
    required CloudProfile profile,
  }) {
    ref.read(authSessionProvider.notifier).signIn(session);
    state = AccountState(status: AccountStatus.authenticated, profile: profile);
  }

  /// 轮换会话（刷新成功路径）。
  void updateSession(AuthSession session) {
    ref.read(authSessionProvider.notifier).updateToken(session.accessToken);
    final current = state;
    if (current.status == AccountStatus.authenticated) {
      state = AccountState(
        status: AccountStatus.authenticated,
        profile: current.profile,
      );
    }
  }

  /// 更新云资料缓存（不改变会话）。
  void updateProfile(CloudProfile profile) {
    final current = state;
    state = AccountState(status: current.status, profile: profile);
  }

  /// 回到未登录（登出完成或认证类 401 清除凭证后）。
  void signOut() {
    ref.read(authSessionProvider.notifier).signOut();
    state = AccountState.local;
  }

  /// 启动恢复：用缓存资料渲染已登录身份（不写会话——断网启动时
  /// AuthSession 允许为 null，恢复网络后由后台刷新补全会话）。
  void restoreFromCache(CloudProfile profile) {
    state = AccountState(status: AccountStatus.authenticated, profile: profile);
  }

  /// 启动恢复：有凭证但无缓存资料时，先进入 authenticated 空资料态，
  /// 等后台刷新成功后再补全资料（避免闪回未登录）。
  void restorePending() {
    state = AccountState(status: AccountStatus.authenticated);
  }
}

/// 当前账号状态入口：启动恢复与「我的」页双态渲染都读这里。
final accountStateProvider =
    NotifierProvider<AccountStateNotifier, AccountState>(
      AccountStateNotifier.new,
    );
