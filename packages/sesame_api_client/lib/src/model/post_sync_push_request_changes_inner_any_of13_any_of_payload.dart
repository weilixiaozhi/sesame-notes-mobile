//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of13_any_of_payload_exercises_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_rest_timer.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of13_any_of_payload_run_segments_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of13_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload
///
/// Properties:
/// * [name]
/// * [scheduledDate]
/// * [sourceKind]
/// * [sourcePlanId]
/// * [sourcePlanName]
/// * [sourceTemplateId]
/// * [occurrenceKey]
/// * [exercises]
/// * [status]
/// * [runSegments]
/// * [restTimer]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'scheduled_date')
  String get scheduledDate;

  @BuiltValueField(wireName: r'source_kind')
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
      get sourceKind;
  // enum sourceKindEnum {  blank,  template,  plan,  };

  @BuiltValueField(wireName: r'source_plan_id')
  String? get sourcePlanId;

  @BuiltValueField(wireName: r'source_plan_name')
  String? get sourcePlanName;

  @BuiltValueField(wireName: r'source_template_id')
  String? get sourceTemplateId;

  @BuiltValueField(wireName: r'occurrence_key')
  String? get occurrenceKey;

  @BuiltValueField(wireName: r'exercises')
  BuiltList<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>
      get exercises;

  @BuiltValueField(wireName: r'status')
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum get status;
  // enum statusEnum {  scheduled,  in_progress,  completed,  };

  @BuiltValueField(wireName: r'run_segments')
  BuiltList<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>
      get runSegments;

  @BuiltValueField(wireName: r'rest_timer')
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer?
      get restTimer;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'scheduled_date';
    yield serializers.serialize(
      object.scheduledDate,
      specifiedType: const FullType(String),
    );
    yield r'source_kind';
    yield serializers.serialize(
      object.sourceKind,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum),
    );
    yield r'source_plan_id';
    yield object.sourcePlanId == null
        ? null
        : serializers.serialize(
            object.sourcePlanId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'source_plan_name';
    yield object.sourcePlanName == null
        ? null
        : serializers.serialize(
            object.sourcePlanName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'source_template_id';
    yield object.sourceTemplateId == null
        ? null
        : serializers.serialize(
            object.sourceTemplateId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'occurrence_key';
    yield object.occurrenceKey == null
        ? null
        : serializers.serialize(
            object.occurrenceKey,
            specifiedType: const FullType.nullable(String),
          );
    yield r'exercises';
    yield serializers.serialize(
      object.exercises,
      specifiedType: const FullType(BuiltList, [
        FullType(
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner)
      ]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum),
    );
    yield r'run_segments';
    yield serializers.serialize(
      object.runSegments,
      specifiedType: const FullType(BuiltList, [
        FullType(
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner)
      ]),
    );
    yield r'rest_timer';
    yield object.restTimer == null
        ? null
        : serializers.serialize(
            object.restTimer,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder result,
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
        case r'scheduled_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduledDate = valueDes;
          break;
        case r'source_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum;
          result.sourceKind = valueDes;
          break;
        case r'source_plan_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourcePlanId = valueDes;
          break;
        case r'source_plan_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourcePlanName = valueDes;
          break;
        case r'source_template_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceTemplateId = valueDes;
          break;
        case r'occurrence_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.occurrenceKey = valueDes;
          break;
        case r'exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner)
            ]),
          ) as BuiltList<
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum;
          result.status = valueDes;
          break;
        case r'run_segments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner)
            ]),
          ) as BuiltList<
              PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>;
          result.runSegments.replace(valueDes);
          break;
        case r'rest_timer':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer),
          ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer?;
          if (valueDes == null) continue;
          result.restTimer.replace(valueDes);
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
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'blank')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
      blank =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_blank;
  @BuiltValueEnumConst(wireName: r'template')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
      template =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_template;
  @BuiltValueEnumConst(wireName: r'plan')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
      plan =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_plan;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'scheduled')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
      scheduled =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
      inProgress =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'completed')
  static const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
      completed =
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_completed;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumValueOf(
          name);
}
