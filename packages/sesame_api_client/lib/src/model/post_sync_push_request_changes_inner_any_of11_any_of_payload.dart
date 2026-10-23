//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11_any_of_payload_catalog_origin.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of11_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload
///
/// Properties:
/// * [name]
/// * [exercises]
/// * [catalogOrigin]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'exercises')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>
      get exercises;

  @BuiltValueField(wireName: r'catalog_origin')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin?
      get catalogOrigin;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload object, {
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
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner)
      ]),
    );
    if (object.catalogOrigin != null) {
      yield r'catalog_origin';
      yield serializers.serialize(
        object.catalogOrigin,
        specifiedType: const FullType(
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin),
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
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder result,
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
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        case r'catalog_origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin?;
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
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadBuilder();
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
