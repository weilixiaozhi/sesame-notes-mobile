//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_template_copies_inner_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_template_copies_inner.g.dart';

/// PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
///
/// Properties:
/// * [id]
/// * [payload]
@BuiltValue()
abstract class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
    implements
        Built<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'payload')
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload
      get payload;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner._();

  factory PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner(
          [void updates(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder
                  b)]) =
      _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner>
      get serializer =>
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerSerializer();
}

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner> {
  @override
  final Iterable<Type> types = const [
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner,
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
  ];

  @override
  final String wireName =
      r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
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
    required PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder
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
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload),
          ) as PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerPayload;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestTemplateCopiesInnerBuilder();
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
