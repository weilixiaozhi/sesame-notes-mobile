import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../data/models/private_book.dart';
import '../../../shared/providers/account_state_provider.dart';
import 'day_file_actions.dart';

/// 四个业务共用会话身份；日子的附加快照仅用于仓储协议适配。
class DataImportTarget {
  const DataImportTarget({
    this.ledgerTarget,
    this.dayTarget,
    this.memoTarget,
    this.fitnessTarget,
  });
  final PrivateBookTarget? ledgerTarget, memoTarget, fitnessTarget;
  final DayImportTarget? dayTarget;
  String? get ledgerId => ledgerTarget?.bookId;
  PrivateBookTarget? get identity =>
      ledgerTarget ??
      memoTarget ??
      fitnessTarget ??
      (dayTarget == null
          ? null
          : (
              bookId: dayTarget!.book.id,
              accountId: dayTarget!.accountId,
              generation: dayTarget!.generation,
              syncId: dayTarget!.book.syncId,
            ));

  void checkSession(ProviderReader read) {
    if ([
          ledgerTarget,
          dayTarget,
          memoTarget,
          fitnessTarget,
        ].where((v) => v != null).length !=
        1) {
      throw StateError('请选择唯一导入目标');
    }
    final fixed = identity;
    if (fixed == null ||
        fixed.accountId != read(currentAccountIdProvider) ||
        fixed.generation != read(authIdentityGenerationProvider)) {
      throw StateError('导入身份已改变，请重新选择目标');
    }
  }
}
