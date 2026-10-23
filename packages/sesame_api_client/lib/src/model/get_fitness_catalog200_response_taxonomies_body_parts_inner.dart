//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/list_official_fitness_taxonomies200_response_items_inner_name.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_catalog200_response_taxonomies_body_parts_inner.g.dart';

/// GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [isDeleted]
@BuiltValue()
abstract class GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner
    implements
        Built<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner,
            GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  ListOfficialFitnessTaxonomies200ResponseItemsInnerName get name;

  @BuiltValueField(wireName: r'is_deleted')
  bool get isDeleted;

  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner._();

  factory GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner(
          [void updates(
              GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder b)]) =
      _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>
      get serializer =>
          _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerSerializer();
}

class _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner,
    _$GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner
  ];

  @override
  final String wireName =
      r'GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner object, {
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
    required GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessCatalog200ResponseTaxonomiesBodyPartsInnerBuilder();
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
