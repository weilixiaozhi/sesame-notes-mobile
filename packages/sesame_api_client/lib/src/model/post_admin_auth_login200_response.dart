//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_admin_auth_login200_response_admin.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_auth_login200_response.g.dart';

/// PostAdminAuthLogin200Response
///
/// Properties:
/// * [admin]
/// * [expiresAt]
@BuiltValue()
abstract class PostAdminAuthLogin200Response
    implements
        Built<PostAdminAuthLogin200Response,
            PostAdminAuthLogin200ResponseBuilder> {
  @BuiltValueField(wireName: r'admin')
  PostAdminAuthLogin200ResponseAdmin get admin;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  PostAdminAuthLogin200Response._();

  factory PostAdminAuthLogin200Response(
          [void updates(PostAdminAuthLogin200ResponseBuilder b)]) =
      _$PostAdminAuthLogin200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAuthLogin200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAuthLogin200Response> get serializer =>
      _$PostAdminAuthLogin200ResponseSerializer();
}

class _$PostAdminAuthLogin200ResponseSerializer
    implements PrimitiveSerializer<PostAdminAuthLogin200Response> {
  @override
  final Iterable<Type> types = const [
    PostAdminAuthLogin200Response,
    _$PostAdminAuthLogin200Response
  ];

  @override
  final String wireName = r'PostAdminAuthLogin200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAuthLogin200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'admin';
    yield serializers.serialize(
      object.admin,
      specifiedType: const FullType(PostAdminAuthLogin200ResponseAdmin),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAuthLogin200Response object, {
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
    required PostAdminAuthLogin200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'admin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAdminAuthLogin200ResponseAdmin),
          ) as PostAdminAuthLogin200ResponseAdmin;
          result.admin.replace(valueDes);
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAuthLogin200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAuthLogin200ResponseBuilder();
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
