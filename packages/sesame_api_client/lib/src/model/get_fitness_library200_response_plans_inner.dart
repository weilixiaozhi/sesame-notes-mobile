//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner_goals.dart';
import 'package:sesame_api_client/src/model/get_fitness_library200_response_plans_inner_days_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner_name.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response_plans_inner.g.dart';

/// GetFitnessLibrary200ResponsePlansInner
///
/// Properties:
/// * [id]
/// * [revision]
/// * [name]
/// * [description]
/// * [difficulty]
/// * [goals]
/// * [cycleDays]
/// * [days]
@BuiltValue()
abstract class GetFitnessLibrary200ResponsePlansInner
    implements
        Built<GetFitnessLibrary200ResponsePlansInner,
            GetFitnessLibrary200ResponsePlansInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'name')
  GetFitnessLibrary200ResponseTemplatesInnerName get name;

  @BuiltValueField(wireName: r'description')
  GetFitnessLibrary200ResponseTemplatesInnerName get description;

  @BuiltValueField(wireName: r'difficulty')
  GetFitnessLibrary200ResponsePlansInnerDifficultyEnum get difficulty;
  // enum difficultyEnum {  beginner,  intermediate,  advanced,  };

  @BuiltValueField(wireName: r'goals')
  GetFitnessLibrary200ResponseTemplatesInnerGoals get goals;

  @BuiltValueField(wireName: r'cycle_days')
  int get cycleDays;

  @BuiltValueField(wireName: r'days')
  BuiltList<GetFitnessLibrary200ResponsePlansInnerDaysInner> get days;

  GetFitnessLibrary200ResponsePlansInner._();

  factory GetFitnessLibrary200ResponsePlansInner(
          [void updates(GetFitnessLibrary200ResponsePlansInnerBuilder b)]) =
      _$GetFitnessLibrary200ResponsePlansInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetFitnessLibrary200ResponsePlansInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200ResponsePlansInner> get serializer =>
      _$GetFitnessLibrary200ResponsePlansInnerSerializer();
}

class _$GetFitnessLibrary200ResponsePlansInnerSerializer
    implements PrimitiveSerializer<GetFitnessLibrary200ResponsePlansInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200ResponsePlansInner,
    _$GetFitnessLibrary200ResponsePlansInner
  ];

  @override
  final String wireName = r'GetFitnessLibrary200ResponsePlansInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200ResponsePlansInner object, {
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
      specifiedType:
          const FullType(GetFitnessLibrary200ResponsePlansInnerDifficultyEnum),
    );
    yield r'goals';
    yield serializers.serialize(
      object.goals,
      specifiedType:
          const FullType(GetFitnessLibrary200ResponseTemplatesInnerGoals),
    );
    yield r'cycle_days';
    yield serializers.serialize(
      object.cycleDays,
      specifiedType: const FullType(int),
    );
    yield r'days';
    yield serializers.serialize(
      object.days,
      specifiedType: const FullType(BuiltList,
          [FullType(GetFitnessLibrary200ResponsePlansInnerDaysInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200ResponsePlansInner object, {
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
    required GetFitnessLibrary200ResponsePlansInnerBuilder result,
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
                GetFitnessLibrary200ResponsePlansInnerDifficultyEnum),
          ) as GetFitnessLibrary200ResponsePlansInnerDifficultyEnum;
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
            specifiedType: const FullType(BuiltList,
                [FullType(GetFitnessLibrary200ResponsePlansInnerDaysInner)]),
          ) as BuiltList<GetFitnessLibrary200ResponsePlansInnerDaysInner>;
          result.days.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200ResponsePlansInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessLibrary200ResponsePlansInnerBuilder();
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

class GetFitnessLibrary200ResponsePlansInnerDifficultyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'beginner')
  static const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum beginner =
      _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_beginner;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum
      intermediate =
      _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'advanced')
  static const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum advanced =
      _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_advanced;

  static Serializer<GetFitnessLibrary200ResponsePlansInnerDifficultyEnum>
      get serializer =>
          _$getFitnessLibrary200ResponsePlansInnerDifficultyEnumSerializer;

  const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum._(String name)
      : super(name);

  static BuiltSet<GetFitnessLibrary200ResponsePlansInnerDifficultyEnum>
      get values =>
          _$getFitnessLibrary200ResponsePlansInnerDifficultyEnumValues;
  static GetFitnessLibrary200ResponsePlansInnerDifficultyEnum valueOf(
          String name) =>
      _$getFitnessLibrary200ResponsePlansInnerDifficultyEnumValueOf(name);
}
