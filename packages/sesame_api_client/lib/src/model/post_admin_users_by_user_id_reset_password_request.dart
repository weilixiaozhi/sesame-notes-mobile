//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_users_by_user_id_reset_password_request.g.dart';

/// PostAdminUsersByUserIdResetPasswordRequest
///
/// Properties:
/// * [newPassword]
/// * [reason]
@BuiltValue()
abstract class PostAdminUsersByUserIdResetPasswordRequest
    implements
        Built<PostAdminUsersByUserIdResetPasswordRequest,
            PostAdminUsersByUserIdResetPasswordRequestBuilder> {
  @BuiltValueField(wireName: r'new_password')
  String get newPassword;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PostAdminUsersByUserIdResetPasswordRequest._();

  factory PostAdminUsersByUserIdResetPasswordRequest(
          [void updates(PostAdminUsersByUserIdResetPasswordRequestBuilder b)]) =
      _$PostAdminUsersByUserIdResetPasswordRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminUsersByUserIdResetPasswordRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminUsersByUserIdResetPasswordRequest>
      get serializer =>
          _$PostAdminUsersByUserIdResetPasswordRequestSerializer();
}

class _$PostAdminUsersByUserIdResetPasswordRequestSerializer
    implements PrimitiveSerializer<PostAdminUsersByUserIdResetPasswordRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminUsersByUserIdResetPasswordRequest,
    _$PostAdminUsersByUserIdResetPasswordRequest
  ];

  @override
  final String wireName = r'PostAdminUsersByUserIdResetPasswordRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminUsersByUserIdResetPasswordRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'new_password';
    yield serializers.serialize(
      object.newPassword,
      specifiedType: const FullType(String),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminUsersByUserIdResetPasswordRequest object, {
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
    required PostAdminUsersByUserIdResetPasswordRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'new_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newPassword = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminUsersByUserIdResetPasswordRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminUsersByUserIdResetPasswordRequestBuilder();
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
