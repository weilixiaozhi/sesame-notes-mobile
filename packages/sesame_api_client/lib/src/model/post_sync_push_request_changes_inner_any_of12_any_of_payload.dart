//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11_any_of_payload_catalog_origin.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_generation_state.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_pending_schedule.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of12_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload
///
/// Properties:
/// * [name]
/// * [catalogOrigin]
/// * [startDate]
/// * [status]
/// * [cycleDays]
/// * [days]
/// * [generationState]
/// * [pendingSchedule]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'catalog_origin')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin?
      get catalogOrigin;

  @BuiltValueField(wireName: r'start_date')
  String? get startDate;

  @BuiltValueField(wireName: r'status')
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum get status;
  // enum statusEnum {  in_progress,  closed,  };

  @BuiltValueField(wireName: r'cycle_days')
  int get cycleDays;

  @BuiltValueField(wireName: r'days')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>
      get days;

  @BuiltValueField(wireName: r'generation_state')
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
      get generationState;

  @BuiltValueField(wireName: r'pending_schedule')
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule?
      get pendingSchedule;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    if (object.catalogOrigin != null) {
      yield r'catalog_origin';
      yield serializers.serialize(
        object.catalogOrigin,
        specifiedType: const FullType(
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin),
      );
    }
    yield r'start_date';
    yield object.startDate == null
        ? null
        : serializers.serialize(
            object.startDate,
            specifiedType: const FullType.nullable(String),
          );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum),
    );
    yield r'cycle_days';
    yield serializers.serialize(
      object.cycleDays,
      specifiedType: const FullType(int),
    );
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
      ]),
    );
    yield r'generation_state';
    yield serializers.serialize(
      object.generationState,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState),
    );
    yield r'pending_schedule';
    yield object.pendingSchedule == null
        ? null
        : serializers.serialize(
            object.pendingSchedule,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule),
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
    PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder result,
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
        case r'catalog_origin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin?;
          if (valueDes == null) continue;
          result.catalogOrigin.replace(valueDes);
          break;
        case r'start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.startDate = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum;
          result.status = valueDes;
          break;
        case r'cycle_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.cycleDays = valueDes;
          break;
        case r'days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>;
          result.days.replace(valueDes);
          break;
        case r'generation_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState),
          ) as GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState;
          result.generationState.replace(valueDes);
          break;
        case r'pending_schedule':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule),
          ) as GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule?;
          if (valueDes == null) continue;
          result.pendingSchedule.replace(valueDes);
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
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
      inProgress =
      _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'closed')
  static const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
      closed =
      _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_closed;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumValueOf(
          name);
}
