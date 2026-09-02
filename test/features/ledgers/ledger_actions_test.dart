/// 接受邀请用例测试。
///
/// 需求锚点：
/// - 接受邀请不回滚：服务端接受且本地落绑定行后，首批历史数据同步失败
///   不撤销已加入的账本；
/// - bootstrap 把失败收敛为 error 结果返回（非抛出），用例层必须检查该结果：
///   失败时记录携带失败详情的 warning 日志，并向 UI 返回「已加入，历史数据
///   将在联网后同步」的非致命状态；成功时返回正常状态。
library;

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_api_client/sesame_api_client.dart';
import 'package:sesame_notes/core/api/sharing_service.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

import '../../helpers/test_isolation.dart';

class _MockSharingService extends Mock implements SharingService {}

class _MockSyncCoordinator extends Mock implements SyncCoordinator {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late _MockSharingService sharing;
  late _MockSyncCoordinator coordinator;
  late ProviderContainer container;

  setUp(() async {
    resetGlobalTestState();
    SharedPreferences.setMockInitialValues({});
    // logger 是进程级单例，内存日志跨用例残留；每个用例从空日志起步。
    await logger.clear();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    sharing = _MockSharingService();
    coordinator = _MockSyncCoordinator();
    when(() => sharing.acceptInvite('ABC123')).thenAnswer(
      (_) async => PostInvitesByCodeAccept200Response(
        (b) => b
          ..ledgerId = 'ledger-x'
          ..ledgerName = '旅行账本'
          ..role = PostInvitesByCodeAccept200ResponseRoleEnum.editor,
      ),
    );
    container = ProviderContainer(
      overrides: [
        repositoryProvider.overrideWithValue(repo),
        sharingServiceProvider.overrideWithValue(sharing),
        // bootstrap 的网络链路在测试中 mock 掉，按用例指定返回结果。
        syncCoordinatorProvider.overrideWithValue(coordinator),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('首批历史数据同步返回错误结果：加入不回滚，返回待同步状态并记录详细日志', () async {
    // bootstrap 内部把失败收敛为 error 结果返回，而非抛出。
    when(() => coordinator.bootstrap()).thenAnswer(
      (_) async => const SyncRunResult(error: 'bootstrap-error-marker'),
    );

    final result = await container
        .read(ledgerActionsProvider)
        .acceptInvite('ABC123');

    expect(
      result.historySyncDeferred,
      isTrue,
      reason: '首批历史数据未同步成功时，必须向 UI 返回待同步的非致命状态',
    );
    final bound = await db.select(db.ledgers).get();
    expect(bound, hasLength(1), reason: '同步失败不得回滚已加入的账本绑定');
    expect(bound.single.id, 'ledger-x');

    final warnings = logger.logs.where(
      (entry) =>
          entry.tag == 'LedgerActions' && entry.level == LogLevel.warning,
    );
    expect(warnings, isNotEmpty, reason: '首批历史数据同步失败必须记录 warning 日志');
    expect(
      warnings.last.message,
      contains('bootstrap-error-marker'),
      reason: 'warning 日志必须携带失败详情，便于排查',
    );
  });

  test('首批历史数据同步成功：返回正常状态', () async {
    when(
      () => coordinator.bootstrap(),
    ).thenAnswer((_) async => const SyncRunResult());

    final result = await container
        .read(ledgerActionsProvider)
        .acceptInvite('ABC123');

    expect(result.historySyncDeferred, isFalse);
  });

  test('首批历史数据同步抛出异常：同样降级为待同步状态，不向调用方抛出', () async {
    when(() => coordinator.bootstrap()).thenThrow(StateError('network down'));

    final result = await container
        .read(ledgerActionsProvider)
        .acceptInvite('ABC123');

    expect(result.historySyncDeferred, isTrue);
    final bound = await db.select(db.ledgers).get();
    expect(bound, hasLength(1), reason: '异常路径同样不得回滚已加入的账本绑定');
  });
}
