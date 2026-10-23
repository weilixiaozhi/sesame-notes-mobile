//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_exercises_inner_sets_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
///
/// Properties:
/// * [id]
/// * [kind]
/// * [weight]
/// * [weightLeft]
/// * [weightRight]
/// * [reps]
/// * [completed]
/// * [restDurationsSeconds]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
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

  @BuiltValueField(wireName: r'completed')
  bool get completed;

  @BuiltValueField(wireName: r'rest_durations_seconds')
  BuiltList<int>? get restDurationsSeconds;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner,
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
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
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum),
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
    yield r'completed';
    yield serializers.serialize(
      object.completed,
      specifiedType: const FullType(bool),
    );
    if (object.restDurationsSeconds != null) {
      yield r'rest_durations_seconds';
      yield serializers.serialize(
        object.restDurationsSeconds,
        specifiedType: const FullType(BuiltList, [FullType(int)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
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
    required GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder
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
                GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum;
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
        case r'completed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.completed = valueDes;
          break;
        case r'rest_durations_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [FullType(int)]),
          ) as BuiltList<int>?;
          if (valueDes == null) continue;
          result.restDurationsSeconds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'warmup')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      warmup =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup;
  @BuiltValueEnumConst(wireName: r'working')
  static const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      working =
      _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValueOf(
              name);
}
