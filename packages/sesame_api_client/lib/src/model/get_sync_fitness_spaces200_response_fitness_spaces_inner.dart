//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_fitness_spaces200_response_fitness_spaces_inner.g.dart';

/// GetSyncFitnessSpaces200ResponseFitnessSpacesInner
///
/// Properties:
/// * [name]
/// * [createdAt]
/// * [updatedAt]
/// * [restore]
/// * [expectedFullCursor]
/// * [id]
/// * [syncId]
/// * [revision]
/// * [deletedAt]
/// * [entityCount]
@BuiltValue()
abstract class GetSyncFitnessSpaces200ResponseFitnessSpacesInner
    implements
        Built<GetSyncFitnessSpaces200ResponseFitnessSpacesInner,
            GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder> {
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

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'entity_count')
  int get entityCount;

  GetSyncFitnessSpaces200ResponseFitnessSpacesInner._();

  factory GetSyncFitnessSpaces200ResponseFitnessSpacesInner(
          [void updates(
              GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder b)]) =
      _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFitnessSpaces200ResponseFitnessSpacesInner>
      get serializer =>
          _$GetSyncFitnessSpaces200ResponseFitnessSpacesInnerSerializer();
}

class _$GetSyncFitnessSpaces200ResponseFitnessSpacesInnerSerializer
    implements
        PrimitiveSerializer<GetSyncFitnessSpaces200ResponseFitnessSpacesInner> {
  @override
  final Iterable<Type> types = const [
    GetSyncFitnessSpaces200ResponseFitnessSpacesInner,
    _$GetSyncFitnessSpaces200ResponseFitnessSpacesInner
  ];

  @override
  final String wireName = r'GetSyncFitnessSpaces200ResponseFitnessSpacesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFitnessSpaces200ResponseFitnessSpacesInner object, {
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
    yield r'entity_count';
    yield serializers.serialize(
      object.entityCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFitnessSpaces200ResponseFitnessSpacesInner object, {
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
    required GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder result,
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
        case r'entity_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.entityCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFitnessSpaces200ResponseFitnessSpacesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFitnessSpaces200ResponseFitnessSpacesInnerBuilder();
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
