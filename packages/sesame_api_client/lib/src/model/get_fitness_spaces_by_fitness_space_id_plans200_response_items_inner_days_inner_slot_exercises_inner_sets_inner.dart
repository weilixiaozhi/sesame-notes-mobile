//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner_sets_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
///
/// Properties:
/// * [id]
/// * [kind]
/// * [weight]
/// * [weightLeft]
/// * [weightRight]
/// * [reps]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
      get kind;
  // enum kindEnum {  warmup,  working,  };

  @BuiltValueField(wireName: r'weight')
  String? get weight;

  @BuiltValueField(wireName: r'weight_left')
  String? get weightLeft;

  @BuiltValueField(wireName: r'weight_right')
  String? get weightRight;

  @BuiltValueField(wireName: r'reps')
  int? get reps;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum),
    );
    yield r'weight';
    yield object.weight == null
        ? null
        : serializers.serialize(
            object.weight,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_left';
    yield object.weightLeft == null
        ? null
        : serializers.serialize(
            object.weightLeft,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_right';
    yield object.weightRight == null
        ? null
        : serializers.serialize(
            object.weightRight,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reps';
    yield object.reps == null
        ? null
        : serializers.serialize(
            object.reps,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weight = valueDes;
          break;
        case r'weight_left':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightLeft = valueDes;
          break;
        case r'weight_right':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightRight = valueDes;
          break;
        case r'reps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.reps = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'warmup')
  static const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
      warmup =
      _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_warmup;
  @BuiltValueEnumConst(wireName: r'working')
  static const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
      working =
      _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_working;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumValueOf(
              name);
}
