//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_admin_fitness_plans_request_content.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_admin_fitness_plans_by_content_id_request.g.dart';

/// PatchAdminFitnessPlansByContentIdRequest
///
/// Properties:
/// * [version]
/// * [content]
/// * [isEnabled]
@BuiltValue()
abstract class PatchAdminFitnessPlansByContentIdRequest
    implements
        Built<PatchAdminFitnessPlansByContentIdRequest,
            PatchAdminFitnessPlansByContentIdRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'content')
  PostAdminFitnessPlansRequestContent? get content;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  PatchAdminFitnessPlansByContentIdRequest._();

  factory PatchAdminFitnessPlansByContentIdRequest(
          [void updates(PatchAdminFitnessPlansByContentIdRequestBuilder b)]) =
      _$PatchAdminFitnessPlansByContentIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PatchAdminFitnessPlansByContentIdRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAdminFitnessPlansByContentIdRequest> get serializer =>
      _$PatchAdminFitnessPlansByContentIdRequestSerializer();
}

class _$PatchAdminFitnessPlansByContentIdRequestSerializer
    implements PrimitiveSerializer<PatchAdminFitnessPlansByContentIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchAdminFitnessPlansByContentIdRequest,
    _$PatchAdminFitnessPlansByContentIdRequest
  ];

  @override
  final String wireName = r'PatchAdminFitnessPlansByContentIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAdminFitnessPlansByContentIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(PostAdminFitnessPlansRequestContent),
      );
    }
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
    PatchAdminFitnessPlansByContentIdRequest object, {
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
    required PatchAdminFitnessPlansByContentIdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(PostAdminFitnessPlansRequestContent),
          ) as PostAdminFitnessPlansRequestContent?;
          if (valueDes == null) continue;
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
  PatchAdminFitnessPlansByContentIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAdminFitnessPlansByContentIdRequestBuilder();
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
