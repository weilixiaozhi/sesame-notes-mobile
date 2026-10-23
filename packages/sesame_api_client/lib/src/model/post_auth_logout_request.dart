//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_auth_logout_request.g.dart';

/// PostAuthLogoutRequest
///
/// Properties:
/// * [refreshToken]
@BuiltValue()
abstract class PostAuthLogoutRequest
    implements Built<PostAuthLogoutRequest, PostAuthLogoutRequestBuilder> {
  @BuiltValueField(wireName: r'refresh_token')
  String get refreshToken;

  PostAuthLogoutRequest._();

  factory PostAuthLogoutRequest(
      [void updates(PostAuthLogoutRequestBuilder b)]) = _$PostAuthLogoutRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAuthLogoutRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAuthLogoutRequest> get serializer =>
      _$PostAuthLogoutRequestSerializer();
}

class _$PostAuthLogoutRequestSerializer
    implements PrimitiveSerializer<PostAuthLogoutRequest> {
  @override
  final Iterable<Type> types = const [
    PostAuthLogoutRequest,
    _$PostAuthLogoutRequest
  ];

  @override
  final String wireName = r'PostAuthLogoutRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAuthLogoutRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'refresh_token';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAuthLogoutRequest object, {
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
    required PostAuthLogoutRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAuthLogoutRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAuthLogoutRequestBuilder();
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
