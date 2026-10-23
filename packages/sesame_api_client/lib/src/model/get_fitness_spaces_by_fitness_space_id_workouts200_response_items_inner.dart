//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_exercises_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_run_segments_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_rest_timer.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner
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
/// * [id]
/// * [fitnessSpaceId]
/// * [syncId]
/// * [revision]
/// * [deletedAt]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'scheduled_date')
  String get scheduledDate;

  @BuiltValueField(wireName: r'source_kind')
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
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
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>
      get exercises;

  @BuiltValueField(wireName: r'status')
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      get status;
  // enum statusEnum {  scheduled,  in_progress,  completed,  };

  @BuiltValueField(wireName: r'run_segments')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>
      get runSegments;

  @BuiltValueField(wireName: r'rest_timer')
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer?
      get restTimer;

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

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner,
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner object, {
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
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum),
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
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner)
      ]),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum),
    );
    yield r'run_segments';
    yield serializers.serialize(
      object.runSegments,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner)
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
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner object, {
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
    required GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder
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
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum;
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
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'run_segments':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>;
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
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'blank')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
      blank =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_blank;
  @BuiltValueEnumConst(wireName: r'template')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
      template =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_template;
  @BuiltValueEnumConst(wireName: r'plan')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
      plan =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_plan;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumValueOf(
              name);
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'scheduled')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      scheduled =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      inProgress =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'completed')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      completed =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_completed;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumValueOf(
              name);
}
