import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/storage/cloud_ledger_download_store.dart';

import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('并发标记多账本后重载持久存储，账号隔离且成功清除只影响目标', () async {
    final store = CloudLedgerDownloadStore(SharedPreferences.getInstance);
    await Future.wait([
      store.markPending('account-a', 'ledger-1'),
      store.markPending('account-a', 'ledger-2'),
      store.markPending('account-b', 'ledger-1'),
    ]);
    await (await SharedPreferences.getInstance()).reload();
    final reopened = CloudLedgerDownloadStore(SharedPreferences.getInstance);
    expect(await reopened.pending('account-a'), {'ledger-1', 'ledger-2'});
    expect(await reopened.pending('account-b'), {'ledger-1'});

    await reopened.markReady('account-a', 'ledger-1');
    expect(await reopened.pending('account-a'), {'ledger-2'});
    expect(await reopened.pending('account-b'), {'ledger-1'});
    await reopened.forgetAccount('account-a');
    expect(await reopened.pending('account-a'), isEmpty);
    expect(await reopened.pending('account-b'), {'ledger-1'});
  });

  test('首次下载和后台刷新都持久重试，仅首次下载阻止发布', () async {
    final store = CloudLedgerDownloadStore(SharedPreferences.getInstance);
    await store.markPending('account-a', 'first');
    await store.markPending('account-a', 'ready', hasLocalSnapshot: true);
    await store.markPending('account-b', 'first');
    await (await SharedPreferences.getInstance()).reload();
    final reopened = CloudLedgerDownloadStore(SharedPreferences.getInstance);

    expect(await reopened.pending('account-a'), {'first', 'ready'});
    expect(await reopened.unpublished('account-a'), {'first'});
    expect(await reopened.unpublished('account-b'), {'first'});
    await reopened.markReady('account-a', 'first');
    expect(await reopened.pending('account-a'), {'ready'});
    expect(await reopened.unpublished('account-a'), isEmpty);
    await reopened.forgetAccount('account-a');
    expect(await reopened.pending('account-a'), isEmpty);
    expect(await reopened.pending('account-b'), {'first'});
  });

  test('首次下载任务不能因占位行存在而升级为刷新，完成后才可登记刷新', () async {
    final store = CloudLedgerDownloadStore(SharedPreferences.getInstance);
    await store.markPending('account-a', 'first');
    await store.markPending('account-a', 'first', hasLocalSnapshot: true);
    await (await SharedPreferences.getInstance()).reload();
    expect(await store.unpublished('account-a'), {'first'});
    expect(
      (await SharedPreferences.getInstance()).get(
        'cloud_pending_full:account-a:first',
      ),
      'initial',
    );

    await store.markReady('account-a', 'first');
    await store.markPending('account-a', 'first', hasLocalSnapshot: true);
    expect(await store.pending('account-a'), {'first'});
    expect(await store.unpublished('account-a'), isEmpty);
    expect(
      (await SharedPreferences.getInstance()).get(
        'cloud_pending_full:account-a:first',
      ),
      'refresh',
    );
    await store.forgetAll();
    expect(await store.pending('account-a'), isEmpty);
    expect(await store.unpublished('account-a'), isEmpty);
  });

  test('后台刷新仅通知调度，首次发布集合变化才通知展示', () async {
    var taskChanges = 0;
    var publicationChanges = 0;
    final store = CloudLedgerDownloadStore(
      SharedPreferences.getInstance,
      onChanged: () => taskChanges++,
      onPublicationChanged: () => publicationChanges++,
    );
    await store.markPending('account', 'ready', hasLocalSnapshot: true);
    await store.markReady('account', 'ready');
    expect(taskChanges, 2);
    expect(publicationChanges, 0);

    await store.markPending('account', 'first');
    await store.markPending('account', 'first', hasLocalSnapshot: true);
    expect(taskChanges, 3);
    expect(publicationChanges, 1);
    await store.markReady('account', 'first');
    expect(taskChanges, 4);
    expect(publicationChanges, 2);

    await store.markPending('account', 'ready', hasLocalSnapshot: true);
    await store.forgetAll();
    expect(taskChanges, 6);
    expect(publicationChanges, 2);
    await store.markPending('account', 'first');
    await store.forgetAll();
    expect(taskChanges, 8);
    expect(publicationChanges, 4);
  });

  for (final invalid in <Object>[
    true,
    false,
    1,
    0.5,
    'unknown',
    <String>['initial'],
  ]) {
    test(
      '非法任务模式${invalid.runtimeType}= $invalid 明确拒读和拒覆盖，持久内容及通知保持不变',
      () async {
        const brokenKey = 'cloud_pending_full:account:broken';
        const validKey = 'cloud_pending_full:account:valid';
        const foreignKey = 'cloud_pending_full:other:ready';
        SharedPreferences.setMockInitialValues({
          validKey: 'initial',
          brokenKey: invalid,
          foreignKey: 'refresh',
          'unrelated': 'retained',
        });
        var taskChanges = 0;
        var publicationChanges = 0;
        final store = CloudLedgerDownloadStore(
          SharedPreferences.getInstance,
          onChanged: () => taskChanges++,
          onPublicationChanged: () => publicationChanges++,
        );
        for (final operation in <Future<dynamic> Function()>[
          () => store.pending('account'),
          () => store.unpublished('account'),
          () => store.markPending('account', 'broken'),
          () => store.markPending('account', 'broken', hasLocalSnapshot: true),
          () => store.markReady('account', 'broken'),
          () => store.forget('account', 'broken'),
          () => store.forgetAccount('account'),
          store.forgetAll,
        ]) {
          await expectLater(operation(), throwsFormatException);
          final prefs = await SharedPreferences.getInstance();
          await prefs.reload();
          expect(prefs.get(brokenKey), invalid);
          expect(prefs.get(validKey), 'initial');
          expect(prefs.get(foreignKey), 'refresh');
          expect(prefs.get('unrelated'), 'retained');
          expect(prefs.getKeys(), {
            brokenKey,
            validKey,
            foreignKey,
            'unrelated',
          });
          expect(taskChanges, 0);
          expect(publicationChanges, 0);
        }
        expect(await store.pending('other'), {
          'ready',
        }, reason: '异常账号不能污染其他账号的读取');
      },
    );
  }
}
