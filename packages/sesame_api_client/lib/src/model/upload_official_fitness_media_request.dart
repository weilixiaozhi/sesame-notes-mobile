//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_official_fitness_media_request.g.dart';

/// UploadOfficialFitnessMediaRequest
///
/// Properties:
/// * [filename]
/// * [dataBase64]
@BuiltValue()
abstract class UploadOfficialFitnessMediaRequest
    implements
        Built<UploadOfficialFitnessMediaRequest,
            UploadOfficialFitnessMediaRequestBuilder> {
  @BuiltValueField(wireName: r'filename')
  String get filename;

  @BuiltValueField(wireName: r'data_base64')
  String get dataBase64;

  UploadOfficialFitnessMediaRequest._();

  factory UploadOfficialFitnessMediaRequest(
          [void updates(UploadOfficialFitnessMediaRequestBuilder b)]) =
      _$UploadOfficialFitnessMediaRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadOfficialFitnessMediaRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadOfficialFitnessMediaRequest> get serializer =>
      _$UploadOfficialFitnessMediaRequestSerializer();
}

class _$UploadOfficialFitnessMediaRequestSerializer
    implements PrimitiveSerializer<UploadOfficialFitnessMediaRequest> {
  @override
  final Iterable<Type> types = const [
    UploadOfficialFitnessMediaRequest,
    _$UploadOfficialFitnessMediaRequest
  ];

  @override
  final String wireName = r'UploadOfficialFitnessMediaRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadOfficialFitnessMediaRequest object, {
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
    UploadOfficialFitnessMediaRequest object, {
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
    required UploadOfficialFitnessMediaRequestBuilder result,
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
  UploadOfficialFitnessMediaRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadOfficialFitnessMediaRequestBuilder();
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
