//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_calendar200_response.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdCalendar200Response
///
/// Properties:
/// * [days]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdCalendar200Response
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdCalendar200Response,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder> {
  @BuiltValueField(wireName: r'days')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>
      get days;

  GetFitnessSpacesByFitnessSpaceIdCalendar200Response._();

  factory GetFitnessSpacesByFitnessSpaceIdCalendar200Response(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessSpacesByFitnessSpaceIdCalendar200Response>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdCalendar200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdCalendar200Response,
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200Response
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdCalendar200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(BuiltList, [
        FullType(GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200Response object, {
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
    required GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInner>;
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
  GetFitnessSpacesByFitnessSpaceIdCalendar200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseBuilder();
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
