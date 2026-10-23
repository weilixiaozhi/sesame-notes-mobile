import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'dart:convert';

import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';

/// 备份中的未确认版本只恢复为显式冲突，不恢复可发送的历史请求。
class FitnessRecoveryBranch {
  final String fitnessSpaceId;
  final String entityType;
  final String canonicalId;
  final String entityId;
  final Map<String, dynamic> payload;
  final DateTime? deletedAt;
  final String kind;
  final String operationId;
  final int revision;

  /// 产生该分支的同步账号；未确认事实必须随分支保留归属。
  final String? accountId;
  const FitnessRecoveryBranch({
    required this.fitnessSpaceId,
    required this.entityType,
    required this.canonicalId,
    required this.entityId,
    required this.payload,
    required this.deletedAt,
    required this.kind,
    required this.operationId,
    required this.revision,
    required this.accountId,
  });

  /// 两条读取路径（Drift 在线库/SQLite 只读快照）共用相同外部结构校验。
  static List<FitnessRecoveryBranch> fromRows({
    required List<FitnessTransferRecord> records,
    required List<Map<String, Object?>> changes,
    required List<Map<String, Object?>> conflicts,
  }) {
    final canonical = {for (final r in records) r.id: r};
    final result = <FitnessRecoveryBranch>[];
    final keys = <String>{};
    Map<String, dynamic> decode(Object? text) =>
        jsonDecode(text as String) as Map<String, dynamic>;
    void add({
      required Map<String, Object?> row,
      required Map<String, dynamic> raw,
      required String kind,
      required String operation,
      bool deleted = false,
      String? entityId,
      int revision = 0,
    }) {
      final owner = row['fitness_space_id'] as String?;
      final local = canonical[row['entity_id']];
      if (owner == null ||
          local == null ||
          local.fitnessSpaceId != owner ||
          local.entityType != row['entity_type'] ||
          row['ledger_id'] != null ||
          row['day_book_id'] != null ||
          row['memo_book_id'] != null) {
        throw const FormatException('fitness branch scope');
      }
      final restored = raw['fitness_recovery'] == true;
      final body =
          Map<String, dynamic>.from(restored ? raw['payload'] as Map : raw)
            ..remove('fitness_space_id')
            ..remove('id')
            ..remove('sync_id')
            ..remove('revision')
            ..remove('deleted')
            ..remove('deleted_at');
      final isDeleted =
          deleted || raw['deleted'] == true || raw['deleted_at'] != null;
      final payload = body.isEmpty && isDeleted
          ? fitnessDeepPayload(local.payload)
          : body;
      validateFitnessPayload(local.entityType, payload);
      final id = entityId ?? raw['id'] as String? ?? local.id;
      if (!FitnessTransferFormat.uuid.hasMatch(id) || revision < 0) {
        throw const FormatException('fitness branch identity');
      }
      validateFitnessIdentity(local.entityType, id, payload);
      DateTime? deletedAt;
      if (isDeleted) {
        deletedAt = raw['deleted_at'] is String
            ? DateTime.parse(raw['deleted_at'] as String)
            : local.deletedAt ??
                  DateTime.parse(payload['updated_at'] as String);
      }
      final source = restored ? raw['source'] as Map : null;
      final stable = source?['operation_id'] as String? ?? operation;
      final branchKind = source?['kind'] as String? ?? kind;
      if (!{
            'pending',
            'frozen',
            'conflict_local',
            'conflict_remote',
          }.contains(branchKind) ||
          stable.isEmpty) {
        throw const FormatException('fitness branch source');
      }
      if (!keys.add('$owner:${local.id}:$stable')) {
        throw const FormatException('duplicate fitness branch');
      }
      result.add(
        FitnessRecoveryBranch(
          fitnessSpaceId: owner,
          entityType: local.entityType,
          canonicalId: local.id,
          entityId: id,
          payload: payload,
          deletedAt: deletedAt,
          kind: branchKind,
          operationId: stable,
          revision: revision,
          accountId: row['account_id'] as String?,
        ),
      );
    }

    for (final row in changes) {
      if (row['pushed_at'] != null) continue;
      final action = row['action'];
      if (action != 'upsert' && action != 'delete') {
        throw const FormatException('fitness branch action');
      }
      final mutation = row['mutation_id'] as String;
      if (!FitnessTransferFormat.uuid.hasMatch(mutation)) {
        throw const FormatException('fitness mutation id');
      }
      add(
        row: row,
        raw: decode(row['payload']),
        kind: 'pending',
        operation: 'pending:$mutation',
        deleted: action == 'delete',
      );
      if (row['frozen_request'] != null) {
        final frozen = decode(row['frozen_request']);
        if (frozen['entity_type'] != row['entity_type'] ||
            frozen['entity_id'] != row['entity_id'] ||
            frozen['mutation_id'] != mutation ||
            !{'upsert', 'delete'}.contains(frozen['action']) ||
            frozen['base_revision'] is! int ||
            (frozen['base_revision'] as int) < 0) {
          throw const FormatException('fitness frozen identity');
        }
        add(
          row: row,
          raw: {
            ...Map<String, dynamic>.from(frozen['payload'] as Map),
            if (frozen['deleted_at'] != null)
              'deleted_at': frozen['deleted_at'],
          },
          kind: 'frozen',
          operation: 'frozen:$mutation',
          deleted: frozen['action'] == 'delete',
          revision: frozen['base_revision'] as int,
        );
      }
    }
    for (final row in conflicts) {
      final marker = row['local_mutation_id'] as String;
      if (row['status'] != 'OPEN' &&
          !(row['resolved_at'] == null &&
              (marker.startsWith('fitness-superseded:') ||
                  marker.startsWith('fitness-recovery:')))) {
        continue;
      }
      final remote = decode(row['remote_payload']);
      final revision = row['remote_revision'] as int;
      if (remote['fitness_recovery'] != true) {
        add(
          row: row,
          raw: decode(row['local_payload']),
          kind: 'conflict_local',
          operation: 'conflict-local:${row['id']}',
          revision: row['base_revision'] as int,
        );
      }
      add(
        row: row,
        raw: remote,
        kind: 'conflict_remote',
        operation: 'conflict-remote:${row['id']}',
        revision: revision,
      );
    }
    return result;
  }

  /// 保留恢复分支的原账号、空间及操作来源，不与目标空间的归属混用。
  Map<String, dynamic> recoveryPayload({
    required String id,
    required Map<String, dynamic> mappedPayload,
  }) => {
    'fitness_recovery': true,
    'id': id,
    'name': mappedPayload['name'] as String? ?? '',
    'payload': mappedPayload,
    'deleted_at': deletedAt == null ? null : wireTimestamp(deletedAt!),
    'source': {
      'kind': kind,
      'account_id': accountId,
      'fitness_space_id': fitnessSpaceId,
      'operation_id': operationId,
    },
  };
}

Map<String, dynamic> fitnessDeepPayload(Map<String, dynamic> payload) =>
    jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
