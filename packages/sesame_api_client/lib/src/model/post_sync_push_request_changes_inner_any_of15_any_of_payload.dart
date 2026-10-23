//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of15_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload
///
/// Properties:
/// * [name]
/// * [createdAt]
/// * [updatedAt]
/// * [restore]
/// * [expectedFullCursor]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'restore')
  bool? get restore;

  @BuiltValueField(wireName: r'expected_full_cursor')
  String? get expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload object, {
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
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.restore != null) {
      yield r'restore';
      yield serializers.serialize(
        object.restore,
        specifiedType: const FullType(bool),
      );
    }
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
    PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder result,
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'restore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.restore = valueDes;
          break;
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
  PostSyncPushRequestChangesInnerAnyOf15AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf15AnyOfPayloadBuilder();
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
