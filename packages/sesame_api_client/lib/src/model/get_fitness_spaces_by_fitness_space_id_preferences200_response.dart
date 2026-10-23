//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_preferences200_response.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPreferences200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPreferences200Response
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdPreferences200Response,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>
      get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetFitnessSpacesByFitnessSpaceIdPreferences200Response._();

  factory GetFitnessSpacesByFitnessSpaceIdPreferences200Response(
      [void updates(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder
              b)]) = _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessSpacesByFitnessSpaceIdPreferences200Response>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPreferences200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPreferences200Response,
    _$GetFitnessSpacesByFitnessSpaceIdPreferences200Response
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPreferences200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner)
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
    GetFitnessSpacesByFitnessSpaceIdPreferences200Response object, {
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
    required GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder
        result,
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
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>;
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
  GetFitnessSpacesByFitnessSpaceIdPreferences200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseBuilder();
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
