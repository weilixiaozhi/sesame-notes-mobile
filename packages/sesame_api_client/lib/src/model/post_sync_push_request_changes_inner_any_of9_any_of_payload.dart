//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of9_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload
///
/// Properties:
/// * [name]
/// * [createdAt]
/// * [updatedAt]
/// * [restore]
/// * [expectedFullCursor]
/// * [type]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder> {
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

  @BuiltValueField(wireName: r'type')
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum get type;
  // enum typeEnum {  normal,  credentials,  };

  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload object, {
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
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder result,
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
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'normal')
  static const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
      normal =
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_normal;
  @BuiltValueEnumConst(wireName: r'credentials')
  static const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum
      credentials =
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum_credentials;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfPayloadTypeEnumValueOf(name);
}
