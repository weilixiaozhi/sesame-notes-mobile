//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of8_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload
///
/// Properties:
/// * [displayName]
/// * [initialStatus]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'initial_status')
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum?
      get initialStatus;
  // enum initialStatusEnum {  ACTIVE,  LEFT,  REMOVED,  };

  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    if (object.initialStatus != null) {
      yield r'initial_status';
      yield serializers.serialize(
        object.initialStatus,
        specifiedType: const FullType(
            PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'initial_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum?;
          if (valueDes == null) continue;
          result.initialStatus = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf8AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ACTIVE')
  static const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
      ACTIVE =
      _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_ACTIVE;
  @BuiltValueEnumConst(wireName: r'LEFT')
  static const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
      LEFT =
      _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_LEFT;
  @BuiltValueEnumConst(wireName: r'REMOVED')
  static const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum
      REMOVED =
      _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum_REMOVED;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf8AnyOfPayloadInitialStatusEnumValueOf(
          name);
}
