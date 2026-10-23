//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
///
/// Properties:
/// * [name]
/// * [createdAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOfAnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOfAnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOfAnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOfAnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOfAnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOfAnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder();
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
