//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response_templates_inner_exercises_inner.g.dart';

/// GetFitnessLibrary200ResponseTemplatesInnerExercisesInner
///
/// Properties:
/// * [exerciseId]
/// * [sets]
/// * [reps]
/// * [weightKg]
/// * [weightMode]
/// * [restSeconds]
@BuiltValue()
abstract class GetFitnessLibrary200ResponseTemplatesInnerExercisesInner
    implements
        Built<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner,
            GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder> {
  @BuiltValueField(wireName: r'exercise_id')
  String get exerciseId;

  @BuiltValueField(wireName: r'sets')
  int get sets;

  @BuiltValueField(wireName: r'reps')
  int get reps;

  @BuiltValueField(wireName: r'weight_kg')
  String? get weightKg;

  @BuiltValueField(wireName: r'weight_mode')
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      get weightMode;
  // enum weightModeEnum {  total,  per_side,  body_weight,  };

  @BuiltValueField(wireName: r'rest_seconds')
  int get restSeconds;

  GetFitnessLibrary200ResponseTemplatesInnerExercisesInner._();

  factory GetFitnessLibrary200ResponseTemplatesInnerExercisesInner(
      [void updates(
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder
              b)]) = _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>
      get serializer =>
          _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerSerializer();
}

class _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessLibrary200ResponseTemplatesInnerExercisesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200ResponseTemplatesInnerExercisesInner,
    _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner
  ];

  @override
  final String wireName =
      r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInnerExercisesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exercise_id';
    yield serializers.serialize(
      object.exerciseId,
      specifiedType: const FullType(String),
    );
    yield r'sets';
    yield serializers.serialize(
      object.sets,
      specifiedType: const FullType(int),
    );
    yield r'reps';
    yield serializers.serialize(
      object.reps,
      specifiedType: const FullType(int),
    );
    yield r'weight_kg';
    yield object.weightKg == null
        ? null
        : serializers.serialize(
            object.weightKg,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_mode';
    yield serializers.serialize(
      object.weightMode,
      specifiedType: const FullType(
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum),
    );
    yield r'rest_seconds';
    yield serializers.serialize(
      object.restSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInnerExercisesInner object, {
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
    required GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exercise_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exerciseId = valueDes;
          break;
        case r'sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sets = valueDes;
          break;
        case r'reps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.reps = valueDes;
          break;
        case r'weight_kg':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightKg = valueDes;
          break;
        case r'weight_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum),
          ) as GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum;
          result.weightMode = valueDes;
          break;
        case r'rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder();
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

class GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'total')
  static const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      total =
      _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_total;
  @BuiltValueEnumConst(wireName: r'per_side')
  static const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      perSide =
      _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_perSide;
  @BuiltValueEnumConst(wireName: r'body_weight')
  static const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      bodyWeight =
      _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_bodyWeight;

  static Serializer<
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum>
      get serializer =>
          _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumSerializer;

  const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum>
      get values =>
          _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumValues;
  static GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      valueOf(String name) =>
          _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumValueOf(
              name);
}
