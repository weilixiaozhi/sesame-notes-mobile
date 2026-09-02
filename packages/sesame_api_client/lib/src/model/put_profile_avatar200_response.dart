//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'put_profile_avatar200_response.g.dart';

/// PutProfileAvatar200Response
///
/// Properties:
/// * [avatarUrl]
/// * [avatarVersion]
@BuiltValue()
abstract class PutProfileAvatar200Response
    implements
        Built<PutProfileAvatar200Response, PutProfileAvatar200ResponseBuilder> {
  @BuiltValueField(wireName: r'avatar_url')
  String get avatarUrl;

  @BuiltValueField(wireName: r'avatar_version')
  int get avatarVersion;

  PutProfileAvatar200Response._();

  factory PutProfileAvatar200Response(
          [void updates(PutProfileAvatar200ResponseBuilder b)]) =
      _$PutProfileAvatar200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PutProfileAvatar200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PutProfileAvatar200Response> get serializer =>
      _$PutProfileAvatar200ResponseSerializer();
}

class _$PutProfileAvatar200ResponseSerializer
    implements PrimitiveSerializer<PutProfileAvatar200Response> {
  @override
  final Iterable<Type> types = const [
    PutProfileAvatar200Response,
    _$PutProfileAvatar200Response
  ];

  @override
  final String wireName = r'PutProfileAvatar200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PutProfileAvatar200Response object, {
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
    PutProfileAvatar200Response object, {
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
    required PutProfileAvatar200ResponseBuilder result,
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
  PutProfileAvatar200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PutProfileAvatar200ResponseBuilder();
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
