//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state_occurrences_inner_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state_occurrences_inner.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
///
/// Properties:
/// * [id]
/// * [deletedAt]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
    implements
        Built<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
      get payload;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner._();

  factory PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner,
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'deleted_at';
    yield object.deletedAt == null
        ? null
        : serializers.serialize(
            object.deletedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
        object, {
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
    required PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder
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
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerBuilder();
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
