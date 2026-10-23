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

part 'post_admin_fitness_templates_request_content.g.dart';

/// PostAdminFitnessTemplatesRequestContent
///
/// Properties:
/// * [name]
/// * [description]
/// * [difficulty]
/// * [goals]
/// * [durationMinutes]
/// * [equipment]
/// * [exercises]
@BuiltValue()
abstract class PostAdminFitnessTemplatesRequestContent
    implements
        Built<PostAdminFitnessTemplatesRequestContent,
            PostAdminFitnessTemplatesRequestContentBuilder> {
  @BuiltValueField(wireName: r'name')
  GetFitnessLibrary200ResponseTemplatesInnerName get name;

  @BuiltValueField(wireName: r'description')
  GetFitnessLibrary200ResponseTemplatesInnerName get description;

  @BuiltValueField(wireName: r'difficulty')
  PostAdminFitnessTemplatesRequestContentDifficultyEnum get difficulty;
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

  PostAdminFitnessTemplatesRequestContent._();

  factory PostAdminFitnessTemplatesRequestContent(
          [void updates(PostAdminFitnessTemplatesRequestContentBuilder b)]) =
      _$PostAdminFitnessTemplatesRequestContent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminFitnessTemplatesRequestContentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminFitnessTemplatesRequestContent> get serializer =>
      _$PostAdminFitnessTemplatesRequestContentSerializer();
}

class _$PostAdminFitnessTemplatesRequestContentSerializer
    implements PrimitiveSerializer<PostAdminFitnessTemplatesRequestContent> {
  @override
  final Iterable<Type> types = const [
    PostAdminFitnessTemplatesRequestContent,
    _$PostAdminFitnessTemplatesRequestContent
  ];

  @override
  final String wireName = r'PostAdminFitnessTemplatesRequestContent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminFitnessTemplatesRequestContent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
          const FullType(PostAdminFitnessTemplatesRequestContentDifficultyEnum),
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
    PostAdminFitnessTemplatesRequestContent object, {
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
    required PostAdminFitnessTemplatesRequestContentBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
                PostAdminFitnessTemplatesRequestContentDifficultyEnum),
          ) as PostAdminFitnessTemplatesRequestContentDifficultyEnum;
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
  PostAdminFitnessTemplatesRequestContent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminFitnessTemplatesRequestContentBuilder();
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

class PostAdminFitnessTemplatesRequestContentDifficultyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'beginner')
  static const PostAdminFitnessTemplatesRequestContentDifficultyEnum beginner =
      _$postAdminFitnessTemplatesRequestContentDifficultyEnum_beginner;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const PostAdminFitnessTemplatesRequestContentDifficultyEnum
      intermediate =
      _$postAdminFitnessTemplatesRequestContentDifficultyEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'advanced')
  static const PostAdminFitnessTemplatesRequestContentDifficultyEnum advanced =
      _$postAdminFitnessTemplatesRequestContentDifficultyEnum_advanced;

  static Serializer<PostAdminFitnessTemplatesRequestContentDifficultyEnum>
      get serializer =>
          _$postAdminFitnessTemplatesRequestContentDifficultyEnumSerializer;

  const PostAdminFitnessTemplatesRequestContentDifficultyEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminFitnessTemplatesRequestContentDifficultyEnum>
      get values =>
          _$postAdminFitnessTemplatesRequestContentDifficultyEnumValues;
  static PostAdminFitnessTemplatesRequestContentDifficultyEnum valueOf(
          String name) =>
      _$postAdminFitnessTemplatesRequestContentDifficultyEnumValueOf(name);
}
