//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_health200_response.g.dart';

/// GetHealth200Response
///
/// Properties:
/// * [status]
/// * [requestId]
@BuiltValue()
abstract class GetHealth200Response
    implements Built<GetHealth200Response, GetHealth200ResponseBuilder> {
  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'request_id')
  String get requestId;

  GetHealth200Response._();

  factory GetHealth200Response([void updates(GetHealth200ResponseBuilder b)]) =
      _$GetHealth200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetHealth200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetHealth200Response> get serializer =>
      _$GetHealth200ResponseSerializer();
}

class _$GetHealth200ResponseSerializer
    implements PrimitiveSerializer<GetHealth200Response> {
  @override
  final Iterable<Type> types = const [
    GetHealth200Response,
    _$GetHealth200Response
  ];

  @override
  final String wireName = r'GetHealth200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetHealth200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'request_id';
    yield serializers.serialize(
      object.requestId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetHealth200Response object, {
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
    required GetHealth200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'request_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.requestId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetHealth200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetHealth200ResponseBuilder();
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
