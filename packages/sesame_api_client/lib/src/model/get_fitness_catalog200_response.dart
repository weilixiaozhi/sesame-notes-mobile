//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_catalog200_response_exercises_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_catalog200_response_taxonomies.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_catalog200_response.g.dart';

/// GetFitnessCatalog200Response
///
/// Properties:
/// * [schemaVersion]
/// * [contentVersion]
/// * [exercises]
/// * [taxonomies]
@BuiltValue()
abstract class GetFitnessCatalog200Response
    implements
        Built<GetFitnessCatalog200Response,
            GetFitnessCatalog200ResponseBuilder> {
  @BuiltValueField(wireName: r'schema_version')
  int get schemaVersion;

  @BuiltValueField(wireName: r'content_version')
  int get contentVersion;

  @BuiltValueField(wireName: r'exercises')
  BuiltList<GetFitnessCatalog200ResponseExercisesInner> get exercises;

  @BuiltValueField(wireName: r'taxonomies')
  GetFitnessCatalog200ResponseTaxonomies? get taxonomies;

  GetFitnessCatalog200Response._();

  factory GetFitnessCatalog200Response(
          [void updates(GetFitnessCatalog200ResponseBuilder b)]) =
      _$GetFitnessCatalog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetFitnessCatalog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessCatalog200Response> get serializer =>
      _$GetFitnessCatalog200ResponseSerializer();
}

class _$GetFitnessCatalog200ResponseSerializer
    implements PrimitiveSerializer<GetFitnessCatalog200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessCatalog200Response,
    _$GetFitnessCatalog200Response
  ];

  @override
  final String wireName = r'GetFitnessCatalog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'schema_version';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType: const FullType(int),
    );
    yield r'content_version';
    yield serializers.serialize(
      object.contentVersion,
      specifiedType: const FullType(int),
    );
    yield r'exercises';
    yield serializers.serialize(
      object.exercises,
      specifiedType: const FullType(
          BuiltList, [FullType(GetFitnessCatalog200ResponseExercisesInner)]),
    );
    if (object.taxonomies != null) {
      yield r'taxonomies';
      yield serializers.serialize(
        object.taxonomies,
        specifiedType: const FullType(GetFitnessCatalog200ResponseTaxonomies),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessCatalog200Response object, {
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
    required GetFitnessCatalog200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'schema_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.schemaVersion = valueDes;
          break;
        case r'content_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.contentVersion = valueDes;
          break;
        case r'exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetFitnessCatalog200ResponseExercisesInner)]),
          ) as BuiltList<GetFitnessCatalog200ResponseExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        case r'taxonomies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(GetFitnessCatalog200ResponseTaxonomies),
          ) as GetFitnessCatalog200ResponseTaxonomies?;
          if (valueDes == null) continue;
          result.taxonomies.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessCatalog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessCatalog200ResponseBuilder();
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
