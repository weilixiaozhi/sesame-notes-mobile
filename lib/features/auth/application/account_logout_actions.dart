/// 退出账号用例编排：确认弹窗之外的决策与副作用全部收敛在此。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/features/auth/application/account_switch_coordinator.dart';
import 'package:sesame_notes/shared/providers/sync_issues_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 退出账号动作入口；每次退出流程用 [start] 固定身份代次。
class AccountLogoutActions {
  AccountLogoutActions(this.ref);

  final Ref ref;

  /// 开始一次退出流程：固定打开流程时的身份代次，确认期间切换账号后
  /// 任何动作都不会作用到新账号。
  AccountLogoutSession start() =>
      AccountLogoutSession(ref, ref.read(authIdentityGenerationProvider));
}

/// 单次退出流程的动作集合：账号与同步副作用只经统一协调器发出。
class AccountLogoutSession {
  AccountLogoutSession(this._ref, this._identityGeneration);

  final Ref _ref;
  final int _identityGeneration;

  /// 身份代次变化即拒绝继续，同步与退出都不得落到新账号上。
  void _validateIdentity() {
    if (_ref.read(authIdentityGenerationProvider) != _identityGeneration) {
      throw StateError('账号已改变，请重新操作');
    }
  }

  /// 读取统一的待处理同步项（含数量与来源）供确认弹窗展示；
  /// 读取完成后复核身份代次，避免展示期间切换账号。
  Future<List<SyncIssue>> loadPendingIssues() async {
    final issues = await _ref.refresh(syncIssuesProvider.future);
    _validateIdentity();
    return issues;
  }

  /// 默认策略退出：存在未同步修改时抛 [PendingChangesBlockedException]，
  /// 绝不自动改用保留本地副本的退出策略。
  Future<bool> logout() async {
    _validateIdentity();
    await _ref.read(accountSwitchCoordinatorProvider).logout();
    return true;
  }

  /// 先同步：只调用统一同步协调器，保留登录供用户检查结果，不退出。
  Future<bool> synchronizeFirst() async {
    _validateIdentity();
    final result = await _ref.read(syncCoordinatorProvider).refreshData();
    if (!result.ok) {
      throw StateError('退出前同步未完成: ${result.error}');
    }
    return false;
  }

  /// 保留本地副本并退出（Safety Fork）；失败向上抛出，绝不报告退出成功。
  Future<bool> keepLocalCopyAndLogout() async {
    _validateIdentity();
    await _ref
        .read(accountSwitchCoordinatorProvider)
        .logout(policy: AccountSwitchPolicy.safetyFork);
    return true;
  }
}

/// 退出账号动作装配。
final accountLogoutActionsProvider = Provider<AccountLogoutActions>(
  AccountLogoutActions.new,
);
