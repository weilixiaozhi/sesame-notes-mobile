// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_invites200_response_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum
    _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnum_editor =
    const GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum._('editor');

GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum
    _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnumValueOf(String name) {
  switch (name) {
    case 'editor':
      return _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnum_editor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum>
    _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnumValues = BuiltSet<
        GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum>(const <GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum>[
  _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnum_editor,
]);

Serializer<GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum>
    _$getLedgersByLedgerIdInvites200ResponseInnerRoleEnumSerializer =
    _$GetLedgersByLedgerIdInvites200ResponseInnerRoleEnumSerializer();

class _$GetLedgersByLedgerIdInvites200ResponseInnerRoleEnumSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editor': 'editor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editor': 'editor',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum
  ];
  @override
  final String wireName = 'GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum';

  @override
  Object serialize(Serializers serializers,
          GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetLedgersByLedgerIdInvites200ResponseInner
    extends GetLedgersByLedgerIdInvites200ResponseInner {
  @override
  final String id;
  @override
  final String codePrefix;
  @override
  final GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum role;
  @override
  final DateTime expiresAt;
  @override
  final DateTime? usedAt;
  @override
  final String? usedByUserId;
  @override
  final DateTime createdAt;

  factory _$GetLedgersByLedgerIdInvites200ResponseInner(
          [void Function(GetLedgersByLedgerIdInvites200ResponseInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdInvites200ResponseInnerBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdInvites200ResponseInner._(
      {required this.id,
      required this.codePrefix,
      required this.role,
      required this.expiresAt,
      this.usedAt,
      this.usedByUserId,
      required this.createdAt})
      : super._();
  @override
  GetLedgersByLedgerIdInvites200ResponseInner rebuild(
          void Function(GetLedgersByLedgerIdInvites200ResponseInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdInvites200ResponseInnerBuilder toBuilder() =>
      GetLedgersByLedgerIdInvites200ResponseInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdInvites200ResponseInner &&
        id == other.id &&
        codePrefix == other.codePrefix &&
        role == other.role &&
        expiresAt == other.expiresAt &&
        usedAt == other.usedAt &&
        usedByUserId == other.usedByUserId &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, codePrefix.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, usedAt.hashCode);
    _$hash = $jc(_$hash, usedByUserId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdInvites200ResponseInner')
          ..add('id', id)
          ..add('codePrefix', codePrefix)
          ..add('role', role)
          ..add('expiresAt', expiresAt)
          ..add('usedAt', usedAt)
          ..add('usedByUserId', usedByUserId)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GetLedgersByLedgerIdInvites200ResponseInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdInvites200ResponseInner,
            GetLedgersByLedgerIdInvites200ResponseInnerBuilder> {
  _$GetLedgersByLedgerIdInvites200ResponseInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _codePrefix;
  String? get codePrefix => _$this._codePrefix;
  set codePrefix(String? codePrefix) => _$this._codePrefix = codePrefix;

  GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum? _role;
  GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum? get role => _$this._role;
  set role(GetLedgersByLedgerIdInvites200ResponseInnerRoleEnum? role) =>
      _$this._role = role;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _usedAt;
  DateTime? get usedAt => _$this._usedAt;
  set usedAt(DateTime? usedAt) => _$this._usedAt = usedAt;

  String? _usedByUserId;
  String? get usedByUserId => _$this._usedByUserId;
  set usedByUserId(String? usedByUserId) => _$this._usedByUserId = usedByUserId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  GetLedgersByLedgerIdInvites200ResponseInnerBuilder() {
    GetLedgersByLedgerIdInvites200ResponseInner._defaults(this);
  }

  GetLedgersByLedgerIdInvites200ResponseInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _codePrefix = $v.codePrefix;
      _role = $v.role;
      _expiresAt = $v.expiresAt;
      _usedAt = $v.usedAt;
      _usedByUserId = $v.usedByUserId;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdInvites200ResponseInner other) {
    _$v = other as _$GetLedgersByLedgerIdInvites200ResponseInner;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdInvites200ResponseInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdInvites200ResponseInner build() => _build();

  _$GetLedgersByLedgerIdInvites200ResponseInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdInvites200ResponseInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetLedgersByLedgerIdInvites200ResponseInner', 'id'),
          codePrefix: BuiltValueNullFieldError.checkNotNull(codePrefix,
              r'GetLedgersByLedgerIdInvites200ResponseInner', 'codePrefix'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'GetLedgersByLedgerIdInvites200ResponseInner', 'role'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(expiresAt,
              r'GetLedgersByLedgerIdInvites200ResponseInner', 'expiresAt'),
          usedAt: usedAt,
          usedByUserId: usedByUserId,
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'GetLedgersByLedgerIdInvites200ResponseInner', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
