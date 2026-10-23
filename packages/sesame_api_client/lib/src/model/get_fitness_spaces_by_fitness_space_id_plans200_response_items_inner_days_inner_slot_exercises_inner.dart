//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner_sets_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
///
/// Properties:
/// * [id]
/// * [exerciseId]
/// * [restSeconds]
/// * [warmupRestSeconds]
/// * [sets]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder> {
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
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>
      get sets;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
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
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder
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
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>;
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
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder();
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
