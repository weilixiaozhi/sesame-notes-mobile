/// 认证类 401 云端数据清理（P0-1）单元测试。
///
/// 需求锚点：
/// 认证类 401（Refresh Token 被服务端明确拒绝）必须与显式退出登录同口径——
/// storage_mode='cloud' 的账本及其全部关联数据整本清除，本地账本一行不动；
/// 同步簿记（待推送队列/设备游标/冲突/拉取错误）全部失效，整表清除；
/// 重登后由 reconnect 全量快照拉回。
/// 闸门语义：清理期间暂停同步；已置闸时（登出协调器正在清理）跳过且不得
/// 提前开闸；清理成功或失败都必须恢复闸门（finally 语义）。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

/// 测试入口：取容器内 Ref 直接调用认证 401 清理（与生产调用方同形态）。
final _refProvider = Provider<Ref>((ref) => ref);

/// 给云端账本播种全套同步簿记行（待推送变更/游标/冲突/拉取错误）。
Future<void> seedSyncBookkeeping(
  SesameDatabase db, {
  required String ledgerId,
}) async {
  final now = DateTime.now().toUtc();
  await db
      .into(db.syncChanges)
      .insert(
        SyncChangesCompanion.insert(
          entityType: 'ledger',
          entityId: ledgerId,
          ledgerId: d.Value(ledgerId),
          action: 'upsert',
          payload: '{}',
          updatedAt: now,
          mutationId: const Uuid().v4(),
        ),
      );
  await db
      .into(db.syncState)
      .insert(SyncStateCompanion.insert(deviceId: 'device-1'));
  await db
      .into(db.syncConflicts)
      .insert(
        SyncConflictsCompanion.insert(
          id: const Uuid().v4(),
          ledgerId: ledgerId,
          entityType: 'transaction',
          entityId: 'tx-1',
          localPayload: '{}',
          remotePayload: '{}',
          baseRevision: 1,
          remoteRevision: 2,
          localMutationId: const Uuid().v4(),
        ),
      );
  await db
      .into(db.syncPullErrors)
      .insert(
        SyncPullErrorsCompanion.insert(
          changeId: 'change-1',
          ledgerId: d.Value(ledgerId),
          entityType: 'transaction',
          entityId: 'tx-2',
          action: 'upsert',
          rawChangeJson: '{}',
          firstSeenAt: now,
          lastAttemptAt: now,
        ),
      );
}

/// purge 必然失败的仓库桩：验证闸门 finally 语义。
class _BoomRepo extends LocalRepository {
  _BoomRepo(super.db);

  @override
  Future<void> purgeAllCloudLedgers() async {
    throw StateError('purge boom');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late ProviderContainer container;

  setUp(() {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('云端账本与同步簿记整本清除，本地账本保留，闸门恢复', () async {
    const cloudId = 'cloud-auth-fail';
    await repo.createBoundLedger(id: cloudId, name: '云端账本');
    final localId = await repo.createLedger(name: '本地账本', storageMode: 'local');
    await seedSyncBookkeeping(db, ledgerId: cloudId);

    await purgeCloudDataOnAuthFailure(container.read(_refProvider));

    expect(
      await repo.getLedgerById(cloudId),
      isNull,
      reason: '认证类 401 必须整本清除云端账本',
    );
    expect(await repo.getLedgerById(localId), isNotNull, reason: '本地账本一行不动');
    expect(await db.select(db.syncChanges).get(), isEmpty, reason: '待推送队列整表清除');
    expect(await db.select(db.syncState).get(), isEmpty, reason: '设备同步游标清除');
    expect(await db.select(db.syncConflicts).get(), isEmpty, reason: '冲突记录清除');
    expect(await db.select(db.syncPullErrors).get(), isEmpty, reason: '拉取错误清除');
    expect(container.read(syncGateProvider), isFalse, reason: '清理后必须开闸');
  });

  test('闸门已置起时跳过，不重复清理也不提前开闸', () async {
    const cloudId = 'cloud-skip';
    await repo.createBoundLedger(id: cloudId, name: '云端账本');
    container.read(syncGateProvider.notifier).hold();

    await purgeCloudDataOnAuthFailure(container.read(_refProvider));

    expect(container.read(syncGateProvider), isTrue, reason: '他人置闸不得被提前释放');
    expect(
      await repo.getLedgerById(cloudId),
      isNotNull,
      reason: '置闸时由登出协调器负责清理，此处直接跳过',
    );
    container.read(syncGateProvider.notifier).release();
  });

  test('purge 抛错也恢复闸门（finally 语义）', () async {
    final boomRepo = _BoomRepo(db);
    final container2 = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(boomRepo),
      ],
    );
    addTearDown(container2.dispose);

    await purgeCloudDataOnAuthFailure(container2.read(_refProvider));

    expect(
      container2.read(syncGateProvider),
      isFalse,
      reason: '清理失败也绝不能让闸门永久关闭',
    );
  });
}
