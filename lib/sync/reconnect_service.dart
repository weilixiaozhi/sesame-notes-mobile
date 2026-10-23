/// 重连统一使用账号完整快照；备份的显式选择仅下载选中本。
library;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart'
    hide
        Ledger,
        Transaction,
        Category,
        RecurringTransaction,
        ExchangeRateOverride;
import 'sync_service.dart';

/// Reconnect 结果报告（每类账本清单，供 UI 提示）。
class ReconnectReport {
  const ReconnectReport({
    required this.refreshed,
    required this.stale,
    required this.gone,
  });

  /// 已按服务器当前状态刷新的云端账本。
  final List<String> refreshed;

  /// 同步身份不匹配（412）→ 已标记 STALE_BINDING，等待用户决策重绑。
  final List<String> stale;

  /// 服务器已不存在（账号失去访问）的本地云端账本行，保留待用户决策。
  final List<String> gone;
}

/// Reconnect v1：登录原账号后的云端状态收敛。
class ReconnectV1Service {
  ReconnectV1Service({required this.db, required this.sync});

  final SesameDatabase db;
  final SyncService sync;

  /// 普通重连建立四域完整屏障；显式集合只收敛选中本，不推进域水位。
  Future<ReconnectReport> reconnectAfterLogin({
    Set<String>? ledgerIds,
    Set<String>? dayBookIds,
    Set<String>? memoBookIds,
    Set<String>? fitnessSpaceIds,
  }) async {
    try {
      final refreshed = <String>[];
      final stale = <String>[];
      final gone = <String>[];
      final scoped =
          ledgerIds != null ||
          dayBookIds != null ||
          memoBookIds != null ||
          fitnessSpaceIds != null;
      final accountId = sync.currentAccountIdGetter();
      if (!scoped) {
        Object? failure;
        StackTrace? failureStack;
        try {
          await sync.accountingFull();
        } catch (error, stackTrace) {
          failure = error;
          failureStack = stackTrace;
        }
        if (sync.dayRepository != null) {
          try {
            await sync.discoverDayBooks();
          } catch (error, stackTrace) {
            failure ??= error;
            failureStack ??= stackTrace;
          }
        }
        if (sync.memoRepository != null) {
          try {
            await sync.discoverMemoBooks();
          } catch (error, stackTrace) {
            failure ??= error;
            failureStack ??= stackTrace;
          }
        }
        if (sync.fitnessEnabled) {
          try {
            await sync.discoverFitnessSpaces();
          } catch (error, stackTrace) {
            failure ??= error;
            failureStack ??= stackTrace;
          }
        }
        if (failure != null) Error.throwWithStackTrace(failure, failureStack!);
        final ledgers =
            await (db.select(db.ledgers)..where(
                  (b) =>
                      b.storageMode.equals('cloud') &
                      (accountId == null
                          ? const d.Constant(true)
                          : b.scopeAccountId.equals(accountId)),
                ))
                .get();
        for (final book in ledgers) {
          (book.bindingStatus == 'stale'
                  ? stale
                  : book.deletedAt != null
                  ? gone
                  : refreshed)
              .add(book.id);
        }
        final days = await (db.select(
          db.dayBooks,
        )..where((b) => b.scopeAccountId.equals(accountId ?? ''))).get();
        for (final book in days) {
          (book.isStale
                  ? stale
                  : book.deletedAt != null
                  ? gone
                  : refreshed)
              .add(book.id);
        }
        final memos = await (db.select(
          db.memoBooks,
        )..where((b) => b.scopeAccountId.equals(accountId ?? ''))).get();
        for (final book in memos) {
          (book.isStale
                  ? stale
                  : book.deletedAt != null
                  ? gone
                  : refreshed)
              .add(book.id);
        }
        for (final book in await (db.select(
          db.fitnessSpaces,
        )..where((b) => b.scopeAccountId.equals(accountId ?? ''))).get()) {
          (book.isStale
                  ? stale
                  : book.deletedAt != null
                  ? gone
                  : refreshed)
              .add(book.id);
        }
      } else {
        for (final id in ledgerIds ?? <String>{}) {
          final local = await (db.select(
            db.ledgers,
          )..where((b) => b.id.equals(id))).getSingleOrNull();
          if (local?.storageMode == 'local') continue;
          if (local != null &&
              accountId != null &&
              local.scopeAccountId != accountId) {
            throw StateError('所选账本不属于当前账号');
          }
          if (local?.bindingStatus == 'stale') {
            stale.add(id);
            continue;
          }
          try {
            await sync.full(ledgerId: id);
            refreshed.add(id);
          } on DioException catch (error) {
            if (error.response?.statusCode == 412) {
              stale.add(id);
            } else if (error.response?.statusCode == 404) {
              gone.add(id);
            } else {
              rethrow;
            }
          }
        }
        for (final id in dayBookIds ?? <String>{}) {
          final local = await (db.select(
            db.dayBooks,
          )..where((b) => b.id.equals(id))).getSingleOrNull();
          if (local?.storageMode == 'local') continue;
          if (local?.isStale == true) {
            stale.add(id);
            continue;
          }
          try {
            await sync.fullDayBook(dayBookId: id);
            refreshed.add(id);
          } on DioException catch (error) {
            if (error.response?.statusCode == 412) {
              stale.add(id);
            } else if (error.response?.statusCode == 404) {
              gone.add(id);
            } else {
              rethrow;
            }
          }
        }
        for (final (ids, table, download)
            in <(Set<String>, d.TableInfo, Future<void> Function(String))>[
              (
                memoBookIds ?? {},
                db.memoBooks,
                (id) => sync.fullMemoBook(memoBookId: id),
              ),
              (fitnessSpaceIds ?? {}, db.fitnessSpaces, sync.fullFitnessSpace),
            ]) {
          for (final id in ids) {
            final row = await db
                .customSelect(
                  'SELECT * FROM ${table.actualTableName} WHERE id=?',
                  variables: [d.Variable(id)],
                )
                .getSingleOrNull();
            if (row?.read<String>('storage_mode') == 'local') continue;
            if (row != null &&
                row.readNullable<String>('scope_account_id') != accountId) {
              throw StateError('所选本不属于当前账号');
            }
            if (row?.read<bool>('is_stale') == true) {
              stale.add(id);
              continue;
            }
            try {
              await download(id);
              refreshed.add(id);
            } on DioException catch (error) {
              if (error.response?.statusCode == 412) {
                stale.add(id);
              } else if (error.response?.statusCode == 404) {
                gone.add(id);
              } else {
                rethrow;
              }
            }
          }
        }
      }
      return ReconnectReport(refreshed: refreshed, stale: stale, gone: gone);
    } catch (error, stackTrace) {
      logger.error('Reconnect', '恢复云端数据失败', error.runtimeType, stackTrace);
      rethrow;
    }
  }
}
