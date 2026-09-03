import 'package:drift/drift.dart' as d;

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';

/// 本地身份与云身份绑定服务（账号一期收敛版）。
///
/// 设计意图：
/// - 登录只建立账号会话并恢复该账号云数据，绝不改写本地账本：LOCAL ledger、
///   LOCAL member、self_member_id 和历史引用一行不动；
/// - 云账本的 REGISTERED 本人由同步/成员目录按 registeredMemberId 建立；
/// - `unbindOnLogout` 只清空 LOCAL member 的 linked_account_id，不改 member id、
///   display name、交易或分摊引用。
class IdentityBindingService {
  IdentityBindingService._();

  /// 退出登录后执行：本地账本 LOCAL 成员解绑（身份与历史数据保留）。
  static Future<void> unbindOnLogout({required SesameDatabase db}) async {
    try {
      await (db.update(
        db.ledgerMembers,
      )..where((m) => m.memberType.equals('LOCAL'))).write(
        LedgerMembersCompanion(
          linkedAccountId: const d.Value(null),
          updatedAt: d.Value(DateTime.now().toUtc()),
        ),
      );
    } catch (error, stackTrace) {
      logger.warning(
        'IdentityBinding',
        '退出解绑失败(不影响登出流程)',
        '$error\n$stackTrace',
      );
    }
  }
}
