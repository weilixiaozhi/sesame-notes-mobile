//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ws_ticket200_response.g.dart';

/// PostWsTicket200Response
///
/// Properties:
/// * [ticket]
/// * [expiresIn]
@BuiltValue()
abstract class PostWsTicket200Response
    implements Built<PostWsTicket200Response, PostWsTicket200ResponseBuilder> {
  @BuiltValueField(wireName: r'ticket')
  String get ticket;

  @BuiltValueField(wireName: r'expires_in')
  int get expiresIn;

  PostWsTicket200Response._();

  factory PostWsTicket200Response(
          [void updates(PostWsTicket200ResponseBuilder b)]) =
      _$PostWsTicket200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostWsTicket200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostWsTicket200Response> get serializer =>
      _$PostWsTicket200ResponseSerializer();
}

class _$PostWsTicket200ResponseSerializer
    implements PrimitiveSerializer<PostWsTicket200Response> {
  @override
  final Iterable<Type> types = const [
    PostWsTicket200Response,
    _$PostWsTicket200Response
  ];

  @override
  final String wireName = r'PostWsTicket200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostWsTicket200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ticket';
    yield serializers.serialize(
      object.ticket,
      specifiedType: const FullType(String),
    );
    yield r'expires_in';
    yield serializers.serialize(
      object.expiresIn,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostWsTicket200Response object, {
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
    required PostWsTicket200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ticket':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ticket = valueDes;
          break;
        case r'expires_in':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expiresIn = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostWsTicket200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostWsTicket200ResponseBuilder();
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
