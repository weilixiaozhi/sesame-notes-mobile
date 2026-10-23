import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/models/accounting_records.dart';
import 'package:sesame_notes/data/models/ledger_directory_member.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';
import 'package:sesame_notes/features/ledgers/application/member_directory_providers.dart';
import 'package:sesame_notes/infrastructure/account/auth_session.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/infrastructure/sharing/member_directory_service.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 保留目录刷新应用边界，记录实际提交次数。
class _Repository extends Fake implements LedgerRepository {
  int applied = 0;

  /// 本例始终返回同一共享账本，避免用删除本子掩盖身份错误。
  @override
  Future<LedgerSnapshot?> getLedgerById(String id) async => LedgerSnapshot(
    id: id,
    name: '共享本',
    currency: 'CNY',
    monthStartDay: 1,
    aaEnabled: false,
    role: 'owner',
    memberCount: 2,
    storageMode: 'cloud',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  /// 记录应用层是否允许迟到响应到达写入边界。
  @override
  Future<void> applyMemberDirectorySnapshot({
    required String ledgerId,
    required List<LedgerDirectoryMember> members,
  }) async {
    applied++;
  }

  /// 本例只验证网络响应前的身份变化，事务由应用层正常进入。
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
}

/// 为网络回执提供可控的暂停点。
class _Directory extends Fake implements MemberDirectoryService {
  final started = Completer<void>();
  final response = Completer<List<LedgerDirectoryMember>>();

  /// 拉取返回后由用例复核发起账号。
  @override
  Future<List<LedgerDirectoryMember>> fetchMembers(String ledgerId) {
    started.complete();
    return response.future;
  }
}

/// 测试不运行网络同步，仅保留本机写入调度的调用结构。
class _InlineSync extends Fake implements SyncCoordinator {
  /// 仅执行受保护的本机任务，不启动网络同步。
  @override
  Future<T> runDataMutation<T>(Future<T> Function() action) => action();
}

/// 同账号重新认证也构成新身份，旧目录响应不能写入该会话。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final changed in [false, true]) {
    test('成员目录响应：身份变化=$changed', () async {
      SharedPreferences.setMockInitialValues({});
      final repository = _Repository();
      final service = _Directory();
      final container = ProviderContainer(
        overrides: [
          ledgerDataAccessProvider.overrideWithValue(repository),
          memberDirectoryServiceProvider.overrideWithValue(service),
          syncCoordinatorProvider.overrideWithValue(_InlineSync()),
        ],
      );
      try {
        const session = AuthSession(
          accessToken: 'test-token',
          userId: 'a',
          deviceId: 'device',
        );
        container.read(authSessionProvider.notifier).signIn(session);
        final refreshing = refreshLedgerMemberDirectory(container, 'ledger');
        await service.started.future;
        if (changed) {
          container.read(authSessionProvider.notifier).signOut();
          container.read(authSessionProvider.notifier).signIn(session);
        }
        service.response.complete([]);
        await refreshing;
        expect(repository.applied, changed ? 0 : 1);
      } finally {
        container.dispose();
      }
    });
  }
}
