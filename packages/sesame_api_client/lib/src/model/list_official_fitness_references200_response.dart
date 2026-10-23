//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/list_official_fitness_references200_response_exercises_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_fitness_references200_response.g.dart';

/// ListOfficialFitnessReferences200Response
///
/// Properties:
/// * [exercises]
/// * [templates]
@BuiltValue()
abstract class ListOfficialFitnessReferences200Response
    implements
        Built<ListOfficialFitnessReferences200Response,
            ListOfficialFitnessReferences200ResponseBuilder> {
  @BuiltValueField(wireName: r'exercises')
  BuiltList<ListOfficialFitnessReferences200ResponseExercisesInner>
      get exercises;

  @BuiltValueField(wireName: r'templates')
  BuiltList<ListOfficialFitnessReferences200ResponseExercisesInner>
      get templates;

  ListOfficialFitnessReferences200Response._();

  factory ListOfficialFitnessReferences200Response(
          [void updates(ListOfficialFitnessReferences200ResponseBuilder b)]) =
      _$ListOfficialFitnessReferences200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListOfficialFitnessReferences200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialFitnessReferences200Response> get serializer =>
      _$ListOfficialFitnessReferences200ResponseSerializer();
}

class _$ListOfficialFitnessReferences200ResponseSerializer
    implements PrimitiveSerializer<ListOfficialFitnessReferences200Response> {
  @override
  final Iterable<Type> types = const [
    ListOfficialFitnessReferences200Response,
    _$ListOfficialFitnessReferences200Response
  ];

  @override
  final String wireName = r'ListOfficialFitnessReferences200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialFitnessReferences200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exercises';
    yield serializers.serialize(
      object.exercises,
      specifiedType: const FullType(BuiltList,
          [FullType(ListOfficialFitnessReferences200ResponseExercisesInner)]),
    );
    yield r'templates';
    yield serializers.serialize(
      object.templates,
      specifiedType: const FullType(BuiltList,
          [FullType(ListOfficialFitnessReferences200ResponseExercisesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialFitnessReferences200Response object, {
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
    required ListOfficialFitnessReferences200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(ListOfficialFitnessReferences200ResponseExercisesInner)
            ]),
          ) as BuiltList<
              ListOfficialFitnessReferences200ResponseExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        case r'templates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(ListOfficialFitnessReferences200ResponseExercisesInner)
            ]),
          ) as BuiltList<
              ListOfficialFitnessReferences200ResponseExercisesInner>;
          result.templates.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialFitnessReferences200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialFitnessReferences200ResponseBuilder();
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
