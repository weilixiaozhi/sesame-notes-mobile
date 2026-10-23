import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart' show Ledgers;

/// 按本地云端归属规则构造数据库筛选条件。
d.Expression<bool> cloudLedgerFilter(Ledgers ledger) =>
    ledger.storageMode.equals('cloud') |
    ledger.memberCount.isBiggerThanValue(1);
