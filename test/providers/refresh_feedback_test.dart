import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 刷新结果区分本地完成、云端同步及失败。
void main() {
  test('无错误的默认结果不证明云同步，错误和待上传项不能报告成功', () {
    expect(const SyncRunResult().ok, isTrue);
    expect(const SyncRunResult().refreshOutcome, DataRefreshOutcome.localOnly);
    expect(
      const SyncRunResult.cloudSynced().refreshOutcome,
      DataRefreshOutcome.cloudSynced,
    );
    for (final result in [
      const SyncRunResult(error: '失败'),
      const SyncRunResult(pendingCount: 1),
      const SyncRunResult(rejectedCount: 1),
    ]) {
      expect(result.refreshOutcome, DataRefreshOutcome.failed);
    }
  });
}
