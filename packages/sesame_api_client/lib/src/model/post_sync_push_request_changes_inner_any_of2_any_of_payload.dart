//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of2_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
///
/// Properties:
/// * [name]
/// * [kind]
/// * [level]
/// * [sortOrder]
/// * [icon]
/// * [parentId]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum get kind;
  // enum kindEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'level')
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum),
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
    PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum;
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
  PostSyncPushRequestChangesInnerAnyOf2AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
      expense =
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
      income =
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum
      transfer =
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum_transfer;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadKindEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum n1 =
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum n2 =
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum_n2;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf2AnyOfPayloadLevelEnumValueOf(name);
}
