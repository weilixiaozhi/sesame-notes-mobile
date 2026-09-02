//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_request.g.dart';

/// PostLedgersByLedgerIdCategoriesRequest
///
/// Properties:
/// * [id]
/// * [name]
/// * [kind]
/// * [level]
/// * [sortOrder]
/// * [icon]
/// * [parentId]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesRequest
    implements
        Built<PostLedgersByLedgerIdCategoriesRequest,
            PostLedgersByLedgerIdCategoriesRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  PostLedgersByLedgerIdCategoriesRequestKindEnum get kind;
  // enum kindEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'level')
  PostLedgersByLedgerIdCategoriesRequestLevelEnum get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  PostLedgersByLedgerIdCategoriesRequest._();

  factory PostLedgersByLedgerIdCategoriesRequest(
          [void updates(PostLedgersByLedgerIdCategoriesRequestBuilder b)]) =
      _$PostLedgersByLedgerIdCategoriesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdCategoriesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesRequest> get serializer =>
      _$PostLedgersByLedgerIdCategoriesRequestSerializer();
}

class _$PostLedgersByLedgerIdCategoriesRequestSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdCategoriesRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesRequest,
    _$PostLedgersByLedgerIdCategoriesRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdCategoriesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
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
      specifiedType:
          const FullType(PostLedgersByLedgerIdCategoriesRequestKindEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType:
          const FullType(PostLedgersByLedgerIdCategoriesRequestLevelEnum),
    );
    if (object.sortOrder != null) {
      yield r'sort_order';
      yield serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(int),
      );
    }
    if (object.icon != null) {
      yield r'icon';
      yield serializers.serialize(
        object.icon,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.parentId != null) {
      yield r'parent_id';
      yield serializers.serialize(
        object.parentId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRequest object, {
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
    required PostLedgersByLedgerIdCategoriesRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
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
            specifiedType:
                const FullType(PostLedgersByLedgerIdCategoriesRequestKindEnum),
          ) as PostLedgersByLedgerIdCategoriesRequestKindEnum;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostLedgersByLedgerIdCategoriesRequestLevelEnum),
          ) as PostLedgersByLedgerIdCategoriesRequestLevelEnum;
          result.level = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
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
  PostLedgersByLedgerIdCategoriesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdCategoriesRequestBuilder();
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

class PostLedgersByLedgerIdCategoriesRequestKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostLedgersByLedgerIdCategoriesRequestKindEnum expense =
      _$postLedgersByLedgerIdCategoriesRequestKindEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PostLedgersByLedgerIdCategoriesRequestKindEnum income =
      _$postLedgersByLedgerIdCategoriesRequestKindEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PostLedgersByLedgerIdCategoriesRequestKindEnum transfer =
      _$postLedgersByLedgerIdCategoriesRequestKindEnum_transfer;

  static Serializer<PostLedgersByLedgerIdCategoriesRequestKindEnum>
      get serializer =>
          _$postLedgersByLedgerIdCategoriesRequestKindEnumSerializer;

  const PostLedgersByLedgerIdCategoriesRequestKindEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdCategoriesRequestKindEnum> get values =>
      _$postLedgersByLedgerIdCategoriesRequestKindEnumValues;
  static PostLedgersByLedgerIdCategoriesRequestKindEnum valueOf(String name) =>
      _$postLedgersByLedgerIdCategoriesRequestKindEnumValueOf(name);
}

class PostLedgersByLedgerIdCategoriesRequestLevelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const PostLedgersByLedgerIdCategoriesRequestLevelEnum n1 =
      _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostLedgersByLedgerIdCategoriesRequestLevelEnum n2 =
      _$postLedgersByLedgerIdCategoriesRequestLevelEnum_n2;

  static Serializer<PostLedgersByLedgerIdCategoriesRequestLevelEnum>
      get serializer =>
          _$postLedgersByLedgerIdCategoriesRequestLevelEnumSerializer;

  const PostLedgersByLedgerIdCategoriesRequestLevelEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdCategoriesRequestLevelEnum> get values =>
      _$postLedgersByLedgerIdCategoriesRequestLevelEnumValues;
  static PostLedgersByLedgerIdCategoriesRequestLevelEnum valueOf(String name) =>
      _$postLedgersByLedgerIdCategoriesRequestLevelEnumValueOf(name);
}
