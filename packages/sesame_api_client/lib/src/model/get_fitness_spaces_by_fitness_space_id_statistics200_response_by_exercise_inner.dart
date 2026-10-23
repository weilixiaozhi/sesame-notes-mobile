//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_statistics200_response_by_exercise_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
///
/// Properties:
/// * [exerciseId]
/// * [completedSets]
/// * [workingSets]
/// * [volumeKg]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner,
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder> {
  @BuiltValueField(wireName: r'exercise_id')
  String get exerciseId;

  @BuiltValueField(wireName: r'completed_sets')
  int get completedSets;

  @BuiltValueField(wireName: r'working_sets')
  int get workingSets;

  @BuiltValueField(wireName: r'volume_kg')
  String get volumeKg;

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner._();

  factory GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner,
    _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exercise_id';
    yield serializers.serialize(
      object.exerciseId,
      specifiedType: const FullType(String),
    );
    yield r'completed_sets';
    yield serializers.serialize(
      object.completedSets,
      specifiedType: const FullType(int),
    );
    yield r'working_sets';
    yield serializers.serialize(
      object.workingSets,
      specifiedType: const FullType(int),
    );
    yield r'volume_kg';
    yield serializers.serialize(
      object.volumeKg,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
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
    required GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exercise_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exerciseId = valueDes;
          break;
        case r'completed_sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.completedSets = valueDes;
          break;
        case r'working_sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.workingSets = valueDes;
          break;
        case r'volume_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.volumeKg = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByExerciseInnerBuilder();
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
