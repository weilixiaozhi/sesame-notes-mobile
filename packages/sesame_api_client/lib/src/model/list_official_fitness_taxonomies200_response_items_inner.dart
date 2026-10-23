//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/list_official_fitness_taxonomies200_response_items_inner_name.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_fitness_taxonomies200_response_items_inner.g.dart';

/// ListOfficialFitnessTaxonomies200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [isDeleted]
/// * [kind]
/// * [sortOrder]
/// * [version]
/// * [exerciseCount]
/// * [templateCount]
@BuiltValue()
abstract class ListOfficialFitnessTaxonomies200ResponseItemsInner
    implements
        Built<ListOfficialFitnessTaxonomies200ResponseItemsInner,
            ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  ListOfficialFitnessTaxonomies200ResponseItemsInnerName get name;

  @BuiltValueField(wireName: r'is_deleted')
  bool get isDeleted;

  @BuiltValueField(wireName: r'kind')
  ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum get kind;
  // enum kindEnum {  body_part,  equipment,  };

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'exercise_count')
  int get exerciseCount;

  @BuiltValueField(wireName: r'template_count')
  int get templateCount;

  ListOfficialFitnessTaxonomies200ResponseItemsInner._();

  factory ListOfficialFitnessTaxonomies200ResponseItemsInner(
          [void updates(
              ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder b)]) =
      _$ListOfficialFitnessTaxonomies200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialFitnessTaxonomies200ResponseItemsInner>
      get serializer =>
          _$ListOfficialFitnessTaxonomies200ResponseItemsInnerSerializer();
}

class _$ListOfficialFitnessTaxonomies200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<
            ListOfficialFitnessTaxonomies200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    ListOfficialFitnessTaxonomies200ResponseItemsInner,
    _$ListOfficialFitnessTaxonomies200ResponseItemsInner
  ];

  @override
  final String wireName = r'ListOfficialFitnessTaxonomies200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialFitnessTaxonomies200ResponseItemsInner object, {
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
      specifiedType: const FullType(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerName),
    );
    yield r'is_deleted';
    yield serializers.serialize(
      object.isDeleted,
      specifiedType: const FullType(bool),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum),
    );
    yield r'sort_order';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'exercise_count';
    yield serializers.serialize(
      object.exerciseCount,
      specifiedType: const FullType(int),
    );
    yield r'template_count';
    yield serializers.serialize(
      object.templateCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialFitnessTaxonomies200ResponseItemsInner object, {
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
    required ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder result,
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
            specifiedType: const FullType(
                ListOfficialFitnessTaxonomies200ResponseItemsInnerName),
          ) as ListOfficialFitnessTaxonomies200ResponseItemsInnerName;
          result.name.replace(valueDes);
          break;
        case r'is_deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDeleted = valueDes;
          break;
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum),
          ) as ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'exercise_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.exerciseCount = valueDes;
          break;
        case r'template_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.templateCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialFitnessTaxonomies200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialFitnessTaxonomies200ResponseItemsInnerBuilder();
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

class ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'body_part')
  static const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
      bodyPart =
      _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_bodyPart;
  @BuiltValueEnumConst(wireName: r'equipment')
  static const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum
      equipment =
      _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum_equipment;

  static Serializer<ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum>
      get serializer =>
          _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumSerializer;

  const ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum._(
      String name)
      : super(name);

  static BuiltSet<ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum>
      get values =>
          _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumValues;
  static ListOfficialFitnessTaxonomies200ResponseItemsInnerKindEnum valueOf(
          String name) =>
      _$listOfficialFitnessTaxonomies200ResponseItemsInnerKindEnumValueOf(name);
}
