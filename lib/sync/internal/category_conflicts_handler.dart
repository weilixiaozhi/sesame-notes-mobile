import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/db.dart';
import 'sync_runtime.dart';
import 'package:sesame_notes/data/models/category_conflict_state.dart';
import 'package:sesame_notes/sync/storage/category_cloud_state.dart';

/// 分类候选与可见分类分开持久化；所有确认仅作用于原 ID 与原来源请求。
class CategoryConflictsHandler {
  CategoryConflictsHandler(this._runtime, this._ports);
  final SyncRuntime _runtime;
  final CategoryConflictPorts _ports;
  SesameDatabase get _db => _runtime.db;

  /// 生成客户端已解码的候选投影；不同来源永远保留不同候选记录。
  Future<void> remember(Map<String, dynamic> candidate, String account) async {
    await _runtime.inAccountTransaction(account, () async {
      final id = candidate['id'] as String;
      final old = await (_db.select(
        _db.syncConflicts,
      )..where((c) => c.id.equals(id))).getSingleOrNull();
      if (old != null && old.accountId != account) {
        throw StateError('分类候选不属于当前账号');
      }
      final cloud = Map<String, dynamic>.from(
        candidate['cloud_snapshot'] as Map,
      );
      final local = candidate['local_payload'] is Map
          ? Map<String, dynamic>.from(candidate['local_payload'] as Map)
          : <String, dynamic>{'deleted': true};
      final remote = {...cloud, '_category_conflict': candidate};
      final resolved = candidate['status'] == 'resolved';
      await _db
          .into(_db.syncConflicts)
          .insertOnConflictUpdate(
            SyncConflictsCompanion.insert(
              id: id,
              accountId: d.Value(account),
              entityType: 'category',
              entityId: candidate['category_id'] as String,
              localPayload: jsonEncode(local),
              remotePayload: jsonEncode(remote),
              baseRevision: 0,
              remoteRevision: candidate['candidate_version'] as int,
              localMutationId: candidate['source_mutation_id'] as String,
              resolutionRequest: d.Value(old?.resolutionRequest),
              status: d.Value(
                resolved
                    ? candidate['resolution'] == 'local'
                          ? 'RESOLVED_LOCAL'
                          : 'RESOLVED_REMOTE'
                    : 'OPEN',
              ),
              createdAt: d.Value(
                DateTime.parse(candidate['created_at'] as String),
              ),
              resolvedAt: d.Value(
                candidate['resolved_at'] == null
                    ? null
                    : DateTime.parse(candidate['resolved_at'] as String),
              ),
            ),
          );
      if (resolved) {
        await acceptResolution(
          {
            'conflict_id': id,
            'candidate_version': candidate['candidate_version'],
            'source_device_id': candidate['source_device_id'],
            'source_mutation_id': candidate['source_mutation_id'],
            'resolution': candidate['resolution'],
            'category_state': cloud,
          },
          account,
          currentState: cloud,
        );
      }
    });
  }

  /// 完整分页读取账号候选，连同其他设备已解决的来源回执一起收敛。
  Future<void> refresh() async {
    final account = _runtime.currentAccountIdForCloudOperation('刷新分类确认');
    String? cursor;
    final seen = <String>{};
    do {
      final page = await _ports.list(cursor);
      _runtime.requireAccount(account);
      for (final candidate in page['items'] as List) {
        await remember(Map<String, dynamic>.from(candidate as Map), account);
      }
      if (page['has_more'] != true) break;
      cursor = page['next_cursor'] as String?;
      if (cursor == null || !seen.add(cursor)) {
        throw const FormatException('分类候选分页游标无效');
      }
    } while (true);
  }

  /// 冻结的是用户实际看见的候选和云版本，跨 await 后不替换为新版本。
  Future<void> resolve(
    String id, {
    required bool keepLocal,
    required String expectedDecisionVersion,
    bool restoreDeleted = false,
  }) async {
    final account = _runtime.currentAccountIdForCloudOperation('确认分类');
    await _runtime.inAccountTransaction(account, () async {
      final row = await _requireCandidate(id, account);
      if (row.resolutionRequest != null) {
        throw const CategoryDecisionException('确认结果尚未收到，请重试确认');
      }
      final remote = jsonDecode(row.remotePayload) as Map<String, dynamic>;
      final metadata = remote['_category_conflict'] as Map;
      if (row.status != 'OPEN' ||
          expectedDecisionVersion.isEmpty ||
          categoryDecisionVersion(remote) != expectedDecisionVersion) {
        throw const CategoryDecisionException('分类版本已变化，请重新比较后确认');
      }
      if (keepLocal &&
          metadata['action'] == 'upsert' &&
          remote['deleted_at'] != null &&
          !restoreDeleted) {
        throw const CategoryDecisionException('请先确认恢复原分类');
      }
      final request = jsonEncode({
        'mutation_id': const Uuid().v4(),
        'expected_candidate_version': metadata['candidate_version'],
        'expected_cloud_token': remote['version_token'],
        'choice': keepLocal ? 'local' : 'cloud',
        if (keepLocal && restoreDeleted) 'restore_deleted': true,
      });
      await (_db.update(_db.syncConflicts)..where((c) => c.id.equals(id)))
          .write(SyncConflictsCompanion(resolutionRequest: d.Value(request)));
    });
    await retry(id);
  }

  /// 未知回执重试严格使用已持久化的同一请求与幂等身份。
  Future<void> retry(String id) async {
    final account = _runtime.currentAccountIdForCloudOperation('重试分类确认');
    final row = await _requireCandidate(id, account);
    final request = row.resolutionRequest;
    if (request == null) {
      if (row.status != 'OPEN') return;
      throw const CategoryDecisionException('请重新比较后确认分类');
    }
    try {
      final response = await _ports.resolve(id, request);
      _runtime.requireAccount(account);
      await acceptResolution(response, account);
    } on DioException catch (error) {
      _runtime.requireAccount(account);
      final status = error.response?.statusCode;
      if (status == 400 || status == 409 || status == 422) {
        await _runtime.inAccountTransaction(account, () async {
          await (_db.update(_db.syncConflicts)..where(
                (c) =>
                    c.id.equals(id) &
                    c.accountId.equals(account) &
                    c.resolutionRequest.equals(request),
              ))
              .write(
                const SyncConflictsCompanion(resolutionRequest: d.Value(null)),
              );
        });
        await refresh();
        throw const CategoryDecisionException('分类版本或父子关系已变化，请先处理子分类，再重新比较后确认');
      }
      if (status == 401 || status == 403) rethrow;
      throw const CategoryDecisionException('确认结果尚未收到，请重试确认');
    }
  }

  /// 只确认来源 head；已有后继完整意图及其原基线不重写、不静默重放覆盖。
  Future<void> acceptResolution(
    Map<String, dynamic> receipt,
    String account, {
    Map<String, dynamic>? currentState,
  }) async {
    await _runtime.inAccountTransaction(account, () async {
      final conflictId = receipt['conflict_id'] as String;
      final row =
          await (_db.select(_db.syncConflicts)..where(
                (c) => c.id.equals(conflictId) & c.accountId.equals(account),
              ))
              .getSingleOrNull();
      final state =
          currentState ??
          Map<String, dynamic>.from(receipt['category_state'] as Map);
      final categoryId = state['id'] as String;
      if (row != null && row.entityId != categoryId) {
        throw const FormatException('分类确认身份不匹配');
      }
      String? sourceBaseToken;
      if (receipt['source_device_id'] == _runtime.deviceId) {
        final source =
            await (_db.select(_db.syncChanges)..where(
                  (c) =>
                      c.accountId.equals(account) &
                      c.entityType.equals('category') &
                      c.entityId.equals(categoryId) &
                      c.mutationId.equals(
                        receipt['source_mutation_id'] as String,
                      ),
                ))
                .getSingleOrNull();
        if (source != null) {
          final payload = jsonDecode(source.payload) as Map<String, dynamic>;
          sourceBaseToken = payload['base_token'] as String?;
        }
        await (_db.update(_db.syncChanges)..where(
              (c) =>
                  c.accountId.equals(account) &
                  c.entityType.equals('category') &
                  c.entityId.equals(categoryId) &
                  c.mutationId.equals(receipt['source_mutation_id'] as String),
            ))
            .write(
              SyncChangesCompanion(
                pushedAt: d.Value(DateTime.now().toUtc()),
                frozenRequest: const d.Value(null),
                payload: const d.Value('{}'),
                rejectionReason: const d.Value(null),
                rejectionCode: const d.Value(null),
              ),
            );
      }
      if (row != null) {
        await (_db.update(
          _db.syncConflicts,
        )..where((c) => c.id.equals(conflictId))).write(
          SyncConflictsCompanion(
            status: d.Value(
              receipt['resolution'] == 'local'
                  ? 'RESOLVED_LOCAL'
                  : 'RESOLVED_REMOTE',
            ),
            resolvedAt: d.Value(DateTime.now().toUtc()),
            resolutionRequest: const d.Value(null),
          ),
        );
      }
      // 单独确认接口的幂等回执固定为确认时的状态；确认来源仍可完成，
      // 但不得把后来已经拉取的云状态或墓碑覆盖回去。
      if (await _hasNewerCloudProjection(
        state,
        row,
        sourceBaseToken,
        account,
      )) {
        // 旧确认只结束原来源；本机没有后继时显示已观测的最新云态，不能留下已确认草稿。
        final current =
            await (_db.select(_db.categories)..where(
                  (c) =>
                      c.id.equals(categoryId) &
                      c.scopeAccountId.equals(account),
                ))
                .getSingleOrNull();
        final latest = decodeCategoryCloudState(
          current?.observedCloudState,
          id: categoryId,
          account: account,
        );
        if (latest != null) {
          await projectWhenSettled(categoryId, latest, account);
        }
        return;
      }
      await projectWhenSettled(categoryId, state, account);
    });
  }

  /// 分类结果先于通用确认处理，候选不能被当作普通冲突覆盖或被 ignored 清除。
  Future<bool> applyOutcome(
    SyncChange change,
    api.PostSyncPush200ResponseOutcomesInner outcome,
    String account,
  ) async {
    if (outcome.categoryConflict case final conflict?) {
      await remember(
        _runtime.modelMap(conflict, api.CategoryConflict.serializer),
        account,
      );
      return true;
    }
    if (outcome.categoryResolution case final resolution?) {
      await acceptResolution(
        _runtime.modelMap(resolution, api.CategoryResolution.serializer),
        account,
        currentState: outcome.categoryState == null
            ? null
            : _runtime.modelMap(
                outcome.categoryState!,
                api.Category.serializer,
              ),
      );
      return true;
    }
    if (outcome.status ==
        api.PostSyncPush200ResponseOutcomesInnerStatusEnum.conflict) {
      throw const FormatException('分类冲突缺少可确认候选');
    }
    final state = outcome.categoryState;
    final accepted =
        outcome.status ==
        api.PostSyncPush200ResponseOutcomesInnerStatusEnum.accepted;
    final ignored =
        outcome.status ==
        api.PostSyncPush200ResponseOutcomesInnerStatusEnum.ignored;
    if (state == null || (!accepted && !ignored)) return false;
    if (state.id != change.entityId) throw const FormatException('分类确认快照身份不匹配');
    await _runtime.inAccountTransaction(account, () async {
      // 只有首次执行回执的快照能继续同一已知基线的因果编辑；重放可能返回更新云态。
      if (accepted && outcome.changeId != null) {
        final source = jsonDecode(change.payload) as Map<String, dynamic>;
        final originalBase = source['base_token'];
        if (originalBase is String) {
          final successors =
              await (_db.select(_db.syncChanges)..where(
                    (c) =>
                        c.accountId.equals(account) &
                        c.entityType.equals('category') &
                        c.entityId.equals(change.entityId) &
                        c.id.isBiggerThanValue(change.id) &
                        c.pushedAt.isNull() &
                        c.frozenRequest.isNull(),
                  ))
                  .get();
          for (final successor in successors) {
            final payload =
                jsonDecode(successor.payload) as Map<String, dynamic>;
            if (payload['base_token'] != originalBase) continue;
            payload['base_token'] = state.versionToken;
            await (_db.update(
              _db.syncChanges,
            )..where((c) => c.id.equals(successor.id))).write(
              SyncChangesCompanion(payload: d.Value(jsonEncode(payload))),
            );
          }
        }
      }
      await (_db.update(
            _db.syncChanges,
          )..where((c) => c.id.equals(change.id) & c.accountId.equals(account)))
          .write(
            SyncChangesCompanion(
              pushedAt: d.Value(DateTime.now().toUtc()),
              payload: const d.Value('{}'),
              frozenRequest: const d.Value(null),
              rejectionReason: const d.Value(null),
              rejectionCode: const d.Value(null),
            ),
          );
      await projectWhenSettled(
        change.entityId,
        _runtime.modelMap(state, api.Category.serializer),
        account,
      );
    });
    return true;
  }

  /// 没有本机后继编辑时才替换可见投影；不会给旧草稿补上从未确认的 token。
  Future<void> projectWhenSettled(
    String id,
    Map<String, dynamic> state,
    String account,
  ) async {
    final pending = await _runtime.pendingChange('category', id, account);
    if (pending != null) return;
    await _ports.project(state, account);
  }

  /// 源 head 的基线和用户看到的云版本都可能仍对应本地意图，不能按
  /// 本地编辑时钟拒绝用户确认。其他已观测云版本才需要防历史回执倒退。
  Future<bool> _hasNewerCloudProjection(
    Map<String, dynamic> state,
    SyncConflict? conflict,
    String? sourceBaseToken,
    String account,
  ) async {
    final current =
        await (_db.select(_db.categories)..where(
              (c) =>
                  c.id.equals(state['id'] as String) &
                  c.scopeAccountId.equals(account),
            ))
            .getSingleOrNull();
    if (current == null) return false;
    var currentToken = current.serverVersionToken;
    var currentTime = current.updatedAt.toUtc();
    final observed = current.observedCloudState;
    if (observed != null) {
      // 本机草稿保留原基线，已观测的新云版本独立保存，用于阻止历史幂等回执倒退。
      final cloud = decodeCategoryCloudState(
        observed,
        id: state['id'] as String,
        account: account,
      )!;
      currentToken = cloud['version_token'] as String?;
      currentTime = DateTime.parse(cloud['updated_at'] as String).toUtc();
    }
    if ((observed == null && currentToken == null) ||
        (currentToken != null && currentToken == state['version_token']) ||
        (currentToken != null && currentToken == sourceBaseToken)) {
      return false;
    }
    final decision = conflict?.resolutionRequest;
    final decisionBaseToken = decision != null
        ? (jsonDecode(decision) as Map)['expected_cloud_token']
        : conflict == null
        ? null
        : (jsonDecode(conflict.remotePayload) as Map)['version_token'];
    if (currentToken != null && currentToken == decisionBaseToken) return false;
    final receiptTime = DateTime.parse(state['updated_at'] as String).toUtc();
    // 分类投影与服务端时间都保留毫秒，直接比较可以区分同一秒内的删除与恢复。
    // 时间相同且 token 不同的状态无法排序，保留已经观测的版本。
    return !currentTime.isBefore(receiptTime);
  }

  Future<SyncConflict> _requireCandidate(String id, String account) async {
    _runtime.requireAccount(account);
    final row =
        await (_db.select(_db.syncConflicts)..where(
              (c) =>
                  c.id.equals(id) &
                  c.accountId.equals(account) &
                  c.entityType.equals('category'),
            ))
            .getSingleOrNull();
    _runtime.requireAccount(account);
    if (row == null) throw const CategoryDecisionException('分类确认已变化，请刷新');
    return row;
  }
}

/// HTTP 边界由正式生成客户端实现；处理器只接收已解码的持久投影。
class CategoryConflictPorts {
  const CategoryConflictPorts({
    required this.list,
    required this.resolve,
    required this.project,
  });
  final Future<Map<String, dynamic>> Function(String? cursor) list;
  final Future<Map<String, dynamic>> Function(String id, String frozenRequest)
  resolve;
  final Future<void> Function(Map<String, dynamic> state, String account)
  project;
}
