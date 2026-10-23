import 'package:sesame_notes/core/environment/app_environment.dart';
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/identity/local_user_identity.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart' as data;
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/days/presentation/widgets/day_widgets.dart';
import 'package:sesame_notes/features/settings/infrastructure/local_backup_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/main.dart' as product;
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/theme/app_theme.dart';

const _prefix = 'DAYS_PROFILE_JSON:';
const _datasetSize = 1000;
const _samples = int.fromEnvironment('DAYS_PROFILE_SAMPLES', defaultValue: 20);
const _warmups = 3;
const _dataBudgetMs = 200;
const _switchBudgetMs = 500;
const _bookId = '40000000-0000-4000-8000-000000000000';
const _rules = DayDateRules();
final _today = DateOnly(2026, 9, 7);

/// 独立 Android QA 入口；输出真实文件查询、日期计算及主壳切换的测量结果。
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: AppTheme.lightTheme(),
      home: const Scaffold(body: Center(child: Text('正在准备日子性能验收'))),
    ),
  );
  try {
    await WidgetsBinding.instance.endOfFrame;
    await runDayProfileProbe();
  } catch (error, stackTrace) {
    _emit({
      'type': 'error',
      'utc': DateTime.now().toUtc().toIso8601String(),
      'error': safeErrorSummary(error),
      'stack': stackTrace.toString(),
    });
    runApp(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: const Scaffold(body: Center(child: Text('性能验收未完成，请保留日志后重试'))),
      ),
    );
  }
}

/// 先检查 QA 包身份，再建立真实数据库；成功后保留真实主应用供人工检查。
Future<void> runDayProfileProbe() async {
  AppEnvironment.validate();
  if (!Platform.isAndroid ||
      kDebugMode ||
      AppEnvironment.name != 'test' ||
      _samples < 20) {
    throw StateError('需要 Android profile/release 模式及至少 20 次样本');
  }
  final package = await PackageInfo.fromPlatform();
  if (package.packageName != 'com.sesame.notes.test.probe') {
    throw StateError('性能探针只允许写入 .test.probe 独立测试应用');
  }
  final device = {
    for (final key in [
      'ro.product.manufacturer',
      'ro.product.model',
      'ro.product.cpu.abilist',
      'ro.build.version.release',
    ])
      key: await _getProperty(key),
  };
  final directory = await getApplicationDocumentsDirectory();
  // 包级沙箱已验证；采用产品文件名，使实际主壳和手动备份也访问同一 QA 库。
  final file = File(p.join(directory.path, 'sesame_notes.sqlite'));

  /// 每次打开真实文件时都使用产品相同的后台 SQLite 连接。
  data.SesameDatabase open() =>
      data.SesameDatabase.withExecutor(NativeDatabase.createInBackground(file));
  var db = open();
  ProviderContainer? container;
  var mounted = false;
  try {
    var repository = DayRepository(db, validateAndProject: validateAndProject);
    await db.transaction(() async {
      if (await repository.getBook(_bookId) != null) {
        await repository.deleteBook(await repository.target(_bookId));
      }
      await repository.createBook(id: _bookId, name: '日子固定性能样本');
      for (var index = 0; index < _datasetSize; index++) {
        await repository.saveEvent(_fixture(index));
      }
    });
    // 关闭写连接再打开，计量使用真实 SQLite 文件及与生产一致的后台连接。
    await db.close();
    db = open();
    repository = DayRepository(db, validateAndProject: validateAndProject);
    final l10n = lookupAppLocalizations(const Locale('zh'));
    final events = await repository.getEvents(_bookId);
    final counts = {
      for (final category in DayCategory.values)
        category: events.where((e) => e.definition.category == category).length,
    };
    if (events.length != _datasetSize ||
        counts.values.any((count) => count != _datasetSize ~/ 4) ||
        !events.any((e) => e.definition.event?.isLeapMonth == true) ||
        !events.any((e) => e.definition.repeatType == DayRepeatType.none) ||
        !events.any((e) => e.definition.intervalDays == 1)) {
      throw StateError('固定性能数据集不完整');
    }
    _emit({
      'type': 'metadata',
      'utc': DateTime.now().toUtc().toIso8601String(),
      'device': device,
      'package': package.packageName,
      'version': '${package.version}+${package.buildNumber}',
      'mode': kProfileMode ? 'profile' : 'release',
      'dataset': 'days-mixed-1000-v1',
      'category_counts': counts,
      'today': _today.iso8601,
      'visible_grid_days': DateTime.daysPerWeek * 6,
      'samples': _samples,
      'warmups': _warmups,
      'database': file.path,
      'database_bytes': await file.length(),
      'storage': 'file_sqlite_background_connection_warm_os_cache',
      'repository_scope':
          'getEvents + sortEvents + recentEvent + next/display/statistic for every row',
      'calendar_scope':
          'eventsInCalendarRange + visible 42-day grouping/sorting; excludes repository read',
      'switch_scope':
          'real MainApp/SesameNotesApp; mode state change to data-ready Flutter layout frame; excludes GPU/input latency',
      'percentile': 'nearest_rank_ceil_0.95_n',
      'sample_unit': 'microseconds',
      'summary_unit': 'milliseconds',
    });

    final querySamples = <int>[];
    final calendarSamples = <int>[];
    int? expectedChecksum;
    for (var sample = -_warmups; sample < _samples; sample++) {
      final timer = Stopwatch()..start();
      final loaded = await repository.getEvents(_bookId);
      final checksum = _derive(loaded, l10n);
      timer.stop();
      final queryUs = timer.elapsedMicroseconds;
      timer
        ..reset()
        ..start();
      final occurrences = _calendar(loaded);
      timer.stop();
      if (loaded.length != _datasetSize ||
          (expectedChecksum != null && expectedChecksum != checksum) ||
          occurrences < DateTime.daysPerWeek * 6) {
        throw StateError('性能样本未完整执行或数据在采样期间变化');
      }
      expectedChecksum = checksum;
      if (sample >= 0) {
        querySamples.add(queryUs);
        calendarSamples.add(timer.elapsedMicroseconds);
        _emit({
          'type': 'sample',
          'index': sample + 1,
          'repository_derive_us': queryUs,
          'visible_calendar_us': timer.elapsedMicroseconds,
          'checksum': checksum,
          'occurrences': occurrences,
        });
      }
      await Future<void>.delayed(Duration.zero);
    }
    _summary('repository_derive', querySamples, _dataBudgetMs);
    _summary('visible_calendar', calendarSamples, _dataBudgetMs);

    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setBool(
          LocalBackupService.prefsKeyAutoBackup,
          false,
        ) ||
        !await preferences.setBool('welcome_shown', true)) {
      throw StateError('QA 测量设置未保存');
    }
    final financialRepository = LocalRepository(db);
    final ledgers = await financialRepository.getAllLedgers();
    final ledgerId = ledgers.isEmpty
        ? await financialRepository.createLedger(
            name: '性能验收本机账本',
            storageMode: 'local',
            localSelfId: await LocalSelfId.getOrCreate(),
          )
        : ledgers.first.id;
    if (!await preferences.setString('current_ledger_id', ledgerId)) {
      throw StateError('QA 账本选择未保存');
    }
    var measuring = true;
    container = ProviderContainer(
      retry: (count, error) => null,
      overrides: [
        databaseProvider.overrideWithValue(db),
        dayDefinitionValidatorProvider.overrideWithValue(validateAndProject),
        dayTodayProvider.overrideWith(
          (ref) => measuring
              ? _today
              : DateOnly.fromDateTime(ref.watch(localTodayProvider)),
        ),
      ],
    );
    final clockContainer = container;
    clockContainer.listen(localTodayProvider, (previous, next) {
      _clockEvent('local_today', next);
    }, fireImmediately: true);
    // 复用同一广播流对象，原生 EventChannel 仍只建立一条订阅。
    clockContainer
        .read(clockChangeEventsProvider)
        .listen(
          (_) => _clockEvent(
            'native_event',
            clockContainer.read(localTodayProvider),
          ),
          onError: (Object error, StackTrace stackTrace) => _emit({
            'type': 'clock_error',
            'error': safeErrorSummary(error),
            'stack': stackTrace.toString(),
          }),
        );
    container.read(currentLedgerIdProvider.notifier).set(ledgerId);
    container.read(appInitStateProvider.notifier).set(AppInitState.ready);
    await container.read(currentDayBookIdProvider.notifier).select(_bookId);
    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const product.MainApp(),
      ),
    );
    mounted = true;
    await container.read(currentLedgerPersistProvider.future);
    await container.read(currentLedgerProvider.future);
    await WidgetsBinding.instance.endOfFrame;
    final coldUs = await _switchToDays(container);
    _emit({'type': 'cold_switch', 'switch_data_frame_us': coldUs});
    final switches = <int>[];
    for (var sample = 0; sample < _samples; sample++) {
      container.read(currentModeProvider.notifier).set(AppMode.bookkeeping);
      await WidgetsBinding.instance.endOfFrame;
      final elapsed = await _switchToDays(container);
      switches.add(elapsed);
      _emit({
        'type': 'switch_sample',
        'index': sample + 1,
        'switch_data_frame_us': elapsed,
      });
    }
    _summary('switch_data_frame', switches, _switchBudgetMs);
    measuring = false;
    container.invalidate(dayTodayProvider);
    _clockEvent('real_clock_enabled', container.read(localTodayProvider));
    _emit({
      'type': 'complete',
      'utc': DateTime.now().toUtc().toIso8601String(),
      'cold_switch_us': coldUs,
    });
  } finally {
    // 已挂载的真实应用继续持有其连接，关闭进程才释放；启动失败则立即释放。
    if (!mounted) {
      container?.dispose();
      await db.close();
    }
  }
}

/// 使用四类均分的固定定义，包含闰月、月底固定日期与 X=1 的有界查询。
DayEvent _fixture(int index) {
  final group = index ~/ DayCategory.values.length;
  final day = group % 28 + 1;
  final solar = OriginalDate.solar(
    DateOnly(2000 + group % 20, group % 12 + 1, day),
  );
  final lunar = OriginalDate(
    calendarType: DayCalendarType.lunar,
    originalYear: 2023,
    originalMonth: 2,
    originalDay: day,
    isLeapMonth: true,
  );
  final name = '固定日子 ${index + 1}';
  final definition = switch (DayCategory.values[index %
      DayCategory.values.length]) {
    DayCategory.birthday => DayEventDefinition(
      name: name,
      category: DayCategory.birthday,
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: group.isEven ? solar : lunar,
    ),
    DayCategory.anniversary => DayEventDefinition(
      name: name,
      category: DayCategory.anniversary,
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: group.isEven ? lunar : solar,
    ),
    DayCategory.countdown when group % 5 >= 3 => DayEventDefinition(
      name: name,
      category: DayCategory.countdown,
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.intervalDays,
      intervalDays: group % 5 == 3 ? 1 : 7,
      start: solar,
    ),
    DayCategory.countdown => DayEventDefinition(
      name: name,
      category: DayCategory.countdown,
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.day,
      countdownMode: DayCountdownMode.fixedDate,
      event: group % 5 == 2 ? lunar : OriginalDate.solar(DateOnly(2020, 1, 31)),
    ),
    _ => DayEventDefinition(
      name: name,
      category: DayCategory.stage,
      repeatType: DayRepeatType.none,
      statisticType: DayStatisticType.year,
      start: OriginalDate.solar(_today.addDays(group % 61 - 30)),
      end: OriginalDate.solar(_today.addDays(group % 61 - 30 + group % 40)),
    ),
  };
  return DayEvent(
    id: '40000000-0000-4000-8000-${(index + 1).toRadixString(16).padLeft(12, '0')}',
    dayBookId: _bookId,
    definition: definition,
    createdAt: DateTime.utc(2020, 1, 1),
    updatedAt: DateTime.utc(2020, 1, 1),
  );
}

/// 复用首页实际排序、最近卡片和展示派生；返回校验值防止无消费的空计算。
int _derive(List<DayEvent> events, AppLocalizations l10n) {
  final sorted = _rules.sortEvents(events, _today, dayBookId: _bookId);
  final recent = _rules.recentEvent(events, _today, dayBookId: _bookId);
  var checksum =
      sorted.length + (recent?.id.codeUnits.fold<int>(0, (a, b) => a + b) ?? 0);
  for (final event in sorted) {
    checksum += _rules.nextOccurrence(event.definition, _today)?.dayNumber ?? 0;
    checksum += dayDisplayTarget(event.definition, _today)?.dayNumber ?? 0;
    checksum += dayStatisticLabel(l10n, event.definition, _today).length;
  }
  return checksum;
}

/// 月格边界、分组和稳定排序使用当前日历页面的同一业务口径。
int _calendar(List<DayEvent> events) {
  final first = DateTime.utc(_today.year, _today.month, 1);
  final from = first.subtract(Duration(days: first.weekday - DateTime.monday));
  final to = from.add(const Duration(days: DateTime.daysPerWeek * 6 - 1));
  final byDate = <String, List<(DayEvent, String)>>{};
  for (final event in events.where((e) => e.dayBookId == _bookId)) {
    for (final occurrence in _rules.eventsInCalendarRange(
      event.definition,
      from,
      to,
    )) {
      byDate.putIfAbsent(occurrence.date.iso8601, () => []).add((
        event,
        occurrence.kind,
      ));
    }
  }
  for (final entries in byDate.values) {
    entries.sort((a, b) {
      final category = dayCategoryOrder
          .indexOf(a.$1.definition.category)
          .compareTo(dayCategoryOrder.indexOf(b.$1.definition.category));
      if (category != 0) return category;
      final created = a.$1.createdAt.compareTo(b.$1.createdAt);
      return created != 0 ? created : a.$1.id.compareTo(b.$1.id);
    });
  }
  return byDate.values.fold(0, (count, rows) => count + rows.length);
}

/// 只度量真实状态切换到数据及布局帧就绪，并验证首页列表已实际构建。
Future<int> _switchToDays(ProviderContainer container) async {
  final timer = Stopwatch()..start();
  container.read(currentModeProvider.notifier).set(AppMode.days);
  await container.read(dayBooksProvider.future);
  await container.read(currentDayBookIdProvider.future);
  final book = container.read(currentDayBookProvider).requireValue;
  final events = await container.read(dayEventsProvider(_bookId).future);
  await WidgetsBinding.instance.endOfFrame;
  timer.stop();
  var hasList = false;

  /// 核对真实首页的列表已构建，防止把加载占位帧计作完成。
  void visit(Element element) {
    if (element.widget.key == const PageStorageKey('days-home-$_bookId')) {
      hasList = true;
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  if (book?.id != _bookId ||
      events.length != _datasetSize ||
      !hasList ||
      container.read(currentModeProvider) != AppMode.days) {
    throw StateError('日子首页未达到真实数据及布局就绪状态');
  }
  return timer.elapsedMicroseconds;
}

/// 使用 Android 系统属性记录真实型号，读取失败不能猜测为指定设备。
Future<String> _getProperty(String key) async {
  final result = await Process.run('/system/bin/getprop', [key]);
  final value = (result.stdout as String).trim();
  if (result.exitCode != 0 || value.isEmpty) throw StateError('读取设备属性失败');
  return value;
}

/// 最近秩 P95 保留原始微秒样本，超标也原样报告，不调整阈值或剔除慢样本。
void _summary(String metric, List<int> samples, int budgetMs) {
  final sorted = [...samples]..sort();
  final p95 =
      sorted[(sorted.length * 95 / 100).ceil() - 1] /
      Duration.microsecondsPerMillisecond;
  _emit({
    'type': 'summary',
    'metric': metric,
    'samples': samples.length,
    'raw_us': samples,
    'p95_ms': p95,
    'budget_ms': budgetMs,
    'within_budget': p95 <= budgetMs,
  });
}

/// 每行单独输出 JSON，adb logcat 可按固定前缀直接提取。
void _emit(Map<String, Object?> value) =>
    stdout.writeln('$_prefix${jsonEncode(value)}');

/// 记录真实系统时间、时区偏移及共享日期状态，测量后恢复主页面真实时钟。
void _clockEvent(String source, DateTime today) {
  final now = DateTime.now();
  stdout.writeln(
    'DAYS_CLOCK_JSON:${jsonEncode({'source': source, 'utc': now.toUtc().toIso8601String(), 'local_now': now.toIso8601String(), 'timezone': now.timeZoneName, 'offset_minutes': now.timeZoneOffset.inMinutes, 'local_today': DateOnly.fromDateTime(today).iso8601})}',
  );
}
