//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11_any_of_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of11_any_of.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf11AnyOf
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [dayBookId]
/// * [memoBookId]
/// * [fitnessSpaceId]
/// * [syncId]
/// * [baseRevision]
/// * [updatedAt]
/// * [action]
/// * [payload]
/// * [deletedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf11AnyOf
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf11AnyOf,
            PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_type')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum get entityType;
  // enum entityTypeEnum {  fitness_template,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'ledger_id')
  String? get ledgerId;

  @BuiltValueField(wireName: r'day_book_id')
  String? get dayBookId;

  @BuiltValueField(wireName: r'memo_book_id')
  String? get memoBookId;

  @BuiltValueField(wireName: r'fitness_space_id')
  String get fitnessSpaceId;

  @BuiltValueField(wireName: r'sync_id')
  String? get syncId;

  @BuiltValueField(wireName: r'base_revision')
  int? get baseRevision;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'action')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum get action;
  // enum actionEnum {  upsert,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload get payload;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  PostSyncPushRequestChangesInnerAnyOf11AnyOf._();

  factory PostSyncPushRequestChangesInnerAnyOf11AnyOf(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf11AnyOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf11AnyOf>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf11AnyOfSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf11AnyOf> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf11AnyOf,
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOf
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf11AnyOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11AnyOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum),
    );
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_id';
    yield object.ledgerId == null
        ? null
        : serializers.serialize(
            object.ledgerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'day_book_id';
    yield object.dayBookId == null
        ? null
        : serializers.serialize(
            object.dayBookId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'memo_book_id';
    yield object.memoBookId == null
        ? null
        : serializers.serialize(
            object.memoBookId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'fitness_space_id';
    yield serializers.serialize(
      object.fitnessSpaceId,
      specifiedType: const FullType(String),
    );
    if (object.syncId != null) {
      yield r'sync_id';
      yield serializers.serialize(
        object.syncId,
        specifiedType: const FullType(String),
      );
    }
    if (object.baseRevision != null) {
      yield r'base_revision';
      yield serializers.serialize(
        object.baseRevision,
        specifiedType: const FullType(int),
      );
    }
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload),
    );
    if (object.deletedAt != null) {
      yield r'deleted_at';
      yield serializers.serialize(
        object.deletedAt,
        specifiedType: const FullType(DateTime),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11AnyOf object, {
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
    required PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder result,
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
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityId = valueDes;
          break;
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ledgerId = valueDes;
          break;
        case r'day_book_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.dayBookId = valueDes;
          break;
        case r'memo_book_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.memoBookId = valueDes;
          break;
        case r'fitness_space_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fitnessSpaceId = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.syncId = valueDes;
          break;
        case r'base_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.baseRevision = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum;
          result.action = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload;
          result.payload.replace(valueDes);
          break;
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf11AnyOfBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_template')
  static const PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum
      fitnessTemplate =
      _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum_fitnessTemplate;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf11AnyOfEntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum upsert =
      _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum_upsert;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf11AnyOfActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf11AnyOfActionEnumValueOf(name);
}
