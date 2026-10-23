//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of3_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf3Payload
///
/// Properties:
/// * [archived]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf3Payload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf3Payload,
            PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder> {
  @BuiltValueField(wireName: r'archived')
  bool get archived;

  PostSyncPushRequestChangesInnerAnyOf3Payload._();

  factory PostSyncPushRequestChangesInnerAnyOf3Payload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf3Payload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf3Payload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf3PayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf3PayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf3Payload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf3Payload,
    _$PostSyncPushRequestChangesInnerAnyOf3Payload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf3Payload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3Payload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'archived';
    yield serializers.serialize(
      object.archived,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3Payload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'archived':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.archived = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3Payload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder();
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
