//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'memo_entry.g.dart';

/// MemoEntry
///
/// Properties:
/// * [bookType]
/// * [title]
/// * [bodyFormat]
/// * [body]
/// * [orderKey]
/// * [createdAt]
/// * [updatedAt]
/// * [id]
/// * [syncId]
/// * [revision]
/// * [deletedAt]
/// * [memoBookId]
/// * [bookUpdatedAt]
@BuiltValue()
abstract class MemoEntry implements Built<MemoEntry, MemoEntryBuilder> {
  @BuiltValueField(wireName: r'book_type')
  MemoEntryBookTypeEnum get bookType;
  // enum bookTypeEnum {  normal,  credentials,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'body_format')
  MemoEntryBodyFormatEnum? get bodyFormat;
  // enum bodyFormatEnum {  delta_v1,  fields_v1,  };

  @BuiltValueField(wireName: r'body')
  BuiltMap<String, JsonObject?>? get body;

  @BuiltValueField(wireName: r'order_key')
  String? get orderKey;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'memo_book_id')
  String get memoBookId;

  @BuiltValueField(wireName: r'book_updated_at')
  DateTime get bookUpdatedAt;

  MemoEntry._();

  factory MemoEntry([void updates(MemoEntryBuilder b)]) = _$MemoEntry;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MemoEntryBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MemoEntry> get serializer => _$MemoEntrySerializer();
}

class _$MemoEntrySerializer implements PrimitiveSerializer<MemoEntry> {
  @override
  final Iterable<Type> types = const [MemoEntry, _$MemoEntry];

  @override
  final String wireName = r'MemoEntry';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MemoEntry object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'book_type';
    yield serializers.serialize(
      object.bookType,
      specifiedType: const FullType(MemoEntryBookTypeEnum),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'body_format';
    yield object.bodyFormat == null
        ? null
        : serializers.serialize(
            object.bodyFormat,
            specifiedType: const FullType.nullable(MemoEntryBodyFormatEnum),
          );
    yield r'body';
    yield object.body == null
        ? null
        : serializers.serialize(
            object.body,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          );
    yield r'order_key';
    yield object.orderKey == null
        ? null
        : serializers.serialize(
            object.orderKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'deleted_at';
    yield object.deletedAt == null
        ? null
        : serializers.serialize(
            object.deletedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'memo_book_id';
    yield serializers.serialize(
      object.memoBookId,
      specifiedType: const FullType(String),
    );
    yield r'book_updated_at';
    yield serializers.serialize(
      object.bookUpdatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MemoEntry object, {
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
    required MemoEntryBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'book_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(MemoEntryBookTypeEnum),
          ) as MemoEntryBookTypeEnum;
          result.bookType = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'body_format':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(MemoEntryBodyFormatEnum),
          ) as MemoEntryBodyFormatEnum?;
          if (valueDes == null) continue;
          result.bodyFormat = valueDes;
          break;
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>?;
          if (valueDes == null) continue;
          result.body.replace(valueDes);
          break;
        case r'order_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.orderKey = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'memo_book_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memoBookId = valueDes;
          break;
        case r'book_updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.bookUpdatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MemoEntry deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MemoEntryBuilder();
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

class MemoEntryBookTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'normal')
  static const MemoEntryBookTypeEnum normal = _$memoEntryBookTypeEnum_normal;
  @BuiltValueEnumConst(wireName: r'credentials')
  static const MemoEntryBookTypeEnum credentials =
      _$memoEntryBookTypeEnum_credentials;

  static Serializer<MemoEntryBookTypeEnum> get serializer =>
      _$memoEntryBookTypeEnumSerializer;

  const MemoEntryBookTypeEnum._(String name) : super(name);

  static BuiltSet<MemoEntryBookTypeEnum> get values =>
      _$memoEntryBookTypeEnumValues;
  static MemoEntryBookTypeEnum valueOf(String name) =>
      _$memoEntryBookTypeEnumValueOf(name);
}

class MemoEntryBodyFormatEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delta_v1')
  static const MemoEntryBodyFormatEnum deltaV1 =
      _$memoEntryBodyFormatEnum_deltaV1;
  @BuiltValueEnumConst(wireName: r'fields_v1')
  static const MemoEntryBodyFormatEnum fieldsV1 =
      _$memoEntryBodyFormatEnum_fieldsV1;

  static Serializer<MemoEntryBodyFormatEnum> get serializer =>
      _$memoEntryBodyFormatEnumSerializer;

  const MemoEntryBodyFormatEnum._(String name) : super(name);

  static BuiltSet<MemoEntryBodyFormatEnum> get values =>
      _$memoEntryBodyFormatEnumValues;
  static MemoEntryBodyFormatEnum valueOf(String name) =>
      _$memoEntryBodyFormatEnumValueOf(name);
}
