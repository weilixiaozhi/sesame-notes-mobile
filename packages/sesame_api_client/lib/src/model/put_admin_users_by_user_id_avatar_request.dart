//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_admin_users_by_user_id_avatar_request.g.dart';

/// PutAdminUsersByUserIdAvatarRequest
///
/// Properties:
/// * [contentType]
/// * [dataBase64]
/// * [avatarVersion]
/// * [reason]
@BuiltValue()
abstract class PutAdminUsersByUserIdAvatarRequest
    implements
        Built<PutAdminUsersByUserIdAvatarRequest,
            PutAdminUsersByUserIdAvatarRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  PutAdminUsersByUserIdAvatarRequestContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/png,  image/jpeg,  image/webp,  };

  @BuiltValueField(wireName: r'data_base64')
  String get dataBase64;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PutAdminUsersByUserIdAvatarRequest._();

  factory PutAdminUsersByUserIdAvatarRequest(
          [void updates(PutAdminUsersByUserIdAvatarRequestBuilder b)]) =
      _$PutAdminUsersByUserIdAvatarRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutAdminUsersByUserIdAvatarRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutAdminUsersByUserIdAvatarRequest> get serializer =>
      _$PutAdminUsersByUserIdAvatarRequestSerializer();
}

class _$PutAdminUsersByUserIdAvatarRequestSerializer
    implements PrimitiveSerializer<PutAdminUsersByUserIdAvatarRequest> {
  @override
  final Iterable<Type> types = const [
    PutAdminUsersByUserIdAvatarRequest,
    _$PutAdminUsersByUserIdAvatarRequest
  ];

  @override
  final String wireName = r'PutAdminUsersByUserIdAvatarRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutAdminUsersByUserIdAvatarRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType:
          const FullType(PutAdminUsersByUserIdAvatarRequestContentTypeEnum),
    );
    yield r'data_base64';
    yield serializers.serialize(
      object.dataBase64,
      specifiedType: const FullType(String),
    );
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
    PutAdminUsersByUserIdAvatarRequest object, {
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
    required PutAdminUsersByUserIdAvatarRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PutAdminUsersByUserIdAvatarRequestContentTypeEnum),
          ) as PutAdminUsersByUserIdAvatarRequestContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'data_base64':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dataBase64 = valueDes;
          break;
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
  PutAdminUsersByUserIdAvatarRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutAdminUsersByUserIdAvatarRequestBuilder();
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

class PutAdminUsersByUserIdAvatarRequestContentTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/png')
  static const PutAdminUsersByUserIdAvatarRequestContentTypeEnum imageSlashPng =
      _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashPng;
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const PutAdminUsersByUserIdAvatarRequestContentTypeEnum
      imageSlashJpeg =
      _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'image/webp')
  static const PutAdminUsersByUserIdAvatarRequestContentTypeEnum
      imageSlashWebp =
      _$putAdminUsersByUserIdAvatarRequestContentTypeEnum_imageSlashWebp;

  static Serializer<PutAdminUsersByUserIdAvatarRequestContentTypeEnum>
      get serializer =>
          _$putAdminUsersByUserIdAvatarRequestContentTypeEnumSerializer;

  const PutAdminUsersByUserIdAvatarRequestContentTypeEnum._(String name)
      : super(name);

  static BuiltSet<PutAdminUsersByUserIdAvatarRequestContentTypeEnum>
      get values => _$putAdminUsersByUserIdAvatarRequestContentTypeEnumValues;
  static PutAdminUsersByUserIdAvatarRequestContentTypeEnum valueOf(
          String name) =>
      _$putAdminUsersByUserIdAvatarRequestContentTypeEnumValueOf(name);
}
