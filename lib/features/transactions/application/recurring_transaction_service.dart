import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/domain/recurring_schedule.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 重复交易服务
///
/// 注意：此服务主要用于生成待处理的周期交易记录
/// 数据读取和写入通过注入的交易数据端口完成。
///
class RecurringTransactionService {
  static const _tag = 'Recurring';

  final TransactionRepository repository;

  RecurringTransactionService(this.repository);

  /// 静态方法：生成待处理的重复交易（供启动时和初始化时调用）
  ///
  /// [ledgers] 由调用方限定扫描范围；未提供时读取仓库全部账本。
  ///
  /// 返回：生成了交易的账本ID集合（用于触发同步）
  static Future<Set<String>> generatePendingTransactionsStatic({
    required TransactionRepository repository,
    List<LedgerSnapshot>? ledgers,
  }) async {
    try {
      logger.info(_tag, '开始生成待处理的重复交易 (Repository=${repository.runtimeType})');

      final service = RecurringTransactionService(repository);
      final generatedTransactions = await service.generatePendingTransactions(
        ledgers: ledgers,
      );

      if (generatedTransactions.isNotEmpty) {
        final ledgerIds = generatedTransactions.map((t) => t.ledgerId).toSet();
        logger.info(
          _tag,
          '本次共生成 ${generatedTransactions.length} 条重复交易,涉及账本 $ledgerIds',
        );
        return ledgerIds;
      } else {
        logger.info(_tag, '本次没有需要生成的重复交易');
        return {};
      }
    } catch (e, stackTrace) {
      // 不抛出异常，避免影响应用启动
      logger.error(_tag, '生成重复交易失败', e, stackTrace);
      return {};
    }
  }

  /// 按规则 IANA 时区计算今天，返回 UTC 承载的纯发生日期。
  DateTime? calculateNextDate(
    RecurringTransactionSnapshot recurring, {
    DateTime? now,
  }) => nextRecurringDate(
    recurring,
    recurringToday(recurring.timeZone, now ?? DateTime.now()),
  );

  /// 在指定账本中生成待处理交易；未提供范围时扫描全部，空集合不生成。
  Future<List<TransactionSnapshot>> generatePendingTransactions({
    List<LedgerSnapshot>? ledgers,
  }) async {
    final nowStr = DateTime.now().toString();
    logger.info(_tag, '开始扫描周期交易 (now=$nowStr)');

    final candidates = ledgers ?? await repository.getAllLedgers();
    logger.info(_tag, '获取到 ${candidates.length} 个账本');

    final generatedTransactions = <TransactionSnapshot>[];

    for (final ledger in candidates) {
      // 只加载当前账本的模板，避免每次循环全表扫描。
      final recurringList = (await repository.getRecurringTransactionsByLedger(
        ledger.id,
      )).where((r) => r.enabled).toList();
      if (recurringList.isEmpty) continue;
      logger.info(
        _tag,
        '账本 id=${ledger.id} 有 ${recurringList.length} 个启用的周期交易',
      );

      for (final recurring in recurringList) {
        logger.info(
          _tag,
          '处理周期交易 id=${recurring.id} freq=${recurring.frequency} interval=${recurring.interval} start=${recurring.startDate} end=${recurring.endDate} lastGen=${recurring.lastGeneratedDate}',
        );
        // 循环生成所有缺失的交易记录
        var currentRecurring = recurring;
        var loopGuard = 0;
        while (true) {
          // 防御:任何情况下单条周期交易一次扫描不应生成上千笔 —— 拦截死循环
          if (++loopGuard > 200) {
            logger.warning(
              _tag,
              '周期交易 id=${recurring.id} 单次生成超过 200 笔,强制中止以防死循环',
            );
            break;
          }
          final nextDate = calculateNextDate(currentRecurring);
          if (nextDate == null) break;

          logger.info(
            _tag,
            '周期交易 id=${currentRecurring.id} 生成一笔: happenedAt=$nextDate type=${currentRecurring.txType}',
          );

          // 写交易 + 推进锚点在同一事务内完成，防止锚点更新失败导致重复生成。
          final transactionId = await repository.generateRecurringTransaction(
            recurring: currentRecurring,
            happenedAt: nextDate,
          );

          // 单条反查新交易，避免订阅整个账本交易流。
          final transaction = await repository.getTransactionById(
            transactionId,
          );

          if (transaction != null) {
            generatedTransactions.add(transaction);
          }

          // 重新读取当前账本更新后的模板，用于下一次循环。
          final updatedList = await repository.getRecurringTransactionsByLedger(
            ledger.id,
          );
          final matchedRecurring = updatedList
              .where((r) => r.id == currentRecurring.id)
              .toList();
          if (matchedRecurring.isEmpty) break;
          final updatedRecurring = matchedRecurring.first;
          currentRecurring = updatedRecurring;
        }
      }
    }

    return generatedTransactions;
  }
}
