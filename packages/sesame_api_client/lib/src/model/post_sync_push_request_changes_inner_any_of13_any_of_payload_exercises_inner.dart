//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of13_any_of_payload_exercises_inner_sets_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of13_any_of_payload_exercises_inner.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner
///
/// Properties:
/// * [id]
/// * [exerciseId]
/// * [restSeconds]
/// * [warmupRestSeconds]
/// * [sets]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'exercise_id')
  String get exerciseId;

  @BuiltValueField(wireName: r'rest_seconds')
  int get restSeconds;

  @BuiltValueField(wireName: r'warmup_rest_seconds')
  int? get warmupRestSeconds;

  @BuiltValueField(wireName: r'sets')
  BuiltList<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner>
      get sets;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner._();

  factory PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner,
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'exercise_id';
    yield serializers.serialize(
      object.exerciseId,
      specifiedType: const FullType(String),
    );
    yield r'rest_seconds';
    yield serializers.serialize(
      object.restSeconds,
      specifiedType: const FullType(int),
    );
    yield r'warmup_rest_seconds';
    yield object.warmupRestSeconds == null
        ? null
        : serializers.serialize(
            object.warmupRestSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'sets';
    yield serializers.serialize(
      object.sets,
      specifiedType: const FullType(BuiltList, [
        FullType(
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'exercise_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exerciseId = valueDes;
          break;
        case r'rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restSeconds = valueDes;
          break;
        case r'warmup_rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warmupRestSeconds = valueDes;
          break;
        case r'sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner)
            ]),
          ) as BuiltList<
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerSetsInner>;
          result.sets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInnerBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
