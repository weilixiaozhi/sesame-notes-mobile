//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_admin_groups_by_group_id_members_request_members_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_groups_by_group_id_members_request.g.dart';

/// PostAdminGroupsByGroupIdMembersRequest
///
/// Properties:
/// * [version]
/// * [members]
/// * [reason]
@BuiltValue()
abstract class PostAdminGroupsByGroupIdMembersRequest
    implements
        Built<PostAdminGroupsByGroupIdMembersRequest,
            PostAdminGroupsByGroupIdMembersRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'members')
  BuiltList<PostAdminGroupsByGroupIdMembersRequestMembersInner> get members;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  PostAdminGroupsByGroupIdMembersRequest._();

  factory PostAdminGroupsByGroupIdMembersRequest(
          [void updates(PostAdminGroupsByGroupIdMembersRequestBuilder b)]) =
      _$PostAdminGroupsByGroupIdMembersRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminGroupsByGroupIdMembersRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminGroupsByGroupIdMembersRequest> get serializer =>
      _$PostAdminGroupsByGroupIdMembersRequestSerializer();
}

class _$PostAdminGroupsByGroupIdMembersRequestSerializer
    implements PrimitiveSerializer<PostAdminGroupsByGroupIdMembersRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminGroupsByGroupIdMembersRequest,
    _$PostAdminGroupsByGroupIdMembersRequest
  ];

  @override
  final String wireName = r'PostAdminGroupsByGroupIdMembersRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminGroupsByGroupIdMembersRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'members';
    yield serializers.serialize(
      object.members,
      specifiedType: const FullType(BuiltList,
          [FullType(PostAdminGroupsByGroupIdMembersRequestMembersInner)]),
    );
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminGroupsByGroupIdMembersRequest object, {
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
    required PostAdminGroupsByGroupIdMembersRequestBuilder result,
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
        case r'members':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(PostAdminGroupsByGroupIdMembersRequestMembersInner)]),
          ) as BuiltList<PostAdminGroupsByGroupIdMembersRequestMembersInner>;
          result.members.replace(valueDes);
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminGroupsByGroupIdMembersRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminGroupsByGroupIdMembersRequestBuilder();
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
