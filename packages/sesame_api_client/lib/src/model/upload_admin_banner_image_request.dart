//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_admin_banner_image_request.g.dart';

/// UploadAdminBannerImageRequest
///
/// Properties:
/// * [filename]
/// * [dataBase64]
@BuiltValue()
abstract class UploadAdminBannerImageRequest
    implements
        Built<UploadAdminBannerImageRequest,
            UploadAdminBannerImageRequestBuilder> {
  @BuiltValueField(wireName: r'filename')
  String get filename;

  @BuiltValueField(wireName: r'data_base64')
  String get dataBase64;

  UploadAdminBannerImageRequest._();

  factory UploadAdminBannerImageRequest(
          [void updates(UploadAdminBannerImageRequestBuilder b)]) =
      _$UploadAdminBannerImageRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadAdminBannerImageRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadAdminBannerImageRequest> get serializer =>
      _$UploadAdminBannerImageRequestSerializer();
}

class _$UploadAdminBannerImageRequestSerializer
    implements PrimitiveSerializer<UploadAdminBannerImageRequest> {
  @override
  final Iterable<Type> types = const [
    UploadAdminBannerImageRequest,
    _$UploadAdminBannerImageRequest
  ];

  @override
  final String wireName = r'UploadAdminBannerImageRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadAdminBannerImageRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'filename';
    yield serializers.serialize(
      object.filename,
      specifiedType: const FullType(String),
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
    UploadAdminBannerImageRequest object, {
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
    required UploadAdminBannerImageRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'filename':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.filename = valueDes;
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
  UploadAdminBannerImageRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadAdminBannerImageRequestBuilder();
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
