import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/restore_gate_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

/// 仅在系统网络由断开到恢复时重试一次，复用账号恢复与同步闸门。
final cloudConnectionSyncProvider = Provider<void>((ref) {
  ref.read(cloudConnectionProvider);
  bool? previous;
  final subscription = ref
      .watch(cloudNetworkEventsProvider)
      .listen(
        (available) async {
          final recovered = previous == false && available;
          previous = available;
          if (!recovered || !ref.mounted) return;
          try {
            if (ref.read(syncGateProvider) || ref.read(restoreGateProvider)) {
              return;
            }
            if (ref.read(authSessionProvider) == null &&
                !ref.read(accountStateProvider).isAuthenticated) {
              return;
            }
            final result = await ref
                .read(syncCoordinatorProvider)
                .refreshData();
            if (result.error != null) {
              logger.warning('CloudConnection', '网络恢复后的同步未完成', result.error);
            }
          } catch (error, stackTrace) {
            logger.error('CloudConnection', '网络恢复后的同步失败', error, stackTrace);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          logger.error('CloudConnection', '网络恢复通知不可用', error, stackTrace);
        },
      );
  ref.onDispose(() => unawaited(subscription.cancel()));
});
