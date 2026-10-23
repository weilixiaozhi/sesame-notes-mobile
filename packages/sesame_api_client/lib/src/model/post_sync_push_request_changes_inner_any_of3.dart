//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of3.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf3
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [syncId]
/// * [action]
/// * [updatedAt]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf3
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf3,
            PostSyncPushRequestChangesInnerAnyOf3Builder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_type')
  PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum get entityType;
  // enum entityTypeEnum {  ledger_archive,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'action')
  PostSyncPushRequestChangesInnerAnyOf3ActionEnum get action;
  // enum actionEnum {  upsert,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf3Payload get payload;

  PostSyncPushRequestChangesInnerAnyOf3._();

  factory PostSyncPushRequestChangesInnerAnyOf3(
          [void updates(PostSyncPushRequestChangesInnerAnyOf3Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf3> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf3Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf3Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf3> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf3,
    _$PostSyncPushRequestChangesInnerAnyOf3
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3 object, {
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
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum),
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
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf3ActionEnum),
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
          const FullType(PostSyncPushRequestChangesInnerAnyOf3Payload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3 object, {
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
    required PostSyncPushRequestChangesInnerAnyOf3Builder result,
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
                PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum;
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
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostSyncPushRequestChangesInnerAnyOf3ActionEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf3ActionEnum;
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
            specifiedType:
                const FullType(PostSyncPushRequestChangesInnerAnyOf3Payload),
          ) as PostSyncPushRequestChangesInnerAnyOf3Payload;
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
  PostSyncPushRequestChangesInnerAnyOf3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf3Builder();
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

class PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ledger_archive')
  static const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
      ledgerArchive =
      _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_ledgerArchive;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf3ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const PostSyncPushRequestChangesInnerAnyOf3ActionEnum upsert =
      _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_upsert;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf3ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf3ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf3ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf3ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValueOf(name);
}
