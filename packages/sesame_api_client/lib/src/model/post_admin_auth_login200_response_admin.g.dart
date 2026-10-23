// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_auth_login200_response_admin.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum
    _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_superAdmin =
    const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum._('superAdmin');
const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum
    _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_standardUser =
    const PostAdminAuthLogin200ResponseAdminIdentityTypeEnum._('standardUser');

PostAdminAuthLogin200ResponseAdminIdentityTypeEnum
    _$postAdminAuthLogin200ResponseAdminIdentityTypeEnumValueOf(String name) {
  switch (name) {
    case 'superAdmin':
      return _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_superAdmin;
    case 'standardUser':
      return _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_standardUser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminAuthLogin200ResponseAdminIdentityTypeEnum>
    _$postAdminAuthLogin200ResponseAdminIdentityTypeEnumValues = BuiltSet<
        PostAdminAuthLogin200ResponseAdminIdentityTypeEnum>(const <PostAdminAuthLogin200ResponseAdminIdentityTypeEnum>[
  _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_superAdmin,
  _$postAdminAuthLogin200ResponseAdminIdentityTypeEnum_standardUser,
]);

Serializer<PostAdminAuthLogin200ResponseAdminIdentityTypeEnum>
    _$postAdminAuthLogin200ResponseAdminIdentityTypeEnumSerializer =
    _$PostAdminAuthLogin200ResponseAdminIdentityTypeEnumSerializer();

class _$PostAdminAuthLogin200ResponseAdminIdentityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostAdminAuthLogin200ResponseAdminIdentityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'superAdmin': 'super_admin',
    'standardUser': 'standard_user',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'super_admin': 'superAdmin',
    'standard_user': 'standardUser',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostAdminAuthLogin200ResponseAdminIdentityTypeEnum
  ];
  @override
  final String wireName = 'PostAdminAuthLogin200ResponseAdminIdentityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminAuthLogin200ResponseAdminIdentityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminAuthLogin200ResponseAdminIdentityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminAuthLogin200ResponseAdminIdentityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminAuthLogin200ResponseAdmin
    extends PostAdminAuthLogin200ResponseAdmin {
  @override
  final String id;
  @override
  final String username;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String displayName;
  @override
  final PostAdminAuthLogin200ResponseAdminIdentityTypeEnum identityType;
  @override
  final String groupId;
  @override
  final PostAdminAuthLogin200ResponseAdminGroup group;
  @override
  final bool isEnabled;
  @override
  final BuiltList<String> permissions;
  @override
  final BuiltList<String> allowedPages;
  @override
  final String authorizationVersion;

  factory _$PostAdminAuthLogin200ResponseAdmin(
          [void Function(PostAdminAuthLogin200ResponseAdminBuilder)?
              updates]) =>
      (PostAdminAuthLogin200ResponseAdminBuilder()..update(updates))._build();

  _$PostAdminAuthLogin200ResponseAdmin._(
      {required this.id,
      required this.username,
      this.email,
      this.phone,
      required this.displayName,
      required this.identityType,
      required this.groupId,
      required this.group,
      required this.isEnabled,
      required this.permissions,
      required this.allowedPages,
      required this.authorizationVersion})
      : super._();
  @override
  PostAdminAuthLogin200ResponseAdmin rebuild(
          void Function(PostAdminAuthLogin200ResponseAdminBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAuthLogin200ResponseAdminBuilder toBuilder() =>
      PostAdminAuthLogin200ResponseAdminBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAuthLogin200ResponseAdmin &&
        id == other.id &&
        username == other.username &&
        email == other.email &&
        phone == other.phone &&
        displayName == other.displayName &&
        identityType == other.identityType &&
        groupId == other.groupId &&
        group == other.group &&
        isEnabled == other.isEnabled &&
        permissions == other.permissions &&
        allowedPages == other.allowedPages &&
        authorizationVersion == other.authorizationVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, identityType.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, group.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, allowedPages.hashCode);
    _$hash = $jc(_$hash, authorizationVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAuthLogin200ResponseAdmin')
          ..add('id', id)
          ..add('username', username)
          ..add('email', email)
          ..add('phone', phone)
          ..add('displayName', displayName)
          ..add('identityType', identityType)
          ..add('groupId', groupId)
          ..add('group', group)
          ..add('isEnabled', isEnabled)
          ..add('permissions', permissions)
          ..add('allowedPages', allowedPages)
          ..add('authorizationVersion', authorizationVersion))
        .toString();
  }
}

class PostAdminAuthLogin200ResponseAdminBuilder
    implements
        Builder<PostAdminAuthLogin200ResponseAdmin,
            PostAdminAuthLogin200ResponseAdminBuilder> {
  _$PostAdminAuthLogin200ResponseAdmin? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  PostAdminAuthLogin200ResponseAdminIdentityTypeEnum? _identityType;
  PostAdminAuthLogin200ResponseAdminIdentityTypeEnum? get identityType =>
      _$this._identityType;
  set identityType(
          PostAdminAuthLogin200ResponseAdminIdentityTypeEnum? identityType) =>
      _$this._identityType = identityType;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  PostAdminAuthLogin200ResponseAdminGroupBuilder? _group;
  PostAdminAuthLogin200ResponseAdminGroupBuilder get group =>
      _$this._group ??= PostAdminAuthLogin200ResponseAdminGroupBuilder();
  set group(PostAdminAuthLogin200ResponseAdminGroupBuilder? group) =>
      _$this._group = group;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  ListBuilder<String>? _permissions;
  ListBuilder<String> get permissions =>
      _$this._permissions ??= ListBuilder<String>();
  set permissions(ListBuilder<String>? permissions) =>
      _$this._permissions = permissions;

  ListBuilder<String>? _allowedPages;
  ListBuilder<String> get allowedPages =>
      _$this._allowedPages ??= ListBuilder<String>();
  set allowedPages(ListBuilder<String>? allowedPages) =>
      _$this._allowedPages = allowedPages;

  String? _authorizationVersion;
  String? get authorizationVersion => _$this._authorizationVersion;
  set authorizationVersion(String? authorizationVersion) =>
      _$this._authorizationVersion = authorizationVersion;

  PostAdminAuthLogin200ResponseAdminBuilder() {
    PostAdminAuthLogin200ResponseAdmin._defaults(this);
  }

  PostAdminAuthLogin200ResponseAdminBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _username = $v.username;
      _email = $v.email;
      _phone = $v.phone;
      _displayName = $v.displayName;
      _identityType = $v.identityType;
      _groupId = $v.groupId;
      _group = $v.group.toBuilder();
      _isEnabled = $v.isEnabled;
      _permissions = $v.permissions.toBuilder();
      _allowedPages = $v.allowedPages.toBuilder();
      _authorizationVersion = $v.authorizationVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAuthLogin200ResponseAdmin other) {
    _$v = other as _$PostAdminAuthLogin200ResponseAdmin;
  }

  @override
  void update(
      void Function(PostAdminAuthLogin200ResponseAdminBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAuthLogin200ResponseAdmin build() => _build();

  _$PostAdminAuthLogin200ResponseAdmin _build() {
    _$PostAdminAuthLogin200ResponseAdmin _$result;
    try {
      _$result = _$v ??
          _$PostAdminAuthLogin200ResponseAdmin._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'PostAdminAuthLogin200ResponseAdmin', 'id'),
            username: BuiltValueNullFieldError.checkNotNull(
                username, r'PostAdminAuthLogin200ResponseAdmin', 'username'),
            email: email,
            phone: phone,
            displayName: BuiltValueNullFieldError.checkNotNull(displayName,
                r'PostAdminAuthLogin200ResponseAdmin', 'displayName'),
            identityType: BuiltValueNullFieldError.checkNotNull(identityType,
                r'PostAdminAuthLogin200ResponseAdmin', 'identityType'),
            groupId: BuiltValueNullFieldError.checkNotNull(
                groupId, r'PostAdminAuthLogin200ResponseAdmin', 'groupId'),
            group: group.build(),
            isEnabled: BuiltValueNullFieldError.checkNotNull(
                isEnabled, r'PostAdminAuthLogin200ResponseAdmin', 'isEnabled'),
            permissions: permissions.build(),
            allowedPages: allowedPages.build(),
            authorizationVersion: BuiltValueNullFieldError.checkNotNull(
                authorizationVersion,
                r'PostAdminAuthLogin200ResponseAdmin',
                'authorizationVersion'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'group';
        group.build();

        _$failedField = 'permissions';
        permissions.build();
        _$failedField = 'allowedPages';
        allowedPages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAdminAuthLogin200ResponseAdmin', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
