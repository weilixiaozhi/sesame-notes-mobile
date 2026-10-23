//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner_workouts_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [status]
/// * [scheduledDate]
/// * [workoutDate]
/// * [sourcePlanId]
/// * [sourcePlanName]
/// * [revision]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'status')
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      get status;
  // enum statusEnum {  scheduled,  in_progress,  completed,  };

  @BuiltValueField(wireName: r'scheduled_date')
  String get scheduledDate;

  @BuiltValueField(wireName: r'workout_date')
  String get workoutDate;

  @BuiltValueField(wireName: r'source_plan_id')
  String? get sourcePlanId;

  @BuiltValueField(wireName: r'source_plan_name')
  String? get sourcePlanName;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner,
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum),
    );
    yield r'scheduled_date';
    yield serializers.serialize(
      object.scheduledDate,
      specifiedType: const FullType(String),
    );
    yield r'workout_date';
    yield serializers.serialize(
      object.workoutDate,
      specifiedType: const FullType(String),
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
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
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
    required GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder
        result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum;
          result.status = valueDes;
          break;
        case r'scheduled_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.scheduledDate = valueDes;
          break;
        case r'workout_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.workoutDate = valueDes;
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
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'scheduled')
  static const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      scheduled =
      _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_scheduled;
  @BuiltValueEnumConst(wireName: r'in_progress')
  static const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      inProgress =
      _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_inProgress;
  @BuiltValueEnumConst(wireName: r'completed')
  static const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      completed =
      _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_completed;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumValueOf(
              name);
}
