//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_groups_by_group_id_members200_response.g.dart';

/// PostAdminGroupsByGroupIdMembers200Response
///
/// Properties:
/// * [transferred]
/// * [selfSessionRevoked]
@BuiltValue()
abstract class PostAdminGroupsByGroupIdMembers200Response
    implements
        Built<PostAdminGroupsByGroupIdMembers200Response,
            PostAdminGroupsByGroupIdMembers200ResponseBuilder> {
  @BuiltValueField(wireName: r'transferred')
  int get transferred;

  @BuiltValueField(wireName: r'self_session_revoked')
  bool get selfSessionRevoked;

  PostAdminGroupsByGroupIdMembers200Response._();

  factory PostAdminGroupsByGroupIdMembers200Response(
          [void updates(PostAdminGroupsByGroupIdMembers200ResponseBuilder b)]) =
      _$PostAdminGroupsByGroupIdMembers200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminGroupsByGroupIdMembers200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminGroupsByGroupIdMembers200Response>
      get serializer =>
          _$PostAdminGroupsByGroupIdMembers200ResponseSerializer();
}

class _$PostAdminGroupsByGroupIdMembers200ResponseSerializer
    implements PrimitiveSerializer<PostAdminGroupsByGroupIdMembers200Response> {
  @override
  final Iterable<Type> types = const [
    PostAdminGroupsByGroupIdMembers200Response,
    _$PostAdminGroupsByGroupIdMembers200Response
  ];

  @override
  final String wireName = r'PostAdminGroupsByGroupIdMembers200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminGroupsByGroupIdMembers200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'transferred';
    yield serializers.serialize(
      object.transferred,
      specifiedType: const FullType(int),
    );
    yield r'self_session_revoked';
    yield serializers.serialize(
      object.selfSessionRevoked,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminGroupsByGroupIdMembers200Response object, {
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
    required PostAdminGroupsByGroupIdMembers200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'transferred':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.transferred = valueDes;
          break;
        case r'self_session_revoked':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.selfSessionRevoked = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminGroupsByGroupIdMembers200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminGroupsByGroupIdMembers200ResponseBuilder();
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
