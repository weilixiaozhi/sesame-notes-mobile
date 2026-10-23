import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/services/notification/notification_navigation.dart';
import 'package:sesame_notes/shell/notification_navigation_listener.dart';

void main() {
  tearDown(() => NotificationNavigation.pending.value = null);

  test('只接受应用定义的通知路径，忽略旧通知和外部地址', () {
    for (final payload in [null, '', 'https://example.com', '/auth/login']) {
      NotificationNavigation.receive(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: payload,
        ),
      );
      expect(NotificationNavigation.pending.value, isNull);
    }
  });

  for (final destination in NotificationDestination.values) {
    testWidgets('通知 $destination 等待解锁后到达正确页面且只消费一次', (tester) async {
      final container = ProviderContainer(
        overrides: [
          fitnessRunningWorkoutProvider.overrideWith(
            (ref) => Stream.value(
              const FitnessWorkout(
                id: 'current-workout',
                name: '训练',
                scheduledDate: '2026-09-21',
                status: 'in_progress',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(
            path: Routes.reminderSettings,
            name: Routes.reminderSettings,
            builder: (_, _) => const Text('settings'),
          ),
          GoRoute(
            path: Routes.fitnessWorkout,
            name: Routes.fitnessWorkout,
            builder: (_, state) =>
                Text('workout:${productAnalyticsArguments(state.extra)}'),
          ),
        ],
      );
      addTearDown(router.dispose);
      var ready = false;
      late StateSetter update;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MaterialApp.router(
                routerConfig: router,
                builder: (context, child) => Stack(
                  children: [
                    child!,
                    NotificationNavigationListener(
                      router: router,
                      ready: ready,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      NotificationNavigation.receive(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: destination.path,
        ),
      );
      await tester.pumpAndSettle();
      expect(NotificationNavigation.pending.value, destination);
      expect(find.text('home'), findsOneWidget);
      update(() => ready = true);
      await tester.pumpAndSettle();
      expect(NotificationNavigation.pending.value, isNull);
      switch (destination) {
        case NotificationDestination.bookkeeping:
          expect(container.read(currentModeProvider), AppMode.bookkeeping);
        case NotificationDestination.days:
          expect(container.read(currentModeProvider), AppMode.days);
        case NotificationDestination.fitness:
          expect(container.read(currentModeProvider), AppMode.fitness);
          expect(find.text('workout:current-workout'), findsOneWidget);
        case NotificationDestination.settings:
          expect(find.text('settings'), findsOneWidget);
      }
      expect(container.read(bottomTabIndexProvider), 0);
    });
  }
}
