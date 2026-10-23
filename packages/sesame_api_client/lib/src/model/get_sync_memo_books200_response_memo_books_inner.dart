//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_memo_books200_response_memo_books_inner.g.dart';

/// GetSyncMemoBooks200ResponseMemoBooksInner
///
/// Properties:
/// * [name]
/// * [createdAt]
/// * [updatedAt]
/// * [restore]
/// * [expectedFullCursor]
/// * [type]
/// * [id]
/// * [syncId]
/// * [revision]
/// * [deletedAt]
/// * [entryCount]
@BuiltValue()
abstract class GetSyncMemoBooks200ResponseMemoBooksInner
    implements
        Built<GetSyncMemoBooks200ResponseMemoBooksInner,
            GetSyncMemoBooks200ResponseMemoBooksInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'restore')
  bool? get restore;

  @BuiltValueField(wireName: r'expected_full_cursor')
  String? get expectedFullCursor;

  @BuiltValueField(wireName: r'type')
  GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum get type;
  // enum typeEnum {  normal,  credentials,  };

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'entry_count')
  int get entryCount;

  GetSyncMemoBooks200ResponseMemoBooksInner._();

  factory GetSyncMemoBooks200ResponseMemoBooksInner(
          [void updates(GetSyncMemoBooks200ResponseMemoBooksInnerBuilder b)]) =
      _$GetSyncMemoBooks200ResponseMemoBooksInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncMemoBooks200ResponseMemoBooksInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncMemoBooks200ResponseMemoBooksInner> get serializer =>
      _$GetSyncMemoBooks200ResponseMemoBooksInnerSerializer();
}

class _$GetSyncMemoBooks200ResponseMemoBooksInnerSerializer
    implements PrimitiveSerializer<GetSyncMemoBooks200ResponseMemoBooksInner> {
  @override
  final Iterable<Type> types = const [
    GetSyncMemoBooks200ResponseMemoBooksInner,
    _$GetSyncMemoBooks200ResponseMemoBooksInner
  ];

  @override
  final String wireName = r'GetSyncMemoBooks200ResponseMemoBooksInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncMemoBooks200ResponseMemoBooksInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
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
    if (object.restore != null) {
      yield r'restore';
      yield serializers.serialize(
        object.restore,
        specifiedType: const FullType(bool),
      );
    }
    if (object.expectedFullCursor != null) {
      yield r'expected_full_cursor';
      yield serializers.serialize(
        object.expectedFullCursor,
        specifiedType: const FullType(String),
      );
    }
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType:
          const FullType(GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum),
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
    yield r'entry_count';
    yield serializers.serialize(
      object.entryCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncMemoBooks200ResponseMemoBooksInner object, {
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
    required GetSyncMemoBooks200ResponseMemoBooksInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
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
        case r'restore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.restore = valueDes;
          break;
        case r'expected_full_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.expectedFullCursor = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum),
          ) as GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum;
          result.type = valueDes;
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
        case r'entry_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.entryCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncMemoBooks200ResponseMemoBooksInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncMemoBooks200ResponseMemoBooksInnerBuilder();
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

class GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'normal')
  static const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum normal =
      _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_normal;
  @BuiltValueEnumConst(wireName: r'credentials')
  static const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum credentials =
      _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnum_credentials;

  static Serializer<GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum>
      get serializer =>
          _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnumSerializer;

  const GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum._(String name)
      : super(name);

  static BuiltSet<GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum>
      get values => _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnumValues;
  static GetSyncMemoBooks200ResponseMemoBooksInnerTypeEnum valueOf(
          String name) =>
      _$getSyncMemoBooks200ResponseMemoBooksInnerTypeEnumValueOf(name);
}
