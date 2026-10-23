import 'package:sesame_notes/shared/application/provider_reader.dart';
import '../providers/ledger_identity_providers.dart';
import '../../core/logging/logger_service.dart';

/// 按账本的本人指针、账号绑定和本地身份规则解析操作者。
Future<String> authorMemberIdForLedger(
  ProviderReader read,
  String ledgerId,
) async {
  try {
    return (await read(ledgerIdentityProvider(ledgerId).future)).selfMemberId;
  } catch (error, stackTrace) {
    logger.error('LedgerIdentity', '解析账本操作者失败', error, stackTrace);
    rethrow;
  }
}
