import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'dart:async';

/// 账号功能通过统一出口读取云资料缓存。
export 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart'
    show cloudProfileCacheProvider;

import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/account/cloud_profile_cache.dart';
import 'package:sesame_notes/infrastructure/account/profile_service.dart';
import 'package:sesame_notes/infrastructure/account/secure_account_store.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/sync_state_providers.dart';

// 账号状态（AccountState/AccountStateNotifier/accountStateProvider）
// 定义于 shared/providers/account_state_provider.dart，此处提供统一出口。
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
export 'package:sesame_notes/shared/providers/account_state_provider.dart'
    show AccountState, AccountStateNotifier, accountStateProvider;

/// 云资料缓存同步桥：token 刷新（拦截器路径）写 CloudProfileCache，本桥监听
/// 缓存写入信号并把最新资料同步进内存展示状态，避免已打开的资料 UI
/// 停留在旧昵称/头像。缓存登录态没有资料时，使用恢复后的会话定位本人缓存。
final profileCacheSyncBridgeProvider = Provider<void>((ref) {
  /// 只同步当前登录账号的资料，避免跨账号缓存写入污染展示状态。
  void syncProfile() {
    final state = ref.read(accountStateProvider);
    if (state.status != AccountStatus.authenticated) return;
    final userId = ref.read(authSessionProvider)?.userId ?? state.userId;
    if (userId == null) return;
    final cached = ref.read(cloudProfileCacheProvider).read(userId);
    if (cached != null) {
      ref.read(accountStateProvider.notifier).updateProfile(cached);
    }
  }

  ref.listen(profileCacheTickProvider, (previous, next) => syncProfile());
  ref.listen(authSessionProvider, (previous, next) {
    if (next != null) syncProfile();
  });
});

/// 启动必需读取：凭证与资料缓存恢复本地身份，存储不可读时阻断初始化。
/// 网络会话轮换由应用就绪后的独立生命周期触发。
final accountBootstrapProvider = FutureProvider<void>((ref) async {
  ref.watch(accountAuthFailureCleanupProvider);
  // 常驻初始化缓存同步桥：拦截器刷新路径经它把新资料同步进内存
  ref.watch(profileCacheSyncBridgeProvider);
  // 先确保 SharedPreferences 就绪：cloudProfileCacheProvider 依赖它，
  // 首个同步读取者必须等 FutureProvider 解析完成（启动主流程 await 本 provider）
  await ref.read(sharedPreferencesProvider.future);
  final store = ref.read(secureAccountStoreProvider);
  final credential = await store.load(requireReadable: true);
  if (credential == null) {
    // 未登录启动时同样只做隔离：云端账本按账号域不可访问（含当前账本回落），
    // 待推送变更保留在队列里，同账号重新登录后继续补推，不做任何内容删除。
    await isolateCloudDataOnAuthFailure(ref);
    return;
  }
  final cache = ref.read(cloudProfileCacheProvider);
  final cached = cache.read(credential.userId);
  if (cached != null) {
    ref.read(accountStateProvider.notifier).restoreFromCache(cached);
  } else {
    ref
        .read(accountStateProvider.notifier)
        .restorePending(userId: credential.userId);
  }
});

/// 后台恢复收尾：登出标记撤销与待发布本地副本恢复。
///
/// 待撤销会话只在服务端确认完成或材料明确失效后删除，暂时失败继续保留。
/// 隐藏 Fork 在本地源行已不存在或确认服务端已删除源账本时发布为正式本地账本；
/// 远端状态无法确认时保留隐藏副本等待重试。
final accountRecoveryProvider = FutureProvider<void>((ref) async {
  final store = ref.read(secureAccountStoreProvider);

  try {
    final markers = await _credentialQueue(store).run(() async {
      final pending = await store.loadPending();
      if (pending != null) {
        final active = await store.load();
        if (active?.refreshToken != pending.refreshToken) {
          // 候选槽与认证提交共用队列，恢复不能把正在提交的新会话当作遗留候选。
          await store.saveLogoutMarker(LogoutMarker(credential: pending));
        }
        await store.clearPending();
      }
      return store.loadLogoutMarkers();
    });
    // 未配置云服务时只保存撤销材料，本地使用不尝试访问空地址。
    if (ref.read(apiConfigProvider).baseUrl.isNotEmpty) {
      for (final marker in markers) {
        await revokePendingCredential(ref, marker.credential);
      }
    }
  } catch (error, stackTrace) {
    logger.error(
      'AccountRecovery',
      '读取撤销待办失败，下次启动重试',
      error.runtimeType,
      stackTrace,
    );
  }

  // ---- 2. pending_local_move：服务端已删除源账本则发布本地 Fork ----
  final repo = ref.read(accountDataAccessProvider);
  final forks = await repo.getPendingLocalMoveForks();
  for (final fork in forks) {
    final sourceId = fork.originLedgerId;
    if (sourceId == null || sourceId.isEmpty) continue;
    final source = await repo.getLedgerById(sourceId);
    if (source == null) {
      // 源行已不在本地（最后一步发布前崩溃）：直接发布完整 Fork
      await _publishPendingFork(ref, fork.id);
      continue;
    }
    // 只有当前账号的有效会话才能查询其云本；本地模式保留待办即可。
    final session = ref.read(authSessionProvider);
    if (session == null ||
        session.userId != source.scopeAccountId ||
        ref.read(apiConfigProvider).baseUrl.isEmpty) {
      continue;
    }
    final generation = ref.read(authIdentityGenerationProvider);
    final config = ref.read(apiConfigProvider);
    try {
      final remote = await ref
          .read(syncServiceProvider)
          .fetchLedgerRemoteStatus(sourceId);
      // 请求期间退出或切换账号，迟到的响应不能继续改动账号数据。
      if (!ref.mounted ||
          ref.read(authSessionProvider)?.userId != session.userId ||
          ref.read(authIdentityGenerationProvider) != generation ||
          !identical(ref.read(apiConfigProvider), config)) {
        continue;
      }
      if (remote.deleted) {
        await _publishPendingFork(ref, fork.id);
      }
      // 云端仍存活：保留 pending，等待用户重试或取消
    } catch (error, stackTrace) {
      logger.error(
        'AccountRecovery',
        '本地副本远端状态确认失败，保留待办供后续重试',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }
});

/// 同一安全存储的账号网络操作共用队列，跨入口复用且不占本机数据写入闸门。
final _credentialQueues = Expando<_AccountCredentialQueue>();

/// 以安全存储实例确定队列归属，独立测试或账号存储之间互不等待。
_AccountCredentialQueue _credentialQueue(SecureAccountStore store) =>
    _credentialQueues[store] ??= _AccountCredentialQueue();

/// 撤销按账号设备单飞，认证及候选恢复串行进入相同网络边界。
class _AccountCredentialQueue {
  Future<void>? _tail;
  final _revocations = <(String, String), Future<void>>{};

  /// 前序请求真实结束后执行当前操作；失败仍释放队列并交给调用方处理。
  Future<T> run<T>(Future<T> Function() action) {
    final current = (_tail ?? Future<void>.value()).then((_) => action());
    late final Future<void> settled;
    settled = current
        .then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            logger.error(
              'AccountCredentials',
              '账号网络操作未完成，后续操作可继续重试',
              safeErrorSummary(error),
              stackTrace,
            );
          },
        )
        .whenComplete(() {
          if (identical(_tail, settled)) _tail = null;
        });
    _tail = settled;
    return current;
  }

  /// 轮换令牌仍属于同一账号设备，并发消费者等待同一份撤销结果。
  Future<void> revoke(
    ActiveCredential credential,
    Future<void> Function() action,
  ) {
    final key = (credential.userId, credential.deviceId);
    final active = _revocations[key];
    if (active != null) return active;
    late final Future<void> pending;
    pending = run(action).whenComplete(() {
      if (identical(_revocations[key], pending)) _revocations.remove(key);
    });
    _revocations[key] = pending;
    return pending;
  }
}

/// 新认证等待已在途的撤销真实结束，并保护候选提交期间的会话和安全槽。
/// 此队列仅约束账号操作，本机记录和数据写入始终可以独立执行。
Future<T> runAccountAuthentication<T>(Ref ref, Future<T> Function() action) =>
    _credentialQueue(ref.read(secureAccountStoreProvider)).run(action);

/// 消费一个安全存储撤销待办；账号设备单飞，远端失败保留安全材料。
Future<void> revokePendingCredential(Ref ref, ActiveCredential credential) {
  final store = ref.read(secureAccountStoreProvider);
  final config = ref.read(apiConfigProvider);
  return _credentialQueue(store).revoke(
    credential,
    () => _revokeCredentialOnce(ref, store, credential, config),
  );
}

/// 开始前重查持久材料与当前会话，迟到的旧待办不得撤销同设备的新登录。
Future<void> _revokeCredentialOnce(
  Ref ref,
  SecureAccountStore store,
  ActiveCredential credential,
  ApiConfig config,
) async {
  try {
    if (!ref.mounted ||
        !config.isConfigured ||
        !identical(ref.read(apiConfigProvider), config)) {
      return;
    }
    final markers = await store.loadLogoutMarkers();
    final saved = markers
        .map((marker) => marker.credential)
        .where(
          (value) =>
              value.userId == credential.userId &&
              value.deviceId == credential.deviceId,
        )
        .lastOrNull;
    // 先前消费者已经完成撤销时，旧快照不能重新创建材料或重复轮换。
    if (saved == null) return;
    var pending = saved;
    final active = await store.load();
    if (store.lastError != null && active == null) {
      throw StateError('当前凭证状态无法确认');
    }
    // 服务端按设备撤销，当前设备再次登录后，旧令牌待办必须等待该会话退出。
    if (active?.userId == pending.userId &&
        active?.deviceId == pending.deviceId) {
      return;
    }
    if (!ref.mounted || !identical(ref.read(apiConfigProvider), config)) return;
    await ref
        .read(authServiceProvider)
        .revokeServerSession(
          pending,
          persistRotatedCredential: (rotated) async {
            await store.replaceLogoutMarker(pending, rotated);
            pending = rotated;
          },
        );
    await store.clearLogoutMarker(pending);
  } catch (error, stackTrace) {
    logger.error(
      'AccountRecovery',
      '服务端撤销尚未完成，安全材料保留待重试',
      error.runtimeType,
      stackTrace,
    );
  }
}

/// 发布隐藏 Fork：单事务清除源云缓存（若存在）并把 binding_status 置空。
Future<void> _publishPendingFork(Ref ref, String forkId) async {
  final db = ref.read(databaseProvider);
  final repo = ref.read(accountDataAccessProvider);
  await db.transaction(() async {
    final fork = await repo.getLedgerById(forkId);
    if (fork == null || fork.bindingStatus != 'pending_local_move') return;
    final sourceId = fork.originLedgerId;
    if (sourceId != null && sourceId.isNotEmpty) {
      // 远端回执只对应建立副本时的云绑定，新时间线或已转本地的来源必须保留。
      final source = await repo.getLedgerById(sourceId);
      if (source != null &&
          (source.storageMode != 'cloud' ||
              source.scopeAccountId != fork.originAccountId ||
              source.syncId != fork.originSyncId)) {
        logger.warning('AccountRecovery', '来源账本身份已变化，保留待确认副本');
        return;
      }
      await (db.delete(db.ledgers)..where((l) => l.id.equals(sourceId))).go();
      await (db.delete(
        db.syncChanges,
      )..where((c) => c.ledgerId.equals(sourceId))).go();
    }
    await (db.update(db.ledgers)..where((l) => l.id.equals(forkId))).write(
      LedgersCompanion(bindingStatus: const d.Value(null)),
    );
  });
}

/// 就绪后的首次会话恢复；已有内存会话无需再次轮换，失败留待网络恢复或手动重试。
final accountStartupRefreshProvider = FutureProvider<void>((ref) async {
  ref.watch(apiConfigProvider);
  if (!ref.watch(
        cloudCapabilityProvider.select((value) => value.canAuthenticate),
      ) ||
      ref.read(cloudCapabilityProvider).hasSession ||
      !ref.read(accountStateProvider).isAuthenticated) {
    return;
  }
  try {
    await ref.read(authSessionProvider.notifier).refresh();
  } catch (error, stackTrace) {
    logger.error(
      'AccountBootstrap',
      '后台会话恢复未完成，保留本地身份供稍后重试',
      safeErrorSummary(error),
      stackTrace,
    );
  }
});

/// ProfileService 装配。
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(apiClientProvider));
});
