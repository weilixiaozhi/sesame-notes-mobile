//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of9_any_of.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf9AnyOf
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [dayBookId]
/// * [memoBookId]
/// * [syncId]
/// * [baseRevision]
/// * [updatedAt]
/// * [action]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf9AnyOf
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf9AnyOf,
            PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_type')
  PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum get entityType;
  // enum entityTypeEnum {  memo_book,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'ledger_id')
  String? get ledgerId;

  @BuiltValueField(wireName: r'day_book_id')
  String? get dayBookId;

  @BuiltValueField(wireName: r'memo_book_id')
  String get memoBookId;

  @BuiltValueField(wireName: r'sync_id')
  String? get syncId;

  @BuiltValueField(wireName: r'base_revision')
  int? get baseRevision;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'action')
  PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum get action;
  // enum actionEnum {  upsert,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload get payload;

  PostSyncPushRequestChangesInnerAnyOf9AnyOf._();

  factory PostSyncPushRequestChangesInnerAnyOf9AnyOf(
          [void updates(PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf9AnyOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf9AnyOfSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOfSerializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf9AnyOf,
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOf
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf9AnyOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOf object, {
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
          PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum),
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
    yield serializers.serialize(
      object.memoBookId,
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
          const FullType(PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOf object, {
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
    required PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder result,
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
                PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum;
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
            specifiedType: const FullType(String),
          ) as String;
          result.memoBookId = valueDes;
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
                PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum;
          result.action = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOfPayload;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf9AnyOfBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'memo_book')
  static const PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum
      memoBook =
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum_memoBook;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfEntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum upsert =
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum_upsert;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9AnyOfActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9AnyOfActionEnumValueOf(name);
}
