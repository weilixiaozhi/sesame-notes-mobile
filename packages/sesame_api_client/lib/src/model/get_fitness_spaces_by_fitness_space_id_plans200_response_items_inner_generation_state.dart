//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_generation_state_generated_cycles_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_generation_state.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
///
/// Properties:
/// * [nextCycleStartDate]
/// * [nextCycleIndex]
/// * [generatedCycles]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder> {
  @BuiltValueField(wireName: r'next_cycle_start_date')
  String? get nextCycleStartDate;

  @BuiltValueField(wireName: r'next_cycle_index')
  int get nextCycleIndex;

  @BuiltValueField(wireName: r'generated_cycles')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>
      get generatedCycles;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'next_cycle_start_date';
    yield object.nextCycleStartDate == null
        ? null
        : serializers.serialize(
            object.nextCycleStartDate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'next_cycle_index';
    yield serializers.serialize(
      object.nextCycleIndex,
      specifiedType: const FullType(int),
    );
    yield r'generated_cycles';
    yield serializers.serialize(
      object.generatedCycles,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'next_cycle_start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCycleStartDate = valueDes;
          break;
        case r'next_cycle_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.nextCycleIndex = valueDes;
          break;
        case r'generated_cycles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>;
          result.generatedCycles.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder();
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
