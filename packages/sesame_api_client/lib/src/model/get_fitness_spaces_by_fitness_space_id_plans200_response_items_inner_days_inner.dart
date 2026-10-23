//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
///
/// Properties:
/// * [dayIndex]
/// * [slot]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder> {
  @BuiltValueField(wireName: r'day_index')
  int get dayIndex;

  @BuiltValueField(wireName: r'slot')
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot?
      get slot;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day_index';
    yield serializers.serialize(
      object.dayIndex,
      specifiedType: const FullType(int),
    );
    yield r'slot';
    yield object.slot == null
        ? null
        : serializers.serialize(
            object.slot,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dayIndex = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot),
          ) as GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot?;
          if (valueDes == null) continue;
          result.slot.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerBuilder();
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
