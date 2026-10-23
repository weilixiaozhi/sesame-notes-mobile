//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_admin_users_by_user_id_avatar200_response.g.dart';

/// PutAdminUsersByUserIdAvatar200Response
///
/// Properties:
/// * [avatarUrl]
/// * [avatarVersion]
@BuiltValue()
abstract class PutAdminUsersByUserIdAvatar200Response
    implements
        Built<PutAdminUsersByUserIdAvatar200Response,
            PutAdminUsersByUserIdAvatar200ResponseBuilder> {
  @BuiltValueField(wireName: r'avatar_url')
  String get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  PutAdminUsersByUserIdAvatar200Response._();

  factory PutAdminUsersByUserIdAvatar200Response(
          [void updates(PutAdminUsersByUserIdAvatar200ResponseBuilder b)]) =
      _$PutAdminUsersByUserIdAvatar200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutAdminUsersByUserIdAvatar200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutAdminUsersByUserIdAvatar200Response> get serializer =>
      _$PutAdminUsersByUserIdAvatar200ResponseSerializer();
}

class _$PutAdminUsersByUserIdAvatar200ResponseSerializer
    implements PrimitiveSerializer<PutAdminUsersByUserIdAvatar200Response> {
  @override
  final Iterable<Type> types = const [
    PutAdminUsersByUserIdAvatar200Response,
    _$PutAdminUsersByUserIdAvatar200Response
  ];

  @override
  final String wireName = r'PutAdminUsersByUserIdAvatar200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutAdminUsersByUserIdAvatar200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'avatar_url';
    yield serializers.serialize(
      object.avatarUrl,
      specifiedType: const FullType(String),
    );
    yield r'avatar_version';
    yield serializers.serialize(
      object.avatarVersion,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PutAdminUsersByUserIdAvatar200Response object, {
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
    required PutAdminUsersByUserIdAvatar200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avatar_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatarUrl = valueDes;
          break;
        case r'avatar_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.avatarVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PutAdminUsersByUserIdAvatar200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutAdminUsersByUserIdAvatar200ResponseBuilder();
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
