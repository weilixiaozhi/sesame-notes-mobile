//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state_occurrences_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState
///
/// Properties:
/// * [lastGeneratedDate]
/// * [deletedAt]
/// * [occurrences]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder> {
  @BuiltValueField(wireName: r'last_generated_date')
  DateTime? get lastGeneratedDate;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'occurrences')
  BuiltList<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>
      get occurrences;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState._();

  factory PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState,
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'last_generated_date';
    yield object.lastGeneratedDate == null
        ? null
        : serializers.serialize(
            object.lastGeneratedDate,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'deleted_at';
    yield object.deletedAt == null
        ? null
        : serializers.serialize(
            object.deletedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'occurrences';
    yield serializers.serialize(
      object.occurrences,
      specifiedType: const FullType(BuiltList, [
        FullType(
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState object, {
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
    required PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'last_generated_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastGeneratedDate = valueDes;
          break;
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'occurrences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner)
            ]),
          ) as BuiltList<
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>;
          result.occurrences.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder();
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
