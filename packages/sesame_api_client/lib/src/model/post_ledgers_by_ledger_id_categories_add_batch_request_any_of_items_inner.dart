//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_add_batch_request_any_of_items_inner.g.dart';

/// PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner
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
abstract class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner
    implements
        Built<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner,
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
      get kind;
  // enum kindEnum {  expense,  };

  @BuiltValueField(wireName: r'level')
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
      get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner._();

  factory PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner(
          [void updates(
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder
                  b)]) =
      _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerSerializer();
}

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner,
    _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner object, {
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
      specifiedType: const FullType(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum),
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
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner object, {
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
    required PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder
        result,
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
            specifiedType: const FullType(
                PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum),
          ) as PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum),
          ) as PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum;
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
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerBuilder();
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

class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
      expense =
      _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum_expense;

  static Serializer<
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum>
      get serializer =>
          _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumSerializer;

  const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum>
      get values =>
          _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumValues;
  static PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnum
      valueOf(String name) =>
          _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerKindEnumValueOf(
              name);
}

class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
      n1 =
      _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
      n2 =
      _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum_n2;

  static Serializer<
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum>
      get serializer =>
          _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumSerializer;

  const PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum>
      get values =>
          _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumValues;
  static PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnum
      valueOf(String name) =>
          _$postLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInnerLevelEnumValueOf(
              name);
}
