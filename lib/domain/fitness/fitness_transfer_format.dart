import 'package:sesame_notes/data/models/private_book.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

class FitnessTransferRecord {
  final String id, entityType, fitnessSpaceId;
  final Map<String, dynamic> payload;
  final DateTime? deletedAt;
  const FitnessTransferRecord({
    required this.id,
    required this.entityType,
    required this.payload,
    required this.fitnessSpaceId,
    this.deletedAt,
  });
}

/// 文档身份仅供本地去重与事务使用，不要求用户文件提供。
class FitnessTransferDocument {
  final String exportId;
  final DateTime exportedAt;
  final List<FitnessTransferRecord> records;
  final FitnessSpace space;
  const FitnessTransferDocument(
    this.exportId,
    this.exportedAt,
    this.records, {
    required this.space,
  });
}

class FitnessTransferFormat {
  static const maxFileBytes = 64 * 1024 * 1024;
  static const types = {
    'fitness_template',
    'fitness_plan',
    'fitness_workout',
    'fitness_preferences',
  };
  static final uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static void validateRecords(Iterable<FitnessTransferRecord> records) {
    final byId = <String, ({String fitnessSpaceId, String entityType})>{};
    final running = <String>{}, preferences = <String>{};
    final referenced = <({String id, String scope, String type})>{};
    void references(dynamic node, String scope) {
      if (node is List) {
        for (final item in node) {
          references(item, scope);
        }
      }
      if (node is! Map) return;
      for (final entry in node.entries) {
        if ((entry.key == 'source_plan_id' ||
                entry.key == 'source_template_id') &&
            entry.value != null) {
          referenced.add((
            id: entry.value as String,
            scope: scope,
            type: entry.key == 'source_plan_id'
                ? 'fitness_plan'
                : 'fitness_template',
          ));
        }
        references(entry.value, scope);
      }
    }

    for (final r in records) {
      if (!uuid.hasMatch(r.id) ||
          !types.contains(r.entityType) ||
          !uuid.hasMatch(r.fitnessSpaceId) ||
          byId.containsKey(r.id) ||
          r.payload.containsKey('id')) {
        throw const FormatException('fitness identity');
      }
      byId[r.id] = (fitnessSpaceId: r.fitnessSpaceId, entityType: r.entityType);
      validateFitnessPayload(r.entityType, r.payload);
      validateFitnessIdentity(r.entityType, r.id, r.payload);
      if (r.deletedAt == null &&
          r.entityType == 'fitness_workout' &&
          r.payload['status'] == 'in_progress' &&
          !running.add(r.fitnessSpaceId)) {
        throw const FormatException('multiple running workouts');
      }
      if (r.entityType == 'fitness_preferences' &&
          !preferences.add(r.fitnessSpaceId)) {
        throw const FormatException('duplicate preferences');
      }
      references(r.payload, r.fitnessSpaceId);
    }
    for (final reference in referenced) {
      final source = byId[reference.id];
      if (source != null &&
          (source.fitnessSpaceId != reference.scope ||
              source.entityType != reference.type)) {
        throw const FormatException('fitness source relationship');
      }
    }
  }

  /// JSON 使用业务对象数组；关联标识只用于表达计划与训练关系。
  static Uint8List encode(FitnessTransferDocument document) {
    validateRecords(document.records);
    final bytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert([
        for (final r in document.records.where((r) => r.deletedAt == null))
          {
            'entity_type': r.entityType,
            'id': r.id,
            if (r.entityType == 'fitness_preferences')
              'preferences': r.payload
            else
              ...r.payload,
          },
      ]),
    );
    if (bytes.length > maxFileBytes) throw const FormatException('健身文件过大');
    return Uint8List.fromList(bytes);
  }
}
