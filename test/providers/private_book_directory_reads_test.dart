import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';

final _directoryVersion = NotifierProvider<SimpleStateNotifier<int>, int>(
  () => SimpleStateNotifier((ref) => 0),
);

/// 在首帧就绪与同步登记目录之间发布下一帧，控制真实异步选择窗口。
class _TwoFrameDayNotifier extends CurrentDayBookNotifier {
  /// 第二帧由测试推进，仓储首值读取仍执行生产逻辑。
  _TwoFrameDayNotifier(this.advance);
  final Future<void> Function() advance;
  var advanced = false;

  /// 只推进一次目录，避免后续依赖重建改变测试场景。
  @override
  Future<void> waitForDirectory() async {
    await super.waitForDirectory();
    if (!advanced) {
      advanced = true;
      await advance();
    }
  }
}

/// 记录真实目录 SQL，识别目录流之外的重复快照查询。
class _DirectoryReads extends d.QueryInterceptor {
  final counts = <String, int>{};

  /// 只统计父目录读取，初始化数据库和子记录查询不影响结果。
  @override
  Future<List<Map<String, Object?>>> runSelect(
    d.QueryExecutor executor,
    String statement,
    List<Object?> args,
  ) async {
    try {
      final rows = await executor.runSelect(statement, args);
      for (final table in ['day_books', 'memo_books', 'fitness_spaces']) {
        if (RegExp(
          'FROM\\s+"?$table"?\\b',
          caseSensitive: false,
        ).hasMatch(statement)) {
          counts.update(table, (value) => value + 1, ifAbsent: () => 1);
        }
      }
      return rows;
    } catch (error, stackTrace) {
      logger.error('PrivateBookReadsTest', '目录读取计数失败', error, stackTrace);
      rethrow;
    }
  }
}

/// 当前本恢复和目录展示共享查询，加载失败仍保持可重试错误状态。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _DirectoryReads reads;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    reads = _DirectoryReads();
    db = SesameDatabase.withExecutor(
      d.ApplyInterceptor(NativeDatabase.memory()).interceptWith(reads),
    );
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(0),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// 同一次提交准备三类目录，备忘录的两个本子类型共用同一目录查询。
  Future<void> seedDirectories(String suffix) async {
    try {
      final stamp = DateTime.utc(2026);
      await db.transaction(() async {
        await db
            .into(db.dayBooks)
            .insert(
              DayBooksCompanion.insert(
                id: 'day-$suffix',
                name: '日子',
                createdAt: stamp,
                updatedAt: stamp,
              ),
            );
        for (final type in ['normal', 'credentials']) {
          await db
              .into(db.memoBooks)
              .insert(
                MemoBooksCompanion.insert(
                  id: '$type-$suffix',
                  name: type,
                  type: type,
                  createdAt: stamp,
                  updatedAt: stamp,
                ),
              );
        }
        await db
            .into(db.fitnessSpaces)
            .insert(
              FitnessSpacesCompanion.insert(
                id: 'fitness-$suffix',
                name: '训练',
                createdAt: stamp,
                updatedAt: stamp,
              ),
            );
      });
    } catch (error, stackTrace) {
      logger.error('PrivateBookReadsTest', '目录夹具准备失败', error, stackTrace);
      rethrow;
    }
  }

  test('四类当前本恢复只各订阅一次目录，目录变化不增加快照查询', () async {
    try {
      await seedDirectories('first');
      reads.counts.clear();
      container.listen(currentDayBookIdProvider, (_, _) {});
      container.listen(currentMemoBookIdProvider, (_, _) {});
      container.listen(currentCredentialBookIdProvider, (_, _) {});
      container.listen(currentFitnessSpaceIdProvider, (_, _) {});

      expect(
        await container.read(currentDayBookIdProvider.future),
        'day-first',
      );
      expect(
        await container.read(currentMemoBookIdProvider.future),
        'normal-first',
      );
      expect(
        await container.read(currentCredentialBookIdProvider.future),
        'credentials-first',
      );
      expect(
        await container.read(currentFitnessSpaceIdProvider.future),
        'fitness-first',
      );
      await container.pump();
      expect(reads.counts, {
        'day_books': 1,
        'memo_books': 1,
        'fitness_spaces': 1,
      });

      await seedDirectories('second');
      // 等待目录流发布新集合，再检查派生选择已经消费同一份结果。
      await Future.wait([
        container.read(dayBooksProvider.future),
        container.read(memoBooksProvider.future),
        container.read(fitnessSpacesProvider.future),
      ]);
      await container.pump();
      await container.pump();
      expect(
        await container.read(currentDayBookIdProvider.future),
        'day-first',
      );
      expect(
        await container.read(currentMemoBookIdProvider.future),
        'normal-first',
      );
      expect(
        await container.read(currentCredentialBookIdProvider.future),
        'credentials-first',
      );
      expect(
        await container.read(currentFitnessSpaceIdProvider.future),
        'fitness-first',
      );
      expect(reads.counts, {
        'day_books': 2,
        'memo_books': 2,
        'fitness_spaces': 2,
      });
    } catch (error, stackTrace) {
      logger.error('PrivateBookReadsTest', '目录复用行为验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('没有页面监听时读取当前本Future也能消费目录首帧', () async {
    try {
      await seedDirectories('first');
      final values = await Future.wait([
        container.read(currentDayBookIdProvider.future),
        container.read(currentMemoBookIdProvider.future),
        container.read(currentCredentialBookIdProvider.future),
        container.read(currentFitnessSpaceIdProvider.future),
      ]).timeout(const Duration(seconds: 3));
      expect(values, [
        'day-first',
        'normal-first',
        'credentials-first',
        'fitness-first',
      ]);
    } catch (error, stackTrace) {
      logger.error('PrivateBookReadsTest', '无页面目录读取验证失败', error, stackTrace);
      rethrow;
    }
  });

  test('目录读取失败不会用额外快照掩盖错误或选择不存在的本子', () async {
    final failure = StateError('目录读取失败');
    final failed = ProviderContainer(
      overrides: [
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(0),
        dayBooksProvider.overrideWith((ref) => Stream.error(failure)),
      ],
    );
    try {
      failed.listen(currentDayBookIdProvider, (_, _) {});
      await expectLater(
        failed.read(currentDayBookIdProvider.future),
        throwsA(same(failure)),
      );
      expect(failed.read(currentDayBookIdProvider).hasError, isTrue);
    } catch (error, stackTrace) {
      logger.error('PrivateBookReadsTest', '目录失败状态验证失败', error, stackTrace);
      rethrow;
    } finally {
      failed.dispose();
    }
  });

  for (final listened in [false, true]) {
    test('目录连续两帧更新时选择登记依赖的最新本子：监听=$listened', () async {
      final stamp = DateTime.utc(2026);
      final first = DayBook(
        id: 'first',
        name: '首帧',
        createdAt: stamp,
        updatedAt: stamp,
      );
      final latest = DayBook(
        id: 'latest',
        name: '第二帧',
        createdAt: stamp,
        updatedAt: stamp,
      );
      late ProviderContainer scoped;
      final notifier = _TwoFrameDayNotifier(() async {
        scoped.read(_directoryVersion.notifier).set(1);
        await readProviderFutureFromContainer(scoped, dayBooksProvider.future);
      });
      scoped = ProviderContainer(
        overrides: [
          currentAccountIdProvider.overrideWithValue(null),
          authIdentityGenerationProvider.overrideWithValue(0),
          dayBooksProvider.overrideWith(
            (ref) => Stream.value([
              ref.watch(_directoryVersion) == 0 ? first : latest,
            ]),
          ),
          currentDayBookIdProvider.overrideWith(() => notifier),
        ],
      );
      try {
        if (listened) scoped.listen(currentDayBookIdProvider, (_, _) {});
        final selected = await scoped
            .read(currentDayBookIdProvider.future)
            .timeout(const Duration(seconds: 3));
        expect(scoped.read(dayBooksProvider).requireValue.single.id, 'latest');
        expect(selected, 'latest', reason: '不能登记第二帧依赖后仍使用已失效首帧选本');
      } catch (error, stackTrace) {
        logger.error('PrivateBookReadsTest', '连续目录帧选择验证失败', error, stackTrace);
        rethrow;
      } finally {
        scoped.dispose();
      }
    });
  }
}
