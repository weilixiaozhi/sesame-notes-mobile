import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/sharing/sharing_service.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';

/// 记录退出共享本是否触发本地删除，迟到响应必须在此之前被拒绝。
class _LedgerRepository extends Fake implements LedgerRepository {
  int purges = 0;

  /// 本地删除是本例需要保护的不可逆副作用。
  @override
  Future<void> purgeLedger(String id) async {
    purges++;
  }
}

/// 将服务端退出结果暂停到账号身份变化之后。
class _Sharing extends Fake implements SharingService {
  final started = Completer<void>();
  final completion = Completer<void>();

  /// 只控制远端回执，不模拟本地清理。
  @override
  Future<void> leaveLedger(String id) {
    started.complete();
    return completion.future;
  }
}

/// 退出请求可以在远端完成，但旧回执不能删除新登录会话的本地账本。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('退出共享账本期间重登同账号，迟到回执不清理本地新会话', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = _LedgerRepository();
    final sharing = _Sharing();
    final container = ProviderContainer(
      overrides: [
        ledgerDataAccessProvider.overrideWithValue(repository),
        sharingServiceProvider.overrideWithValue(sharing),
        cloudNetworkEventsProvider.overrideWithValue(const Stream.empty()),
      ],
    );
    try {
      const session = AuthSession(
        accessToken: 'test-token',
        userId: 'a',
        deviceId: 'device',
      );
      container.read(authSessionProvider.notifier).signIn(session);
      final pending = container
          .read(ledgerActionsProvider)
          .leaveSharedLedger('ledger');
      final assertion = expectLater(pending, throwsStateError);
      await sharing.started.future;
      container.read(authSessionProvider.notifier).signOut();
      container.read(authSessionProvider.notifier).signIn(session);
      sharing.completion.complete();
      await assertion;
      expect(repository.purges, 0);
    } finally {
      container.dispose();
    }
  });
}
