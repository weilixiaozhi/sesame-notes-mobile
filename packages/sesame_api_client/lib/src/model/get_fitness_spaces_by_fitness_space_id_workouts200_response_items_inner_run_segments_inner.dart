//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_run_segments_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
///
/// Properties:
/// * [startedAt]
/// * [endedAt]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder> {
  @BuiltValueField(wireName: r'started_at')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'ended_at')
  DateTime? get endedAt;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner,
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'started_at';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'ended_at';
    yield object.endedAt == null
        ? null
        : serializers.serialize(
            object.endedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
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
    required GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'started_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'ended_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInnerBuilder();
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
