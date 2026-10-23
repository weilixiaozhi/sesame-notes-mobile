//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of10_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload
///
/// Properties:
/// * [bookType]
/// * [title]
/// * [bodyFormat]
/// * [body]
/// * [orderKey]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'book_type')
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum get bookType;
  // enum bookTypeEnum {  normal,  credentials,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body_format')
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum?
      get bodyFormat;
  // enum bodyFormatEnum {  delta_v1,  fields_v1,  };

  @BuiltValueField(wireName: r'body')
  BuiltMap<String, JsonObject?>? get body;

  @BuiltValueField(wireName: r'order_key')
  String? get orderKey;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'book_type';
    yield serializers.serialize(
      object.bookType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'body_format';
    yield object.bodyFormat == null
        ? null
        : serializers.serialize(
            object.bodyFormat,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum),
          );
    yield r'body';
    yield object.body == null
        ? null
        : serializers.serialize(
            object.body,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
    yield r'order_key';
    yield object.orderKey == null
        ? null
        : serializers.serialize(
            object.orderKey,
            specifiedType: const FullType.nullable(String),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'book_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum;
          result.bookType = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'body_format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum?;
          if (valueDes == null) continue;
          result.bodyFormat = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.body.replace(valueDes);
          break;
        case r'order_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.orderKey = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf10AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'normal')
  static const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
      normal =
      _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_normal;
  @BuiltValueEnumConst(wireName: r'credentials')
  static const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum
      credentials =
      _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum_credentials;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBookTypeEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delta_v1')
  static const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
      deltaV1 =
      _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_deltaV1;
  @BuiltValueEnumConst(wireName: r'fields_v1')
  static const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum
      fieldsV1 =
      _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum_fieldsV1;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf10AnyOfPayloadBodyFormatEnumValueOf(
          name);
}
