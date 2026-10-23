//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_template_copies_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_plan.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request.g.dart';

/// PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest
///
/// Properties:
/// * [mutationId]
/// * [syncId]
/// * [baseRevision]
/// * [today]
/// * [action]
/// * [plan]
/// * [restartDate]
/// * [templateCopies]
@BuiltValue()
abstract class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest
    implements
        Built<PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'base_revision')
  int get baseRevision;

  @BuiltValueField(wireName: r'today')
  String get today;

  @BuiltValueField(wireName: r'action')
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
      get action;
  // enum actionEnum {  save,  generate,  };

  @BuiltValueField(wireName: r'plan')
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan? get plan;

  @BuiltValueField(wireName: r'restart_date')
  String? get restartDate;

  @BuiltValueField(wireName: r'template_copies')
  BuiltList<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>?
      get templateCopies;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest._();

  factory PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest(
          [void updates(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder
                  b)]) =
      _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest>
      get serializer =>
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestSerializer();
}

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest> {
  @override
  final Iterable<Type> types = const [
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest,
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest
  ];

  @override
  final String wireName =
      r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'base_revision';
    yield serializers.serialize(
      object.baseRevision,
      specifiedType: const FullType(int),
    );
    yield r'today';
    yield serializers.serialize(
      object.today,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum),
    );
    if (object.plan != null) {
      yield r'plan';
      yield serializers.serialize(
        object.plan,
        specifiedType: const FullType(
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan),
      );
    }
    if (object.restartDate != null) {
      yield r'restart_date';
      yield serializers.serialize(
        object.restartDate,
        specifiedType: const FullType(String),
      );
    }
    if (object.templateCopies != null) {
      yield r'template_copies';
      yield serializers.serialize(
        object.templateCopies,
        specifiedType: const FullType(BuiltList, [
          FullType(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner)
        ]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest object, {
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
    required PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mutation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mutationId = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'base_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.baseRevision = valueDes;
          break;
        case r'today':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.today = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum),
          ) as PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum;
          result.action = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan),
          ) as PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan?;
          if (valueDes == null) continue;
          result.plan.replace(valueDes);
          break;
        case r'restart_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.restartDate = valueDes;
          break;
        case r'template_copies':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [
              FullType(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner)
            ]),
          ) as BuiltList<
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>?;
          if (valueDes == null) continue;
          result.templateCopies.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestBuilder();
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

class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'save')
  static const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
      save =
      _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_save;
  @BuiltValueEnumConst(wireName: r'generate')
  static const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
      generate =
      _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum_generate;

  static Serializer<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum>
      get serializer =>
          _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumSerializer;

  const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum>
      get values =>
          _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumValues;
  static PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnum
      valueOf(String name) =>
          _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestActionEnumValueOf(
              name);
}
