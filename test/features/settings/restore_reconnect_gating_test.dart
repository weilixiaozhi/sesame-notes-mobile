/// 恢复页「云端账本分区判定 / 默认决策 / 恢复后重连」测试。
///
/// 需求锚点：
/// - 已登录且备份账本归属账号 == 当前账号 → 云端账本归「云端账本」分区，
///   选中即「恢复为云账本」；
/// - 未登录 / 账号不符 / 备份缺账号信息 → 云端账本归「本地账本」分区，
///   选中即「恢复为本地副本」；
/// - 本地账本恒归「本地账本」分区，选中即「恢复为本地账本」；
/// - 默认全选（打开备份即预填决策）；
/// - 应用恢复后仅当存在「恢复为云账本」且账号匹配的账本时触发 Reconnect v1。
library;

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

  group('shouldReconnectAfterApply 纯函数', () {
    test('有匹配账号的 reconnect 决策 → true', () {
      final item = _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1');
      expect(
        shouldReconnectAfterApply(
          items: [item],
          decisions: const {'ledger-1': RestoreDecision.reconnect},
          currentAccountId: 'acc-1',
        ),
        isTrue,
      );
    });

    test('未登录或账号不匹配 → false', () {
      final item = _item(origin: LedgerStorageOrigin.cloud, accountId: 'acc-1');
      expect(
        shouldReconnectAfterApply(
          items: [item],
          decisions: const {'ledger-1': RestoreDecision.reconnect},
          currentAccountId: null,
        ),
        isFalse,
      );
      expect(
        shouldReconnectAfterApply(
          items: [item],
          decisions: const {'ledger-1': RestoreDecision.reconnect},
          currentAccountId: 'acc-2',
        ),
        isFalse,
      );
    });
  });
}
