//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push200_response_outcomes_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push200_response.g.dart';

/// PostSyncPush200Response
///
/// Properties:
/// * [outcomes]
/// * [serverCursor]
@BuiltValue()
abstract class PostSyncPush200Response
    implements Built<PostSyncPush200Response, PostSyncPush200ResponseBuilder> {
  @BuiltValueField(wireName: r'outcomes')
  BuiltList<PostSyncPush200ResponseOutcomesInner> get outcomes;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  PostSyncPush200Response._();

  factory PostSyncPush200Response(
          [void updates(PostSyncPush200ResponseBuilder b)]) =
      _$PostSyncPush200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPush200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPush200Response> get serializer =>
      _$PostSyncPush200ResponseSerializer();
}

class _$PostSyncPush200ResponseSerializer
    implements PrimitiveSerializer<PostSyncPush200Response> {
  @override
  final Iterable<Type> types = const [
    PostSyncPush200Response,
    _$PostSyncPush200Response
  ];

  @override
  final String wireName = r'PostSyncPush200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPush200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'outcomes';
    yield serializers.serialize(
      object.outcomes,
      specifiedType: const FullType(
          BuiltList, [FullType(PostSyncPush200ResponseOutcomesInner)]),
    );
    yield r'server_cursor';
    yield serializers.serialize(
      object.serverCursor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPush200Response object, {
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
    required PostSyncPush200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'outcomes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PostSyncPush200ResponseOutcomesInner)]),
          ) as BuiltList<PostSyncPush200ResponseOutcomesInner>;
          result.outcomes.replace(valueDes);
          break;
        case r'server_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPush200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPush200ResponseBuilder();
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
