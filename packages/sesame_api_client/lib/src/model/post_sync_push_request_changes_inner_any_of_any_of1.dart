//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of_any_of1_payload.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of_any_of1.g.dart';

/// PostSyncPushRequestChangesInnerAnyOfAnyOf1
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [dayBookId]
/// * [syncId]
/// * [baseRevision]
/// * [updatedAt]
/// * [action]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOfAnyOf1
    implements
        Built<PostSyncPushRequestChangesInnerAnyOfAnyOf1,
            PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_type')
  PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum get entityType;
  // enum entityTypeEnum {  day_book,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'ledger_id')
  String? get ledgerId;

  @BuiltValueField(wireName: r'day_book_id')
  String get dayBookId;

  @BuiltValueField(wireName: r'sync_id')
  String? get syncId;

  @BuiltValueField(wireName: r'base_revision')
  int? get baseRevision;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'action')
  PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum get action;
  // enum actionEnum {  delete,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload get payload;

  PostSyncPushRequestChangesInnerAnyOfAnyOf1._();

  factory PostSyncPushRequestChangesInnerAnyOfAnyOf1(
          [void updates(PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOfAnyOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOfAnyOf1Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOfAnyOf1,
    _$PostSyncPushRequestChangesInnerAnyOfAnyOf1
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOfAnyOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOfAnyOf1 object, {
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
          PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum),
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
    yield serializers.serialize(
      object.dayBookId,
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
          const FullType(PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOfAnyOf1 object, {
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
    required PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder result,
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
                PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum;
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
            specifiedType: const FullType(String),
          ) as String;
          result.dayBookId = valueDes;
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
                PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum),
          ) as PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum;
          result.action = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload),
          ) as PostSyncPushRequestChangesInnerAnyOfAnyOf1Payload;
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
  PostSyncPushRequestChangesInnerAnyOfAnyOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOfAnyOf1Builder();
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

class PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'day_book')
  static const PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum
      dayBook =
      _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum_dayBook;

  static Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOfAnyOf1EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOfAnyOf1ActionEnumValueOf(name);
}
