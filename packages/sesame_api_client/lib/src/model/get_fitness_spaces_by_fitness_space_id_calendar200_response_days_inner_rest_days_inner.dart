//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner_rest_days_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
///
/// Properties:
/// * [sourcePlanId]
/// * [sourcePlanName]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder> {
  @BuiltValueField(wireName: r'source_plan_id')
  String get sourcePlanId;

  @BuiltValueField(wireName: r'source_plan_name')
  String get sourcePlanName;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner._();

  factory GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner,
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'source_plan_id';
    yield serializers.serialize(
      object.sourcePlanId,
      specifiedType: const FullType(String),
    );
    yield r'source_plan_name';
    yield serializers.serialize(
      object.sourcePlanName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
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
    required GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source_plan_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourcePlanId = valueDes;
          break;
        case r'source_plan_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourcePlanName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerRestDaysInnerBuilder();
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
