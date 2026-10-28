/// 独立 Android profile 验收入口，不依赖 flutter_test。
/// 构建：flutter build apk --profile --flavor envTestProbe --no-pub
/// --target e2e/long_term_android_probe.dart --dart-define=APP_ENV=test。
/// API_BASE_URL 和 UPDATE_MANIFEST_URL 必须为空；只写 .test.probe 应用沙箱。
/// 未完成的验收从当前档位继续；完成后的进程启动保留数据，只计真实初始化到首屏。
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';
import 'package:sesame_notes/core/environment/app_environment.dart';
import 'package:sesame_notes/core/identity/local_user_identity.dart';
import 'package:sesame_notes/core/logging/cloud_backup_logger.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' as data;
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/repositories/local/fitness_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_statistics_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_home_cards.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/home_expense_trend.dart';
import 'package:sesame_notes/features/ledgers/presentation/widgets/home_money_hero.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/features/memos/presentation/widgets/memo_entry_tile.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/features/statistics/application/statistics_providers.dart';
import 'package:sesame_notes/features/transactions/presentation/widgets/transaction/transaction_list_item.dart';
import 'package:sesame_notes/main.dart' as product;
import 'package:sesame_notes/providers/app_composition.dart';
import 'package:sesame_notes/providers/app_init_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/theme/app_theme.dart';

import 'long_term_android_faults.dart';
import 'long_term_android_fixture.dart';
import 'long_term_android_restore.dart';

const _version = 'long-term-android-v1';
const _prefix = 'LONG_TERM_ANDROID_JSON:';
const _samples = int.fromEnvironment(
  'LONG_TERM_ANDROID_SAMPLES',
  defaultValue: 20,
);
const _warmups = 3;
IOSink? _sink;

/// 记录 Dart 入口计时；已有数据时首帧直接来自真实产品主壳。
Future<void> main() async {
  final entry = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _run(entry);
  } catch (error, stack) {
    _emit({
      'type': 'error',
      'error': safeErrorSummary(error),
      'stack': '$stack',
    });
    await _sink?.flush();
    runApp(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: const Scaffold(
          body: Center(child: Text('长期使用验收未完成，请保留测试日志后重试。')),
        ),
      ),
    );
  }
}

/// 在任何数据写入之前验证包身份和服务配置，防止误用正式包或正式账号服务。
Future<void> _run(Stopwatch entry) async {
  AppEnvironment.validate();
  final package = await PackageInfo.fromPlatform();
  if (!Platform.isAndroid ||
      kDebugMode ||
      AppEnvironment.name != 'test' ||
      package.packageName != 'com.sesame.notes.test.probe' ||
      AppEnvironment.apiBaseUrl.isNotEmpty ||
      AppEnvironment.updateManifestUrl.isNotEmpty ||
      _samples < 20 ||
      _samples > 100) {
    throw StateError('需要独立 Android profile/release 测试包、空服务地址及20至100次样本');
  }
  final directory = await getApplicationDocumentsDirectory();
  final runDirectory = await Directory(
    p.join(directory.path, 'long_term_probe'),
  ).create(recursive: true);
  _sink = File(
    p.join(
      runDirectory.path,
      'run_${DateTime.now().microsecondsSinceEpoch}.jsonl',
    ),
  ).openWrite();
  final prefs = await SharedPreferences.getInstance();
  final existingVersion = prefs.getString('long_term_probe_version');
  final preparedYears = prefs.getInt('long_term_probe_years') ?? 0;
  final fresh = existingVersion == null;
  final benchmarksComplete = prefs.getBool('long_term_probe_complete') ?? false;
  if (!fresh &&
      (existingVersion != _version || ![1, 5, 10].contains(preparedYears))) {
    throw StateError('测试数据版本或准备标记不匹配，请核对本测试包的数据');
  }
  if (benchmarksComplete && (fresh || preparedYears != 10)) {
    throw StateError('验收完成标记与十年数据档位不一致');
  }
  var currentYears = preparedYears;
  final file = File(p.join(directory.path, 'sesame_notes.sqlite'));
  final db = data.SesameDatabase.withExecutor(
    NativeDatabase.createInBackground(file).interceptWith(ProbeWriteBarrier()),
  );
  ProviderContainer? container;
  var mounted = false;
  try {
    final open = Stopwatch()..start();
    await db.customSelect('SELECT 1').get();
    open.stop();
    final localSelfId = await LocalSelfId.getOrCreate();
    final anchor = fresh
        ? DateTime.now()
        : DateTime.parse(prefs.getString('long_term_probe_anchor')!);
    if (fresh) {
      // 首次准备不是冷启动测量；空沙箱才允许填充，以免覆盖其他人工测试数据。
      final existing = await db
          .customSelect(
            'SELECT (SELECT count(*) FROM ledgers)+(SELECT count(*) FROM memo_books)+(SELECT count(*) FROM fitness_spaces) AS n',
          )
          .getSingle();
      if (existing.read<int>('n') != 0) throw StateError('未标记的测试数据库已有内容，已停止填充');
      runApp(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: const Scaffold(
            body: Center(child: Text('正在准备独立测试数据，请保持应用在前台。')),
          ),
        ),
      );
      await WidgetsBinding.instance.endOfFrame;
      await _prepare(db, prefs, 1, anchor, localSelfId);
      currentYears = 1;
    }
    // 本测试只关闭自动备份这一项后台干扰；真实初始化和主壳生命周期完整保留。
    if (!await prefs.setBool(LocalBackupService.prefsKeyAutoBackup, false) ||
        !await prefs.setBool('welcome_shown', true) ||
        !await prefs.setString('current_ledger_id', androidProbeLedgerId) ||
        !await prefs.setString(
          'current_memo_book_id_local',
          androidProbeMemoBookId,
        ) ||
        !await prefs.setString(
          'current_credential_book_id_local',
          androidProbeCredentialBookId,
        ) ||
        !await prefs.setString(
          'current_fitness_space_id_local',
          androidProbeFitnessSpaceId,
        )) {
      throw StateError('测试设置未能持久化');
    }
    final init = Stopwatch()..start();
    registerSupabaseBackend(logger: cloudBackupLogger);
    registerWebDavBackend(logger: cloudBackupLogger);
    registerS3Backend(logger: cloudBackupLogger);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final appContainer = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        ...applicationOverrides(),
        databaseProvider.overrideWithValue(db),
      ],
    );
    container = appContainer;
    // 与产品 main 相同的依赖装配和 initializeLocalApp，不人工发布 ready 状态。
    await _startupStage(
      'initialize_local_app',
      () => initializeLocalApp(appContainer),
      flushProgress: !benchmarksComplete,
    );
    if (appContainer.read(currentAccountIdProvider) != null ||
        appContainer.read(appInitStateProvider) != AppInitState.ready) {
      throw StateError('测试主壳必须处于已完成真实初始化的匿名本机状态');
    }
    // 当前本由真实主壳从预置的本机偏好自然恢复，挂载前不主动调用选本用例。
    await _startupStage('mount_product_app', () {
      runApp(
        UncontrolledProviderScope(
          container: appContainer,
          child: const product.MainApp(),
        ),
      );
      mounted = true;
    }, flushProgress: !benchmarksComplete);
    await _startupStage(
      'bookkeeping_page_ready',
      () => _pageReady(appContainer, AppMode.bookkeeping),
      flushProgress: !benchmarksComplete,
    );
    init.stop();
    entry.stop();
    _emit({
      'type': fresh
          ? 'prepared_startup'
          : benchmarksComplete
          ? 'cold_startup'
          : 'resumed_startup',
      'years': currentYears,
      'dart_entry_to_data_layout_us': entry.elapsedMicroseconds,
      'real_product_initialization_to_data_layout_us': init.elapsedMicroseconds,
      'database_open_us': open.elapsedMicroseconds,
      'includes_seed_preparation': fresh,
      'scope':
          'Dart entry and QA guards through initializeLocalApp and actual populated product layout; no GPU or input latency',
    });
    _emit({
      'type': 'metadata',
      'package': package.packageName,
      'version': '${package.version}+${package.buildNumber}',
      'mode': kProfileMode ? 'profile' : 'release',
      'dataset': _version,
      'anchor': anchor.toIso8601String(),
      'samples': _samples,
      'warmups': _warmups,
      'auto_backup': false,
      'api_configured': false,
      'database': file.path,
      'run_directory': runDirectory.path,
      'device': await _device(),
      'fresh_preparation': fresh,
      'resume_benchmarks': !fresh && !benchmarksComplete,
      'starting_years': currentYears,
      'scope':
          'file SQLite background connection; in-process warm-cache reads and mode switches to populated Flutter layout',
    });
    if (!benchmarksComplete) {
      for (final years in [1, 5, 10]) {
        if (years < currentYears) continue;
        // 当前已准备的档位只重测；后续档位追加更早记录，不重建已有数据。
        if (years > currentYears) {
          await _prepare(db, prefs, years, anchor, localSelfId);
          currentYears = years;
        }
        await _readBenchmarks(db, years, anchor);
        await _pageBenchmarks(appContainer, years);
      }
      await runAndroidRestoreProbe(db, file, runDirectory, localSelfId, _emit);
      if (!await prefs.setBool('long_term_probe_complete', true)) {
        throw StateError('验收完成标记未保存');
      }
    }
    // 已完成验收的重启不重跑基准，便于核对人工保存、强杀及重新进入的真实结果。
    await emitAndroidRecoveryAudit(db);
    _emit({
      'type': 'ready_for_manual',
      'years': currentYears,
      'benchmarks_complete': prefs.getBool('long_term_probe_complete') ?? false,
      'inventory': await _inventory(db),
      'database_bytes': await file.length(),
      'note': '真实主壳继续使用原数据库；后续进程启动保留全部人工编辑',
    });
    await _sink?.flush();
  } catch (error, stack) {
    logger.error(
      'AndroidLongTermProbe',
      '独立测试运行未完成',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  } finally {
    if (!mounted) {
      container?.dispose();
      await db.close();
    }
  }
}

/// 将启动等待定位到明确阶段；未完成的验收即时刷盘，所有阶段最多等待三十秒。
Future<T> _startupStage<T>(
  String name,
  FutureOr<T> Function() action, {
  required bool flushProgress,
}) async {
  final timer = Stopwatch()..start();
  try {
    _emit({'type': 'startup_stage', 'stage': name, 'status': 'begin'});
    if (flushProgress) await _sink?.flush();
    final result = await Future<T>.sync(
      action,
    ).timeout(const Duration(seconds: 30));
    _emit({
      'type': 'startup_stage',
      'stage': name,
      'status': 'complete',
      'elapsed_us': timer.elapsedMicroseconds,
    });
    if (flushProgress) await _sink?.flush();
    return result;
  } catch (error, stack) {
    _emit({
      'type': 'startup_stage',
      'stage': name,
      'status': 'failed',
      'elapsed_us': timer.elapsedMicroseconds,
      'error': safeErrorSummary(error),
      'stack': '$stack',
    });
    await _sink?.flush();
    rethrow;
  } finally {
    timer.stop();
  }
}

/// 增量生成当前规模；事务完成后再发布持久化准备标记。
Future<void> _prepare(
  data.SesameDatabase db,
  SharedPreferences prefs,
  int years,
  DateTime anchor,
  String selfId,
) async {
  final timer = Stopwatch()..start();
  try {
    await seedAndroidProbeData(db, years, anchor: anchor, localSelfId: selfId);
    if (!await prefs.setString(
          'long_term_probe_anchor',
          anchor.toIso8601String(),
        ) ||
        !await prefs.setInt('long_term_probe_years', years) ||
        !await prefs.setString('long_term_probe_version', _version)) {
      throw StateError('数据准备标记未保存');
    }
    _emit({
      'type': 'prepared',
      'years': years,
      'preparation_us': timer.elapsedMicroseconds,
      'inventory': await _inventory(db),
    });
  } catch (error, stack) {
    _emit({
      'type': 'preparation_error',
      'years': years,
      'error': safeErrorSummary(error),
      'stack': '$stack',
    });
    rethrow;
  }
}

/// 每个查询消费真实结果，三个预热样本独立于二十次计量样本。
Future<void> _readBenchmarks(
  data.SesameDatabase db,
  int years,
  DateTime anchor,
) async {
  final memos = MemoRepository(db);
  final fitness = FitnessRepository(db, spaceId: androidProbeFitnessSpaceId);
  final actions = <String, Future<void> Function()>{
    'memo_first_100': () async {
      if ((await memos.watchEntries(androidProbeMemoBookId, limit: 100).first)
              .length !=
          100) {
        throw StateError('备忘首屏数据不足');
      }
    },
    'credential_search': () async {
      if ((await memos
                  .watchCredentialEntries(
                    bookId: androidProbeCredentialBookId,
                    search: 'synthetic_1@',
                  )
                  .first)
              .length !=
          1) {
        throw StateError('凭据字段搜索结果不符');
      }
    },
    'transaction_first_20': () async {
      if ((await LocalTransactionRepository(
                db,
              ).watchRecentTransactions(ledgerId: androidProbeLedgerId).first)
              .length !=
          20) {
        throw StateError('账单首屏数据不足');
      }
    },
    'expense_statistics_all_years': () async {
      final values = await LocalStatisticsRepository(db)
          .totalsByCategoryWithHierarchy(
            ledgerId: androidProbeLedgerId,
            type: 'expense',
            start: anchor.subtract(Duration(days: years * 366)),
            end: anchor.add(const Duration(days: 1)),
          );
      final sum = values.fold<double>(0, (sum, value) => sum + value.total);
      if ((sum - years * 1460 * 12.34).abs() > 0.01) {
        throw StateError('统计金额与合成数据不符');
      }
    },
    'memo_read_all': () async {
      if ((await memos.getEntries(androidProbeMemoBookId)).length !=
          years * 365) {
        throw StateError('备忘全量计数不符');
      }
    },
    'workout_read_all': () async {
      if ((await fitness.getWorkouts()).length != years * 156 + 1) {
        throw StateError('训练全量计数不符');
      }
    },
  };
  for (final action in actions.entries) {
    final samples = <int>[];
    for (var index = -_warmups; index < _samples; index++) {
      final timer = Stopwatch()..start();
      try {
        await action.value();
      } catch (error, stack) {
        _emit({
          'type': 'query_error',
          'metric': action.key,
          'error': safeErrorSummary(error),
          'stack': '$stack',
        });
        rethrow;
      }
      timer.stop();
      if (index >= 0) samples.add(timer.elapsedMicroseconds);
      await Future<void>.delayed(Duration.zero);
    }
    _summary(action.key, years, samples);
  }
}

/// 循环切换三域主壳，首次每域另列，后续样本不冒充进程冷启动。
Future<void> _pageBenchmarks(ProviderContainer container, int years) async {
  final samples = {
    for (final mode in [AppMode.memos, AppMode.fitness, AppMode.bookkeeping])
      mode: <int>[],
  };
  for (var index = 0; index <= _samples; index++) {
    for (final mode in samples.keys) {
      final timer = Stopwatch()..start();
      container.read(bottomTabIndexProvider.notifier).set(0);
      container.read(currentModeProvider.notifier).set(mode);
      await _pageReady(container, mode);
      timer.stop();
      if (index == 0) {
        _emit({
          'type': 'first_domain_layout',
          'years': years,
          'mode': mode.name,
          'elapsed_us': timer.elapsedMicroseconds,
        });
      } else {
        samples[mode]!.add(timer.elapsedMicroseconds);
      }
    }
  }
  for (final entry in samples.entries) {
    _summary('${entry.key.name}_mode_to_data_layout', years, entry.value);
  }
}

/// 等待真实产品查询与含实际记录的布局；加载占位和空列表不会被计作就绪。
Future<void> _pageReady(ProviderContainer container, AppMode mode) async {
  final subscriptions = <ProviderSubscription<Object?>>[];
  const budget = Duration(seconds: 30);
  final deadline = Stopwatch()..start();

  /// 在本次页面核对结束前保持真实监听，避免首值尚未到达时被自动释放。
  Future<T> hold<T>(ProviderListenable<Future<T>> provider) {
    final subscription = container.listen(provider, (_, _) {});
    subscriptions.add(subscription);
    final remaining = budget - deadline.elapsed;
    if (remaining <= Duration.zero) {
      throw TimeoutException('${mode.name} 页面查询超过三十秒');
    }
    return subscription.read().timeout(remaining);
  }

  try {
    // 模式状态已更新，先让实际页面挂载监听，再建立验收观察者。
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame.timeout(budget);
    if (mode == AppMode.memos) {
      await hold(memoBooksProvider.future);
      await hold(
        memoEntriesProvider((
          bookId: androidProbeMemoBookId,
          date: null,
          limit: 100,
        )).future,
      );
    } else if (mode == AppMode.fitness) {
      final now = DateTime.now();
      await hold(fitnessCalendarPlansProvider.future);
      await hold(
        fitnessWorkoutsInRangeProvider((
          start: DateTime(now.year, now.month, 1 - 7),
          until: DateTime(now.year, now.month + 1, 1 + 7),
          calendar: true,
        )).future,
      );
    } else {
      await hold(currentLedgerProvider.future);
      final month = container.read(selectedMonthProvider);
      final query = (ledgerId: androidProbeLedgerId, month: month);
      await Future.wait([
        hold(monthlyTotalsProvider(query).future),
        hold(todayExpenseProvider(androidProbeLedgerId).future),
        hold(weekExpenseProvider(androidProbeLedgerId).future),
        hold(homeExpenseTrendProvider(query).future),
      ]);
    }
    while (deadline.elapsed < budget) {
      WidgetsBinding.instance.scheduleFrame();
      await WidgetsBinding.instance.endOfFrame.timeout(
        budget - deadline.elapsed,
      );
      if (container.read(currentModeProvider) == mode &&
          container.read(bottomTabIndexProvider) == 0 &&
          _containsData(mode)) {
        return;
      }
    }
    throw StateError('${mode.name} 页面未达到包含真实记录的布局状态');
  } catch (error, stack) {
    _emit({
      'type': 'layout_error',
      'mode': mode.name,
      'error': safeErrorSummary(error),
      'stack': '$stack',
    });
    rethrow;
  } finally {
    deadline.stop();
    for (final subscription in subscriptions.reversed) {
      subscription.close();
    }
  }
}

/// 遍历当前可见元素，核对产品列表中的记录实例而非仅核对容器存在。
bool _containsData(AppMode mode) {
  var found = false;
  var hero = false;
  var placeholder = false;

  /// 排除保留在元素树中的后台页面，核对当前域真正参与布局的业务行。
  void visit(Element element) {
    final widget = element.widget;
    if (widget is Offstage && widget.offstage) return;
    if (widget is Visibility && !widget.visible) return;
    if (widget is TickerMode && !widget.enabled) return;
    if (mode == AppMode.memos &&
        widget is MemoEntryTile &&
        widget.entry.id == androidProbeMemoId(0)) {
      found = true;
    }
    if (mode == AppMode.fitness &&
        widget is FitnessHomeWorkoutCard &&
        widget.workout.id == androidProbeTodayWorkoutId) {
      found = true;
    }
    if (mode == AppMode.bookkeeping &&
        widget is TransactionListItem &&
        widget.ledgerId == androidProbeLedgerId) {
      found = true;
    }
    if (widget is HomeMoneyHero) hero = true;
    if (widget.key == const ValueKey('home-summary-amount-placeholder')) {
      placeholder = true;
    }
    // 只走IndexedStack当前实际绘制的分支，不向业务元素注册额外的可见性依赖。
    if (element is MultiChildRenderObjectElement &&
        element.renderObject is RenderIndexedStack) {
      final selected = (element.renderObject as RenderIndexedStack).index;
      var index = 0;
      element.visitChildren((child) {
        if (index++ == selected) {
          visit(child);
        }
      });
      return;
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return found && (mode != AppMode.bookkeeping || (hero && !placeholder));
}

/// 读取计数只作为当前磁盘事实，不在重启时纠正或覆盖人工变更。
Future<Map<String, int>> _inventory(data.SesameDatabase db) async {
  final row = await db
      .customSelect(
        "SELECT (SELECT count(*) FROM transactions) AS transactions,(SELECT count(*) FROM memo_entries WHERE book_type='normal') AS memos,(SELECT count(*) FROM memo_entries WHERE book_type='credentials') AS credentials,(SELECT count(*) FROM fitness_entities WHERE entity_type='fitness_workout') AS workouts",
      )
      .getSingle();
  return {for (final entry in row.data.entries) entry.key: entry.value as int};
}

/// 读取实际 Android 设备信息，采样之后读取以免影响启动子区间。
Future<Map<String, String>> _device() async {
  final result = <String, String>{};
  for (final key in [
    'ro.product.manufacturer',
    'ro.product.model',
    'ro.product.cpu.abilist',
    'ro.build.version.release',
  ]) {
    final response = await Process.run('/system/bin/getprop', [key]);
    if (response.exitCode != 0) throw StateError('设备属性读取失败');
    result[key] = '${response.stdout}'.trim();
  }
  return result;
}

/// 保留所有原始值；最近秩P95只用于二十次以上的本次样本描述，不宣称长期分位。
void _summary(String metric, int years, List<int> values) {
  final sorted = [...values]..sort();
  _emit({
    'type': 'summary',
    'metric': metric,
    'years': years,
    'samples': values.length,
    'raw_us': values,
    'median_ms':
        (sorted[(sorted.length - 1) ~/ 2] + sorted[sorted.length ~/ 2]) / 2000,
    'p95_ms': sorted[(sorted.length * .95).ceil() - 1] / 1000,
    'max_ms': sorted.last / 1000,
  });
}

/// 同步输出结构化日志到logcat；磁盘写入使用队列，阶段末尾显式flush。
void _emit(Map<String, Object?> value) {
  final line = jsonEncode({
    'utc': DateTime.now().toUtc().toIso8601String(),
    ...value,
  });
  debugPrintSynchronously('$_prefix$line');
  _sink?.writeln(line);
}
