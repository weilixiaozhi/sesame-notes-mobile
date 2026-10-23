//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of_any_of1_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload
///
/// Properties:
/// * [expectedFullCursor] - 删除日子本时需提供完整同步返回的 server_cursor，用于确认本内内容未变化。
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload,
            PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder> {
  /// 删除日子本时需提供完整同步返回的 server_cursor，用于确认本内内容未变化。
  @BuiltValueField(wireName: r'expected_full_cursor')
  String? get expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload._();

  factory PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload,
    _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload object, {
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
    PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload object, {
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
    required PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder result,
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
  PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOfAnyOf1PayloadBuilder();
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
