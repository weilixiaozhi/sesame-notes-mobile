//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_statistics200_response_by_exercise_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_statistics200_response_by_date_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_statistics200_response.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdStatistics200Response
///
/// Properties:
/// * [trainingDays]
/// * [completedWorkouts]
/// * [completedSets]
/// * [totalDurationMs]
/// * [volumeKg]
/// * [byDate]
/// * [byExercise]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdStatistics200Response
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdStatistics200Response,
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder> {
  @BuiltValueField(wireName: r'training_days')
  int get trainingDays;

  @BuiltValueField(wireName: r'completed_workouts')
  int get completedWorkouts;

  @BuiltValueField(wireName: r'completed_sets')
  int get completedSets;

  @BuiltValueField(wireName: r'total_duration_ms')
  int get totalDurationMs;

  @BuiltValueField(wireName: r'volume_kg')
  String get volumeKg;

  @BuiltValueField(wireName: r'by_date')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>
      get byDate;

  @BuiltValueField(wireName: r'by_exercise')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>
      get byExercise;

  GetFitnessSpacesByFitnessSpaceIdStatistics200Response._();

  factory GetFitnessSpacesByFitnessSpaceIdStatistics200Response(
      [void updates(
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder
              b)]) = _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessSpacesByFitnessSpaceIdStatistics200Response>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdStatistics200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdStatistics200Response,
    _$GetFitnessSpacesByFitnessSpaceIdStatistics200Response
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdStatistics200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdStatistics200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'training_days';
    yield serializers.serialize(
      object.trainingDays,
      specifiedType: const FullType(int),
    );
    yield r'completed_workouts';
    yield serializers.serialize(
      object.completedWorkouts,
      specifiedType: const FullType(int),
    );
    yield r'completed_sets';
    yield serializers.serialize(
      object.completedSets,
      specifiedType: const FullType(int),
    );
    yield r'total_duration_ms';
    yield serializers.serialize(
      object.totalDurationMs,
      specifiedType: const FullType(int),
    );
    yield r'volume_kg';
    yield serializers.serialize(
      object.volumeKg,
      specifiedType: const FullType(String),
    );
    yield r'by_date';
    yield serializers.serialize(
      object.byDate,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner)
      ]),
    );
    yield r'by_exercise';
    yield serializers.serialize(
      object.byExercise,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdStatistics200Response object, {
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
    required GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'training_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.trainingDays = valueDes;
          break;
        case r'completed_workouts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedWorkouts = valueDes;
          break;
        case r'completed_sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedSets = valueDes;
          break;
        case r'total_duration_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.totalDurationMs = valueDes;
          break;
        case r'volume_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.volumeKg = valueDes;
          break;
        case r'by_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>;
          result.byDate.replace(valueDes);
          break;
        case r'by_exercise':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>;
          result.byExercise.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseBuilder();
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
