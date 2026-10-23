//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_auth_password_request.g.dart';

/// PostAdminAuthPasswordRequest
///
/// Properties:
/// * [oldPassword]
/// * [newPassword]
@BuiltValue()
abstract class PostAdminAuthPasswordRequest
    implements
        Built<PostAdminAuthPasswordRequest,
            PostAdminAuthPasswordRequestBuilder> {
  @BuiltValueField(wireName: r'old_password')
  String get oldPassword;

  @BuiltValueField(wireName: r'new_password')
  String get newPassword;

  PostAdminAuthPasswordRequest._();

  factory PostAdminAuthPasswordRequest(
          [void updates(PostAdminAuthPasswordRequestBuilder b)]) =
      _$PostAdminAuthPasswordRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAuthPasswordRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAuthPasswordRequest> get serializer =>
      _$PostAdminAuthPasswordRequestSerializer();
}

class _$PostAdminAuthPasswordRequestSerializer
    implements PrimitiveSerializer<PostAdminAuthPasswordRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminAuthPasswordRequest,
    _$PostAdminAuthPasswordRequest
  ];

  @override
  final String wireName = r'PostAdminAuthPasswordRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAuthPasswordRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'old_password';
    yield serializers.serialize(
      object.oldPassword,
      specifiedType: const FullType(String),
    );
    yield r'new_password';
    yield serializers.serialize(
      object.newPassword,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAuthPasswordRequest object, {
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
    required PostAdminAuthPasswordRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'old_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.oldPassword = valueDes;
          break;
        case r'new_password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.newPassword = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAuthPasswordRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAuthPasswordRequestBuilder();
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
