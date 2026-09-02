//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_auth_register_request_device.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_auth_register_request.g.dart';

/// PostAuthRegisterRequest
///
/// Properties:
/// * [countryCode]
/// * [phone]
/// * [password]
/// * [device]
@BuiltValue()
abstract class PostAuthRegisterRequest
    implements Built<PostAuthRegisterRequest, PostAuthRegisterRequestBuilder> {
  @BuiltValueField(wireName: r'country_code')
  String get countryCode;

  @BuiltValueField(wireName: r'phone')
  String get phone;

  @BuiltValueField(wireName: r'password')
  String get password;

  @BuiltValueField(wireName: r'device')
  PostAuthRegisterRequestDevice get device;

  PostAuthRegisterRequest._();

  factory PostAuthRegisterRequest(
          [void updates(PostAuthRegisterRequestBuilder b)]) =
      _$PostAuthRegisterRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAuthRegisterRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAuthRegisterRequest> get serializer =>
      _$PostAuthRegisterRequestSerializer();
}

class _$PostAuthRegisterRequestSerializer
    implements PrimitiveSerializer<PostAuthRegisterRequest> {
  @override
  final Iterable<Type> types = const [
    PostAuthRegisterRequest,
    _$PostAuthRegisterRequest
  ];

  @override
  final String wireName = r'PostAuthRegisterRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAuthRegisterRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'country_code';
    yield serializers.serialize(
      object.countryCode,
      specifiedType: const FullType(String),
    );
    yield r'phone';
    yield serializers.serialize(
      object.phone,
      specifiedType: const FullType(String),
    );
    yield r'password';
    yield serializers.serialize(
      object.password,
      specifiedType: const FullType(String),
    );
    yield r'device';
    yield serializers.serialize(
      object.device,
      specifiedType: const FullType(PostAuthRegisterRequestDevice),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAuthRegisterRequest object, {
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
    required PostAuthRegisterRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'country_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.countryCode = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.phone = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'device':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAuthRegisterRequestDevice),
          ) as PostAuthRegisterRequestDevice;
          result.device.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAuthRegisterRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAuthRegisterRequestBuilder();
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
