//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push200_response_outcomes_inner.g.dart';

/// PostSyncPush200ResponseOutcomesInner
///
/// Properties:
/// * [mutationId]
/// * [entityId]
/// * [status]
/// * [changeId]
/// * [syncId]
/// * [revision]
/// * [currentRevision]
/// * [currentDeleted]
/// * [currentEntity]
/// * [message]
@BuiltValue()
abstract class PostSyncPush200ResponseOutcomesInner
    implements
        Built<PostSyncPush200ResponseOutcomesInner,
            PostSyncPush200ResponseOutcomesInnerBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'status')
  PostSyncPush200ResponseOutcomesInnerStatusEnum get status;
  // enum statusEnum {  accepted,  ignored,  conflict,  invalid,  };

  @BuiltValueField(wireName: r'change_id')
  String? get changeId;

  @BuiltValueField(wireName: r'sync_id')
  String? get syncId;

  @BuiltValueField(wireName: r'revision')
  int? get revision;

  @BuiltValueField(wireName: r'current_revision')
  int? get currentRevision;

  @BuiltValueField(wireName: r'current_deleted')
  bool? get currentDeleted;

  @BuiltValueField(wireName: r'current_entity')
  JsonObject? get currentEntity;

  @BuiltValueField(wireName: r'message')
  String? get message;

  PostSyncPush200ResponseOutcomesInner._();

  factory PostSyncPush200ResponseOutcomesInner(
          [void updates(PostSyncPush200ResponseOutcomesInnerBuilder b)]) =
      _$PostSyncPush200ResponseOutcomesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPush200ResponseOutcomesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPush200ResponseOutcomesInner> get serializer =>
      _$PostSyncPush200ResponseOutcomesInnerSerializer();
}

class _$PostSyncPush200ResponseOutcomesInnerSerializer
    implements PrimitiveSerializer<PostSyncPush200ResponseOutcomesInner> {
  @override
  final Iterable<Type> types = const [
    PostSyncPush200ResponseOutcomesInner,
    _$PostSyncPush200ResponseOutcomesInner
  ];

  @override
  final String wireName = r'PostSyncPush200ResponseOutcomesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPush200ResponseOutcomesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType:
          const FullType(PostSyncPush200ResponseOutcomesInnerStatusEnum),
    );
    yield r'change_id';
    yield object.changeId == null
        ? null
        : serializers.serialize(
            object.changeId,
            specifiedType: const FullType.nullable(String),
          );
    if (object.syncId != null) {
      yield r'sync_id';
      yield serializers.serialize(
        object.syncId,
        specifiedType: const FullType(String),
      );
    }
    if (object.revision != null) {
      yield r'revision';
      yield serializers.serialize(
        object.revision,
        specifiedType: const FullType(int),
      );
    }
    if (object.currentRevision != null) {
      yield r'current_revision';
      yield serializers.serialize(
        object.currentRevision,
        specifiedType: const FullType(int),
      );
    }
    if (object.currentDeleted != null) {
      yield r'current_deleted';
      yield serializers.serialize(
        object.currentDeleted,
        specifiedType: const FullType(bool),
      );
    }
    if (object.currentEntity != null) {
      yield r'current_entity';
      yield serializers.serialize(
        object.currentEntity,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPush200ResponseOutcomesInner object, {
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
    required PostSyncPush200ResponseOutcomesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mutation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mutationId = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostSyncPush200ResponseOutcomesInnerStatusEnum),
          ) as PostSyncPush200ResponseOutcomesInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'change_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.changeId = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.syncId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.revision = valueDes;
          break;
        case r'current_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.currentRevision = valueDes;
          break;
        case r'current_deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.currentDeleted = valueDes;
          break;
        case r'current_entity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.currentEntity = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPush200ResponseOutcomesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPush200ResponseOutcomesInnerBuilder();
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

class PostSyncPush200ResponseOutcomesInnerStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'accepted')
  static const PostSyncPush200ResponseOutcomesInnerStatusEnum accepted =
      _$postSyncPush200ResponseOutcomesInnerStatusEnum_accepted;
  @BuiltValueEnumConst(wireName: r'ignored')
  static const PostSyncPush200ResponseOutcomesInnerStatusEnum ignored =
      _$postSyncPush200ResponseOutcomesInnerStatusEnum_ignored;
  @BuiltValueEnumConst(wireName: r'conflict')
  static const PostSyncPush200ResponseOutcomesInnerStatusEnum conflict =
      _$postSyncPush200ResponseOutcomesInnerStatusEnum_conflict;
  @BuiltValueEnumConst(wireName: r'invalid')
  static const PostSyncPush200ResponseOutcomesInnerStatusEnum invalid =
      _$postSyncPush200ResponseOutcomesInnerStatusEnum_invalid;

  static Serializer<PostSyncPush200ResponseOutcomesInnerStatusEnum>
      get serializer =>
          _$postSyncPush200ResponseOutcomesInnerStatusEnumSerializer;

  const PostSyncPush200ResponseOutcomesInnerStatusEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPush200ResponseOutcomesInnerStatusEnum> get values =>
      _$postSyncPush200ResponseOutcomesInnerStatusEnumValues;
  static PostSyncPush200ResponseOutcomesInnerStatusEnum valueOf(String name) =>
      _$postSyncPush200ResponseOutcomesInnerStatusEnumValueOf(name);
}
