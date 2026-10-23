// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_admin_accounts_by_admin_id_identity_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
    _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_superAdmin =
    const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum._(
        'superAdmin');
const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
    _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_standardUser =
    const PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum._(
        'standardUser');

PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
    _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'superAdmin':
      return _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_superAdmin;
    case 'standardUser':
      return _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_standardUser;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum>
    _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumValues = BuiltSet<
        PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum>(const <PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum>[
  _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_superAdmin,
  _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum_standardUser,
]);

Serializer<PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum>
    _$putAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumSerializer =
    _$PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumSerializer();

class _$PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum> {
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
    PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum
  ];
  @override
  final String wireName =
      'PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PutAdminAccountsByAdminIdIdentityRequest
    extends PutAdminAccountsByAdminIdIdentityRequest {
  @override
  final int version;
  @override
  final PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum identityType;
  @override
  final String reason;

  factory _$PutAdminAccountsByAdminIdIdentityRequest(
          [void Function(PutAdminAccountsByAdminIdIdentityRequestBuilder)?
              updates]) =>
      (PutAdminAccountsByAdminIdIdentityRequestBuilder()..update(updates))
          ._build();

  _$PutAdminAccountsByAdminIdIdentityRequest._(
      {required this.version, required this.identityType, required this.reason})
      : super._();
  @override
  PutAdminAccountsByAdminIdIdentityRequest rebuild(
          void Function(PutAdminAccountsByAdminIdIdentityRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutAdminAccountsByAdminIdIdentityRequestBuilder toBuilder() =>
      PutAdminAccountsByAdminIdIdentityRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutAdminAccountsByAdminIdIdentityRequest &&
        version == other.version &&
        identityType == other.identityType &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, identityType.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PutAdminAccountsByAdminIdIdentityRequest')
          ..add('version', version)
          ..add('identityType', identityType)
          ..add('reason', reason))
        .toString();
  }
}

class PutAdminAccountsByAdminIdIdentityRequestBuilder
    implements
        Builder<PutAdminAccountsByAdminIdIdentityRequest,
            PutAdminAccountsByAdminIdIdentityRequestBuilder> {
  _$PutAdminAccountsByAdminIdIdentityRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum? _identityType;
  PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum? get identityType =>
      _$this._identityType;
  set identityType(
          PutAdminAccountsByAdminIdIdentityRequestIdentityTypeEnum?
              identityType) =>
      _$this._identityType = identityType;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PutAdminAccountsByAdminIdIdentityRequestBuilder() {
    PutAdminAccountsByAdminIdIdentityRequest._defaults(this);
  }

  PutAdminAccountsByAdminIdIdentityRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _identityType = $v.identityType;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutAdminAccountsByAdminIdIdentityRequest other) {
    _$v = other as _$PutAdminAccountsByAdminIdIdentityRequest;
  }

  @override
  void update(
      void Function(PutAdminAccountsByAdminIdIdentityRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutAdminAccountsByAdminIdIdentityRequest build() => _build();

  _$PutAdminAccountsByAdminIdIdentityRequest _build() {
    final _$result = _$v ??
        _$PutAdminAccountsByAdminIdIdentityRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'PutAdminAccountsByAdminIdIdentityRequest', 'version'),
          identityType: BuiltValueNullFieldError.checkNotNull(identityType,
              r'PutAdminAccountsByAdminIdIdentityRequest', 'identityType'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PutAdminAccountsByAdminIdIdentityRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
