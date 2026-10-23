import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';

/// 账号状态：只有 local 与 authenticated 两种，无登录失效中间态。
enum AccountStatus { local, authenticated }

/// 账号状态：决定「我的」页与身份语义，可由本地缓存恢复。
class AccountState {
  final AccountStatus status;
  final CloudProfile? profile;
  final String? credentialUserId;

  const AccountState({
    required this.status,
    this.profile,
    this.credentialUserId,
  });

  /// 账号身份来自已保存凭证，资料缓存缺失不影响离线访问本账号的数据。
  String? get userId => profile?.userId ?? credentialUserId;

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
    });
    return AccountState.local;
  }

  /// 已保存凭证后，使内存会话与账号资料生效。
  void signIn({required AuthSession session, required CloudProfile profile}) {
    ref.read(authSessionProvider.notifier).signIn(session);
    state = AccountState(status: AccountStatus.authenticated, profile: profile);
  }

  /// 更新云资料缓存（不改变会话）。
  void updateProfile(CloudProfile profile) {
    final current = state;
    final userId = ref.read(authSessionProvider)?.userId ?? current.userId;
    if (!current.isAuthenticated || userId != profile.userId) return;
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
  void restorePending({String? userId}) {
    state = AccountState(
      status: AccountStatus.authenticated,
      credentialUserId: userId,
    );
  }
}

/// 当前账号状态入口：启动恢复与「我的」页双态渲染都读这里。
final accountStateProvider =
    NotifierProvider<AccountStateNotifier, AccountState>(
      AccountStateNotifier.new,
    );

/// 本地写入与缓存读取共用身份：会话优先，离线时只接受已恢复的认证账号。
final currentAccountIdProvider = Provider<String?>((ref) {
  final sessionId = ref.watch(authSessionProvider)?.userId;
  if (sessionId != null) return sessionId;
  final account = ref.watch(accountStateProvider);
  return account.isAuthenticated ? account.userId : null;
});
