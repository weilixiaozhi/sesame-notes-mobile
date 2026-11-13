//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_memo_media_by_media_id200_response.g.dart';

/// PutMemoMediaByMediaId200Response
///
/// Properties:
/// * [id]
/// * [byteSize]
/// * [width]
/// * [height]
/// * [sha256]
@BuiltValue()
abstract class PutMemoMediaByMediaId200Response
    implements
        Built<PutMemoMediaByMediaId200Response,
            PutMemoMediaByMediaId200ResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'byte_size')
  int get byteSize;

  @BuiltValueField(wireName: r'width')
  int get width;

  @BuiltValueField(wireName: r'height')
  int get height;

  @BuiltValueField(wireName: r'sha256')
  String get sha256;

  PutMemoMediaByMediaId200Response._();

  factory PutMemoMediaByMediaId200Response(
          [void updates(PutMemoMediaByMediaId200ResponseBuilder b)]) =
      _$PutMemoMediaByMediaId200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutMemoMediaByMediaId200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutMemoMediaByMediaId200Response> get serializer =>
      _$PutMemoMediaByMediaId200ResponseSerializer();
}

class _$PutMemoMediaByMediaId200ResponseSerializer
    implements PrimitiveSerializer<PutMemoMediaByMediaId200Response> {
  @override
  final Iterable<Type> types = const [
    PutMemoMediaByMediaId200Response,
    _$PutMemoMediaByMediaId200Response
  ];

  @override
  final String wireName = r'PutMemoMediaByMediaId200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutMemoMediaByMediaId200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'byte_size';
    yield serializers.serialize(
      object.byteSize,
      specifiedType: const FullType(int),
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
    yield r'sha256';
    yield serializers.serialize(
      object.sha256,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PutMemoMediaByMediaId200Response object, {
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
    required PutMemoMediaByMediaId200ResponseBuilder result,
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
        case r'byte_size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.byteSize = valueDes;
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
        case r'sha256':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sha256 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PutMemoMediaByMediaId200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutMemoMediaByMediaId200ResponseBuilder();
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
