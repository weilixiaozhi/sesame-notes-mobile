//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_catalog200_response_taxonomies_body_parts_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_catalog200_response_taxonomies.g.dart';

/// GetFitnessCatalog200ResponseTaxonomies
///
/// Properties:
/// * [bodyParts]
/// * [equipment]
@BuiltValue()
abstract class GetFitnessCatalog200ResponseTaxonomies
    implements
        Built<GetFitnessCatalog200ResponseTaxonomies,
            GetFitnessCatalog200ResponseTaxonomiesBuilder> {
  @BuiltValueField(wireName: r'body_parts')
  BuiltList<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner> get bodyParts;

  @BuiltValueField(wireName: r'equipment')
  BuiltList<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner> get equipment;

  GetFitnessCatalog200ResponseTaxonomies._();

  factory GetFitnessCatalog200ResponseTaxonomies(
          [void updates(GetFitnessCatalog200ResponseTaxonomiesBuilder b)]) =
      _$GetFitnessCatalog200ResponseTaxonomies;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetFitnessCatalog200ResponseTaxonomiesBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessCatalog200ResponseTaxonomies> get serializer =>
      _$GetFitnessCatalog200ResponseTaxonomiesSerializer();
}

class _$GetFitnessCatalog200ResponseTaxonomiesSerializer
    implements PrimitiveSerializer<GetFitnessCatalog200ResponseTaxonomies> {
  @override
  final Iterable<Type> types = const [
    GetFitnessCatalog200ResponseTaxonomies,
    _$GetFitnessCatalog200ResponseTaxonomies
  ];

  @override
  final String wireName = r'GetFitnessCatalog200ResponseTaxonomies';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessCatalog200ResponseTaxonomies object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body_parts';
    yield serializers.serialize(
      object.bodyParts,
      specifiedType: const FullType(BuiltList,
          [FullType(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner)]),
    );
    yield r'equipment';
    yield serializers.serialize(
      object.equipment,
      specifiedType: const FullType(BuiltList,
          [FullType(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessCatalog200ResponseTaxonomies object, {
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
    required GetFitnessCatalog200ResponseTaxonomiesBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body_parts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner)
            ]),
          ) as BuiltList<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>;
          result.bodyParts.replace(valueDes);
          break;
        case r'equipment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner)
            ]),
          ) as BuiltList<GetFitnessCatalog200ResponseTaxonomiesBodyPartsInner>;
          result.equipment.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessCatalog200ResponseTaxonomies deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessCatalog200ResponseTaxonomiesBuilder();
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
