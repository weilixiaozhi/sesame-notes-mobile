//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_auth_login_request.g.dart';

/// PostAdminAuthLoginRequest
///
/// Properties:
/// * [username]
/// * [password]
@BuiltValue()
abstract class PostAdminAuthLoginRequest
    implements
        Built<PostAdminAuthLoginRequest, PostAdminAuthLoginRequestBuilder> {
  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'password')
  String get password;

  PostAdminAuthLoginRequest._();

  factory PostAdminAuthLoginRequest(
          [void updates(PostAdminAuthLoginRequestBuilder b)]) =
      _$PostAdminAuthLoginRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAuthLoginRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAuthLoginRequest> get serializer =>
      _$PostAdminAuthLoginRequestSerializer();
}

class _$PostAdminAuthLoginRequestSerializer
    implements PrimitiveSerializer<PostAdminAuthLoginRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminAuthLoginRequest,
    _$PostAdminAuthLoginRequest
  ];

  @override
  final String wireName = r'PostAdminAuthLoginRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAuthLoginRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAuthLoginRequest object, {
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
    required PostAdminAuthLoginRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAuthLoginRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAuthLoginRequestBuilder();
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
