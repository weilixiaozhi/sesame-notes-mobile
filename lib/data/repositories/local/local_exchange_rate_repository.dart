import 'package:drift/drift.dart' as d;
import 'package:drift/drift.dart' show Expression;

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/repositories/support/change_recorder.dart';
import 'package:sesame_notes/utils/exchange_rate_id.dart';

/// Drift 实现。tracker 用 getter 闭包注入:LocalRepository.changeTracker 是
/// 可变字段(构造后才赋值),直接传引用会捕获 null —— 2026-04 的 orphan-change
/// 坑就是这类时序问题,闭包取值规避。tracker 类型为 data 层抽象
/// [ChangeRecorder],不依赖 cloud 层具体实现。
class LocalExchangeRateRepository {
  /// 本地域（未登录）兜底身份键：与服务端真实 userId（v4 UUID）派生结果
  /// 永不相撞，本地域行确定性且不会被推送（sync_service 过滤 null 账号变更）。
  static const _localDomainOwner = 'local';

  final SesameDatabase db;
  final ChangeRecorder? Function() trackerGetter;

  /// 当前云账号 userId（null = 未登录本地域）。
  final String? Function()? accountIdGetter;

  LocalExchangeRateRepository(
    this.db, {
    required this.trackerGetter,
    this.accountIdGetter,
  });

  Future<void> upsertAutoRates({
    required String base,
    required String rateDate,
    required Map<String, String> rates,
    required String source,
    required DateTime fetchedAt,
  }) async {
    final baseUp = base.toUpperCase();
    await db.batch((b) {
      for (final e in rates.entries) {
        b.insert(
          db.exchangeRates,
          ExchangeRatesCompanion.insert(
            baseCurrency: baseUp,
            quoteCurrency: e.key.toUpperCase(),
            rateDate: rateDate,
            rate: e.value,
            source: source,
            fetchedAt: fetchedAt,
          ),
          onConflict: d.DoUpdate(
            (_) => ExchangeRatesCompanion(
              rate: d.Value(e.value),
              source: d.Value(source),
              fetchedAt: d.Value(fetchedAt),
            ),
          ),
        );
      }
    });
    // 注意:自动汇率绝不记 change,测试有红线断言。
  }

  Future<List<ExchangeRate>> getLatestAutoRates(String base) async {
    final rows = await db
        .customSelect(
          'SELECT e.base_currency, e.quote_currency, e.rate_date, '
          'e.rate, e.source, e.fetched_at '
          'FROM exchange_rates e '
          'JOIN ('
          '  SELECT quote_currency, MAX(rate_date) AS max_date '
          '  FROM exchange_rates '
          '  WHERE base_currency = ?1 '
          '  GROUP BY quote_currency'
          ') latest '
          'ON latest.quote_currency = e.quote_currency '
          'AND latest.max_date = e.rate_date '
          'WHERE e.base_currency = ?1 '
          'ORDER BY e.quote_currency',
          variables: [d.Variable.withString(base.toUpperCase())],
          readsFrom: {db.exchangeRates},
        )
        .get();
    return rows
        .map(
          (row) => ExchangeRate(
            baseCurrency: row.read<String>('base_currency'),
            quoteCurrency: row.read<String>('quote_currency'),
            rateDate: row.read<String>('rate_date'),
            rate: row.read<String>('rate'),
            source: row.read<String>('source'),
            fetchedAt: row.read<DateTime>('fetched_at'),
          ),
        )
        .toList();
  }

  Future<DateTime?> getLastFetchedAt(String base) async {
    final row =
        await (db.select(db.exchangeRates)
              ..where((t) => t.baseCurrency.equals(base.toUpperCase()))
              ..orderBy([(t) => d.OrderingTerm.desc(t.fetchedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.fetchedAt;
  }

  /// 当前账号域的 scope 过滤条件：未登录只读本地域（null），登录只读当前账号域。
  ///
  /// 设计意图：手工汇率覆盖「本地域一份、每账号域各一份」，任何读取/写入
  /// 都必须按当前账号域隔离，A 不能看到 B 的覆盖。
  Expression<bool> _scopeCondition() {
    final accountId = accountIdGetter?.call();
    final column = db.exchangeRateOverrides.scopeAccountId;
    return accountId == null ? column.isNull() : column.equals(accountId);
  }

  /// 读取当前账号域内仍有效的手工汇率覆盖。
  Future<List<ExchangeRateOverride>> getOverrides(String base) {
    return (db.select(db.exchangeRateOverrides)
          ..where(
            (t) =>
                t.baseCurrency.equals(base.toUpperCase()) &
                t.deletedAt.isNull() &
                _scopeCondition(),
          )
          ..orderBy([(t) => d.OrderingTerm.asc(t.quoteCurrency)]))
        .get();
  }

  /// 监听当前账号域内仍有效的手工汇率覆盖。
  Stream<List<ExchangeRateOverride>> watchOverrides(String base) {
    return (db.select(db.exchangeRateOverrides)
          ..where(
            (t) =>
                t.baseCurrency.equals(base.toUpperCase()) &
                t.deletedAt.isNull() &
                _scopeCondition(),
          )
          ..orderBy([(t) => d.OrderingTerm.asc(t.quoteCurrency)]))
        .watch();
  }

  /// 设置手工汇率；同一确定性实体曾被远端删除时按新 upsert 显式复活。
  Future<void> setOverride({
    required String base,
    required String quote,
    required String rate,
  }) async {
    final baseUp = base.toUpperCase();
    final quoteUp = quote.toUpperCase();
    try {
      // 写覆盖汇率与登记变更同事务:登记失败时回滚,避免本地已生效但云端漏推。
      await db.transaction(() async {
        final accountId = accountIdGetter?.call();
        final existing =
            await (db.select(db.exchangeRateOverrides)..where(
                  (t) =>
                      t.baseCurrency.equals(baseUp) &
                      t.quoteCurrency.equals(quoteUp) &
                      _scopeCondition(),
                ))
                .getSingleOrNull();
        final now = DateTime.now().toUtc();
        if (existing == null) {
          // 主键按服务端契约确定性派生（UUIDv5(账号id, BASE, QUOTE)）：
          // 同账号同币对收敛同一实体，push 才能被服务端接受；
          // 未登录本地域用固定兜底键，保证同币对 upsert 复用同一 id。
          final id = exchangeRateOverrideId(
            accountId ?? _localDomainOwner,
            baseUp,
            quoteUp,
          );
          await db
              .into(db.exchangeRateOverrides)
              .insert(
                ExchangeRateOverridesCompanion.insert(
                  baseCurrency: baseUp,
                  quoteCurrency: quoteUp,
                  rate: rate,
                  id: id,
                  // 覆盖必须归属当前账号域（未登录为本地域 null）
                  scopeAccountId: d.Value(accountId),
                  updatedAt: now,
                ),
              );
          await trackerGetter()?.recordUserGlobalChange(
            entityType: 'exchange_rate_override',
            entityId: id,
            action: 'upsert',
            payload: _overridePayload(id, baseUp, quoteUp, rate, now),
            updatedAt: now,
          );
        } else {
          await (db.update(
            db.exchangeRateOverrides,
          )..where((t) => t.id.equals(existing.id))).write(
            ExchangeRateOverridesCompanion(
              rate: d.Value(rate),
              updatedAt: d.Value(now),
              // upsert 的业务语义是重新启用覆盖；若保留 tombstone，读取层会
              // 永久忽略这次设置，并产生“已同步但不生效”的幽灵配置。
              deletedAt: const d.Value(null),
            ),
          );
          await trackerGetter()?.recordUserGlobalChange(
            entityType: 'exchange_rate_override',
            entityId: existing.id,
            action: 'upsert',
            payload: _overridePayload(existing.id, baseUp, quoteUp, rate, now),
            updatedAt: now,
          );
        }
      });
    } catch (error, stackTrace) {
      logger.error(
        'LocalExchangeRateRepository',
        '设置手工汇率失败',
        error,
        stackTrace,
      );
      rethrow;
    }
  }

  Future<void> removeOverride({
    required String base,
    required String quote,
  }) async {
    // 删除与登记变更同事务:登记失败时回滚,避免本地已删但云端仍持有投影。
    await db.transaction(() async {
      final existing =
          await (db.select(db.exchangeRateOverrides)..where(
                (t) =>
                    t.baseCurrency.equals(base.toUpperCase()) &
                    t.quoteCurrency.equals(quote.toUpperCase()) &
                    _scopeCondition(),
              ))
              .getSingleOrNull();
      if (existing == null) return;
      await (db.delete(
        db.exchangeRateOverrides,
      )..where((t) => t.id.equals(existing.id))).go();
      final now = DateTime.now().toUtc();
      await trackerGetter()?.recordUserGlobalChange(
        entityType: 'exchange_rate_override',
        entityId: existing.id,
        action: 'delete',
        payload: _overridePayload(
          existing.id,
          existing.baseCurrency,
          existing.quoteCurrency,
          existing.rate,
          now,
        ),
        updatedAt: now,
      );
    });
  }

  /// 构造契约形状的完整实体 payload(规范化 decimal 字符串)。
  static String _overridePayload(
    String id,
    String base,
    String quote,
    String rate,
    DateTime updatedAt,
  ) {
    return '{"id":"$id","base_currency":"$base","quote_currency":"$quote",'
        '"rate":"$rate","updated_at":"${updatedAt.toIso8601String()}"}';
  }
}
