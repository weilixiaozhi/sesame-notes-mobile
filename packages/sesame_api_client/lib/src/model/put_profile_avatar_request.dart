//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_profile_avatar_request.g.dart';

/// PutProfileAvatarRequest
///
/// Properties:
/// * [contentType]
/// * [dataBase64]
@BuiltValue()
abstract class PutProfileAvatarRequest
    implements Built<PutProfileAvatarRequest, PutProfileAvatarRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  PutProfileAvatarRequestContentTypeEnum get contentType;
  // enum contentTypeEnum {  image/png,  image/jpeg,  image/webp,  };

  @BuiltValueField(wireName: r'data_base64')
  String get dataBase64;

  PutProfileAvatarRequest._();

  factory PutProfileAvatarRequest(
          [void updates(PutProfileAvatarRequestBuilder b)]) =
      _$PutProfileAvatarRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutProfileAvatarRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutProfileAvatarRequest> get serializer =>
      _$PutProfileAvatarRequestSerializer();
}

class _$PutProfileAvatarRequestSerializer
    implements PrimitiveSerializer<PutProfileAvatarRequest> {
  @override
  final Iterable<Type> types = const [
    PutProfileAvatarRequest,
    _$PutProfileAvatarRequest
  ];

  @override
  final String wireName = r'PutProfileAvatarRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutProfileAvatarRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(PutProfileAvatarRequestContentTypeEnum),
    );
    yield r'data_base64';
    yield serializers.serialize(
      object.dataBase64,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PutProfileAvatarRequest object, {
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
    required PutProfileAvatarRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PutProfileAvatarRequestContentTypeEnum),
          ) as PutProfileAvatarRequestContentTypeEnum;
          result.contentType = valueDes;
          break;
        case r'data_base64':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dataBase64 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PutProfileAvatarRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutProfileAvatarRequestBuilder();
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

class PutProfileAvatarRequestContentTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'image/png')
  static const PutProfileAvatarRequestContentTypeEnum imageSlashPng =
      _$putProfileAvatarRequestContentTypeEnum_imageSlashPng;
  @BuiltValueEnumConst(wireName: r'image/jpeg')
  static const PutProfileAvatarRequestContentTypeEnum imageSlashJpeg =
      _$putProfileAvatarRequestContentTypeEnum_imageSlashJpeg;
  @BuiltValueEnumConst(wireName: r'image/webp')
  static const PutProfileAvatarRequestContentTypeEnum imageSlashWebp =
      _$putProfileAvatarRequestContentTypeEnum_imageSlashWebp;

  static Serializer<PutProfileAvatarRequestContentTypeEnum> get serializer =>
      _$putProfileAvatarRequestContentTypeEnumSerializer;

  const PutProfileAvatarRequestContentTypeEnum._(String name) : super(name);

  static BuiltSet<PutProfileAvatarRequestContentTypeEnum> get values =>
      _$putProfileAvatarRequestContentTypeEnumValues;
  static PutProfileAvatarRequestContentTypeEnum valueOf(String name) =>
      _$putProfileAvatarRequestContentTypeEnumValueOf(name);
}
