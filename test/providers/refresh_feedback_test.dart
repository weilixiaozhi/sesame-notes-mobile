import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/application/fitness_space_queries.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_home_page.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/presentation/memos_page.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/widgets/app_pull_to_refresh.dart';
import 'package:sesame_notes/theme/app_theme.dart';

/// 替代远端结果，界面和刷新文案仍使用真实实现。
class _Sync extends Mock implements SyncCoordinator {}

/// 本地读取边界可控制成功或失败，不接触用户文件。
class _MemoActions extends Mock implements MemoActions {}

class _FitnessActions extends Mock implements FitnessActions {}

class _FitnessSpaces extends Mock implements FitnessSpaceQueries {}

/// 验证真正页面刷新回调的文案，保留账号和云本条件来复现误报。
void main() {
  final now = DateTime(2026, 10, 23);
  final book = MemoBook(
    id: 'memo',
    name: '下载的备忘录本',
    type: 'normal',
    createdAt: now,
    updatedAt: now,
    storageMode: 'cloud',
    scopeAccountId: 'account',
    syncId: 'memo-sync',
    fullCursor: '1',
  );
  final space = FitnessSpace(
    id: 'fitness',
    name: '下载的健身空间',
    createdAt: now,
    updatedAt: now,
    storageMode: 'cloud',
    scopeAccountId: 'account',
    syncId: 'fitness-sync',
    fullCursor: '1',
  );
  const target = (
    bookId: 'fitness',
    accountId: 'account',
    generation: 0,
    syncId: 'fitness-sync',
  );

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

  for (final fitness in [false, true]) {
    for (final scenario in [
      'no-server',
      'local-only',
      'cloud',
      'failure',
      'pending',
      'rejected',
      'throw',
      'local-read-failed',
    ]) {
      testWidgets('${fitness ? '健身' : '备忘'}首页按实际刷新结果反馈：$scenario', (
        tester,
      ) async {
        final sync = _Sync();
        final memos = _MemoActions();
        final workouts = _FitnessActions();
        final spaces = _FitnessSpaces();
        final localReadFails = scenario == 'local-read-failed';
        when(
          () => memos.refreshLocalSnapshot(
            accountId: 'account',
            bookId: 'memo',
            limit: 100,
          ),
        ).thenAnswer((_) async {
          if (localReadFails) throw StateError('本地读取失败');
        });
        when(() => workouts.target).thenReturn(target);
        when(() => workouts.refreshLocalSnapshot()).thenAnswer((_) async {
          if (localReadFails) throw StateError('本地读取失败');
        });
        when(
          () => spaces.getBooks(accountId: 'account'),
        ).thenAnswer((_) async => [space]);
        when(() => sync.refreshData()).thenAnswer((_) async {
          return switch (scenario) {
            'cloud' => const SyncRunResult.cloudSynced(),
            'failure' => const SyncRunResult(error: '云端失败'),
            'pending' => const SyncRunResult(pendingCount: 1),
            'rejected' => const SyncRunResult(rejectedCount: 1),
            'throw' => throw StateError('云端异常'),
            _ => const SyncRunResult.localOnly(),
          };
        });
        final container = ProviderContainer(
          retry: (_, _) => null,
          overrides: [
            apiConfigProvider.overrideWithValue(const ApiConfig(baseUrl: '')),
            if (scenario != 'no-server')
              syncCoordinatorProvider.overrideWithValue(sync),
            currentMemoBookProvider.overrideWithValue(AsyncData(book)),
            currentMemoBookIdProvider.overrideWithBuild(
              (ref, notifier) => book.id,
            ),
            memoBooksProvider.overrideWith((ref) => Stream.value([book])),
            memoEntriesProvider.overrideWith((ref, query) => Stream.value([])),
            memoActionsProvider.overrideWithValue(memos),
            currentFitnessSpaceProvider.overrideWithValue(AsyncData(space)),
            currentFitnessSpaceIdProvider.overrideWithBuild(
              (ref, notifier) => space.id,
            ),
            fitnessActionsProvider.overrideWithValue(workouts),
            fitnessSpaceQueriesProvider.overrideWithValue(spaces),
            fitnessWorkoutsInRangeProvider.overrideWith(
              (ref, range) => Stream.value([]),
            ),
            fitnessCalendarPlansProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
            localTodayProvider.overrideWithBuild((ref, notifier) => now),
          ],
        );
        container
            .read(accountStateProvider.notifier)
            .restorePending(userId: 'account');
        try {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: AppTheme.lightTheme(),
                locale: const Locale('zh'),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: fitness
                    ? const FitnessHomePage()
                    : const MemosPage(kind: MemoPageKind.home),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final pull = tester.widget<AppPullToRefresh>(
            find.byType(AppPullToRefresh),
          );
          final actual = await pull.onRefresh();
          final l10n = lookupAppLocalizations(const Locale('zh'));
          final failedCloud = [
            'failure',
            'pending',
            'rejected',
            'throw',
          ].contains(scenario);
          final expected = localReadFails
              ? (fitness ? l10n.fitnessLoadFailed : l10n.memoPullLocalFailed)
              : scenario == 'cloud'
              ? (fitness
                    ? l10n.fitnessPullCloudSuccess
                    : l10n.memoPullCloudSuccess)
              : failedCloud
              ? (fitness
                    ? l10n.fitnessPullCloudFailedButLocalOk
                    : l10n.memoPullCloudFailedButLocalOk)
              : (fitness
                    ? l10n.fitnessPullLocalSuccess
                    : l10n.memoPullLocalSuccess);
          expect(actual, expected);
          expect(container.read(currentAccountIdProvider), 'account');
          if (scenario == 'no-server') verifyNever(() => sync.refreshData());
          expect(tester.takeException(), isNull);
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          container.dispose();
        }
      });
    }
  }
}
