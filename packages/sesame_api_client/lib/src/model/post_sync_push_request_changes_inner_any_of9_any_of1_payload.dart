//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of9_any_of1_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload
///
/// Properties:
/// * [expectedFullCursor]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload,
            PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder> {
  @BuiltValueField(wireName: r'expected_full_cursor')
  String get expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload._();

  factory PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload,
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'expected_full_cursor';
    yield serializers.serialize(
      object.expectedFullCursor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_full_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedFullCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder();
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
