import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/logging/logger_service.dart';
import '../features/fitness/application/fitness_providers.dart';
import '../navigation/route_consts.dart';
import '../data/models/app_mode.dart';
import '../shared/providers/ui_state_providers.dart';
import '../shared/services/notification/notification_navigation.dart';

/// 常驻导航器外，热启动和冷启动通知都等待初始化、欢迎页及锁屏放行。
class NotificationNavigationListener extends ConsumerStatefulWidget {
  const NotificationNavigationListener({
    super.key,
    required this.router,
    required this.ready,
  });
  final GoRouter router;
  final bool ready;

  @override
  ConsumerState<NotificationNavigationListener> createState() =>
      _NotificationNavigationListenerState();
}

class _NotificationNavigationListenerState
    extends ConsumerState<NotificationNavigationListener> {
  bool _opening = false;

  /// 消费一次通知点击；健身入口读取当前账号训练，避免旧通知越过账号边界。
  Future<void> _open(NotificationDestination destination) async {
    if (_opening ||
        !mounted ||
        !widget.ready ||
        NotificationNavigation.pending.value != destination) {
      return;
    }
    _opening = true;
    try {
      final workoutState = destination == NotificationDestination.fitness
          ? ref.read(fitnessRunningWorkoutProvider)
          : null;
      if (workoutState?.isLoading == true) {
        return;
      }
      final workout = destination == NotificationDestination.fitness
          ? workoutState?.asData?.value
          : null;
      NotificationNavigation.pending.value = null;
      final mode = switch (destination) {
        NotificationDestination.bookkeeping => AppMode.bookkeeping,
        NotificationDestination.days => AppMode.days,
        NotificationDestination.fitness => AppMode.fitness,
        NotificationDestination.settings => null,
      };
      if (mode != null) {
        ref.read(currentModeProvider.notifier).set(mode);
        ref.read(bottomTabIndexProvider.notifier).set(0);
      }
      widget.router.go('/');
      if (destination == NotificationDestination.settings) {
        unawaited(widget.router.pushNamed(Routes.reminderSettings));
      } else if (workout != null) {
        final scope = await ref
            .read(fitnessAnalyticsProvider)
            .navigationContext(workout.id);
        if (!mounted) return;
        final current = ref
            .read(productAnalyticsControllerProvider)
            .currentIdentity();
        if (scope.identity.account != current.account ||
            scope.identity.generation != current.generation) {
          return;
        }
        unawaited(
          widget.router.pushNamed(
            Routes.fitnessWorkout,
            extra: ProductAnalyticsNavigation(
              arguments: workout.id,
              context: scope,
            ),
          ),
        );
      }
    } catch (error, stack) {
      logger.error('NotificationNavigation', '打开提醒页面失败', error, stack);
      if (mounted) NotificationNavigation.pending.value = null;
    } finally {
      _opening = false;
    }
  }

  /// 在首帧完成后操作导航，防止通知回调在构建期间修改页面状态。
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: NotificationNavigation.pending,
    builder: (context, destination, _) {
      // 数据流就绪后会触发重建；等待期间不消耗点击，也不持有旧账号的异步结果。
      final waiting =
          destination == NotificationDestination.fitness &&
          ref.watch(fitnessRunningWorkoutProvider).isLoading;
      if (widget.ready && destination != null && !waiting) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _open(destination));
      }
      return const SizedBox.shrink();
    },
  );
}
