//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:sesame_api_client/src/model/category_conflict_local_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category_conflict.g.dart';

/// CategoryConflict
///
/// Properties:
/// * [id]
/// * [categoryId]
/// * [templateKey]
/// * [sourceDeviceId]
/// * [sourceMutationId]
/// * [candidateVersion]
/// * [action]
/// * [localPayload]
/// * [localUpdatedAt]
/// * [cloudSnapshot]
/// * [status]
/// * [resolution]
/// * [createdAt]
/// * [resolvedAt]
@BuiltValue()
abstract class CategoryConflict
    implements Built<CategoryConflict, CategoryConflictBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'category_id')
  String get categoryId;

  @BuiltValueField(wireName: r'template_key')
  String get templateKey;

  @BuiltValueField(wireName: r'source_device_id')
  String get sourceDeviceId;

  @BuiltValueField(wireName: r'source_mutation_id')
  String get sourceMutationId;

  @BuiltValueField(wireName: r'candidate_version')
  int get candidateVersion;

  @BuiltValueField(wireName: r'action')
  CategoryConflictActionEnum get action;
  // enum actionEnum {  upsert,  delete,  };

  @BuiltValueField(wireName: r'local_payload')
  CategoryConflictLocalPayload? get localPayload;

  @BuiltValueField(wireName: r'local_updated_at')
  DateTime get localUpdatedAt;

  @BuiltValueField(wireName: r'cloud_snapshot')
  Category get cloudSnapshot;

  @BuiltValueField(wireName: r'status')
  CategoryConflictStatusEnum get status;
  // enum statusEnum {  pending,  resolved,  };

  @BuiltValueField(wireName: r'resolution')
  CategoryConflictResolutionEnum? get resolution;
  // enum resolutionEnum {  cloud,  local,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'resolved_at')
  DateTime? get resolvedAt;

  CategoryConflict._();

  factory CategoryConflict([void updates(CategoryConflictBuilder b)]) =
      _$CategoryConflict;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CategoryConflictBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CategoryConflict> get serializer =>
      _$CategoryConflictSerializer();
}

class _$CategoryConflictSerializer
    implements PrimitiveSerializer<CategoryConflict> {
  @override
  final Iterable<Type> types = const [CategoryConflict, _$CategoryConflict];

  @override
  final String wireName = r'CategoryConflict';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CategoryConflict object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'category_id';
    yield serializers.serialize(
      object.categoryId,
      specifiedType: const FullType(String),
    );
    yield r'template_key';
    yield serializers.serialize(
      object.templateKey,
      specifiedType: const FullType(String),
    );
    yield r'source_device_id';
    yield serializers.serialize(
      object.sourceDeviceId,
      specifiedType: const FullType(String),
    );
    yield r'source_mutation_id';
    yield serializers.serialize(
      object.sourceMutationId,
      specifiedType: const FullType(String),
    );
    yield r'candidate_version';
    yield serializers.serialize(
      object.candidateVersion,
      specifiedType: const FullType(int),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(CategoryConflictActionEnum),
    );
    yield r'local_payload';
    yield object.localPayload == null
        ? null
        : serializers.serialize(
            object.localPayload,
            specifiedType:
                const FullType.nullable(CategoryConflictLocalPayload),
          );
    yield r'local_updated_at';
    yield serializers.serialize(
      object.localUpdatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'cloud_snapshot';
    yield serializers.serialize(
      object.cloudSnapshot,
      specifiedType: const FullType(Category),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(CategoryConflictStatusEnum),
    );
    yield r'resolution';
    yield object.resolution == null
        ? null
        : serializers.serialize(
            object.resolution,
            specifiedType:
                const FullType.nullable(CategoryConflictResolutionEnum),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'resolved_at';
    yield object.resolvedAt == null
        ? null
        : serializers.serialize(
            object.resolvedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    CategoryConflict object, {
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
    required CategoryConflictBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.categoryId = valueDes;
          break;
        case r'template_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.templateKey = valueDes;
          break;
        case r'source_device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceDeviceId = valueDes;
          break;
        case r'source_mutation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sourceMutationId = valueDes;
          break;
        case r'candidate_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.candidateVersion = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CategoryConflictActionEnum),
          ) as CategoryConflictActionEnum;
          result.action = valueDes;
          break;
        case r'local_payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(CategoryConflictLocalPayload),
          ) as CategoryConflictLocalPayload?;
          if (valueDes == null) continue;
          result.localPayload.replace(valueDes);
          break;
        case r'local_updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.localUpdatedAt = valueDes;
          break;
        case r'cloud_snapshot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Category),
          ) as Category;
          result.cloudSnapshot.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CategoryConflictStatusEnum),
          ) as CategoryConflictStatusEnum;
          result.status = valueDes;
          break;
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(CategoryConflictResolutionEnum),
          ) as CategoryConflictResolutionEnum?;
          if (valueDes == null) continue;
          result.resolution = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'resolved_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.resolvedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CategoryConflict deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CategoryConflictBuilder();
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

class CategoryConflictActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const CategoryConflictActionEnum upsert =
      _$categoryConflictActionEnum_upsert;
  @BuiltValueEnumConst(wireName: r'delete')
  static const CategoryConflictActionEnum delete =
      _$categoryConflictActionEnum_delete;

  static Serializer<CategoryConflictActionEnum> get serializer =>
      _$categoryConflictActionEnumSerializer;

  const CategoryConflictActionEnum._(String name) : super(name);

  static BuiltSet<CategoryConflictActionEnum> get values =>
      _$categoryConflictActionEnumValues;
  static CategoryConflictActionEnum valueOf(String name) =>
      _$categoryConflictActionEnumValueOf(name);
}

class CategoryConflictStatusEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'pending')
  static const CategoryConflictStatusEnum pending =
      _$categoryConflictStatusEnum_pending;
  @BuiltValueEnumConst(wireName: r'resolved')
  static const CategoryConflictStatusEnum resolved =
      _$categoryConflictStatusEnum_resolved;

  static Serializer<CategoryConflictStatusEnum> get serializer =>
      _$categoryConflictStatusEnumSerializer;

  const CategoryConflictStatusEnum._(String name) : super(name);

  static BuiltSet<CategoryConflictStatusEnum> get values =>
      _$categoryConflictStatusEnumValues;
  static CategoryConflictStatusEnum valueOf(String name) =>
      _$categoryConflictStatusEnumValueOf(name);
}

class CategoryConflictResolutionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cloud')
  static const CategoryConflictResolutionEnum cloud =
      _$categoryConflictResolutionEnum_cloud;
  @BuiltValueEnumConst(wireName: r'local')
  static const CategoryConflictResolutionEnum local =
      _$categoryConflictResolutionEnum_local;

  static Serializer<CategoryConflictResolutionEnum> get serializer =>
      _$categoryConflictResolutionEnumSerializer;

  const CategoryConflictResolutionEnum._(String name) : super(name);

  static BuiltSet<CategoryConflictResolutionEnum> get values =>
      _$categoryConflictResolutionEnumValues;
  static CategoryConflictResolutionEnum valueOf(String name) =>
      _$categoryConflictResolutionEnumValueOf(name);
}
