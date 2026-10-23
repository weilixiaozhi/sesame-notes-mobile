//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_rest_timer.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
///
/// Properties:
/// * [status]
/// * [endsAt]
/// * [remainingSeconds]
/// * [durationSeconds]
/// * [elapsedSeconds]
/// * [exerciseId]
/// * [setId]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder> {
  @BuiltValueField(wireName: r'status')
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
      get status;
  // enum statusEnum {  running,  paused,  };

  @BuiltValueField(wireName: r'ends_at')
  DateTime? get endsAt;

  @BuiltValueField(wireName: r'remaining_seconds')
  int get remainingSeconds;

  @BuiltValueField(wireName: r'duration_seconds')
  int get durationSeconds;

  @BuiltValueField(wireName: r'elapsed_seconds')
  int? get elapsedSeconds;

  @BuiltValueField(wireName: r'exercise_id')
  String? get exerciseId;

  @BuiltValueField(wireName: r'set_id')
  String? get setId;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer._();

  factory GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer,
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum),
    );
    yield r'ends_at';
    yield object.endsAt == null
        ? null
        : serializers.serialize(
            object.endsAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'remaining_seconds';
    yield serializers.serialize(
      object.remainingSeconds,
      specifiedType: const FullType(int),
    );
    yield r'duration_seconds';
    yield serializers.serialize(
      object.durationSeconds,
      specifiedType: const FullType(int),
    );
    if (object.elapsedSeconds != null) {
      yield r'elapsed_seconds';
      yield serializers.serialize(
        object.elapsedSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.exerciseId != null) {
      yield r'exercise_id';
      yield serializers.serialize(
        object.exerciseId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.setId != null) {
      yield r'set_id';
      yield serializers.serialize(
        object.setId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
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
    required GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum;
          result.status = valueDes;
          break;
        case r'ends_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endsAt = valueDes;
          break;
        case r'remaining_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.remainingSeconds = valueDes;
          break;
        case r'duration_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationSeconds = valueDes;
          break;
        case r'elapsed_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.elapsedSeconds = valueDes;
          break;
        case r'exercise_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.exerciseId = valueDes;
          break;
        case r'set_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.setId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'running')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
      running =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_running;
  @BuiltValueEnumConst(wireName: r'paused')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
      paused =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_paused;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumValueOf(
              name);
}
