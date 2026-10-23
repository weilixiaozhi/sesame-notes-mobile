//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_catalog_origin.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
///
/// Properties:
/// * [source_]
/// * [itemId]
/// * [revision]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder> {
  @BuiltValueField(wireName: r'source')
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
      get source_;
  // enum source_Enum {  official,  };

  @BuiltValueField(wireName: r'item_id')
  String get itemId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin._();

  factory GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin,
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum),
    );
    yield r'item_id';
    yield serializers.serialize(
      object.itemId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
        object, {
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
    required GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum),
          ) as GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum;
          result.source_ = valueDes;
          break;
        case r'item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.itemId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'official')
  static const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
      official =
      _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnum_official;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSource_Enum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginSourceEnumValueOf(
              name);
}
