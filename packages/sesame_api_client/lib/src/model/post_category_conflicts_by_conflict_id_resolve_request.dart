//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_category_conflicts_by_conflict_id_resolve_request.g.dart';

/// PostCategoryConflictsByConflictIdResolveRequest
///
/// Properties:
/// * [mutationId]
/// * [expectedCandidateVersion]
/// * [expectedCloudToken]
/// * [choice]
/// * [restoreDeleted]
@BuiltValue()
abstract class PostCategoryConflictsByConflictIdResolveRequest
    implements
        Built<PostCategoryConflictsByConflictIdResolveRequest,
            PostCategoryConflictsByConflictIdResolveRequestBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'expected_candidate_version')
  int get expectedCandidateVersion;

  @BuiltValueField(wireName: r'expected_cloud_token')
  String get expectedCloudToken;

  @BuiltValueField(wireName: r'choice')
  PostCategoryConflictsByConflictIdResolveRequestChoiceEnum get choice;
  // enum choiceEnum {  cloud,  local,  };

  @BuiltValueField(wireName: r'restore_deleted')
  bool? get restoreDeleted;

  PostCategoryConflictsByConflictIdResolveRequest._();

  factory PostCategoryConflictsByConflictIdResolveRequest(
          [void updates(
              PostCategoryConflictsByConflictIdResolveRequestBuilder b)]) =
      _$PostCategoryConflictsByConflictIdResolveRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostCategoryConflictsByConflictIdResolveRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostCategoryConflictsByConflictIdResolveRequest>
      get serializer =>
          _$PostCategoryConflictsByConflictIdResolveRequestSerializer();
}

class _$PostCategoryConflictsByConflictIdResolveRequestSerializer
    implements
        PrimitiveSerializer<PostCategoryConflictsByConflictIdResolveRequest> {
  @override
  final Iterable<Type> types = const [
    PostCategoryConflictsByConflictIdResolveRequest,
    _$PostCategoryConflictsByConflictIdResolveRequest
  ];

  @override
  final String wireName = r'PostCategoryConflictsByConflictIdResolveRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostCategoryConflictsByConflictIdResolveRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'expected_candidate_version';
    yield serializers.serialize(
      object.expectedCandidateVersion,
      specifiedType: const FullType(int),
    );
    yield r'expected_cloud_token';
    yield serializers.serialize(
      object.expectedCloudToken,
      specifiedType: const FullType(String),
    );
    yield r'choice';
    yield serializers.serialize(
      object.choice,
      specifiedType: const FullType(
          PostCategoryConflictsByConflictIdResolveRequestChoiceEnum),
    );
    if (object.restoreDeleted != null) {
      yield r'restore_deleted';
      yield serializers.serialize(
        object.restoreDeleted,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostCategoryConflictsByConflictIdResolveRequest object, {
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
    required PostCategoryConflictsByConflictIdResolveRequestBuilder result,
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
        case r'expected_candidate_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.expectedCandidateVersion = valueDes;
          break;
        case r'expected_cloud_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedCloudToken = valueDes;
          break;
        case r'choice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostCategoryConflictsByConflictIdResolveRequestChoiceEnum),
          ) as PostCategoryConflictsByConflictIdResolveRequestChoiceEnum;
          result.choice = valueDes;
          break;
        case r'restore_deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.restoreDeleted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostCategoryConflictsByConflictIdResolveRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostCategoryConflictsByConflictIdResolveRequestBuilder();
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

class PostCategoryConflictsByConflictIdResolveRequestChoiceEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'cloud')
  static const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum cloud =
      _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_cloud;
  @BuiltValueEnumConst(wireName: r'local')
  static const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum local =
      _$postCategoryConflictsByConflictIdResolveRequestChoiceEnum_local;

  static Serializer<PostCategoryConflictsByConflictIdResolveRequestChoiceEnum>
      get serializer =>
          _$postCategoryConflictsByConflictIdResolveRequestChoiceEnumSerializer;

  const PostCategoryConflictsByConflictIdResolveRequestChoiceEnum._(String name)
      : super(name);

  static BuiltSet<PostCategoryConflictsByConflictIdResolveRequestChoiceEnum>
      get values =>
          _$postCategoryConflictsByConflictIdResolveRequestChoiceEnumValues;
  static PostCategoryConflictsByConflictIdResolveRequestChoiceEnum valueOf(
          String name) =>
      _$postCategoryConflictsByConflictIdResolveRequestChoiceEnumValueOf(name);
}
