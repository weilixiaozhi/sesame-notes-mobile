import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';

RestoreLedgerItem _item({
  required LedgerStorageOrigin origin,
  String? accountId,
  String id = 'ledger-1',
}) => RestoreLedgerItem(
  ledgerBackupId: id,
  name: '账本',
  storageOrigin: origin,
  accountId: accountId,
  currency: 'CNY',
  expenseTotal: 0,
  memberCount: 1,
  transactionCount: 0,
  conflictCount: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('cloudSectionOf 纯函数', () {
    test('云端账本且账号匹配 → 云端分区', () {
      expect(
        cloudSectionOf(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1'),
          currentAccountId: 'acc-1',
        ),
        isTrue,
      );
    });

    test('未登录 → 本地分区', () {
      expect(
        cloudSectionOf(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1'),
          currentAccountId: null,
        ),
        isFalse,
      );
    });

    test('账号不符 → 本地分区', () {
      expect(
        cloudSectionOf(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1'),
          currentAccountId: 'acc-2',
        ),
        isFalse,
      );
    });

    test('备份缺账号信息 → 本地分区', () {
      expect(
        cloudSectionOf(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: null),
          currentAccountId: 'acc-1',
        ),
        isFalse,
      );
    });

    test('本地账本 → 本地分区', () {
      expect(
        cloudSectionOf(
          item: _item(origin: LedgerStorageOrigin.local, accountId: null),
          currentAccountId: 'acc-1',
        ),
        isFalse,
      );
    });
  });

  group('defaultDecisionFor 纯函数', () {
    test('本地账本 → 恢复为本地账本', () {
      expect(
        defaultDecisionFor(
          item: _item(origin: LedgerStorageOrigin.local),
          currentAccountId: 'acc-1',
        ),
        RestoreDecision.restoreLocal,
      );
    });

    test('云端账本账号匹配 → 恢复为云账本', () {
      expect(
        defaultDecisionFor(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1'),
          currentAccountId: 'acc-1',
        ),
        RestoreDecision.reconnect,
      );
    });

    test('云端账本账号不符 → 恢复为本地副本', () {
      expect(
        defaultDecisionFor(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1'),
          currentAccountId: 'acc-2',
        ),
        RestoreDecision.forkCloudToLocal,
      );
    });

    test('云端账本未登录 → 恢复为本地副本', () {
      expect(
        defaultDecisionFor(
          item: _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1'),
          currentAccountId: null,
        ),
        RestoreDecision.forkCloudToLocal,
      );
    });
  });
}
