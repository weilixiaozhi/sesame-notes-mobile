//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_fitness_spaces_full200_response_fitness_space.g.dart';

/// GetSyncFitnessSpacesFull200ResponseFitnessSpace
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
@BuiltValue()
abstract class GetSyncFitnessSpacesFull200ResponseFitnessSpace
    implements
        Built<GetSyncFitnessSpacesFull200ResponseFitnessSpace,
            GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder> {
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

  GetSyncFitnessSpacesFull200ResponseFitnessSpace._();

  factory GetSyncFitnessSpacesFull200ResponseFitnessSpace(
          [void updates(
              GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder b)]) =
      _$GetSyncFitnessSpacesFull200ResponseFitnessSpace;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFitnessSpacesFull200ResponseFitnessSpace>
      get serializer =>
          _$GetSyncFitnessSpacesFull200ResponseFitnessSpaceSerializer();
}

class _$GetSyncFitnessSpacesFull200ResponseFitnessSpaceSerializer
    implements
        PrimitiveSerializer<GetSyncFitnessSpacesFull200ResponseFitnessSpace> {
  @override
  final Iterable<Type> types = const [
    GetSyncFitnessSpacesFull200ResponseFitnessSpace,
    _$GetSyncFitnessSpacesFull200ResponseFitnessSpace
  ];

  @override
  final String wireName = r'GetSyncFitnessSpacesFull200ResponseFitnessSpace';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFitnessSpacesFull200ResponseFitnessSpace object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFitnessSpacesFull200ResponseFitnessSpace object, {
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
    required GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFitnessSpacesFull200ResponseFitnessSpace deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFitnessSpacesFull200ResponseFitnessSpaceBuilder();
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
