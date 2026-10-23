import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

/// 人工编辑时钟在实体权威版本和同账号、同实体的待确认时间之后按毫秒推进。
/// 不用于初始化、确保注册或远端投影，不改变已冻结请求，也不累计整秒。
Future<DateTime> nextSyncEditTime(
  SesameDatabase db, {
  required String entityType,
  required String entityId,
  required String? accountId,
  required DateTime storedUpdatedAt,
  DateTime? now,
}) async {
  try {
    final previous =
        await (db.select(db.syncChanges)
              ..where(
                (row) =>
                    row.entityType.equals(entityType) &
                    row.entityId.equals(entityId) &
                    row.pushedAt.isNull() &
                    (accountId == null
                        ? row.accountId.isNull()
                        : row.accountId.equals(accountId)),
              )
              ..orderBy([(row) => d.OrderingTerm.desc(row.id)])
              ..limit(1))
            .getSingleOrNull();
    var baseline = storedUpdatedAt.millisecondsSinceEpoch;
    if (previous != null) {
      final precise = previous.updatedAt.millisecondsSinceEpoch;
      if (precise > baseline) baseline = precise;
    }
    final current = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return DateTime.fromMillisecondsSinceEpoch(
      current > baseline ? current : baseline + 1,
      isUtc: true,
    );
  } catch (error, stack) {
    logger.error(
      'SyncEditClock',
      '读取人工编辑时钟失败：type=$entityType，entity=$entityId',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}
