//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6_any_of_payload.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of6_any_of.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf6AnyOf
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [syncId]
/// * [baseRevision]
/// * [action]
/// * [updatedAt]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf6AnyOf
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf6AnyOf,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_type')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum get entityType;
  // enum entityTypeEnum {  recurring_transaction,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'sync_id')
  String? get syncId;

  @BuiltValueField(wireName: r'base_revision')
  int? get baseRevision;

  @BuiltValueField(wireName: r'action')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum get action;
  // enum actionEnum {  upsert,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload get payload;

  PostSyncPushRequestChangesInnerAnyOf6AnyOf._();

  factory PostSyncPushRequestChangesInnerAnyOf6AnyOf(
          [void updates(PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf6AnyOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOf>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfSerializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf6AnyOf> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf6AnyOf,
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOf
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf6AnyOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOf object, {
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
          PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum),
    );
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
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
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOf object, {
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
    required PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder result,
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
                PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum;
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
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
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
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum;
          result.action = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload;
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
  PostSyncPushRequestChangesInnerAnyOf6AnyOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf6AnyOfBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'recurring_transaction')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum
      recurringTransaction =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum_recurringTransaction;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfEntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum upsert =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum_upsert;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6AnyOfActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfActionEnumValueOf(name);
}
