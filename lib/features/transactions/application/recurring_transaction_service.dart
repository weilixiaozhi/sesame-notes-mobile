import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/repositories/support/exceptions.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/application/ports/mutation_executor.dart';

/// 单次发生提交后的交易和模板快照，下一发生使用最新连续游标。
typedef _RecurringOccurrenceResult = ({
  TransactionSnapshot? transaction,
  RecurringTransactionSnapshot? recurring,
});

/// 提交事实独立于展示快照回读，数据库读取失败不能抹掉已经完成的发生。
class _RecurringGenerationProgress {
  /// 仅需要返回交易明细的调用收集展示快照，后台扫描只记录提交身份。
  _RecurringGenerationProgress({required this.collectTransactions});

  final bool collectTransactions;
  final transactions = <TransactionSnapshot>[];
  final committedLedgerIds = <String>{};
  final committedOccurrenceIds = <String>{};

  /// 只在生成事务返回且原作用域仍有效后登记，重复发生身份只统计一次。
  void recordCommitted(String ledgerId, String occurrenceId) {
    committedLedgerIds.add(ledgerId);
    committedOccurrenceIds.add(occurrenceId);
  }
}

/// 账号或数据库生命周期已结束，旧扫描不得把余下发生交给新的作用域。
class RecurringGenerationCancelledException implements Exception {
  /// 固定提示可用于日志，不包含身份或业务内容。
  const RecurringGenerationCancelledException();

  /// 说明扫描已安全停止，已提交发生继续保留。
  @override
  String toString() => '周期补记所属的数据状态已变化，剩余内容将在下次扫描时重试。';
}

/// 按模板独立补记周期交易，发生事务与本机写入生命周期保持一致。
class RecurringTransactionService {
  static const _tag = 'Recurring';

  final TransactionRepository repository;
  final MutationExecutor? mutationExecutor;
  final void Function()? verifyScope;

  /// 仓储保存规则与发生；应用装配注入本机写屏障及固定身份、数据库校验。
  RecurringTransactionService(
    this.repository, {
    this.mutationExecutor,
    this.verifyScope,
  });

  /// 启动扫描不抛出后台异常，停止或失败时仍返回已经完成的账本集合。
  static Future<Set<String>> generatePendingTransactionsStatic({
    required TransactionRepository repository,
    List<LedgerSnapshot>? ledgers,
    MutationExecutor? mutationExecutor,
    void Function()? verifyScope,
  }) async {
    final progress = _RecurringGenerationProgress(collectTransactions: false);
    try {
      await RecurringTransactionService(
        repository,
        mutationExecutor: mutationExecutor,
        verifyScope: verifyScope,
      )._scan(progress, ledgers: ledgers);
    } on RecurringGenerationCancelledException {
      logger.info(_tag, '周期补记所属状态已变化，已提交内容保留，剩余内容稍后重试');
    } on DataMutationPausedException {
      logger.info(_tag, '账号转换或恢复期间暂停周期补记，已提交内容保留');
    } catch (error, stackTrace) {
      // 基础设施与未知错误终止扫描，不能误认作可跳过的单模板业务错误。
      logger.error(
        _tag,
        '周期扫描未完成，已提交内容保留，请稍后重试',
        safeErrorSummary(error),
        stackTrace,
      );
    }
    final ledgerIds = progress.committedLedgerIds;
    logger.info(
      _tag,
      '本轮已完成 ${progress.committedOccurrenceIds.length} 次周期发生，涉及 ${ledgerIds.length} 本账本',
    );
    return ledgerIds;
  }

  /// 按规则 IANA 时区计算今天，返回 UTC 承载的纯发生日期。
  DateTime? calculateNextDate(
    RecurringTransactionSnapshot recurring, {
    DateTime? now,
  }) => nextRecurringDate(
    recurring,
    recurringToday(recurring.timeZone, now ?? DateTime.now()),
  );

  /// 指定范围内独立处理模板；数据库及未知错误传播给显式调用者。
  Future<List<TransactionSnapshot>> generatePendingTransactions({
    List<LedgerSnapshot>? ledgers,
  }) async {
    final progress = _RecurringGenerationProgress(collectTransactions: true);
    await _scan(progress, ledgers: ledgers);
    return progress.transactions;
  }

  /// 使用同一成功集合记录每次完成，后续模板失败不会抹掉已提交的结果。
  Future<void> _scan(
    _RecurringGenerationProgress progress, {
    List<LedgerSnapshot>? ledgers,
  }) async {
    verifyScope?.call();
    final candidates = ledgers ?? await repository.getAllLedgers();
    verifyScope?.call();
    for (final ledger in candidates) {
      verifyScope?.call();
      final rules = await repository.getRecurringTransactionsByLedger(
        ledger.id,
      );
      verifyScope?.call();
      for (final rule in rules.where((row) => row.enabled)) {
        try {
          var current = rule;
          for (var count = 0; count < 200; count++) {
            verifyScope?.call();
            final next = _nextDateForGeneration(current);
            if (next == null) break;
            final result = await _generateOccurrence(current, next, progress);
            if (result.transaction != null) {
              progress.transactions.add(result.transaction!);
            }
            final updated = result.recurring;
            if (updated == null || !updated.enabled) break;
            current = updated;
            if (count == 199) {
              logger.warning(_tag, '单个周期模板本轮补记已达 200 笔，余下发生留待后续扫描');
            }
          }
        } on RecurringGenerationRejectedException catch (error, stackTrace) {
          _logRejectedRule(rule.id, error, stackTrace);
        } on MissingExchangeRateException catch (error, stackTrace) {
          _logRejectedRule(rule.id, error, stackTrace);
        }
      }
    }
  }

  /// 仅将纯规则计算抛出的格式异常归类为模板问题，不吞数据库解码异常。
  DateTime? _nextDateForGeneration(RecurringTransactionSnapshot recurring) {
    try {
      return calculateNextDate(recurring);
    } on FormatException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        RecurringGenerationRejectedException(error.message),
        stackTrace,
      );
    }
  }

  /// 单次发生及其结果读取共用一个本机写屏障，账号转换只等待有限工作。
  Future<_RecurringOccurrenceResult> _generateOccurrence(
    RecurringTransactionSnapshot recurring,
    DateTime happenedAt,
    _RecurringGenerationProgress progress,
  ) async {
    /// 生成与游标推进由仓储事务保证原子性，屏障保护其完整应用生命周期。
    Future<_RecurringOccurrenceResult> generate() async {
      verifyScope?.call();
      final id = await repository.generateRecurringTransaction(
        recurring: recurring,
        happenedAt: happenedAt,
      );
      // 生成事务已经完成，后续快照回读失败只停止扫描，不撤销提交事实。
      verifyScope?.call();
      progress.recordCommitted(recurring.ledgerId, id);
      final transaction = progress.collectTransactions
          ? await repository.getTransactionById(id)
          : null;
      final updated = await repository.getRecurringTransactionById(
        recurring.id,
        ledgerId: recurring.ledgerId,
      );
      verifyScope?.call();
      return (transaction: transaction, recurring: updated);
    }

    verifyScope?.call();
    final executor = mutationExecutor;
    return executor == null ? generate() : executor.runDataMutation(generate);
  }

  /// 留下模板定位和完整堆栈，异常正文与金额不进入日志。
  void _logRejectedRule(String id, Object error, StackTrace stackTrace) {
    logger.error(
      _tag,
      '周期模板暂未生成，请检查规则或更新汇率后重试：$id',
      safeErrorSummary(error),
      stackTrace,
    );
  }
}
