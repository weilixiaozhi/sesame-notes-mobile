import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/sync/sync_service.dart';

import '../helpers/test_isolation.dart';

const _account = '10000000-0000-4000-8000-000000000001';
const _category = '20000000-0000-4000-8000-000000000001';
final _precise = DateTime.utc(2026, 10, 11, 1, 2, 3, 947);

/// 当前分类正文使用 UTC 时间，冻结包络在首次发送后保持原始排版。
Map<String, Object?> _categoryBody() => {
  'name': '订阅服务',
  'kind': 'expense',
  'level': '1',
  'sort_order': 0,
  'icon': null,
  'parent_id': null,
  'updated_at': _precise.toIso8601String(),
};

/// 构造当前已发送但未收到回执的完整请求，空业务范围保持当前协议形状。
String _envelope(String mutation) =>
    const JsonEncoder.withIndent('  ').convert({
      'mutation_id': mutation,
      'entity_type': 'category',
      'entity_id': _category,
      'action': 'upsert',
      'updated_at': _precise.toIso8601String(),
      'ledger_id': null,
      'day_book_id': null,
      'memo_book_id': null,
      'fitness_space_id': null,
      'payload': {..._categoryBody()}..remove('updated_at'),
    });

/// 真实 Dio 出口确认原始正文，分类回执使用当前账号的权威快照。
class _AcceptingAdapter implements HttpClientAdapter {
  final List<String> bodies = [];
  final List<Map<String, dynamic>> changes = [];

  /// 读取真实传输正文并返回当前生成 SDK 接受的服务端回执。
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    try {
      expect(options.method, 'POST');
      expect(options.path, endsWith('/sync/push'));
      final body = options.data as String;
      bodies.add(body);
      final wire = jsonDecode(body) as Map;
      final sent = [
        for (final value in wire['changes'] as List)
          Map<String, dynamic>.from(value as Map),
      ];
      changes.addAll(sent);
      return ResponseBody.fromString(
        jsonEncode({
          'server_cursor': '100',
          'outcomes': [
            for (final change in sent)
              {
                'mutation_id': change['mutation_id'],
                'entity_id': change['entity_id'],
                'status': 'accepted',
                'change_id': '100',
                'revision': 8,
                'category_state': {
                  ..._categoryBody(),
                  'id': _category,
                  'owner_id': _account,
                  'updated_at': change['updated_at'],
                  'deleted_at': null,
                  'version_token': 'a' * 64,
                },
              },
          ],
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    } catch (error, stack) {
      logger.error(
        'QueueReplayTest',
        '模拟传输确认失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  /// 传输夹具不持有外部资源。
  @override
  void close({bool force = false}) {}
}

/// 未知结果重放必须复用当前队列保存的正文和幂等身份。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('未知结果以原字节和幂等键重放，手动重试不重新登记', () async {
    const mutation = '80000000-0000-4000-8000-000000000001';
    final frozen = '${_envelope(mutation)}\n';
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final client = api.SesameApiClient(
      basePathOverride: 'https://queue-replay.test',
    );
    final adapter = _AcceptingAdapter();
    client.dio.httpClientAdapter = adapter;
    final service = SyncService(
      client: client,
      db: db,
      deviceId: 'replay-device',
      currentAccountIdGetter: () => _account,
    );
    try {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: _category,
              name: '订阅服务',
              kind: 'expense',
              level: 1,
              updatedAt: _precise,
              scopeAccountId: const d.Value(_account),
            ),
          );
      await db
          .into(db.syncChanges)
          .insert(
            SyncChangesCompanion.insert(
              entityType: 'category',
              entityId: _category,
              action: 'upsert',
              payload: jsonEncode(_categoryBody()),
              updatedAt: _precise,
              mutationId: mutation,
              frozenRequest: d.Value(frozen),
              accountId: const d.Value(_account),
              baseRevision: const d.Value(7),
            ),
          );
      final before = await db.select(db.syncChanges).getSingle();
      expect(before.updatedAt, _precise);
      expect(before.frozenRequest, frozen);

      await service.retryRejectedChange(before.id.toString());
      expect(await db.select(db.syncChanges).getSingle(), before);
      await service.push();

      expect(
        adapter.bodies.single,
        '{"device_id":"replay-device","changes":[$frozen]}',
      );
      expect(adapter.changes.single['mutation_id'], mutation);
      final after = await db.select(db.syncChanges).getSingle();
      expect(after.frozenRequest, isNull);
      expect(after.mutationId, mutation);
      expect(after.pushedAt, isNotNull);
    } catch (error, stack) {
      logger.error(
        'QueueReplayTest',
        '未知结果原样重放回归失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    } finally {
      client.dio.close(force: true);
      await db.close();
    }
  });
}
