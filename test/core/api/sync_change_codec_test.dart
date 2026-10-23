import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_of/any_of.dart';
import 'package:sesame_api_client/sesame_api_client.dart' hide Error;
import 'package:sesame_notes/infrastructure/api/api_serializers.dart';
import 'package:sesame_notes/infrastructure/api/sync_change_codec.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bookId = '11111111-1111-4111-8111-111111111111';
const _entityId = '22222222-2222-4222-8222-222222222222';
const _syncId = '33333333-3333-4333-8333-333333333333';
const _mutationId = '44444444-4444-4444-8444-444444444444';
const _time = '2026-10-16T01:02:03.123456Z';

typedef _EntityCase = ({
  String entity,
  PostSyncPushRequestChangesInner Function(String) decode,
  Type outerType,
  Type upsertType,
  Type deleteType,
});

/// 验证协议边界能够生成可发送请求，并保留冻结数据的独立性。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  final codec = SyncChangeCodec(apiSerializers);
  final cases = <_EntityCase>[
    (
      entity: 'day_book',
      decode: codec.dayChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf,
      upsertType: PostSyncPushRequestChangesInnerAnyOfAnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOfAnyOf1,
    ),
    (
      entity: 'day_event',
      decode: codec.dayChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf1,
      upsertType: PostSyncPushRequestChangesInnerAnyOf1AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf1AnyOf1,
    ),
    (
      entity: 'memo_book',
      decode: codec.memoChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf9,
      upsertType: PostSyncPushRequestChangesInnerAnyOf9AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf9AnyOf1,
    ),
    (
      entity: 'memo_entry',
      decode: codec.memoChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf10,
      upsertType: PostSyncPushRequestChangesInnerAnyOf10AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf10AnyOf1,
    ),
    (
      entity: 'fitness_template',
      decode: codec.fitnessChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf11,
      upsertType: PostSyncPushRequestChangesInnerAnyOf11AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf11AnyOf1,
    ),
    (
      entity: 'fitness_plan',
      decode: codec.fitnessChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf12,
      upsertType: PostSyncPushRequestChangesInnerAnyOf12AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf12AnyOf1,
    ),
    (
      entity: 'fitness_workout',
      decode: codec.fitnessChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf13,
      upsertType: PostSyncPushRequestChangesInnerAnyOf13AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf13AnyOf1,
    ),
    (
      entity: 'fitness_preferences',
      decode: codec.fitnessChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf14,
      upsertType: PostSyncPushRequestChangesInnerAnyOf14AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf14AnyOf1,
    ),
    (
      entity: 'fitness_space',
      decode: codec.fitnessChangeFromFrozen,
      outerType: PostSyncPushRequestChangesInnerAnyOf15,
      upsertType: PostSyncPushRequestChangesInnerAnyOf15AnyOf,
      deleteType: PostSyncPushRequestChangesInnerAnyOf15AnyOf1,
    ),
  ];

  for (final item in cases) {
    for (final action in ['upsert', 'delete']) {
      _codecTest('${item.entity} $action 选择唯一正确分支并生成完整可发送请求', () {
        final original = _envelope(item.entity, action);
        final frozen = const JsonEncoder.withIndent('  ').convert(original);
        final change = item.decode(frozen);
        expect(change.anyOf.valueTypes, [item.outerType]);
        expect(_innerUnion(change).valueTypes, [
          action == 'delete' ? item.deleteType : item.upsertType,
        ]);

        // 完整请求序列化可发现联合分支索引错误，单独解码 DTO 无法覆盖此问题。
        final sent = _requestChange(change);
        for (final key in [
          'mutation_id',
          'entity_type',
          'entity_id',
          'ledger_id',
          'day_book_id',
          'memo_book_id',
          'fitness_space_id',
          'sync_id',
          'base_revision',
          'action',
          'updated_at',
          'payload',
        ]) {
          if (original.containsKey(key)) {
            expect(sent, containsPair(key, original[key]), reason: key);
          }
        }
        expect(_requestChange(item.decode(jsonEncode(sent))), sent);
        expect(
          frozen,
          const JsonEncoder.withIndent('  ').convert(original),
          reason: '适配过程不得替换调用方保存的冻结原文',
        );
      });
    }

    _codecTest('${item.entity} 缺少必要载荷字段时拒绝请求', () {
      final original = _envelope(item.entity, 'upsert');
      final payload = original['payload'] as Map<String, dynamic>;
      payload.remove(switch (item.entity) {
        'memo_entry' => 'title',
        'fitness_preferences' => 'default_rest_seconds',
        _ => 'name',
      });
      expect(
        () => item.decode(jsonEncode(original)),
        throwsA(isA<DeserializationError>()),
      );
    });
  }

  _codecTest('三类转换均使用客户端注入的序列化插件', () {
    final plugin = _RecordingSerializerPlugin();
    final injected = SyncChangeCodec(
      (apiSerializers.toBuilder()..addPlugin(plugin)).build(),
    );
    injected.dayChangeFromFrozen(jsonEncode(_envelope('day_book', 'upsert')));
    injected.memoChangeFromFrozen(
      jsonEncode(_envelope('memo_entry', 'upsert')),
    );
    injected.fitnessChangeFromFrozen(
      jsonEncode(_envelope('fitness_preferences', 'upsert')),
    );
    expect(
      plugin.deserializedTypes,
      containsAll([
        const FullType(PostSyncPushRequestChangesInnerAnyOfAnyOf),
        const FullType(PostSyncPushRequestChangesInnerAnyOf10AnyOf),
        const FullType(PostSyncPushRequestChangesInnerAnyOf14AnyOf),
      ]),
    );
  });

  for (final type in ['normal', 'credentials']) {
    _codecTest('备忘录 $type 正文原始字符、扩展内容和显式空值完整往返', () {
      final raw = _envelope('memo_entry', 'upsert');
      final payload = raw['payload'] as Map<String, dynamic>;
      payload.addAll({
        'book_type': type,
        'title': ' \t真实\u0000与字面\\u0000中文😀\n ',
        'body_format': type == 'normal' ? 'delta_v1' : 'fields_v1',
        'order_key': type == 'normal' ? null : '9007199254740993',
        'body': {
          if (type == 'normal')
            'ops': [
              {
                'insert': '正文\u0000\\u0000\n',
                'attributes': {'bold': true, 'color': null},
              },
            ]
          else
            'fields': [
              {'label': '密码🔐', 'value': ' \u0000密码\\u0000 '},
            ],
          'future_content': {
            'nullable': null,
            'nested': [true, 7, 1.25, '扩展字段'],
          },
        },
      });
      final frozen = jsonEncode(raw);
      final sent = _requestChange(codec.memoChangeFromFrozen(frozen));
      expect(sent['payload'], payload);
      expect(jsonDecode(frozen), raw);
      expect(
        _requestChange(codec.memoChangeFromFrozen(jsonEncode(sent))),
        sent,
      );
    });
  }

  _codecTest('未知信封字段和时间文本保留在冻结原文，DTO 保持微秒精度', () {
    final raw = _envelope('memo_entry', 'upsert');
    raw['updated_at'] = '2026-10-16T09:02:03.123456+08:00';
    raw['future_envelope'] = {'token': '保留', 'nullable': null};
    final frozen = '\n${const JsonEncoder.withIndent('    ').convert(raw)}\n';
    final sent = _requestChange(codec.memoChangeFromFrozen(frozen));
    expect(sent['updated_at'], _time);
    expect(sent, containsPair('ledger_id', null));
    expect(sent, containsPair('day_book_id', null));
    expect((sent['payload'] as Map), containsPair('order_key', null));
    expect(jsonDecode(frozen), raw);
    expect(frozen.startsWith('\n{\n    '), isTrue);
    expect(frozen, contains('2026-10-16T09:02:03.123456+08:00'));
    expect(frozen, contains('future_envelope'));
  });

  _codecTest('健身历史删除时间与嵌套计时数据保持可发送精度', () {
    final raw = _envelope('fitness_workout', 'upsert');
    raw['deleted_at'] = _time;
    final payload = raw['payload'] as Map<String, dynamic>;
    payload.addAll({
      'status': 'in_progress',
      'run_segments': [
        {'started_at': _time, 'ended_at': null},
      ],
      'rest_timer': {
        'status': 'paused',
        'ends_at': null,
        'remaining_seconds': 30,
        'duration_seconds': 60,
        'elapsed_seconds': 30,
        'exercise_id': _entityId,
        'set_id': _mutationId,
      },
    });
    final sent = _requestChange(codec.fitnessChangeFromFrozen(jsonEncode(raw)));
    expect(sent, containsPair('deleted_at', _time));
    expect(sent['payload'], payload);
  });

  final domains = {
    '日子': (codec.dayChangeFromFrozen, 'day_book', 'memo_entry'),
    '备忘录': (codec.memoChangeFromFrozen, 'memo_book', 'fitness_space'),
    '健身': (codec.fitnessChangeFromFrozen, 'fitness_space', 'day_event'),
  };
  for (final domain in domains.entries) {
    final (decode, entity, foreignEntity) = domain.value;
    _codecTest('${domain.key} 拒绝其他业务域实体与未知实体', () {
      for (final invalid in [foreignEntity, 'unknown_entity']) {
        final raw = _envelope(entity, 'upsert')..['entity_type'] = invalid;
        expect(() => decode(jsonEncode(raw)), throwsFormatException);
      }
    });
    _codecTest('${domain.key} 拒绝无效动作、非对象载荷和损坏冻结文本', () {
      final invalidAction = _envelope(entity, 'upsert')..['action'] = 'merge';
      final invalidPayload = _envelope(entity, 'upsert')..['payload'] = [];
      for (final invalid in [
        jsonEncode(invalidAction),
        jsonEncode(invalidPayload),
        '{broken',
        'null',
        '[]',
      ]) {
        expect(
          () => decode(invalid),
          throwsA(anyOf(isA<Exception>(), isA<Error>())),
        );
      }
    });
  }
}

/// 记录实际解码目标，验证适配层沿用调用方的序列化扩展。
class _RecordingSerializerPlugin implements SerializerPlugin {
  final deserializedTypes = <FullType>[];

  /// 不改变序列化前的输入对象。
  @override
  Object? beforeSerialize(Object? object, FullType specifiedType) => object;

  /// 不改变序列化后的协议数据。
  @override
  Object? afterSerialize(Object? object, FullType specifiedType) => object;

  /// 不改变传给生成序列化器的数据。
  @override
  Object? beforeDeserialize(Object? object, FullType specifiedType) => object;

  /// 记录成功解码目标并保持结果原样返回。
  @override
  Object? afterDeserialize(Object? object, FullType specifiedType) {
    try {
      deserializedTypes.add(specifiedType);
      return object;
    } catch (error, stack) {
      Error.throwWithStackTrace(error, stack);
    }
  }
}

/// 将断言错误和完整堆栈交给测试运行器记录，保留具体失败用例。
void _codecTest(String description, void Function() body) {
  test(description, () {
    try {
      body();
    } catch (error, stack) {
      Error.throwWithStackTrace(
        TestFailure('同步协议适配测试失败：$description\n$error'),
        stack,
      );
    }
  });
}

/// 构造符合服务端字段约束的冻结信封，隔离范围由各业务域明确指定。
Map<String, dynamic> _envelope(String entity, String action) {
  try {
    final day = entity.startsWith('day_');
    final memo = entity.startsWith('memo_');
    return {
      'mutation_id': _mutationId,
      'entity_type': entity,
      'entity_id': entity.endsWith('_book') || entity == 'fitness_space'
          ? _bookId
          : _entityId,
      'ledger_id': null,
      'day_book_id': day ? _bookId : null,
      if (!day) 'memo_book_id': memo ? _bookId : null,
      if (!day && !memo) 'fitness_space_id': _bookId,
      'sync_id': _syncId,
      'base_revision': 17,
      'action': action,
      'updated_at': _time,
      'payload': action == 'upsert'
          ? _upsertPayload(entity)
          : {
              if (entity.endsWith('_book') || entity == 'fitness_space')
                'expected_full_cursor': '9007199254740993',
            },
    };
  } catch (error, stack) {
    Error.throwWithStackTrace(error, stack);
  }
}

/// 提供各实体的合法协议样本，包含真实业务需要的空值、列表及嵌套字段。
Map<String, dynamic> _upsertPayload(String entity) {
  try {
    return switch (entity) {
      'day_book' => {'name': '纪念日', 'created_at': _time},
      'day_event' => {
        'name': '生日',
        'category': 'birthday',
        'countdown_mode': null,
        'interval_days': null,
        'repeat_type': 'yearly',
        'statistic_type': 'year',
        'event': {
          'calendar_type': 'lunar',
          'original_year': 2000,
          'original_month': 8,
          'original_day': 15,
          'is_leap_month': false,
          'solar_date': '2000-09-12',
        },
        'start': null,
        'end': null,
        'created_at': _time,
      },
      'memo_book' => {
        'name': '备忘录',
        'type': 'normal',
        'created_at': _time,
        'updated_at': _time,
        'restore': true,
        'expected_full_cursor': '9007199254740993',
      },
      'memo_entry' => {
        'book_type': 'normal',
        'title': '备忘录记录',
        'body_format': 'delta_v1',
        'body': {
          'ops': [
            {'insert': '正文\n'},
          ],
        },
        'order_key': null,
        'created_at': _time,
        'updated_at': _time,
      },
      'fitness_template' => {
        'name': '训练模板',
        'exercises': [
          {
            'id': _entityId,
            'exercise_id': '0025',
            'rest_seconds': 60,
            'warmup_rest_seconds': null,
            'sets': [],
          },
        ],
        'catalog_origin': {
          'source': 'official',
          'item_id': _entityId,
          'revision': 2,
        },
        'created_at': _time,
        'updated_at': _time,
      },
      'fitness_plan' => {
        'name': '训练计划',
        'start_date': null,
        'status': 'closed',
        'cycle_days': 1,
        'days': [
          {'day_index': 0, 'slot': null},
        ],
        'generation_state': {
          'next_cycle_start_date': null,
          'next_cycle_index': 0,
          'generated_cycles': [],
        },
        'pending_schedule': null,
        'created_at': _time,
        'updated_at': _time,
      },
      'fitness_workout' => {
        'name': '训练记录',
        'scheduled_date': '2026-10-16',
        'source_kind': 'blank',
        'source_plan_id': null,
        'source_plan_name': null,
        'source_template_id': null,
        'occurrence_key': null,
        'exercises': [],
        'status': 'scheduled',
        'run_segments': [],
        'rest_timer': null,
        'created_at': _time,
        'updated_at': _time,
      },
      'fitness_preferences' => {
        'custom_exercises': [],
        'default_rest_seconds': 60,
        'default_warmup_rest_seconds': 30,
        'exercise_rest_settings': {
          '0025': {'rest_seconds': 90, 'warmup_rest_seconds': 45},
        },
        'sound_enabled': true,
        'vibration_enabled': false,
        'pinned_exercise_ids': ['0025'],
        'exercise_weight_modes': {'0025': true},
        'created_at': _time,
        'updated_at': _time,
      },
      'fitness_space' => {
        'name': '健身空间',
        'created_at': _time,
        'updated_at': _time,
        'restore': true,
        'expected_full_cursor': '9007199254740993',
      },
      _ => throw StateError('测试样本实体无效：$entity'),
    };
  } catch (error, stack) {
    Error.throwWithStackTrace(error, stack);
  }
}

/// 获取实体内部联合，仅用于断言协议动作对应唯一生成变体。
AnyOf _innerUnion(PostSyncPushRequestChangesInner change) {
  try {
    final entity = change.anyOf.values.values.single;
    return switch (entity) {
      PostSyncPushRequestChangesInnerAnyOf value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf1 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf9 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf10 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf11 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf12 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf13 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf14 value => value.anyOf,
      PostSyncPushRequestChangesInnerAnyOf15 value => value.anyOf,
      _ => throw StateError('同步请求包含非预期实体联合：${entity.runtimeType}'),
    };
  } catch (error, stack) {
    Error.throwWithStackTrace(error, stack);
  }
}

/// 经完整 push 请求和 JSON 编解码提取变更，验证实际发送边界。
Map<String, dynamic> _requestChange(PostSyncPushRequestChangesInner change) {
  try {
    final request = PostSyncPushRequest(
      (builder) => builder
        ..deviceId = _mutationId
        ..changes = ListBuilder([change]),
    );
    final encoded = jsonEncode(
      apiSerializers.serializeWith(PostSyncPushRequest.serializer, request),
    );
    final wire = jsonDecode(encoded) as Map<String, dynamic>;
    expect(wire['device_id'], _mutationId);
    return (wire['changes'] as List).single as Map<String, dynamic>;
  } catch (error, stack) {
    Error.throwWithStackTrace(error, stack);
  }
}
