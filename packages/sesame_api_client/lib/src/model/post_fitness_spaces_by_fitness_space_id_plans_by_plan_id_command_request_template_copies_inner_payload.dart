//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_catalog_origin.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_template_copies_inner_payload.g.dart';

/// PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
///
/// Properties:
/// * [name]
/// * [exercises]
/// * [catalogOrigin]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
    implements
        Built<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder> {
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

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload._();

  factory PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload(
          [void updates(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
                  b)]) =
      _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload>
      get serializer =>
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadSerializer();
}

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload> {
  @override
  final Iterable<Type> types = const [
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload,
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
  ];

  @override
  final String wireName =
      r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
        object, {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
        object, {
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
    required PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayloadBuilder();
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
