//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_auth_refresh_request.g.dart';

/// PostAuthRefreshRequest
///
/// Properties:
/// * [refreshToken]
/// * [device]
@BuiltValue()
abstract class PostAuthRefreshRequest
    implements Built<PostAuthRefreshRequest, PostAuthRefreshRequestBuilder> {
  @BuiltValueField(wireName: r'refresh_token')
  String get refreshToken;

  @BuiltValueField(wireName: r'device')
  JsonObject? get device;

  PostAuthRefreshRequest._();

  factory PostAuthRefreshRequest(
          [void updates(PostAuthRefreshRequestBuilder b)]) =
      _$PostAuthRefreshRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAuthRefreshRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAuthRefreshRequest> get serializer =>
      _$PostAuthRefreshRequestSerializer();
}

class _$PostAuthRefreshRequestSerializer
    implements PrimitiveSerializer<PostAuthRefreshRequest> {
  @override
  final Iterable<Type> types = const [
    PostAuthRefreshRequest,
    _$PostAuthRefreshRequest
  ];

  @override
  final String wireName = r'PostAuthRefreshRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAuthRefreshRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'refresh_token';
    yield serializers.serialize(
      object.refreshToken,
      specifiedType: const FullType(String),
    );
    if (object.device != null) {
      yield r'device';
      yield serializers.serialize(
        object.device,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAuthRefreshRequest object, {
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
    required PostAuthRefreshRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'refresh_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'device':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.device = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAuthRefreshRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAuthRefreshRequestBuilder();
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
