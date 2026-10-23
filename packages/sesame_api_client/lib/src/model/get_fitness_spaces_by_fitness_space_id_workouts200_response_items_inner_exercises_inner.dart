//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_exercises_inner_sets_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_exercises_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
///
/// Properties:
/// * [id]
/// * [exerciseId]
/// * [restSeconds]
/// * [warmupRestSeconds]
/// * [sets]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'exercise_id')
  String get exerciseId;

  @BuiltValueField(wireName: r'rest_seconds')
  int get restSeconds;

  @BuiltValueField(wireName: r'warmup_rest_seconds')
  int? get warmupRestSeconds;

  @BuiltValueField(wireName: r'sets')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>
      get sets;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner._();

  factory GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner,
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'exercise_id';
    yield serializers.serialize(
      object.exerciseId,
      specifiedType: const FullType(String),
    );
    yield r'rest_seconds';
    yield serializers.serialize(
      object.restSeconds,
      specifiedType: const FullType(int),
    );
    yield r'warmup_rest_seconds';
    yield object.warmupRestSeconds == null
        ? null
        : serializers.serialize(
            object.warmupRestSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'sets';
    yield serializers.serialize(
      object.sets,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
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
    required GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder
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
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'exercise_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exerciseId = valueDes;
          break;
        case r'rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restSeconds = valueDes;
          break;
        case r'warmup_rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warmupRestSeconds = valueDes;
          break;
        case r'sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>;
          result.sets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerBuilder();
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
