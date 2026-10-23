//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'category_resolution.g.dart';

/// CategoryResolution
///
/// Properties:
/// * [conflictId]
/// * [candidateVersion]
/// * [sourceDeviceId]
/// * [sourceMutationId]
/// * [resolution]
/// * [categoryState]
@BuiltValue()
abstract class CategoryResolution
    implements Built<CategoryResolution, CategoryResolutionBuilder> {
  @BuiltValueField(wireName: r'conflict_id')
  String get conflictId;

  @BuiltValueField(wireName: r'candidate_version')
  int get candidateVersion;

  @BuiltValueField(wireName: r'source_device_id')
  String get sourceDeviceId;

  @BuiltValueField(wireName: r'source_mutation_id')
  String get sourceMutationId;

  @BuiltValueField(wireName: r'resolution')
  CategoryResolutionResolutionEnum get resolution;
  // enum resolutionEnum {  cloud,  local,  };

  @BuiltValueField(wireName: r'category_state')
  Category get categoryState;

  CategoryResolution._();

  factory CategoryResolution([void updates(CategoryResolutionBuilder b)]) =
      _$CategoryResolution;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CategoryResolutionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CategoryResolution> get serializer =>
      _$CategoryResolutionSerializer();
}

class _$CategoryResolutionSerializer
    implements PrimitiveSerializer<CategoryResolution> {
  @override
  final Iterable<Type> types = const [CategoryResolution, _$CategoryResolution];

  @override
  final String wireName = r'CategoryResolution';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CategoryResolution object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'conflict_id';
    yield serializers.serialize(
      object.conflictId,
      specifiedType: const FullType(String),
    );
    yield r'candidate_version';
    yield serializers.serialize(
      object.candidateVersion,
      specifiedType: const FullType(int),
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
    yield r'resolution';
    yield serializers.serialize(
      object.resolution,
      specifiedType: const FullType(CategoryResolutionResolutionEnum),
    );
    yield r'category_state';
    yield serializers.serialize(
      object.categoryState,
      specifiedType: const FullType(Category),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CategoryResolution object, {
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
    required CategoryResolutionBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'conflict_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.conflictId = valueDes;
          break;
        case r'candidate_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.candidateVersion = valueDes;
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
        case r'resolution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CategoryResolutionResolutionEnum),
          ) as CategoryResolutionResolutionEnum;
          result.resolution = valueDes;
          break;
        case r'category_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(Category),
          ) as Category;
          result.categoryState.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CategoryResolution deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CategoryResolutionBuilder();
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

class CategoryResolutionResolutionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cloud')
  static const CategoryResolutionResolutionEnum cloud =
      _$categoryResolutionResolutionEnum_cloud;
  @BuiltValueEnumConst(wireName: r'local')
  static const CategoryResolutionResolutionEnum local =
      _$categoryResolutionResolutionEnum_local;

  static Serializer<CategoryResolutionResolutionEnum> get serializer =>
      _$categoryResolutionResolutionEnumSerializer;

  const CategoryResolutionResolutionEnum._(String name) : super(name);

  static BuiltSet<CategoryResolutionResolutionEnum> get values =>
      _$categoryResolutionResolutionEnumValues;
  static CategoryResolutionResolutionEnum valueOf(String name) =>
      _$categoryResolutionResolutionEnumValueOf(name);
}
