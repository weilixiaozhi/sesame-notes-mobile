import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';

/// 最近一次真实同步的反馈，初始状态没有完成事件。
class CloudSyncRunFeedback {
  const CloudSyncRunFeedback({this.completedAt, this.error, this.failure});
  final DateTime? completedAt;
  final String? error;
  final SyncOperationFailure? failure;
}

/// 同步横幅使用完成事实，身份变化时清空瞬态反馈。
final cloudSyncRunFeedbackProvider =
    NotifierProvider<CloudSyncRunFeedbackNotifier, CloudSyncRunFeedback>(
      CloudSyncRunFeedbackNotifier.new,
    );

class CloudSyncRunFeedbackNotifier extends Notifier<CloudSyncRunFeedback> {
  /// 令牌轮换保留反馈，退出或切换身份后清空。
  @override
  CloudSyncRunFeedback build() {
    ref.watch(currentAccountIdProvider);
    ref.watch(
      authSessionProvider.select(
        (session) => (session?.userId, session?.deviceId),
      ),
    );
    return const CloudSyncRunFeedback();
  }

  /// 同步结束后由编排器核验身份并记录实际结果。
  void record({String? error, SyncOperationFailure? failure}) {
    if (ref.read(currentAccountIdProvider) == null) return;
    state = CloudSyncRunFeedback(
      completedAt: DateTime.now().toUtc(),
      error: error,
      failure: failure,
    );
  }
}
