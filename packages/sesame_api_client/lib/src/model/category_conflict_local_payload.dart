//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category_conflict_local_payload.g.dart';

/// CategoryConflictLocalPayload
///
/// Properties:
/// * [name]
/// * [kind]
/// * [level]
/// * [sortOrder]
/// * [icon]
/// * [parentId]
@BuiltValue()
abstract class CategoryConflictLocalPayload
    implements
        Built<CategoryConflictLocalPayload,
            CategoryConflictLocalPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'kind')
  CategoryConflictLocalPayloadKindEnum get kind;
  // enum kindEnum {  expense,  };

  @BuiltValueField(wireName: r'level')
  CategoryConflictLocalPayloadLevelEnum get level;
  // enum levelEnum {  1,  2,  };

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'icon')
  String? get icon;

  @BuiltValueField(wireName: r'parent_id')
  String? get parentId;

  CategoryConflictLocalPayload._();

  factory CategoryConflictLocalPayload(
          [void updates(CategoryConflictLocalPayloadBuilder b)]) =
      _$CategoryConflictLocalPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CategoryConflictLocalPayloadBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CategoryConflictLocalPayload> get serializer =>
      _$CategoryConflictLocalPayloadSerializer();
}

class _$CategoryConflictLocalPayloadSerializer
    implements PrimitiveSerializer<CategoryConflictLocalPayload> {
  @override
  final Iterable<Type> types = const [
    CategoryConflictLocalPayload,
    _$CategoryConflictLocalPayload
  ];

  @override
  final String wireName = r'CategoryConflictLocalPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CategoryConflictLocalPayload object, {
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
      specifiedType: const FullType(CategoryConflictLocalPayloadKindEnum),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(CategoryConflictLocalPayloadLevelEnum),
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
    CategoryConflictLocalPayload object, {
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
    required CategoryConflictLocalPayloadBuilder result,
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
            specifiedType: const FullType(CategoryConflictLocalPayloadKindEnum),
          ) as CategoryConflictLocalPayloadKindEnum;
          result.kind = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(CategoryConflictLocalPayloadLevelEnum),
          ) as CategoryConflictLocalPayloadLevelEnum;
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
  CategoryConflictLocalPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CategoryConflictLocalPayloadBuilder();
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

class CategoryConflictLocalPayloadKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const CategoryConflictLocalPayloadKindEnum expense =
      _$categoryConflictLocalPayloadKindEnum_expense;

  static Serializer<CategoryConflictLocalPayloadKindEnum> get serializer =>
      _$categoryConflictLocalPayloadKindEnumSerializer;

  const CategoryConflictLocalPayloadKindEnum._(String name) : super(name);

  static BuiltSet<CategoryConflictLocalPayloadKindEnum> get values =>
      _$categoryConflictLocalPayloadKindEnumValues;
  static CategoryConflictLocalPayloadKindEnum valueOf(String name) =>
      _$categoryConflictLocalPayloadKindEnumValueOf(name);
}

class CategoryConflictLocalPayloadLevelEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'1')
  static const CategoryConflictLocalPayloadLevelEnum n1 =
      _$categoryConflictLocalPayloadLevelEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const CategoryConflictLocalPayloadLevelEnum n2 =
      _$categoryConflictLocalPayloadLevelEnum_n2;

  static Serializer<CategoryConflictLocalPayloadLevelEnum> get serializer =>
      _$categoryConflictLocalPayloadLevelEnumSerializer;

  const CategoryConflictLocalPayloadLevelEnum._(String name) : super(name);

  static BuiltSet<CategoryConflictLocalPayloadLevelEnum> get values =>
      _$categoryConflictLocalPayloadLevelEnumValues;
  static CategoryConflictLocalPayloadLevelEnum valueOf(String name) =>
      _$categoryConflictLocalPayloadLevelEnumValueOf(name);
}
