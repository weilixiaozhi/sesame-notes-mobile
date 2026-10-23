import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 分类查询使用非空 SQL 账号键，不能以 SQL IS NULL 查询经过转换器保存的本地域。
d.Expression<bool> categoryScopePredicate(
  Categories categories,
  String? account,
) => categories.scopeAccountId.equals(account ?? '');

/// 私有分类管理只影响同域本地账本或账号所有者账本，共享协作者账本使用自己的镜像。
d.Expression<bool> categoryLedgerPredicate(Ledgers ledgers, String? account) =>
    account == null
    ? ledgers.storageMode.equals('local') & ledgers.scopeAccountId.isNull()
    : ledgers.storageMode.equals('cloud') &
          ledgers.scopeAccountId.equals(account) &
          ledgers.ownerAccountId.equals(account);

/// 本地账本引用本地类别，云账本引用权威所有者的类别；缺少共享归属时停止私有查询。
String? categoryScopeForLedger(LedgerSnapshot ledger) {
  try {
    if (ledger.storageMode == 'local') return null;
    final owner = ledger.ownerAccountId;
    if (owner == null || owner.isEmpty) throw StateError('账本分类归属尚未确认，请先同步账本');
    return owner;
  } catch (error, stack) {
    logger.error(
      'CategoryScope',
      '读取账本分类归属失败: ledger=${ledger.id}',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}
