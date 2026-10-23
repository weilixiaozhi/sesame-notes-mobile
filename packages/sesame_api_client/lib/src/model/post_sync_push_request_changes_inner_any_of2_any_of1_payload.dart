//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of2_any_of1_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload
///
/// Properties:
/// * [expectedFullCursor]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload,
            PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder> {
  @BuiltValueField(wireName: r'expected_full_cursor')
  String? get expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload._();

  factory PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload,
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.expectedFullCursor != null) {
      yield r'expected_full_cursor';
      yield serializers.serialize(
        object.expectedFullCursor,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'expected_full_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
  PostSyncPushRequestChangesInnerAnyOf2AnyOf1Payload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf2AnyOf1PayloadBuilder();
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
