import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sesame_notes/infrastructure/api/cloud_connection.dart';
import 'package:sesame_notes/infrastructure/sharing/sharing_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

class _Sharing extends Mock implements SharingService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);
  test('离线协作不发请求，本地虚拟成员照常保存', () async {
    final events = StreamController<bool>.broadcast(sync: true);
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final sharing = _Sharing();
    final repo = LocalRepository(
      db,
      changeTracker: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
    );
    final container = ProviderContainer(
      overrides: [
        cloudNetworkEventsProvider.overrideWithValue(events.stream),
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        sharingServiceProvider.overrideWithValue(sharing),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await events.close();
      await db.close();
    });
    container.read(cloudConnectionProvider);
    events.add(false);
    final actions = container.read(ledgerActionsProvider);
    for (final operation in <Future<Object?> Function()>[
      () => actions.queryInvite('CODE'),
      () => actions.acceptInvite('CODE'),
      () => actions.createInvite(ledgerId: 'ledger', expiresInHours: 1),
      () => actions.removeMember(
        ledgerId: 'ledger',
        memberId: 'member',
        accountId: 'other',
      ),
      () => actions.leaveSharedLedger('ledger'),
    ]) {
      await expectLater(operation(), throwsA(isA<SocketException>()));
    }
    verifyZeroInteractions(sharing);
    final ledger = await actions.create(name: '离线账本', storageMode: 'cloud');
    final member = await actions.createPlaceholderMember(
      ledgerId: ledger,
      name: '同行者',
    );
    expect(
      (await db.select(db.ledgerMembers).get()).any((row) => row.id == member),
      isTrue,
    );
    expect(
      (await db.select(db.syncChanges).get()).any(
        (row) => row.entityId == member,
      ),
      isTrue,
    );
  });
}
