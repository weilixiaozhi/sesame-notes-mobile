//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_admin_auth_login200_response_admin_group.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_groups_by_group_id_members200_response_items_inner.g.dart';

/// GetAdminGroupsByGroupIdMembers200ResponseItemsInner
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
/// * [version]
/// * [lastLoginAt]
/// * [createdBy]
/// * [updatedBy]
/// * [createdAt]
/// * [updatedAt]
@BuiltValue()
abstract class GetAdminGroupsByGroupIdMembers200ResponseItemsInner
    implements
        Built<GetAdminGroupsByGroupIdMembers200ResponseItemsInner,
            GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder> {
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
  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
      get identityType;
  // enum identityTypeEnum {  super_admin,  standard_user,  };

  @BuiltValueField(wireName: r'group_id')
  String get groupId;

  @BuiltValueField(wireName: r'group')
  PostAdminAuthLogin200ResponseAdminGroup get group;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'last_login_at')
  DateTime? get lastLoginAt;

  @BuiltValueField(wireName: r'created_by')
  String? get createdBy;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  GetAdminGroupsByGroupIdMembers200ResponseItemsInner._();

  factory GetAdminGroupsByGroupIdMembers200ResponseItemsInner(
          [void updates(
              GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder b)]) =
      _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminGroupsByGroupIdMembers200ResponseItemsInner>
      get serializer =>
          _$GetAdminGroupsByGroupIdMembers200ResponseItemsInnerSerializer();
}

class _$GetAdminGroupsByGroupIdMembers200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<
            GetAdminGroupsByGroupIdMembers200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminGroupsByGroupIdMembers200ResponseItemsInner,
    _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner
  ];

  @override
  final String wireName =
      r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminGroupsByGroupIdMembers200ResponseItemsInner object, {
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
      specifiedType: const FullType(
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum),
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
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'last_login_at';
    yield object.lastLoginAt == null
        ? null
        : serializers.serialize(
            object.lastLoginAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'created_by';
    yield object.createdBy == null
        ? null
        : serializers.serialize(
            object.createdBy,
            specifiedType: const FullType.nullable(String),
          );
    yield r'updated_by';
    yield object.updatedBy == null
        ? null
        : serializers.serialize(
            object.updatedBy,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminGroupsByGroupIdMembers200ResponseItemsInner object, {
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
    required GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder result,
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
                GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum),
          ) as GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum;
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
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'last_login_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        case r'created_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdBy = valueDes;
          break;
        case r'updated_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedBy = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminGroupsByGroupIdMembers200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder();
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

class GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'super_admin')
  static const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
      superAdmin =
      _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_superAdmin;
  @BuiltValueEnumConst(wireName: r'standard_user')
  static const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
      standardUser =
      _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_standardUser;

  static Serializer<
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum>
      get serializer =>
          _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumSerializer;

  const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum>
      get values =>
          _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumValues;
  static GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
      valueOf(String name) =>
          _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumValueOf(
              name);
}
