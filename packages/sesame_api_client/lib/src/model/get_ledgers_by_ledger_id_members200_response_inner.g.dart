// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_members200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_ACTIVE =
    const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum._('ACTIVE');
const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_LEFT =
    const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum._('LEFT');
const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_REMOVED =
    const GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum._('REMOVED');

GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'ACTIVE':
      return _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_ACTIVE;
    case 'LEFT':
      return _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_LEFT;
    case 'REMOVED':
      return _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_REMOVED;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum>
    _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnumValues = BuiltSet<
        GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum>(const <GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum>[
  _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_ACTIVE,
  _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_LEFT,
  _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnum_REMOVED,
]);

const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_owner =
    const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum._('owner');
const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_editor =
    const GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum._('editor');

GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum
    _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnumValueOf(String name) {
  switch (name) {
    case 'owner':
      return _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_owner;
    case 'editor':
      return _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_editor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum>
    _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnumValues = BuiltSet<
        GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum>(const <GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum>[
  _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_owner,
  _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnum_editor,
]);

Serializer<GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum>
    _$getLedgersByLedgerIdMembers200ResponseInnerStatusEnumSerializer =
    _$GetLedgersByLedgerIdMembers200ResponseInnerStatusEnumSerializer();
Serializer<GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum>
    _$getLedgersByLedgerIdMembers200ResponseInnerRoleEnumSerializer =
    _$GetLedgersByLedgerIdMembers200ResponseInnerRoleEnumSerializer();

class _$GetLedgersByLedgerIdMembers200ResponseInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ACTIVE': 'ACTIVE',
    'LEFT': 'LEFT',
    'REMOVED': 'REMOVED',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ACTIVE': 'ACTIVE',
    'LEFT': 'LEFT',
    'REMOVED': 'REMOVED',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum
  ];
  @override
  final String wireName =
      'GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum';

  @override
  Object serialize(Serializers serializers,
          GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetLedgersByLedgerIdMembers200ResponseInnerRoleEnumSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'owner': 'owner',
    'editor': 'editor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'owner': 'owner',
    'editor': 'editor',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum
  ];
  @override
  final String wireName = 'GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum';

  @override
  Object serialize(Serializers serializers,
          GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetLedgersByLedgerIdMembers200ResponseInner
    extends GetLedgersByLedgerIdMembers200ResponseInner {
  @override
  final String userId;
  @override
  final String? memberId;
  @override
  final GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum? status;
  @override
  final String? linkedAccountId;
  @override
  final String? sesameNumber;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  final int avatarVersion;
  @override
  final GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum role;
  @override
  final DateTime joinedAt;

  factory _$GetLedgersByLedgerIdMembers200ResponseInner(
          [void Function(GetLedgersByLedgerIdMembers200ResponseInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdMembers200ResponseInnerBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdMembers200ResponseInner._(
      {required this.userId,
      this.memberId,
      this.status,
      this.linkedAccountId,
      this.sesameNumber,
      this.displayName,
      this.avatarUrl,
      required this.avatarVersion,
      required this.role,
      required this.joinedAt})
      : super._();
  @override
  GetLedgersByLedgerIdMembers200ResponseInner rebuild(
          void Function(GetLedgersByLedgerIdMembers200ResponseInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdMembers200ResponseInnerBuilder toBuilder() =>
      GetLedgersByLedgerIdMembers200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdMembers200ResponseInner &&
        userId == other.userId &&
        memberId == other.memberId &&
        status == other.status &&
        linkedAccountId == other.linkedAccountId &&
        sesameNumber == other.sesameNumber &&
        displayName == other.displayName &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion &&
        role == other.role &&
        joinedAt == other.joinedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, linkedAccountId.hashCode);
    _$hash = $jc(_$hash, sesameNumber.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, joinedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdMembers200ResponseInner')
          ..add('userId', userId)
          ..add('memberId', memberId)
          ..add('status', status)
          ..add('linkedAccountId', linkedAccountId)
          ..add('sesameNumber', sesameNumber)
          ..add('displayName', displayName)
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion)
          ..add('role', role)
          ..add('joinedAt', joinedAt))
        .toString();
  }
}

class GetLedgersByLedgerIdMembers200ResponseInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdMembers200ResponseInner,
            GetLedgersByLedgerIdMembers200ResponseInnerBuilder> {
  _$GetLedgersByLedgerIdMembers200ResponseInner? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum? _status;
  GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum? get status =>
      _$this._status;
  set status(GetLedgersByLedgerIdMembers200ResponseInnerStatusEnum? status) =>
      _$this._status = status;

  String? _linkedAccountId;
  String? get linkedAccountId => _$this._linkedAccountId;
  set linkedAccountId(String? linkedAccountId) =>
      _$this._linkedAccountId = linkedAccountId;

  String? _sesameNumber;
  String? get sesameNumber => _$this._sesameNumber;
  set sesameNumber(String? sesameNumber) => _$this._sesameNumber = sesameNumber;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum? _role;
  GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum? get role => _$this._role;
  set role(GetLedgersByLedgerIdMembers200ResponseInnerRoleEnum? role) =>
      _$this._role = role;

  DateTime? _joinedAt;
  DateTime? get joinedAt => _$this._joinedAt;
  set joinedAt(DateTime? joinedAt) => _$this._joinedAt = joinedAt;

  GetLedgersByLedgerIdMembers200ResponseInnerBuilder() {
    GetLedgersByLedgerIdMembers200ResponseInner._defaults(this);
  }

  GetLedgersByLedgerIdMembers200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _memberId = $v.memberId;
      _status = $v.status;
      _linkedAccountId = $v.linkedAccountId;
      _sesameNumber = $v.sesameNumber;
      _displayName = $v.displayName;
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _role = $v.role;
      _joinedAt = $v.joinedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdMembers200ResponseInner other) {
    _$v = other as _$GetLedgersByLedgerIdMembers200ResponseInner;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdMembers200ResponseInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdMembers200ResponseInner build() => _build();

  _$GetLedgersByLedgerIdMembers200ResponseInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdMembers200ResponseInner._(
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'GetLedgersByLedgerIdMembers200ResponseInner', 'userId'),
          memberId: memberId,
          status: status,
          linkedAccountId: linkedAccountId,
          sesameNumber: sesameNumber,
          displayName: displayName,
          avatarUrl: avatarUrl,
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'GetLedgersByLedgerIdMembers200ResponseInner', 'avatarVersion'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'GetLedgersByLedgerIdMembers200ResponseInner', 'role'),
          joinedAt: BuiltValueNullFieldError.checkNotNull(joinedAt,
              r'GetLedgersByLedgerIdMembers200ResponseInner', 'joinedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
