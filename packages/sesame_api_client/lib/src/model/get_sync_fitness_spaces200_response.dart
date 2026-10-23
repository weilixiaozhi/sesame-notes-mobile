//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_sync_fitness_spaces200_response_fitness_spaces_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_fitness_spaces200_response.g.dart';

/// GetSyncFitnessSpaces200Response
///
/// Properties:
/// * [fitnessSpaces]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncFitnessSpaces200Response
    implements
        Built<GetSyncFitnessSpaces200Response,
            GetSyncFitnessSpaces200ResponseBuilder> {
  @BuiltValueField(wireName: r'fitness_spaces')
  BuiltList<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>
      get fitnessSpaces;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncFitnessSpaces200Response._();

  factory GetSyncFitnessSpaces200Response(
          [void updates(GetSyncFitnessSpaces200ResponseBuilder b)]) =
      _$GetSyncFitnessSpaces200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncFitnessSpaces200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFitnessSpaces200Response> get serializer =>
      _$GetSyncFitnessSpaces200ResponseSerializer();
}

class _$GetSyncFitnessSpaces200ResponseSerializer
    implements PrimitiveSerializer<GetSyncFitnessSpaces200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncFitnessSpaces200Response,
    _$GetSyncFitnessSpaces200Response
  ];

  @override
  final String wireName = r'GetSyncFitnessSpaces200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFitnessSpaces200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fitness_spaces';
    yield serializers.serialize(
      object.fitnessSpaces,
      specifiedType: const FullType(BuiltList,
          [FullType(GetSyncFitnessSpaces200ResponseFitnessSpacesInner)]),
    );
    yield r'server_cursor';
    yield serializers.serialize(
      object.serverCursor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFitnessSpaces200Response object, {
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
    required GetSyncFitnessSpaces200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fitness_spaces':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetSyncFitnessSpaces200ResponseFitnessSpacesInner)]),
          ) as BuiltList<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>;
          result.fitnessSpaces.replace(valueDes);
          break;
        case r'server_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFitnessSpaces200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFitnessSpaces200ResponseBuilder();
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
