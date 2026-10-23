//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_pending_schedule.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
///
/// Properties:
/// * [cycleDays]
/// * [days]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder> {
  @BuiltValueField(wireName: r'cycle_days')
  int get cycleDays;

  @BuiltValueField(wireName: r'days')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>
      get days;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'cycle_days';
    yield serializers.serialize(
      object.cycleDays,
      specifiedType: const FullType(int),
    );
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'cycle_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cycleDays = valueDes;
          break;
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>;
          result.days.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder();
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
