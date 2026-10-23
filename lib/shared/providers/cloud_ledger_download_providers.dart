import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

/// 下载标记变化只发出叶子版本信号，避免存储 provider 反向依赖自己的消费者。
final _cloudDownloadRevisionProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

/// 只有首次内容的发布状态变化才通知前台，后台刷新任务不重建展示查询。
final _cloudPublicationRevisionProvider =
    NotifierProvider<TickStateNotifier, int>(
      () => TickStateNotifier((ref) => 0),
    );

/// 同步和页面共用下载状态存储，写入成功后统一刷新展示缓存。
final Provider<CloudLedgerDownloadStore> cloudLedgerDownloadStoreProvider =
    Provider<CloudLedgerDownloadStore>((ref) {
      return CloudLedgerDownloadStore(
        () => ref.read(sharedPreferencesProvider.future),
        onChanged: () {
          if (ref.mounted) {
            ref.read(_cloudDownloadRevisionProvider.notifier).tick();
          }
        },
        onPublicationChanged: () {
          if (ref.mounted) {
            ref.read(_cloudPublicationRevisionProvider.notifier).tick();
          }
        },
      );
    });

/// 仅暴露当前账号的待下载集合，未登录不读取其他账号的数据。
final FutureProvider<Set<String>> pendingCloudLedgerDownloadsProvider =
    FutureProvider<Set<String>>((ref) {
      ref.watch(_cloudDownloadRevisionProvider);
      final accountId = ref.watch(currentAccountIdProvider);
      if (accountId == null) return const {};
      return ref.watch(cloudLedgerDownloadStoreProvider).pending(accountId);
    });

/// 首次完整内容尚未提交的账本不进入前台；后台刷新任务不影响已发布内容。
final unpublishedCloudLedgersProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(_cloudPublicationRevisionProvider);
  final accountId = ref.watch(currentAccountIdProvider);
  if (accountId == null) return const {};
  return ref.watch(cloudLedgerDownloadStoreProvider).unpublished(accountId);
});
