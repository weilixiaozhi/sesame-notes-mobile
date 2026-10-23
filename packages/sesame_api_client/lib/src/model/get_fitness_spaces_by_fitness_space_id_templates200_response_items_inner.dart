//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_catalog_origin.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner
///
/// Properties:
/// * [name]
/// * [exercises]
/// * [catalogOrigin]
/// * [createdAt]
/// * [updatedAt]
/// * [id]
/// * [fitnessSpaceId]
/// * [syncId]
/// * [revision]
/// * [deletedAt]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'exercises')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>
      get exercises;

  @BuiltValueField(wireName: r'catalog_origin')
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin?
      get catalogOrigin;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'fitness_space_id')
  String get fitnessSpaceId;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'deleted_at')
  String? get deletedAt;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner,
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'exercises';
    yield serializers.serialize(
      object.exercises,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner)
      ]),
    );
    if (object.catalogOrigin != null) {
      yield r'catalog_origin';
      yield serializers.serialize(
        object.catalogOrigin,
        specifiedType: const FullType(
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin),
      );
    }
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
    yield r'fitness_space_id';
    yield serializers.serialize(
      object.fitnessSpaceId,
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
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner object, {
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
    required GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder
        result,
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
        case r'exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        case r'catalog_origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin),
          ) as GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin?;
          if (valueDes == null) continue;
          result.catalogOrigin.replace(valueDes);
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
        case r'fitness_space_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fitnessSpaceId = valueDes;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
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
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerBuilder();
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
