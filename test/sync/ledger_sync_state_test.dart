import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/sync/ledger_sync_state.dart';

void main() {
  test('ledger 持久字段唯一映射到同步绑定状态', () {
    expect(ledgerSyncStateOf(storageMode: 'local'), LedgerSyncState.local);
    expect(
      ledgerSyncStateOf(storageMode: 'cloud'),
      LedgerSyncState.cloudUnbound,
    );
    expect(
      ledgerSyncStateOf(storageMode: 'cloud', syncId: 'S1'),
      LedgerSyncState.cloudBound,
    );
    expect(
      ledgerSyncStateOf(
        storageMode: 'cloud',
        syncId: 'S1',
        bindingStatus: 'stale',
      ),
      LedgerSyncState.staleBinding,
    );
  });

  test('非法字段组合失败关闭，不得发起同步', () {
    final invalidStates = [
      ledgerSyncStateOf(storageMode: 'local', syncId: 'S1'),
      ledgerSyncStateOf(storageMode: 'local', bindingStatus: 'stale'),
      ledgerSyncStateOf(storageMode: 'unknown'),
    ];

    expect(invalidStates, everyElement(LedgerSyncState.invalid));
    expect(invalidStates.map((state) => state.canSync), everyElement(isFalse));
  });
}
