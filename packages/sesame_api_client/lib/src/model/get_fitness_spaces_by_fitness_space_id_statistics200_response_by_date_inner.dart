//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_statistics200_response_by_date_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner
///
/// Properties:
/// * [date]
/// * [completedWorkouts]
/// * [completedSets]
/// * [durationMs]
/// * [volumeKg]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner,
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder> {
  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'completed_workouts')
  int get completedWorkouts;

  @BuiltValueField(wireName: r'completed_sets')
  int get completedSets;

  @BuiltValueField(wireName: r'duration_ms')
  int get durationMs;

  @BuiltValueField(wireName: r'volume_kg')
  String get volumeKg;

  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner._();

  factory GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner,
    _$GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(String),
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
    yield r'duration_ms';
    yield serializers.serialize(
      object.durationMs,
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
    GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner object, {
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
    required GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.date = valueDes;
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
        case r'duration_ms':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationMs = valueDes;
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
  GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdStatistics200ResponseByDateInnerBuilder();
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
