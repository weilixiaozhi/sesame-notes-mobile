//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_accounts_by_admin_id_reset_password_request.g.dart';

/// PostAdminAccountsByAdminIdResetPasswordRequest
///
/// Properties:
/// * [version]
/// * [newPassword]
/// * [reason]
@BuiltValue()
abstract class PostAdminAccountsByAdminIdResetPasswordRequest
    implements
        Built<PostAdminAccountsByAdminIdResetPasswordRequest,
            PostAdminAccountsByAdminIdResetPasswordRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'new_password')
  String get newPassword;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PostAdminAccountsByAdminIdResetPasswordRequest._();

  factory PostAdminAccountsByAdminIdResetPasswordRequest(
          [void updates(
              PostAdminAccountsByAdminIdResetPasswordRequestBuilder b)]) =
      _$PostAdminAccountsByAdminIdResetPasswordRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostAdminAccountsByAdminIdResetPasswordRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAccountsByAdminIdResetPasswordRequest>
      get serializer =>
          _$PostAdminAccountsByAdminIdResetPasswordRequestSerializer();
}

class _$PostAdminAccountsByAdminIdResetPasswordRequestSerializer
    implements
        PrimitiveSerializer<PostAdminAccountsByAdminIdResetPasswordRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminAccountsByAdminIdResetPasswordRequest,
    _$PostAdminAccountsByAdminIdResetPasswordRequest
  ];

  @override
  final String wireName = r'PostAdminAccountsByAdminIdResetPasswordRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAccountsByAdminIdResetPasswordRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
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
    PostAdminAccountsByAdminIdResetPasswordRequest object, {
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
    required PostAdminAccountsByAdminIdResetPasswordRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
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
  PostAdminAccountsByAdminIdResetPasswordRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAccountsByAdminIdResetPasswordRequestBuilder();
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
