//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_admin_users_by_user_id_avatar_request.g.dart';

/// DeleteAdminUsersByUserIdAvatarRequest
///
/// Properties:
/// * [avatarVersion]
/// * [reason]
@BuiltValue()
abstract class DeleteAdminUsersByUserIdAvatarRequest
    implements
        Built<DeleteAdminUsersByUserIdAvatarRequest,
            DeleteAdminUsersByUserIdAvatarRequestBuilder> {
  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  DeleteAdminUsersByUserIdAvatarRequest._();

  factory DeleteAdminUsersByUserIdAvatarRequest(
          [void updates(DeleteAdminUsersByUserIdAvatarRequestBuilder b)]) =
      _$DeleteAdminUsersByUserIdAvatarRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteAdminUsersByUserIdAvatarRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteAdminUsersByUserIdAvatarRequest> get serializer =>
      _$DeleteAdminUsersByUserIdAvatarRequestSerializer();
}

class _$DeleteAdminUsersByUserIdAvatarRequestSerializer
    implements PrimitiveSerializer<DeleteAdminUsersByUserIdAvatarRequest> {
  @override
  final Iterable<Type> types = const [
    DeleteAdminUsersByUserIdAvatarRequest,
    _$DeleteAdminUsersByUserIdAvatarRequest
  ];

  @override
  final String wireName = r'DeleteAdminUsersByUserIdAvatarRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteAdminUsersByUserIdAvatarRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'avatar_version';
    yield serializers.serialize(
      object.avatarVersion,
      specifiedType: const FullType(int),
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
    DeleteAdminUsersByUserIdAvatarRequest object, {
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
    required DeleteAdminUsersByUserIdAvatarRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'avatar_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.avatarVersion = valueDes;
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
  DeleteAdminUsersByUserIdAvatarRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteAdminUsersByUserIdAvatarRequestBuilder();
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
