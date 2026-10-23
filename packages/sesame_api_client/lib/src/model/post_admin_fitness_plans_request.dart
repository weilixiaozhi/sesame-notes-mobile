//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_admin_fitness_plans_request_content.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_fitness_plans_request.g.dart';

/// PostAdminFitnessPlansRequest
///
/// Properties:
/// * [content]
/// * [isEnabled]
@BuiltValue()
abstract class PostAdminFitnessPlansRequest
    implements
        Built<PostAdminFitnessPlansRequest,
            PostAdminFitnessPlansRequestBuilder> {
  @BuiltValueField(wireName: r'content')
  PostAdminFitnessPlansRequestContent get content;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  PostAdminFitnessPlansRequest._();

  factory PostAdminFitnessPlansRequest(
          [void updates(PostAdminFitnessPlansRequestBuilder b)]) =
      _$PostAdminFitnessPlansRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminFitnessPlansRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminFitnessPlansRequest> get serializer =>
      _$PostAdminFitnessPlansRequestSerializer();
}

class _$PostAdminFitnessPlansRequestSerializer
    implements PrimitiveSerializer<PostAdminFitnessPlansRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminFitnessPlansRequest,
    _$PostAdminFitnessPlansRequest
  ];

  @override
  final String wireName = r'PostAdminFitnessPlansRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminFitnessPlansRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(PostAdminFitnessPlansRequestContent),
    );
    if (object.isEnabled != null) {
      yield r'is_enabled';
      yield serializers.serialize(
        object.isEnabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminFitnessPlansRequest object, {
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
    required PostAdminFitnessPlansRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PostAdminFitnessPlansRequestContent),
          ) as PostAdminFitnessPlansRequestContent;
          result.content.replace(valueDes);
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.isEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminFitnessPlansRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminFitnessPlansRequestBuilder();
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
