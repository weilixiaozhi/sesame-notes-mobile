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

part 'post_admin_fitness_plans_request_content.g.dart';

/// PostAdminFitnessPlansRequestContent
///
/// Properties:
/// * [name]
/// * [description]
/// * [difficulty]
/// * [goals]
/// * [cycleDays]
/// * [days]
@BuiltValue()
abstract class PostAdminFitnessPlansRequestContent
    implements
        Built<PostAdminFitnessPlansRequestContent,
            PostAdminFitnessPlansRequestContentBuilder> {
  @BuiltValueField(wireName: r'name')
  GetFitnessLibrary200ResponseTemplatesInnerName get name;

  @BuiltValueField(wireName: r'description')
  GetFitnessLibrary200ResponseTemplatesInnerName get description;

  @BuiltValueField(wireName: r'difficulty')
  PostAdminFitnessPlansRequestContentDifficultyEnum get difficulty;
  // enum difficultyEnum {  beginner,  intermediate,  advanced,  };

  @BuiltValueField(wireName: r'goals')
  GetFitnessLibrary200ResponseTemplatesInnerGoals get goals;

  @BuiltValueField(wireName: r'cycle_days')
  int get cycleDays;

  @BuiltValueField(wireName: r'days')
  BuiltList<GetFitnessLibrary200ResponsePlansInnerDaysInner> get days;

  PostAdminFitnessPlansRequestContent._();

  factory PostAdminFitnessPlansRequestContent(
          [void updates(PostAdminFitnessPlansRequestContentBuilder b)]) =
      _$PostAdminFitnessPlansRequestContent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminFitnessPlansRequestContentBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminFitnessPlansRequestContent> get serializer =>
      _$PostAdminFitnessPlansRequestContentSerializer();
}

class _$PostAdminFitnessPlansRequestContentSerializer
    implements PrimitiveSerializer<PostAdminFitnessPlansRequestContent> {
  @override
  final Iterable<Type> types = const [
    PostAdminFitnessPlansRequestContent,
    _$PostAdminFitnessPlansRequestContent
  ];

  @override
  final String wireName = r'PostAdminFitnessPlansRequestContent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminFitnessPlansRequestContent object, {
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
          const FullType(PostAdminFitnessPlansRequestContentDifficultyEnum),
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
    PostAdminFitnessPlansRequestContent object, {
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
    required PostAdminFitnessPlansRequestContentBuilder result,
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
                PostAdminFitnessPlansRequestContentDifficultyEnum),
          ) as PostAdminFitnessPlansRequestContentDifficultyEnum;
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
  PostAdminFitnessPlansRequestContent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminFitnessPlansRequestContentBuilder();
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

class PostAdminFitnessPlansRequestContentDifficultyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'beginner')
  static const PostAdminFitnessPlansRequestContentDifficultyEnum beginner =
      _$postAdminFitnessPlansRequestContentDifficultyEnum_beginner;
  @BuiltValueEnumConst(wireName: r'intermediate')
  static const PostAdminFitnessPlansRequestContentDifficultyEnum intermediate =
      _$postAdminFitnessPlansRequestContentDifficultyEnum_intermediate;
  @BuiltValueEnumConst(wireName: r'advanced')
  static const PostAdminFitnessPlansRequestContentDifficultyEnum advanced =
      _$postAdminFitnessPlansRequestContentDifficultyEnum_advanced;

  static Serializer<PostAdminFitnessPlansRequestContentDifficultyEnum>
      get serializer =>
          _$postAdminFitnessPlansRequestContentDifficultyEnumSerializer;

  const PostAdminFitnessPlansRequestContentDifficultyEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminFitnessPlansRequestContentDifficultyEnum>
      get values => _$postAdminFitnessPlansRequestContentDifficultyEnumValues;
  static PostAdminFitnessPlansRequestContentDifficultyEnum valueOf(
          String name) =>
      _$postAdminFitnessPlansRequestContentDifficultyEnumValueOf(name);
}
