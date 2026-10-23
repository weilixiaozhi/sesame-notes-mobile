//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner_rest_days_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner_workouts_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner
///
/// Properties:
/// * [date]
/// * [workouts]
/// * [restDays]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder> {
  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'workouts')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>
      get workouts;

  @BuiltValueField(wireName: r'rest_days')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>
      get restDays;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner._();

  factory GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner,
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(String),
    );
    yield r'workouts';
    yield serializers.serialize(
      object.workouts,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner)
      ]),
    );
    yield r'rest_days';
    yield serializers.serialize(
      object.restDays,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner object, {
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
    required GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder
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
        case r'workouts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>;
          result.workouts.replace(valueDes);
          break;
        case r'rest_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>;
          result.restDays.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerBuilder();
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
