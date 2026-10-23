//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upload_official_fitness_media201_response.g.dart';

/// UploadOfficialFitnessMedia201Response
///
/// Properties:
/// * [id]
/// * [url]
/// * [width]
/// * [height]
/// * [frames]
/// * [byteSize]
@BuiltValue()
abstract class UploadOfficialFitnessMedia201Response
    implements
        Built<UploadOfficialFitnessMedia201Response,
            UploadOfficialFitnessMedia201ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'width')
  int get width;

  @BuiltValueField(wireName: r'height')
  int get height;

  @BuiltValueField(wireName: r'frames')
  int get frames;

  @BuiltValueField(wireName: r'byte_size')
  int get byteSize;

  UploadOfficialFitnessMedia201Response._();

  factory UploadOfficialFitnessMedia201Response(
          [void updates(UploadOfficialFitnessMedia201ResponseBuilder b)]) =
      _$UploadOfficialFitnessMedia201Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UploadOfficialFitnessMedia201ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UploadOfficialFitnessMedia201Response> get serializer =>
      _$UploadOfficialFitnessMedia201ResponseSerializer();
}

class _$UploadOfficialFitnessMedia201ResponseSerializer
    implements PrimitiveSerializer<UploadOfficialFitnessMedia201Response> {
  @override
  final Iterable<Type> types = const [
    UploadOfficialFitnessMedia201Response,
    _$UploadOfficialFitnessMedia201Response
  ];

  @override
  final String wireName = r'UploadOfficialFitnessMedia201Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UploadOfficialFitnessMedia201Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
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
    yield r'frames';
    yield serializers.serialize(
      object.frames,
      specifiedType: const FullType(int),
    );
    yield r'byte_size';
    yield serializers.serialize(
      object.byteSize,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UploadOfficialFitnessMedia201Response object, {
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
    required UploadOfficialFitnessMedia201ResponseBuilder result,
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
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
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
        case r'frames':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.frames = valueDes;
          break;
        case r'byte_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.byteSize = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UploadOfficialFitnessMedia201Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UploadOfficialFitnessMedia201ResponseBuilder();
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
