//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of1_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of9_any_of1.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf9AnyOf1
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
abstract class PostSyncPushRequestChangesInnerAnyOf9AnyOf1
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf9AnyOf1,
            PostSyncPushRequestChangesInnerAnyOf9AnyOf1Builder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'entity_type')
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum get entityType;
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
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum get action;
  // enum actionEnum {  delete,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload get payload;

  PostSyncPushRequestChangesInnerAnyOf9AnyOf1._();

  factory PostSyncPushRequestChangesInnerAnyOf9AnyOf1(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf9AnyOf1Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf9AnyOf1Builder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf1>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Serializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf1> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1,
    _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf9AnyOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1 object, {
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
          PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum),
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
          const FullType(PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1 object, {
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
    required PostSyncPushRequestChangesInnerAnyOf9AnyOf1Builder result,
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
                PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum;
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
                PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum;
          result.action = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload),
          ) as PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload;
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
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf9AnyOf1Builder();
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

class PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'memo_book')
  static const PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum
      memoBook =
      _$postSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum_memoBook;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9AnyOf1EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9AnyOf1ActionEnumValueOf(name);
}
