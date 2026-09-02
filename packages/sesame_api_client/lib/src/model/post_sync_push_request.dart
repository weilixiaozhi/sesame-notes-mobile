//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request.g.dart';

/// PostSyncPushRequest
///
/// Properties:
/// * [deviceId]
/// * [changes]
@BuiltValue()
abstract class PostSyncPushRequest
    implements Built<PostSyncPushRequest, PostSyncPushRequestBuilder> {
  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  @BuiltValueField(wireName: r'changes')
  BuiltList<PostSyncPushRequestChangesInner> get changes;

  PostSyncPushRequest._();

  factory PostSyncPushRequest([void updates(PostSyncPushRequestBuilder b)]) =
      _$PostSyncPushRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequest> get serializer =>
      _$PostSyncPushRequestSerializer();
}

class _$PostSyncPushRequestSerializer
    implements PrimitiveSerializer<PostSyncPushRequest> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequest,
    _$PostSyncPushRequest
  ];

  @override
  final String wireName = r'PostSyncPushRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
    yield r'changes';
    yield serializers.serialize(
      object.changes,
      specifiedType: const FullType(
          BuiltList, [FullType(PostSyncPushRequestChangesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequest object, {
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
    required PostSyncPushRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'changes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PostSyncPushRequestChangesInner)]),
          ) as BuiltList<PostSyncPushRequestChangesInner>;
          result.changes.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestBuilder();
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
