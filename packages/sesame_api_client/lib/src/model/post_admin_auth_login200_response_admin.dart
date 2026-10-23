//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_admin_auth_login200_response_admin_group.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_auth_login200_response_admin.g.dart';

/// PostAdminAuthLogin200ResponseAdmin
///
/// Properties:
/// * [id]
/// * [username]
/// * [email]
/// * [phone]
/// * [displayName]
/// * [identityType]
/// * [groupId]
/// * [group]
/// * [isEnabled]
/// * [permissions]
/// * [allowedPages]
/// * [authorizationVersion]
@BuiltValue()
abstract class PostAdminAuthLogin200ResponseAdmin
    implements
        Built<PostAdminAuthLogin200ResponseAdmin,
            PostAdminAuthLogin200ResponseAdminBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'username')
  String get username;

  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'phone')
  String? get phone;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'identity_type')
  PostAdminAuthLogin200ResponseAdminIdentityTypeEnum get identityType;
  // enum identityTypeEnum {  super_admin,  standard_user,  };

  @BuiltValueField(wireName: r'group_id')
  String get groupId;

  @BuiltValueField(wireName: r'group')
  PostAdminAuthLogin200ResponseAdminGroup get group;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'permissions')
  BuiltList<String> get permissions;

  @BuiltValueField(wireName: r'allowed_pages')
  BuiltList<String> get allowedPages;

  @BuiltValueField(wireName: r'authorization_version')
  String get authorizationVersion;

  PostAdminAuthLogin200ResponseAdmin._();

  factory PostAdminAuthLogin200ResponseAdmin(
          [void updates(PostAdminAuthLogin200ResponseAdminBuilder b)]) =
      _$PostAdminAuthLogin200ResponseAdmin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminAuthLogin200ResponseAdminBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminAuthLogin200ResponseAdmin> get serializer =>
      _$PostAdminAuthLogin200ResponseAdminSerializer();
}

class _$PostAdminAuthLogin200ResponseAdminSerializer
    implements PrimitiveSerializer<PostAdminAuthLogin200ResponseAdmin> {
  @override
  final Iterable<Type> types = const [
    PostAdminAuthLogin200ResponseAdmin,
    _$PostAdminAuthLogin200ResponseAdmin
  ];

  @override
  final String wireName = r'PostAdminAuthLogin200ResponseAdmin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminAuthLogin200ResponseAdmin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'username';
    yield serializers.serialize(
      object.username,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield object.email == null
        ? null
        : serializers.serialize(
            object.email,
            specifiedType: const FullType.nullable(String),
          );
    yield r'phone';
    yield object.phone == null
        ? null
        : serializers.serialize(
            object.phone,
            specifiedType: const FullType.nullable(String),
          );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'identity_type';
    yield serializers.serialize(
      object.identityType,
      specifiedType:
          const FullType(PostAdminAuthLogin200ResponseAdminIdentityTypeEnum),
    );
    yield r'group_id';
    yield serializers.serialize(
      object.groupId,
      specifiedType: const FullType(String),
    );
    yield r'group';
    yield serializers.serialize(
      object.group,
      specifiedType: const FullType(PostAdminAuthLogin200ResponseAdminGroup),
    );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'permissions';
    yield serializers.serialize(
      object.permissions,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'allowed_pages';
    yield serializers.serialize(
      object.allowedPages,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'authorization_version';
    yield serializers.serialize(
      object.authorizationVersion,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminAuthLogin200ResponseAdmin object, {
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
    required PostAdminAuthLogin200ResponseAdminBuilder result,
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
        case r'username':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.username = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.email = valueDes;
          break;
        case r'phone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.phone = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'identity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostAdminAuthLogin200ResponseAdminIdentityTypeEnum),
          ) as PostAdminAuthLogin200ResponseAdminIdentityTypeEnum;
          result.identityType = valueDes;
          break;
        case r'group_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.groupId = valueDes;
          break;
        case r'group':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAdminAuthLogin200ResponseAdminGroup),
          ) as PostAdminAuthLogin200ResponseAdminGroup;
          result.group.replace(valueDes);
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        case r'permissions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.permissions.replace(valueDes);
          break;
        case r'allowed_pages':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.allowedPages.replace(valueDes);
          break;
        case r'authorization_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorizationVersion = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAdminAuthLogin200ResponseAdmin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminAuthLogin200ResponseAdminBuilder();
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

class PostAdminAuthLogin200ResponseAdminIdentityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'super_admin')
  static const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum superAdmin =
      _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_superAdmin;
  @BuiltValueEnumConst(wireName: r'standard_user')
  static const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum standardUser =
      _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_standardUser;

  static Serializer<PostAdminAuthLogin200ResponseAdminIdentityTypeEnum>
      get serializer =>
          _$postAdminAuthLogin200ResponseAdminIdentityTypeEnumSerializer;

  const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostAdminAuthLogin200ResponseAdminIdentityTypeEnum>
      get values => _$postAdminAuthLogin200ResponseAdminIdentityTypeEnumValues;
  static PostAdminAuthLogin200ResponseAdminIdentityTypeEnum valueOf(
          String name) =>
      _$postAdminAuthLogin200ResponseAdminIdentityTypeEnumValueOf(name);
}
