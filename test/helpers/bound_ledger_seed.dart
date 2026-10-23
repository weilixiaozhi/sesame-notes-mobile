import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';

/// 准备已存在的云账本状态；账号、所有者和同步身份由场景显式指定。
///
/// 只插入夹具数据，不推导账号、不调用业务写入口，也不登记同步变更。
Future<void> seedBoundLedger(
  SesameDatabase db, {
  required String? accountId,
  required String id,
  required String name,
  String currency = 'CNY',
  bool aaEnabled = false,
  int monthStartDay = 1,
  String? syncId,
  String? ownerAccountId,
}) async {
  try {
    await db
        .into(db.ledgers)
        .insert(
          LedgersCompanion.insert(
            id: id,
            name: name,
            currency: d.Value(currency),
            monthStartDay: d.Value(monthStartDay),
            aaEnabled: d.Value(aaEnabled),
            storageMode: const d.Value('cloud'),
            scopeAccountId: d.Value(accountId),
            ownerAccountId: d.Value(ownerAccountId),
            syncId: d.Value(syncId),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
  } catch (error, stackTrace) {
    logger.error('LedgerTestFixture', '准备云账本测试状态失败', error, stackTrace);
    rethrow;
  }
}
