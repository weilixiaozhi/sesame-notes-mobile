/// 账本卡片同步状态纯函数映射测试。
///
/// 需求锚点：
/// - 绿云语义 = 「能连上服务器」：已登录且绑定正常（含待推送）即绿；
/// - 未登录 / 绑定失效（stale）/ 存在 OPEN 冲突（推送被暂停）一律离线灰；
/// - 纯本地账本映射 local（卡片用本地图标，不画云）。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/sync/ledger_sync_status.dart';

void main() {
  test('云端账本：已登录、绑定正常、无待推无冲突 → inSync', () {
    expect(
      ledgerSyncStatusOf(
        storageMode: 'cloud',
        bindingStatus: 'bound',
        hasSession: true,
        pendingCount: 0,
        conflictCount: 0,
      ),
      LedgerSyncStatus.inSync,
    );
  });

  test('云端账本：有待推送变更仍映射 pendingPush（卡片按绿处理）', () {
    expect(
      ledgerSyncStatusOf(
        storageMode: 'cloud',
        bindingStatus: null,
        hasSession: true,
        pendingCount: 3,
        conflictCount: 0,
      ),
      LedgerSyncStatus.pendingPush,
    );
  });

  test('云端账本：未登录 → notLoggedIn（离线灰）', () {
    expect(
      ledgerSyncStatusOf(
        storageMode: 'cloud',
        bindingStatus: 'bound',
        hasSession: false,
        pendingCount: 0,
        conflictCount: 0,
      ),
      LedgerSyncStatus.notLoggedIn,
    );
  });

  test('云端账本：绑定失效 → staleBinding（离线灰）', () {
    expect(
      ledgerSyncStatusOf(
        storageMode: 'cloud',
        bindingStatus: 'stale',
        hasSession: true,
        pendingCount: 0,
        conflictCount: 0,
      ),
      LedgerSyncStatus.staleBinding,
    );
  });

  test('云端账本：存在 OPEN 冲突（推送暂停）→ conflict（离线灰）', () {
    expect(
      ledgerSyncStatusOf(
        storageMode: 'cloud',
        bindingStatus: 'bound',
        hasSession: true,
        pendingCount: 0,
        conflictCount: 1,
      ),
      LedgerSyncStatus.conflict,
    );
  });

  test('纯本地账本 → local（卡片用本地图标）', () {
    expect(
      ledgerSyncStatusOf(
        storageMode: 'local',
        bindingStatus: null,
        hasSession: false,
        pendingCount: 0,
        conflictCount: 0,
      ),
      LedgerSyncStatus.local,
    );
  });

  test('卡片绿灰判定：inSync 与 pendingPush 为绿（能连上服务器），其余非本地态为灰', () {
    const green = [LedgerSyncStatus.inSync, LedgerSyncStatus.pendingPush];
    const gray = [
      LedgerSyncStatus.notLoggedIn,
      LedgerSyncStatus.staleBinding,
      LedgerSyncStatus.conflict,
    ];
    for (final status in green) {
      expect(status.isConnected, isTrue, reason: '$status 应为绿云');
    }
    for (final status in gray) {
      expect(status.isConnected, isFalse, reason: '$status 应为灰云');
    }
    expect(LedgerSyncStatus.local.isConnected, isFalse, reason: '本地态不画云');
  });
}
