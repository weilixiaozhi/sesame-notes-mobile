// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_invites_by_code200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetInvitesByCode200ResponseRoleEnum
    _$getInvitesByCode200ResponseRoleEnum_editor =
    const GetInvitesByCode200ResponseRoleEnum._('editor');

GetInvitesByCode200ResponseRoleEnum
    _$getInvitesByCode200ResponseRoleEnumValueOf(String name) {
  switch (name) {
    case 'editor':
      return _$getInvitesByCode200ResponseRoleEnum_editor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetInvitesByCode200ResponseRoleEnum>
    _$getInvitesByCode200ResponseRoleEnumValues = BuiltSet<
        GetInvitesByCode200ResponseRoleEnum>(const <GetInvitesByCode200ResponseRoleEnum>[
  _$getInvitesByCode200ResponseRoleEnum_editor,
]);

Serializer<GetInvitesByCode200ResponseRoleEnum>
    _$getInvitesByCode200ResponseRoleEnumSerializer =
    _$GetInvitesByCode200ResponseRoleEnumSerializer();

class _$GetInvitesByCode200ResponseRoleEnumSerializer
    implements PrimitiveSerializer<GetInvitesByCode200ResponseRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'editor': 'editor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'editor': 'editor',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetInvitesByCode200ResponseRoleEnum
  ];
  @override
  final String wireName = 'GetInvitesByCode200ResponseRoleEnum';

  @override
  Object serialize(
          Serializers serializers, GetInvitesByCode200ResponseRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetInvitesByCode200ResponseRoleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetInvitesByCode200ResponseRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetInvitesByCode200Response extends GetInvitesByCode200Response {
  @override
  final String ledgerId;
  @override
  final String ledgerName;
  @override
  final GetInvitesByCode200ResponseRoleEnum role;
  @override
  final DateTime expiresAt;

  factory _$GetInvitesByCode200Response(
          [void Function(GetInvitesByCode200ResponseBuilder)? updates]) =>
      (GetInvitesByCode200ResponseBuilder()..update(updates))._build();

  _$GetInvitesByCode200Response._(
      {required this.ledgerId,
      required this.ledgerName,
      required this.role,
      required this.expiresAt})
      : super._();
  @override
  GetInvitesByCode200Response rebuild(
          void Function(GetInvitesByCode200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetInvitesByCode200ResponseBuilder toBuilder() =>
      GetInvitesByCode200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetInvitesByCode200Response &&
        ledgerId == other.ledgerId &&
        ledgerName == other.ledgerName &&
        role == other.role &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, ledgerName.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetInvitesByCode200Response')
          ..add('ledgerId', ledgerId)
          ..add('ledgerName', ledgerName)
          ..add('role', role)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class GetInvitesByCode200ResponseBuilder
    implements
        Builder<GetInvitesByCode200Response,
            GetInvitesByCode200ResponseBuilder> {
  _$GetInvitesByCode200Response? _$v;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  String? _ledgerName;
  String? get ledgerName => _$this._ledgerName;
  set ledgerName(String? ledgerName) => _$this._ledgerName = ledgerName;

  GetInvitesByCode200ResponseRoleEnum? _role;
  GetInvitesByCode200ResponseRoleEnum? get role => _$this._role;
  set role(GetInvitesByCode200ResponseRoleEnum? role) => _$this._role = role;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  GetInvitesByCode200ResponseBuilder() {
    GetInvitesByCode200Response._defaults(this);
  }

  GetInvitesByCode200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledgerId = $v.ledgerId;
      _ledgerName = $v.ledgerName;
      _role = $v.role;
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetInvitesByCode200Response other) {
    _$v = other as _$GetInvitesByCode200Response;
  }

  @override
  void update(void Function(GetInvitesByCode200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetInvitesByCode200Response build() => _build();

  _$GetInvitesByCode200Response _build() {
    final _$result = _$v ??
        _$GetInvitesByCode200Response._(
          ledgerId: BuiltValueNullFieldError.checkNotNull(
              ledgerId, r'GetInvitesByCode200Response', 'ledgerId'),
          ledgerName: BuiltValueNullFieldError.checkNotNull(
              ledgerName, r'GetInvitesByCode200Response', 'ledgerName'),
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'GetInvitesByCode200Response', 'role'),
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'GetInvitesByCode200Response', 'expiresAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
