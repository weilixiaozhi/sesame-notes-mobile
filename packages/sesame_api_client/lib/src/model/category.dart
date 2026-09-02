//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category.g.dart';

/// Category
///
/// Properties:
/// * [id]
/// * [name]
/// * [kind]
/// * [level]
/// * [sortOrder]
/// * [icon]
/// * [parentId]
/// * [updatedAt]
@BuiltValue()
abstract class Category implements Built<Category, CategoryBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  CategoryKindEnum get kind;
  // enum kindEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'level')
  CategoryLevelEnum get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  Category._();

  factory Category([void updates(CategoryBuilder b)]) = _$Category;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CategoryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Category> get serializer => _$CategorySerializer();
}

class _$CategorySerializer implements PrimitiveSerializer<Category> {
  @override
  final Iterable<Type> types = const [Category, _$Category];

  @override
  final String wireName = r'Category';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Category object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(CategoryKindEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(CategoryLevelEnum),
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
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    Category object, {
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
    required CategoryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType: const FullType(CategoryKindEnum),
          ) as CategoryKindEnum;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CategoryLevelEnum),
          ) as CategoryLevelEnum;
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
  Category deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CategoryBuilder();
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

class CategoryKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const CategoryKindEnum expense = _$categoryKindEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const CategoryKindEnum income = _$categoryKindEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const CategoryKindEnum transfer = _$categoryKindEnum_transfer;

  static Serializer<CategoryKindEnum> get serializer =>
      _$categoryKindEnumSerializer;

  const CategoryKindEnum._(String name) : super(name);

  static BuiltSet<CategoryKindEnum> get values => _$categoryKindEnumValues;
  static CategoryKindEnum valueOf(String name) =>
      _$categoryKindEnumValueOf(name);
}

class CategoryLevelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const CategoryLevelEnum n1 = _$categoryLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const CategoryLevelEnum n2 = _$categoryLevelEnum_n2;

  static Serializer<CategoryLevelEnum> get serializer =>
      _$categoryLevelEnumSerializer;

  const CategoryLevelEnum._(String name) : super(name);

  static BuiltSet<CategoryLevelEnum> get values => _$categoryLevelEnumValues;
  static CategoryLevelEnum valueOf(String name) =>
      _$categoryLevelEnumValueOf(name);
}
