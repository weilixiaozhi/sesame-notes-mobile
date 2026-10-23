// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_groups_by_group_id_members200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
    _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_superAdmin =
    const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum._(
        'superAdmin');
const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
    _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_standardUser =
    const GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum._(
        'standardUser');

GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
    _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'superAdmin':
      return _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_superAdmin;
    case 'standardUser':
      return _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_standardUser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum>
    _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumValues =
    BuiltSet<
        GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum>(const <GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum>[
  _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_superAdmin,
  _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum_standardUser,
]);

Serializer<GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum>
    _$getAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumSerializer =
    _$GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumSerializer();

class _$GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum> {
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
    GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
  ];
  @override
  final String wireName =
      'GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner
    extends GetAdminGroupsByGroupIdMembers200ResponseItemsInner {
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
  final GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum
      identityType;
  @override
  final String groupId;
  @override
  final PostAdminAuthLogin200ResponseAdminGroup group;
  @override
  final bool isEnabled;
  @override
  final int version;
  @override
  final DateTime? lastLoginAt;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner(
          [void Function(
                  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner._(
      {required this.id,
      required this.username,
      this.email,
      this.phone,
      required this.displayName,
      required this.identityType,
      required this.groupId,
      required this.group,
      required this.isEnabled,
      required this.version,
      this.lastLoginAt,
      this.createdBy,
      this.updatedBy,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  GetAdminGroupsByGroupIdMembers200ResponseItemsInner rebuild(
          void Function(
                  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminGroupsByGroupIdMembers200ResponseItemsInner &&
        id == other.id &&
        username == other.username &&
        email == other.email &&
        phone == other.phone &&
        displayName == other.displayName &&
        identityType == other.identityType &&
        groupId == other.groupId &&
        group == other.group &&
        isEnabled == other.isEnabled &&
        version == other.version &&
        lastLoginAt == other.lastLoginAt &&
        createdBy == other.createdBy &&
        updatedBy == other.updatedBy &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner')
          ..add('id', id)
          ..add('username', username)
          ..add('email', email)
          ..add('phone', phone)
          ..add('displayName', displayName)
          ..add('identityType', identityType)
          ..add('groupId', groupId)
          ..add('group', group)
          ..add('isEnabled', isEnabled)
          ..add('version', version)
          ..add('lastLoginAt', lastLoginAt)
          ..add('createdBy', createdBy)
          ..add('updatedBy', updatedBy)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminGroupsByGroupIdMembers200ResponseItemsInner,
            GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder> {
  _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner? _$v;

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

  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum?
      _identityType;
  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum?
      get identityType => _$this._identityType;
  set identityType(
          GetAdminGroupsByGroupIdMembers200ResponseItemsInnerIdentityTypeEnum?
              identityType) =>
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

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(DateTime? lastLoginAt) => _$this._lastLoginAt = lastLoginAt;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder() {
    GetAdminGroupsByGroupIdMembers200ResponseItemsInner._defaults(this);
  }

  GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder get _$this {
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
      _version = $v.version;
      _lastLoginAt = $v.lastLoginAt;
      _createdBy = $v.createdBy;
      _updatedBy = $v.updatedBy;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminGroupsByGroupIdMembers200ResponseItemsInner other) {
    _$v = other as _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminGroupsByGroupIdMembers200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminGroupsByGroupIdMembers200ResponseItemsInner build() => _build();

  _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner _build() {
    _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminGroupsByGroupIdMembers200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner', 'id'),
            username: BuiltValueNullFieldError.checkNotNull(
                username,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'username'),
            email: email,
            phone: phone,
            displayName: BuiltValueNullFieldError.checkNotNull(
                displayName,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'displayName'),
            identityType: BuiltValueNullFieldError.checkNotNull(
                identityType,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'identityType'),
            groupId: BuiltValueNullFieldError.checkNotNull(
                groupId,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'groupId'),
            group: group.build(),
            isEnabled: BuiltValueNullFieldError.checkNotNull(
                isEnabled,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'isEnabled'),
            version: BuiltValueNullFieldError.checkNotNull(
                version,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'version'),
            lastLoginAt: lastLoginAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
                'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'group';
        group.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminGroupsByGroupIdMembers200ResponseItemsInner',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
