import 'dart:async';

/// 云资料缓存装配（定义于 core/api/cloud_profile_cache.dart，此处 re-export 保持调用方不变）。
export 'package:sesame_notes/core/api/cloud_profile_cache.dart'
    show cloudProfileCacheProvider;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d; // & 表达式运算符（drift 扩展）
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/core/api/cloud_profile_cache.dart';
import 'package:sesame_notes/core/api/profile_service.dart';
import 'package:sesame_notes/core/api/secure_account_store.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

// 账号状态（AccountState/AccountStateNotifier/accountStateProvider）
// 定义于 shared/providers 叶子，此处 re-export 保持调用方不变。
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
export 'package:sesame_notes/shared/providers/account_state_provider.dart';

/// 云资料缓存同步桥：token 刷新（拦截器路径）只写磁盘缓存，本桥监听
/// 缓存写入信号并把最新资料同步进内存展示状态，避免已打开的资料 UI
/// 停留在旧昵称/头像。仅当已登录且已有内存资料时同步；未登录时忽略。
final profileCacheSyncBridgeProvider = Provider<void>((ref) {
  ref.listen(profileCacheTickProvider, (previous, next) {
    final state = ref.read(accountStateProvider);
    if (state.status != AccountStatus.authenticated) return;
    final profile = state.profile;
    if (profile == null) return;
    final cached = ref.read(cloudProfileCacheProvider).read(profile.userId);
    if (cached != null) {
      ref.read(accountStateProvider.notifier).updateProfile(cached);
    }
  });
});

/// 启动账号恢复：读 ActiveCredential + 资料缓存 → 恢复 authenticated →
/// 后台刷新（200 原子轮换凭证束；认证类 401 清除凭证回未登录；
/// 网络错误/5xx 保留凭证与缓存身份，等待下次重试）。
final accountBootstrapProvider = FutureProvider<void>((ref) async {
  // 常驻初始化缓存同步桥：拦截器刷新路径经它把新资料同步进内存
  ref.watch(profileCacheSyncBridgeProvider);
  // 先确保 SharedPreferences 就绪：cloudProfileCacheProvider 依赖它，
  // 首个同步读取者必须等 FutureProvider 解析完成（启动主流程 await 本 provider）
  await ref.read(sharedPreferencesProvider.future);
  final store = ref.read(secureAccountStoreProvider);
  final credential = await store.load();
  if (credential == null) return;
  final cache = ref.read(cloudProfileCacheProvider);
  final cached = cache.read(credential.userId);
  if (cached != null) {
    ref.read(accountStateProvider.notifier).restoreFromCache(cached);
  } else {
    ref.read(accountStateProvider.notifier).restorePending();
  }
  // 后台刷新不阻塞首帧：失败分类处理，绝不因网络抖动清除凭证
  unawaited(_refreshInBackground(ref, credential, cached));
});

/// 启动恢复收尾：登出标记撤销 + pending_local_move 隐藏 Fork 发布。
///
/// 设计意图（14.2/13.3）：崩溃不能绕过清理——登出 marker 捕获的 A 凭证
/// 在这里完成服务端撤销；隐藏 Fork 在服务端已删除源账本时发布为正式本地
/// 账本（发布中断在最后一步的崩溃场景可安全恢复，不会丢账）。
final accountRecoveryProvider = FutureProvider<void>((ref) async {
  final store = ref.read(secureAccountStoreProvider);

  // ---- 1. logout marker：完成服务端撤销并清标记（多次失败不阻塞启动）----
  final marker = await store.loadLogoutMarker();
  if (marker != null) {
    try {
      await ref
          .read(authServiceProvider)
          .revokeServerSession(marker.credential);
    } catch (error, stackTrace) {
      logger.warning('AccountRecovery', '登出撤销重试失败，标记保留', '$error\n$stackTrace');
    } finally {
      await store.clearLogoutMarker();
    }
  }

  // ---- 2. pending_local_move：服务端已删除源账本则发布本地 Fork ----
  final repo = ref.read(repositoryProvider);
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
    try {
      final remote = await ref
          .read(syncServiceProvider)
          .fetchLedgerRemoteStatus(sourceId);
      if (remote.deleted) {
        await _publishPendingFork(ref, fork.id);
      }
      // 云端仍存活：保留 pending，等待用户重试或取消
    } on DioException catch (error) {
      // 会话/网络不可用（401/403/网络错误）：无法权威确认，保留 pending
      logger.warning('AccountRecovery', '隐藏 Fork 远端状态确认失败，保留待重试', '$error');
    }
  }
});

/// 发布隐藏 Fork：单事务清除源云缓存（若存在）并把 binding_status 置空。
Future<void> _publishPendingFork(Ref ref, String forkId) async {
  final db = ref.read(databaseProvider);
  final repo = ref.read(repositoryProvider);
  await db.transaction(() async {
    final fork = await repo.getLedgerById(forkId);
    if (fork == null) return;
    final sourceId = fork.originLedgerId;
    if (sourceId != null && sourceId.isNotEmpty) {
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

/// 后台刷新分类处理：与 401 拦截器共用同一判定边界。
Future<void> _refreshInBackground(
  Ref ref,
  ActiveCredential credential,
  CloudProfile? cached,
) async {
  final store = ref.read(secureAccountStoreProvider);
  try {
    final refreshed = await ref
        .read(authServiceProvider)
        .refresh(credential: credential);
    // 原子覆盖：凭证束 → 会话与资料（先落安全存储，再生效内存状态）
    final next = ActiveCredential(
      userId: refreshed.session.userId,
      deviceId: refreshed.session.deviceId,
      refreshToken: refreshed.refreshToken,
    );
    await store.save(next);
    await ref.read(cloudProfileCacheProvider).write(refreshed.profile);
    ref
        .read(accountStateProvider.notifier)
        .signIn(
          session: refreshed.session,
          credential: next,
          profile: refreshed.profile,
        );
  } on DioException catch (error, stackTrace) {
    final status = error.response?.statusCode;
    if (status == 401) {
      // 明确认证类 401：删除 ActiveCredential 回到未登录；本地账本与
      // 原账号域缓存保留，重新登录同账号后恢复
      try {
        await store.clear();
      } catch (clearError, clearStackTrace) {
        logger.error(
          'AccountBootstrap',
          '认证失效后清理凭证失败',
          clearError,
          clearStackTrace,
        );
      } finally {
        ref.read(accountStateProvider.notifier).signOut();
      }
      logger.warning(
        'AccountBootstrap',
        '启动刷新被认证类 401 拒绝，凭证已清除',
        '$error\n$stackTrace',
      );
    } else {
      // 网络错误/超时/5xx：凭证与缓存身份都保留，等待下次刷新重试
      logger.warning(
        'AccountBootstrap',
        '启动刷新暂不可用（网络/服务端），保留已登录缓存',
        '$error\n$stackTrace',
      );
    }
  } catch (error, stackTrace) {
    // 解析/格式等异常按临时失败处理，保留凭证
    logger.warning(
      'AccountBootstrap',
      '启动刷新响应解析失败，保留本地会话',
      '$error\n$stackTrace',
    );
  }
}

/// ProfileService 装配。
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.watch(apiClientProvider));
});

/// 云资料缓存装配（定义于 core/api/cloud_profile_cache.dart，此处 re-export 保持调用方不变）。
