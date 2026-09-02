//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_profile_avatar_by_user_id200_response.g.dart';

/// GetProfileAvatarByUserId200Response
///
/// Properties:
/// * [contentType]
/// * [dataBase64]
/// * [avatarVersion]
@BuiltValue()
abstract class GetProfileAvatarByUserId200Response
    implements
        Built<GetProfileAvatarByUserId200Response,
            GetProfileAvatarByUserId200ResponseBuilder> {
  @BuiltValueField(wireName: r'content_type')
  GetProfileAvatarByUserId200ResponseContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/png,  image/jpeg,  image/webp,  };

  @BuiltValueField(wireName: r'data_base64')
  String get dataBase64;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  GetProfileAvatarByUserId200Response._();

  factory GetProfileAvatarByUserId200Response(
          [void updates(GetProfileAvatarByUserId200ResponseBuilder b)]) =
      _$GetProfileAvatarByUserId200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetProfileAvatarByUserId200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetProfileAvatarByUserId200Response> get serializer =>
      _$GetProfileAvatarByUserId200ResponseSerializer();
}

class _$GetProfileAvatarByUserId200ResponseSerializer
    implements PrimitiveSerializer<GetProfileAvatarByUserId200Response> {
  @override
  final Iterable<Type> types = const [
    GetProfileAvatarByUserId200Response,
    _$GetProfileAvatarByUserId200Response
  ];

  @override
  final String wireName = r'GetProfileAvatarByUserId200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetProfileAvatarByUserId200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType:
          const FullType(GetProfileAvatarByUserId200ResponseContentTypeEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetProfileAvatarByUserId200Response object, {
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
    required GetProfileAvatarByUserId200ResponseBuilder result,
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
                GetProfileAvatarByUserId200ResponseContentTypeEnum),
          ) as GetProfileAvatarByUserId200ResponseContentTypeEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetProfileAvatarByUserId200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetProfileAvatarByUserId200ResponseBuilder();
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

class GetProfileAvatarByUserId200ResponseContentTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/png')
  static const GetProfileAvatarByUserId200ResponseContentTypeEnum
      imageSlashPng =
      _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashPng;
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const GetProfileAvatarByUserId200ResponseContentTypeEnum
      imageSlashJpeg =
      _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'image/webp')
  static const GetProfileAvatarByUserId200ResponseContentTypeEnum
      imageSlashWebp =
      _$getProfileAvatarByUserId200ResponseContentTypeEnum_imageSlashWebp;

  static Serializer<GetProfileAvatarByUserId200ResponseContentTypeEnum>
      get serializer =>
          _$getProfileAvatarByUserId200ResponseContentTypeEnumSerializer;

  const GetProfileAvatarByUserId200ResponseContentTypeEnum._(String name)
      : super(name);

  static BuiltSet<GetProfileAvatarByUserId200ResponseContentTypeEnum>
      get values => _$getProfileAvatarByUserId200ResponseContentTypeEnumValues;
  static GetProfileAvatarByUserId200ResponseContentTypeEnum valueOf(
          String name) =>
      _$getProfileAvatarByUserId200ResponseContentTypeEnumValueOf(name);
}
