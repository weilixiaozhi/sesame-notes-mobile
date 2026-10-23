import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:sesame_notes/shared/providers/simple_state_notifier.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';

import 'package:sesame_notes/data/db.dart' show Ledger;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/utils/currency/rate_math.dart';
import 'package:sesame_notes/shared/services/exchange_rate_service.dart';
import 'package:sesame_notes/utils/currency/currencies.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

// 只依赖叶子模块拿云客户端实例（server 汇率源），不 import 编排器
// sync_providers.dart，避免「域 → 编排」反向边成环。

/// 多币种 provider 层。
///
/// 折算基准 = 账本本位币(`ledger.currency`),[currentLedgerCurrencyProvider]
/// 为唯一来源;无「全局账本币种(baseCurrency)」双轨制。

/// 汇率数据变更信号:拉取成功 / 手动编辑后 bump,触发 effectiveRates 重算。
final rateRefreshTickProvider = NotifierProvider<TickStateNotifier, int>(
  () => TickStateNotifier((ref) => 0),
);

final exchangeRateServiceProvider = Provider<ExchangeRateService>(
  (ref) => ExchangeRateService(),
);

/// 可见币种集合(用户在「管理展示币种」页勾选的币种,大写 ISO code)。
///
/// 设计意图:全量 146 个币种在选择列表里过长,用户只需维护一个「常用子集」,
/// 该集合仅影响 UI 展示范围(汇率列表、各币种选择弹窗),不影响 API 拉取与
/// 交易数据——API 全量拉取全量存储,交易保留原币种码。
///
/// 当前账本的可见集合：每账本一套，保存在本机偏好中，
/// 不走云同步；默认值 = [kCommonCurrencyCodes](13 个常用币种)
/// ∪ {该账本本位币},由 [visibleCurrenciesInitProvider] 初始化并即时落盘。
final visibleCurrenciesProvider =
    NotifierProvider<SimpleStateNotifier<Set<String>>, Set<String>>(
      () => SimpleStateNotifier((ref) => kCommonCurrencyCodes.toSet()),
    );

/// 可见币种持久化 key:每账本一套(`visibleCurrencies.<ledgerId>`),
/// 值为逗号分隔的大写币种码,如 "CNY,USD,EUR,JPY,..."。
/// 用本地 ledgerId(纯本地偏好,无需跨设备稳定;删账本时同步清理该 key)。
String visibleCurrenciesKeyFor(String ledgerId) =>
    'visibleCurrencies.$ledgerId';

/// 无账本时的兜底持久化 key:保持「toggle 即落盘」行为一致,
/// 避免无账本态的勾选在重启后丢失。
const _kVisibleCurrenciesFallbackKey = 'visibleCurrencies._none';

/// 偏好落盘后使按账本读取的币种集合重新查询，避免编辑器读取旧集合。
final _visibleCurrenciesRevisionProvider =
    NotifierProvider<TickStateNotifier, int>(
      () => TickStateNotifier((ref) => 0),
    );

/// 初始化、勾选和本位币补入共用队列，失败重读整份偏好时不会覆盖另一笔在途缓存。
final _visibleCurrencyWritesProvider = Provider(
  (_) => _VisibleCurrencyWrites(),
);

/// 队列仅持有尚未结束的本机写入，不等待网络。
class _VisibleCurrencyWrites {
  Future<void>? tail;
}

/// 前序失败只结束该次请求，后续操作仍按实际落盘集合继续。
Future<T> _serializeVisibleCurrencies<T>(
  ProviderReader read,
  Future<T> Function() action,
) {
  final pending = read(_visibleCurrencyWritesProvider);
  final current = (pending.tail ?? Future<void>.value()).then((_) => action());
  late final Future<void> settled;
  settled = current
      .then<void>((_) {}, onError: (Object _, StackTrace _) {})
      .whenComplete(() {
        if (identical(pending.tail, settled)) pending.tail = null;
      });
  pending.tail = settled;
  return current;
}

/// 只有平台确认成功才发布内存状态，失败重读插件缓存以保持磁盘事实。
Future<void> _saveVisibleCurrencies(
  SharedPreferences prefs,
  String key,
  Set<String> values,
) async {
  try {
    if (!await prefs.setString(key, values.join(','))) {
      throw StateError('展示币种设置未能保存，请稍后重试');
    }
  } catch (error, stackTrace) {
    try {
      await prefs.reload();
    } catch (reloadError, reloadStackTrace) {
      logger.error(
        'CurrencyProviders',
        '重读展示币种偏好失败',
        safeErrorSummary(reloadError),
        reloadStackTrace,
      );
    }
    Error.throwWithStackTrace(error, stackTrace);
  }
}

/// 固定账本的展示币种只读取该本偏好，不借用当前首页的内存集合。
final visibleCurrenciesForLedgerProvider = FutureProvider.autoDispose
    .family<Set<String>, String>((ref, ledgerId) async {
      ref.watch(_visibleCurrenciesRevisionProvider);
      final available = ref.watch(ledgerByIdProvider(ledgerId).future);
      final preferences = ref.watch(sharedPreferencesProvider.future);
      try {
        final ledger = await available;
        final prefs = await preferences;
        if (ledger == null || ledger.archivedAt != null) {
          throw StateError('LEDGER_UNAVAILABLE');
        }
        final base = normalizeLedgerCurrency(ledger.currency);
        return {
          ..._decodeVisibleCurrencies(
            prefs.getString(visibleCurrenciesKeyFor(ledgerId)),
            base,
          ),
          base,
        };
      } catch (error, stackTrace) {
        logger.error('CurrencyProviders', '读取固定账本展示币种失败', error, stackTrace);
        rethrow;
      }
    }, retry: (_, _) => null);

/// 已保存的列表保留用户选择，首次使用则返回常用币种及本位币。
Set<String> _decodeVisibleCurrencies(String? saved, String? base) {
  if (saved == null || saved.isEmpty) {
    return {
      ...kCommonCurrencyCodes.map((code) => code.toUpperCase()),
      if (base != null && base.isNotEmpty) base.toUpperCase(),
    };
  }
  return {
    ...saved
        .split(',')
        .map((code) => code.trim().toUpperCase())
        .where((code) => code.isNotEmpty),
    if (base != null && base.isNotEmpty) base.toUpperCase(),
  };
}

/// 启动初始化:等当前账本就绪 → 加载其 key(无则默认 13 常用 ∪ 本位币并
/// 落盘) → listen 当前账本 id 变化重新加载目标账本的集合。
///
/// 设计要点:
/// - 必须先等当前账本就绪再读 key,否则先渲染默认集合再被真值覆盖,
///   会造成可见列表闪烁。
/// - 勾选与初始化串行落盘，成功后才发布当前本的内存选择。
/// - 同一账本的字段更新(如改本位币)不触发重载——仅 id 变化才切集合;
///   新本位币由公共函数 applyLedgerCurrencyChange 负责补入集合。
final visibleCurrenciesInitProvider = FutureProvider<void>((ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  if (!ref.mounted) return;
  var loadGeneration = 0;

  /// 加载目标账本的可见集合，无偏好时初始化常用币种和本位币。
  Future<void> loadFor(String? ledgerId, String? ledgerCurrency) async {
    final generation = ++loadGeneration;
    final key = ledgerId == null
        ? _kVisibleCurrenciesFallbackKey
        : visibleCurrenciesKeyFor(ledgerId);
    final initial = await _serializeVisibleCurrencies(ref.read, () async {
      final saved = prefs.getString(key);
      final initial = _decodeVisibleCurrencies(saved, ledgerCurrency);
      if (saved == null || saved.isEmpty) {
        await _saveVisibleCurrencies(prefs, key, initial);
      }
      return initial;
    });
    // 旧账本的首次写入可能晚于切本完成，只有最新且仍存活的查询可发布集合。
    if (!ref.mounted ||
        generation != loadGeneration ||
        ref.read(currentLedgerProvider).value?.id != ledgerId) {
      return;
    }
    // 始终创建新 Set 赋值以触发 Riverpod 重建(Set 的可变性不触发通知)
    ref.read(visibleCurrenciesProvider.notifier).set(initial);
  }

  // 等当前账本就绪(StreamProvider 首次发射)再加载,避免默认集合闪烁
  final ledger = await ref.watch(currentLedgerProvider.future);
  if (!ref.mounted) return;
  await loadFor(ledger?.id, ledger?.currency);
  if (!ref.mounted) return;

  // 切账本 → 加载目标账本 key(无则初始化);无账本 → 兜底 key
  ref.listen<AsyncValue<Ledger?>>(currentLedgerProvider, (prev, next) {
    final nextLedger = next.value;
    if (nextLedger?.id == prev?.value?.id) return;
    unawaited(
      loadFor(nextLedger?.id, nextLedger?.currency).catchError((
        Object error,
        StackTrace stackTrace,
      ) {
        logger.error(
          'CurrencyProviders',
          '切换账本展示币种失败',
          safeErrorSummary(error),
          stackTrace,
        );
      }),
    );
  });
});

/// 切换某币种的可见性(增/删)。
///
/// 当前账本本位币(折算基准)不可隐藏——静默忽略,保证折算基准始终可见;
/// 其他账本的本位币在当前账本集合里是普通币种,可隐藏。
/// 始终创建新 Set 赋值以触发 Riverpod 重建(原地 add/remove 不通知)。
/// 按请求顺序持久化后发布展示状态；失败保留原选择，无账本时使用兜底 key。
Future<void> toggleCurrencyVisibility(ProviderReader read, String code) async {
  final codeUp = code.trim().toUpperCase();
  if (codeUp.isEmpty) return;
  final base = read(currentLedgerCurrencyProvider);
  // 本位币锁定:不允许隐藏,静默忽略
  if (codeUp == base) return;

  final ledgerId = read(currentLedgerProvider).value?.id;
  final key = ledgerId == null
      ? _kVisibleCurrenciesFallbackKey
      : visibleCurrenciesKeyFor(ledgerId);
  try {
    await _serializeVisibleCurrencies(read, () async {
      final prefs = await read(sharedPreferencesProvider.future);
      final next = _decodeVisibleCurrencies(prefs.getString(key), base);
      if (!next.remove(codeUp)) next.add(codeUp);
      await _saveVisibleCurrencies(prefs, key, next);
      if (read(currentLedgerProvider).value?.id == ledgerId) {
        read(visibleCurrenciesProvider.notifier).set(next);
      }
      read(_visibleCurrenciesRevisionProvider.notifier).tick();
    });
  } catch (e, st) {
    logger.error('CurrencyProviders', '展示币种设置未保存', safeErrorSummary(e), st);
    rethrow;
  }
}

/// 把指定币种补入当前账本可见集合，持久偏好已包含它时跳过写入。
///
/// 供切本位币公共函数(applyLedgerCurrencyChange)调用:新本位币必须在
/// 当前账本的各选择列表中可见。
/// 返回 false 只表示可选偏好未保存，不撤销已经提交的账本币种。
Future<bool> ensureCurrencyVisibleForCurrentLedger(
  ProviderReader read,
  String code,
) async {
  final codeUp = code.trim().toUpperCase();
  if (codeUp.isEmpty) return true;
  final ledgerId = read(currentLedgerProvider).value?.id;
  final key = ledgerId == null
      ? _kVisibleCurrenciesFallbackKey
      : visibleCurrenciesKeyFor(ledgerId);
  try {
    await _serializeVisibleCurrencies(read, () async {
      final prefs = await read(sharedPreferencesProvider.future);
      final saved = prefs.getString(key);
      final next = _decodeVisibleCurrencies(saved, codeUp);
      if (saved == null || !saved.split(',').contains(codeUp)) {
        await _saveVisibleCurrencies(prefs, key, next);
      }
      if (read(currentLedgerProvider).value?.id == ledgerId) {
        read(visibleCurrenciesProvider.notifier).set(next);
      }
      read(_visibleCurrenciesRevisionProvider.notifier).tick();
    });
    return true;
  } catch (e, st) {
    logger.error(
      'CurrencyProviders',
      '账本已保存，展示币种偏好未保存',
      safeErrorSummary(e),
      st,
    );
    // 本位币可见性来自已提交的账本事实，不因可选偏好保存失败而隐藏。
    if (read(currentLedgerProvider).value?.id == ledgerId) {
      read(
        visibleCurrenciesProvider.notifier,
      ).set({...read(visibleCurrenciesProvider), codeUp});
    }
    return false;
  }
}

/// 币种选择弹窗的展示汇率:1 该币种 ≈ ? base。拉一次全量(fawaz base→quote
/// 全量返回),手动 override 优先。仅展示用,不落库。family key = base(大写)。
/// 值 = 「1 quote 币种 = value base」(便于 UI 显示 1 JPY ≈ 0.048 CNY)。
final currencyPickerRatesProvider = FutureProvider.autoDispose
    .family<Map<String, double>, String>((ref, base) async {
      final pending = ref.keepAlive();
      try {
        ref.watch(rateRefreshTickProvider);
        final baseUp = base.toUpperCase();
        final repo = ref.watch(transactionDataAccessProvider);
        final out = <String, double>{};
        // 先公网/服务端全量(1 base = y quote → 1 quote = 1/y base)
        try {
          final result = await ref
              .read(exchangeRateServiceProvider)
              .fetch(baseUp);
          for (final e in result.ratesBaseToQuote.entries) {
            final y = double.tryParse(e.value);
            if (y != null && isInvertibleRate(y)) {
              out[e.key.toUpperCase()] = 1 / y;
            }
          }
        } catch (_) {
          /* 拉不到就只用本地 override,下方覆盖 */
        }
        // 手动 override 覆盖(1 quote = rate base,直接用)
        try {
          for (final o in await repo.getOverrides(baseUp)) {
            final r = double.tryParse(o.rate);
            if (r != null && r.isFinite && r > 0) {
              out[o.quoteCurrency.toUpperCase()] = r;
            }
          }
        } catch (e, st) {
          // 本地手动汇率读失败只降级覆盖精度(自动汇率仍展示),但必须留痕:
          // 弹窗汇率与实际折算口径不一致时,排查只能靠这条日志。
          logger.warning('currency_providers', '读取手动汇率失败(降级为仅自动汇率): $e', st);
        }
        return out;
      } finally {
        pending.close();
      }
    });

/// 当前账本本位币(ISO 大写)。`ledger.currency` 的语义化别名——交易级多币种后
/// 它的语义是「账本统计折算的目标币种」。
final currentLedgerCurrencyProvider = Provider<String>((ref) {
  final ledger = ref.watch(currentLedgerProvider).value;
  return normalizeLedgerCurrency(ledger?.currency);
});

/// 以**账本本位币**为 base 的有效汇率(交易币种 → 账本本位币),手动 >
/// 最新自动,缺失显式缺失。折算基准的唯一来源;切账本自动重算。
/// 记账折算与汇率页展示共用这组有效汇率。
final effectiveRatesForLedgerProvider =
    FutureProvider<Map<String, EffectiveRate>>((ref) {
      final base = ref.watch(currentLedgerCurrencyProvider);
      return ref.watch(effectiveRatesForBaseProvider(base).future);
    });

/// 固定折算目标的有效汇率，当前首页切换账本不会改变此查询的基准。
final effectiveRatesForBaseProvider = FutureProvider.autoDispose
    .family<Map<String, EffectiveRate>, String>((ref, base) async {
      ref.watch(rateRefreshTickProvider);
      ref.watch(accountingDataChangeSignalProvider);
      final repo = ref.watch(transactionDataAccessProvider);
      final normalizedBase = normalizeLedgerCurrency(base);
      try {
        final autos = await repo.getLatestAutoRates(normalizedBase);
        final overrides = await repo.getOverrides(normalizedBase);
        return mergeEffectiveRates(
          autoRates: [
            for (final rate in autos)
              (
                quote: rate.quoteCurrency,
                rate: rate.rate,
                rateDate: rate.rateDate,
              ),
          ],
          overrides: [
            for (final rate in overrides)
              (quote: rate.quoteCurrency, rate: rate.rate),
          ],
        );
      } catch (error, stackTrace) {
        logger.error(
          'CurrencyProviders',
          '读取有效汇率失败 base=$normalizedBase',
          error,
          stackTrace,
        );
        rethrow;
      }
    });

/// 当前账本「未折算外币交易」条数:>0 时统计页显示补折算横幅。
/// watch statsRefresh(重算完成/交易变动后重查)。
final ledgerUnconvertedForeignTxCountProvider = FutureProvider<int>((
  ref,
) async {
  ref.watch(accountingDataChangeSignalProvider);
  ref.watch(rateRefreshTickProvider);
  final ledger = ref.watch(currentLedgerProvider).value;
  if (ledger == null) return 0;
  final repo = ref.watch(transactionDataAccessProvider);
  return repo.countUnconvertedForeignTx(ledger.id);
});

/// 当前账本外币交易条数(含已折算):>0 时账本统计页显示折算脚注。
final ledgerForeignTxCountProvider = FutureProvider<int>((ref) async {
  ref.watch(accountingDataChangeSignalProvider);
  final ledger = ref.watch(currentLedgerProvider).value;
  if (ledger == null) return 0;
  final repo = ref.watch(transactionDataAccessProvider);
  return repo.countForeignCurrencyTx(ledger.id);
});

/// 拉取并保存账本汇率，只依赖 read 能力，界面与后台共用同一用例。
///
/// 每个本位币从汇率服务拉取全量币种并保存倒数，成功后触发汇率刷新信号。
/// force=false 时按 24h 节流。失败返回 false，供页面展示友好反馈。
///
/// base 集合 = {各账本本位币}——折算基准 = 账本本位币,每个不同本位币的账本
/// 都需要以它为 base 的汇率组;无账本时无折算需求,直接跳过拉取。
/// [extraBases]:尚未写入账本表、但本次操作即将启用的本位币集合。
Future<bool> refreshExchangeRates({
  required ProviderReader read,
  bool force = false,
  Set<String>? extraBases,
}) async {
  try {
    final repo = read(transactionDataAccessProvider);

    // base 集合:各账本本位币(大写);无账本(或读账本失败)时跳过拉取
    final bases = <String>{};
    try {
      final ledgers = await repo.getAllLedgers();
      bases.addAll(
        ledgers.map((l) => l.currency.toUpperCase()).where((c) => c.isNotEmpty),
      );
    } catch (e) {
      logger.warning('currency_providers', '读取账本本位币集合失败(跳过拉取): $e');
    }
    // 换币流程必须在落库前拉新 base，避免网络 I/O 夹在元数据更新与快照重算之间。
    bases.addAll(
      (extraBases ?? const <String>{})
          .map((c) => c.trim().toUpperCase())
          .where((c) => c.isNotEmpty),
    );
    if (bases.isEmpty) {
      logger.info('currency_providers', '无账本本位币,跳过汇率拉取');
      return true;
    }

    // 汇率服务返回全部币种，完整保存后供展示与尚无交易的新币种使用。
    var anySuccess = false;
    for (final base in bases) {
      if (!force) {
        final last = await repo.getLastFetchedAt(base);
        if (last != null &&
            DateTime.now().toUtc().difference(last) <
                const Duration(hours: 24)) {
          anySuccess = true; // 未过期视作成功,无需拉取
          continue;
        }
      }
      if (await _fetchAndStoreRatesForBase(
        read: read,
        repo: repo,
        base: base,
      )) {
        anySuccess = true;
      }
    }
    if (anySuccess) read(rateRefreshTickProvider.notifier).tick();
    return anySuccess;
  } catch (e, st) {
    logger.warning('currency_providers', '汇率刷新失败: $e', st);
    return false;
  }
}

/// 拉取并落库单个 base 的汇率。
/// 汇率页展示除基准币种外的全部币种,因此此函数存储 API 返回的全部汇率,
/// 不按 "quotes" 集合过滤——一次 API 调用已返回所有币种数据,过滤掉纯属浪费。
Future<bool> _fetchAndStoreRatesForBase({
  required T Function<T>(ProviderListenable<T>) read,
  required TransactionRepository repo,
  required String base,
}) async {
  try {
    final rateData = await read(exchangeRateServiceProvider).fetch(base);

    // 倒数成「1 quote = x base」,存储 API 返回的全部币种汇率
    // 需求:汇率页展示除基准币种外的全部币种——一次网络调用已拿回全部数据,
    // 二次过滤纯属浪费;此处存储全量,UI 侧按需展示即可。
    final inverted = <String, String>{};
    for (final e in rateData.ratesBaseToQuote.entries) {
      final raw = double.tryParse(e.value);
      if (raw != null && isInvertibleRate(raw)) {
        inverted[e.key.toUpperCase()] = invertRate(raw);
      }
    }
    if (inverted.isEmpty) return false;
    await repo.upsertAutoRates(
      base: base,
      rateDate: rateData.rateDate,
      rates: inverted,
      source: rateData.source,
      fetchedAt: DateTime.now().toUtc(),
    );
    return true;
  } catch (e, st) {
    logger.warning('currency_providers', 'base=$base 汇率拉取失败: $e', st);
    return false;
  }
}
