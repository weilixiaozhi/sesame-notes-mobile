//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_groups_by_group_id_members_request_members_inner.g.dart';

/// PostAdminGroupsByGroupIdMembersRequestMembersInner
///
/// Properties:
/// * [adminId]
/// * [version]
/// * [groupId]
/// * [groupVersion]
@BuiltValue()
abstract class PostAdminGroupsByGroupIdMembersRequestMembersInner
    implements
        Built<PostAdminGroupsByGroupIdMembersRequestMembersInner,
            PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder> {
  @BuiltValueField(wireName: r'admin_id')
  String get adminId;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'group_id')
  String get groupId;

  @BuiltValueField(wireName: r'group_version')
  int get groupVersion;

  PostAdminGroupsByGroupIdMembersRequestMembersInner._();

  factory PostAdminGroupsByGroupIdMembersRequestMembersInner(
          [void updates(
              PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder b)]) =
      _$PostAdminGroupsByGroupIdMembersRequestMembersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminGroupsByGroupIdMembersRequestMembersInner>
      get serializer =>
          _$PostAdminGroupsByGroupIdMembersRequestMembersInnerSerializer();
}

class _$PostAdminGroupsByGroupIdMembersRequestMembersInnerSerializer
    implements
        PrimitiveSerializer<
            PostAdminGroupsByGroupIdMembersRequestMembersInner> {
  @override
  final Iterable<Type> types = const [
    PostAdminGroupsByGroupIdMembersRequestMembersInner,
    _$PostAdminGroupsByGroupIdMembersRequestMembersInner
  ];

  @override
  final String wireName = r'PostAdminGroupsByGroupIdMembersRequestMembersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminGroupsByGroupIdMembersRequestMembersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'admin_id';
    yield serializers.serialize(
      object.adminId,
      specifiedType: const FullType(String),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'group_id';
    yield serializers.serialize(
      object.groupId,
      specifiedType: const FullType(String),
    );
    yield r'group_version';
    yield serializers.serialize(
      object.groupVersion,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminGroupsByGroupIdMembersRequestMembersInner object, {
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
    required PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'admin_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adminId = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'group_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'group_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.groupVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminGroupsByGroupIdMembersRequestMembersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder();
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
