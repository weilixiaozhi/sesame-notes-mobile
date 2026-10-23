import 'package:sesame_api_client/sesame_api_client.dart';

/// 传输桩按真实请求逐条返回确认；畸形响应测试仍须显式构造错误响应。
List<Map<String, dynamic>> syncRequestChanges(PostSyncPushRequest request) {
  final wire =
      standardSerializers.serializeWith(PostSyncPushRequest.serializer, request)
          as Map;
  return (wire['changes'] as List)
      .map((value) => Map<String, dynamic>.from(value as Map))
      .toList();
}

PostSyncPush200Response acknowledgeSyncRequest(
  PostSyncPushRequest request, {
  String syncId = 'S-BOUND',
  List<PostSyncPush200ResponseOutcomesInner> overrides = const [],
}) {
  final custom = {for (final outcome in overrides) outcome.mutationId: outcome};
  final changes = syncRequestChanges(request);
  return standardSerializers.deserializeWith(
    PostSyncPush200Response.serializer,
    {
      'server_cursor': '100',
      'outcomes': [
        for (final change in changes)
          if (custom[change['mutation_id']] case final outcome?)
            {
              ...standardSerializers.serializeWith(
                    PostSyncPush200ResponseOutcomesInner.serializer,
                    outcome,
                  )
                  as Map,
              'entity_id': change['entity_id'],
            }
          else
            {
              'mutation_id': change['mutation_id'],
              'entity_id': change['entity_id'],
              'status': 'accepted',
              'change_id': '100',
              'revision': (change['base_revision'] as int? ?? 0) + 1,
              if (change['entity_type'] == 'ledger' ||
                  (change['entity_type'] as String).startsWith('fitness_') ||
                  (change['entity_type'] as String).startsWith('day_') ||
                  (change['entity_type'] as String).startsWith('memo_'))
                'sync_id': change['sync_id'] ?? syncId,
            },
      ],
    },
  )!;
}
