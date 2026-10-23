import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' as d;
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_ledger_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_recurring_transaction_repository.dart';
import 'package:sesame_notes/data/repositories/local/local_transaction_repository.dart';
import 'package:sesame_notes/sync/sync_service.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';

/// 使用真实同步引擎与投影；只替换网络边界，保留复制、确认、失败与身份重写的行为断言。
class LedgerSyncFixture implements HttpClientAdapter {
  LedgerSyncFixture(
    this.db,
    this.account, {
    required Future<String> Function() localSelfId,
  }) {
    client = api.SesameApiClient(basePathOverride: 'https://sync.test');
    client.dio.httpClientAdapter = this;
    service = SyncService(
      client: client,
      db: db,
      deviceId: 'device-1',
      repo: LocalLedgerRepository(db),
      currentAccountIdGetter: () => account,
      localSelfIdLoader: localSelfId,
    );
  }
  final SesameDatabase db;
  final String account;
  late final api.SesameApiClient client;
  late final SyncService service;
  String deleteStatus = 'accepted';
  bool remoteDeleted = false;
  int deleteCalls = 0;
  int fullCalls = 0;
  int cursor = 10;
  Object? deleteError;
  final requests = <Map<String, dynamic>>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.endsWith('/sync/push')) {
      final body = options.data is String
          ? jsonDecode(options.data as String) as Map
          : options.data as Map;
      final outcomes = <Map<String, dynamic>>[];
      for (final raw in body['changes'] as List) {
        final change = Map<String, dynamic>.from(raw as Map);
        requests.add(change);
        final deleting =
            change['entity_type'] == 'ledger' && change['action'] == 'delete';
        if (deleting) {
          deleteCalls++;
          if (deleteError != null) throw deleteError!;
          if (deleteStatus == 'accepted') remoteDeleted = true;
        }
        final status = deleting ? deleteStatus : 'accepted';
        outcomes.add({
          'mutation_id': change['mutation_id'],
          'entity_id': change['entity_id'],
          'status': status,
          'change_id': ['accepted', 'ignored'].contains(status)
              ? '${++cursor}'
              : null,
          if (['accepted', 'ignored'].contains(status)) ...{
            'revision': (change['base_revision'] as int? ?? 0) + 1,
            if (change['entity_type'] == 'ledger')
              'sync_id': change['sync_id'] ?? 'test-binding',
          },
          if (status == 'conflict') ...{
            'current_revision': 1,
            'current_deleted': false,
            'current_entity': {'name': '云端版本'},
          },
          if (status == 'invalid') 'message': '内容已变化，请刷新后重新确认',
        });
      }
      return ResponseBody.fromString(
        jsonEncode({'outcomes': outcomes, 'server_cursor': '$cursor'}),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    if (options.path.endsWith('/sync/full')) {
      fullCalls++;
      if (remoteDeleted && deleteCalls > 0) {
        return ResponseBody.fromString(
          '{}',
          404,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      }
      final id = options.queryParameters['ledger_id'] as String;
      return ResponseBody.fromString(
        jsonEncode(await _full(id)),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    if (options.path.endsWith('/sync/pull')) {
      return ResponseBody.fromString(
        jsonEncode({
          'changes': [],
          'server_cursor': '$cursor',
          'has_more': false,
        }),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    final ledgerRequest = RegExp(r'/ledgers/([^/]+)$').firstMatch(options.path);
    if (ledgerRequest != null && options.method == 'GET') {
      return ResponseBody.fromString(
        jsonEncode((await _full(ledgerRequest.group(1)!))['ledger']),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    throw StateError('Unexpected test request: ${options.path}');
  }

  /// 服务器夹具声明权威所有者，分类完整目录严格限定该所有者域。
  Future<Map<String, dynamic>> _full(String id) async {
    final book = await (db.select(
      db.ledgers,
    )..where((b) => b.id.equals(id))).getSingle();
    final transactions = await (db.select(
      db.transactions,
    )..where((t) => t.ledgerId.equals(id) & t.deletedAt.isNull())).get();
    final members = await (db.select(
      db.ledgerMembers,
    )..where((m) => m.ledgerId.equals(id))).get();
    final owner = book.ownerAccountId ?? account;
    final categories =
        await (db.select(db.categories)..where(
              (c) => categoryScopePredicate(c, owner) & c.deletedAt.isNull(),
            ))
            .get();
    final recurring = await (db.select(
      db.recurringTransactions,
    )..where((r) => r.ledgerId.equals(id) & r.deletedAt.isNull())).get();
    final rows = <Map<String, dynamic>>[];
    for (final t in transactions) {
      final splits = await (db.select(
        db.transactionSplits,
      )..where((s) => s.transactionId.equals(t.id))).get();
      rows.add({
        'id': t.id,
        'ledger_id': id,
        'revision': t.serverRevision ?? 1,
        'created_at': t.createdAt.toUtc().toIso8601String(),
        'updated_at': t.updatedAt.toUtc().toIso8601String(),
        ...jsonDecode(
              transactionPayload(t, [
                for (final s in splits)
                  (memberId: s.memberId, amount: s.amount),
              ], payerMemberId: t.payerMemberId),
            )
            as Map<String, dynamic>,
      });
    }
    return {
      'ledger': {
        'id': id,
        'owner_id': owner,
        'sync_id': book.syncId ?? 'test-binding',
        'name': book.name,
        'currency': book.currency,
        'month_start_day': book.monthStartDay,
        'aa_enabled': book.aaEnabled,
        'role': book.role,
        'member_count': book.memberCount,
        'updated_at': book.updatedAt.toUtc().toIso8601String(),
      },
      'transactions': rows,
      'members': [
        for (final m in members)
          if (m.memberType != 'LOCAL')
            {
              'id': m.id,
              'ledger_id': id,
              'display_name': m.displayName,
              'member_type': m.memberType,
              'status': m.status,
              'updated_at': m.updatedAt.toUtc().toIso8601String(),
            },
      ],
      'categories': [
        for (final c in categories)
          {
            'id': c.id,
            'owner_id': owner,
            'name': c.name,
            'kind': c.kind,
            'level': c.level.toString(),
            'sort_order': c.sortOrder,
            'icon': c.icon,
            'parent_id': c.parentId,
            'updated_at': c.updatedAt.toUtc().toIso8601String(),
          },
      ],
      'category_tombstones': [],
      'recurring_transactions': [
        for (final r in recurring)
          {
            'id': r.id,
            'ledger_id': id,
            ...jsonDecode(recurringTransactionPayload(r))
                as Map<String, dynamic>,
          },
      ],
      'exchange_rate_overrides': [],
      'server_cursor': '$cursor',
    };
  }

  @override
  void close({bool force = false}) {}
}
