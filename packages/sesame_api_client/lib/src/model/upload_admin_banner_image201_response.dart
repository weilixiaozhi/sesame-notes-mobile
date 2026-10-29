//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_admin_banner_image201_response.g.dart';

/// UploadAdminBannerImage201Response
///
/// Properties:
/// * [id]
/// * [imagePath]
/// * [width]
/// * [height]
@BuiltValue()
abstract class UploadAdminBannerImage201Response
    implements
        Built<UploadAdminBannerImage201Response,
            UploadAdminBannerImage201ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'image_path')
  String get imagePath;

  @BuiltValueField(wireName: r'width')
  int get width;

  @BuiltValueField(wireName: r'height')
  int get height;

  UploadAdminBannerImage201Response._();

  factory UploadAdminBannerImage201Response(
          [void updates(UploadAdminBannerImage201ResponseBuilder b)]) =
      _$UploadAdminBannerImage201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadAdminBannerImage201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadAdminBannerImage201Response> get serializer =>
      _$UploadAdminBannerImage201ResponseSerializer();
}

class _$UploadAdminBannerImage201ResponseSerializer
    implements PrimitiveSerializer<UploadAdminBannerImage201Response> {
  @override
  final Iterable<Type> types = const [
    UploadAdminBannerImage201Response,
    _$UploadAdminBannerImage201Response
  ];

  @override
  final String wireName = r'UploadAdminBannerImage201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadAdminBannerImage201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'image_path';
    yield serializers.serialize(
      object.imagePath,
      specifiedType: const FullType(String),
    );
    yield r'width';
    yield serializers.serialize(
      object.width,
      specifiedType: const FullType(int),
    );
    yield r'height';
    yield serializers.serialize(
      object.height,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UploadAdminBannerImage201Response object, {
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
    required UploadAdminBannerImage201ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'image_path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imagePath = valueDes;
          break;
        case r'width':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.width = valueDes;
          break;
        case r'height':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.height = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UploadAdminBannerImage201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadAdminBannerImage201ResponseBuilder();
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
