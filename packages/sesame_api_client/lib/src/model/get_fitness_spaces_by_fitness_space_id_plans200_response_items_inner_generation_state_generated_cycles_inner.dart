//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_generation_state_generated_cycles_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
///
/// Properties:
/// * [cycleIndex]
/// * [startDate]
/// * [cycleDays]
/// * [generatedFromDate]
/// * [restDates]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerBuilder> {
  @BuiltValueField(wireName: r'cycle_index')
  int get cycleIndex;

  @BuiltValueField(wireName: r'start_date')
  String get startDate;

  @BuiltValueField(wireName: r'cycle_days')
  int get cycleDays;

  @BuiltValueField(wireName: r'generated_from_date')
  String get generatedFromDate;

  @BuiltValueField(wireName: r'rest_dates')
  BuiltList<String> get restDates;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cycle_index';
    yield serializers.serialize(
      object.cycleIndex,
      specifiedType: const FullType(int),
    );
    yield r'start_date';
    yield serializers.serialize(
      object.startDate,
      specifiedType: const FullType(String),
    );
    yield r'cycle_days';
    yield serializers.serialize(
      object.cycleDays,
      specifiedType: const FullType(int),
    );
    yield r'generated_from_date';
    yield serializers.serialize(
      object.generatedFromDate,
      specifiedType: const FullType(String),
    );
    yield r'rest_dates';
    yield serializers.serialize(
      object.restDates,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cycle_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cycleIndex = valueDes;
          break;
        case r'start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.startDate = valueDes;
          break;
        case r'cycle_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cycleDays = valueDes;
          break;
        case r'generated_from_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.generatedFromDate = valueDes;
          break;
        case r'rest_dates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.restDates.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInnerBuilder();
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
