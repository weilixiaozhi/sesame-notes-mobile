//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command200_response.g.dart';

/// PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response
///
/// Properties:
/// * [plan]
/// * [generatedCount]
/// * [removedCount]
/// * [hasMore]
/// * [replayed]
@BuiltValue()
abstract class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response
    implements
        Built<PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder> {
  @BuiltValueField(wireName: r'plan')
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner get plan;

  @BuiltValueField(wireName: r'generated_count')
  int get generatedCount;

  @BuiltValueField(wireName: r'removed_count')
  int get removedCount;

  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  @BuiltValueField(wireName: r'replayed')
  bool get replayed;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response._();

  factory PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response(
          [void updates(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder
                  b)]) =
      _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response>
      get serializer =>
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseSerializer();
}

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response> {
  @override
  final Iterable<Type> types = const [
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response,
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response
  ];

  @override
  final String wireName =
      r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner),
    );
    yield r'generated_count';
    yield serializers.serialize(
      object.generatedCount,
      specifiedType: const FullType(int),
    );
    yield r'removed_count';
    yield serializers.serialize(
      object.removedCount,
      specifiedType: const FullType(int),
    );
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    yield r'replayed';
    yield serializers.serialize(
      object.replayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response object, {
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
    required PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner),
          ) as GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner;
          result.plan.replace(valueDes);
          break;
        case r'generated_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generatedCount = valueDes;
          break;
        case r'removed_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.removedCount = valueDes;
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.replayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommand200ResponseBuilder();
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
