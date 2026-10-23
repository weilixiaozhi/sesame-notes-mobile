//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of5_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
///
/// Properties:
/// * [baseToken]
/// * [name]
/// * [kind]
/// * [level]
/// * [sortOrder]
/// * [icon]
/// * [parentId]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'base_token')
  String? get baseToken;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum get kind;
  // enum kindEnum {  expense,  };

  @BuiltValueField(wireName: r'level')
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.baseToken != null) {
      yield r'base_token';
      yield serializers.serialize(
        object.baseToken,
        specifiedType: const FullType(String),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum),
    );
    yield r'sort_order';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'icon';
    yield object.icon == null
        ? null
        : serializers.serialize(
            object.icon,
            specifiedType: const FullType.nullable(String),
          );
    yield r'parent_id';
    yield object.parentId == null
        ? null
        : serializers.serialize(
            object.parentId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'base_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.baseToken = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum;
          result.level = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'icon':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.icon = valueDes;
          break;
        case r'parent_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.parentId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf5AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum
      expense =
      _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum_expense;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadKindEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum n1 =
      _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum n2 =
      _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum_n2;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf5AnyOfPayloadLevelEnumValueOf(name);
}
