//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner_goals.dart';
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner_name.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner_exercises_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response_templates_inner.g.dart';

/// GetFitnessLibrary200ResponseTemplatesInner
///
/// Properties:
/// * [id]
/// * [revision]
/// * [name]
/// * [description]
/// * [difficulty]
/// * [goals]
/// * [durationMinutes]
/// * [equipment]
/// * [exercises]
@BuiltValue()
abstract class GetFitnessLibrary200ResponseTemplatesInner
    implements
        Built<GetFitnessLibrary200ResponseTemplatesInner,
            GetFitnessLibrary200ResponseTemplatesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'name')
  GetFitnessLibrary200ResponseTemplatesInnerName get name;

  @BuiltValueField(wireName: r'description')
  GetFitnessLibrary200ResponseTemplatesInnerName get description;

  @BuiltValueField(wireName: r'difficulty')
  GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum get difficulty;
  // enum difficultyEnum {  beginner,  intermediate,  advanced,  };

  @BuiltValueField(wireName: r'goals')
  GetFitnessLibrary200ResponseTemplatesInnerGoals get goals;

  @BuiltValueField(wireName: r'duration_minutes')
  int get durationMinutes;

  @BuiltValueField(wireName: r'equipment')
  BuiltSet<String> get equipment;

  @BuiltValueField(wireName: r'exercises')
  BuiltList<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>
      get exercises;

  GetFitnessLibrary200ResponseTemplatesInner._();

  factory GetFitnessLibrary200ResponseTemplatesInner(
          [void updates(GetFitnessLibrary200ResponseTemplatesInnerBuilder b)]) =
      _$GetFitnessLibrary200ResponseTemplatesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetFitnessLibrary200ResponseTemplatesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200ResponseTemplatesInner>
      get serializer =>
          _$GetFitnessLibrary200ResponseTemplatesInnerSerializer();
}

class _$GetFitnessLibrary200ResponseTemplatesInnerSerializer
    implements PrimitiveSerializer<GetFitnessLibrary200ResponseTemplatesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200ResponseTemplatesInner,
    _$GetFitnessLibrary200ResponseTemplatesInner
  ];

  @override
  final String wireName = r'GetFitnessLibrary200ResponseTemplatesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType:
          const FullType(GetFitnessLibrary200ResponseTemplatesInnerName),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType:
          const FullType(GetFitnessLibrary200ResponseTemplatesInnerName),
    );
    yield r'difficulty';
    yield serializers.serialize(
      object.difficulty,
      specifiedType: const FullType(
          GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum),
    );
    yield r'goals';
    yield serializers.serialize(
      object.goals,
      specifiedType:
          const FullType(GetFitnessLibrary200ResponseTemplatesInnerGoals),
    );
    yield r'duration_minutes';
    yield serializers.serialize(
      object.durationMinutes,
      specifiedType: const FullType(int),
    );
    yield r'equipment';
    yield serializers.serialize(
      object.equipment,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'exercises';
    yield serializers.serialize(
      object.exercises,
      specifiedType: const FullType(BuiltList,
          [FullType(GetFitnessLibrary200ResponseTemplatesInnerExercisesInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInner object, {
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
    required GetFitnessLibrary200ResponseTemplatesInnerBuilder result,
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
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetFitnessLibrary200ResponseTemplatesInnerName),
          ) as GetFitnessLibrary200ResponseTemplatesInnerName;
          result.name.replace(valueDes);
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetFitnessLibrary200ResponseTemplatesInnerName),
          ) as GetFitnessLibrary200ResponseTemplatesInnerName;
          result.description.replace(valueDes);
          break;
        case r'difficulty':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum),
          ) as GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum;
          result.difficulty = valueDes;
          break;
        case r'goals':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetFitnessLibrary200ResponseTemplatesInnerGoals),
          ) as GetFitnessLibrary200ResponseTemplatesInnerGoals;
          result.goals.replace(valueDes);
          break;
        case r'duration_minutes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.durationMinutes = valueDes;
          break;
        case r'equipment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.equipment.replace(valueDes);
          break;
        case r'exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetFitnessLibrary200ResponseTemplatesInnerExercisesInner)
            ]),
          ) as BuiltList<
              GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessLibrary200ResponseTemplatesInnerBuilder();
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

class GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'beginner')
  static const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
      beginner =
      _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_beginner;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
      intermediate =
      _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'advanced')
  static const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
      advanced =
      _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_advanced;

  static Serializer<GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum>
      get serializer =>
          _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnumSerializer;

  const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum._(String name)
      : super(name);

  static BuiltSet<GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum>
      get values =>
          _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnumValues;
  static GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum valueOf(
          String name) =>
      _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnumValueOf(name);
}
