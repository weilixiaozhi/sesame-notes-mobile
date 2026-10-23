//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_workouts200_response.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdWorkouts200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdWorkouts200Response
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdWorkouts200Response,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200Response._();

  factory GetFitnessSpacesByFitnessSpaceIdWorkouts200Response(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessSpacesByFitnessSpaceIdWorkouts200Response>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdWorkouts200Response,
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200Response
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdWorkouts200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner)
      ]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null
        ? null
        : serializers.serialize(
            object.nextCursor,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200Response object, {
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
    required GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseBuilder();
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
