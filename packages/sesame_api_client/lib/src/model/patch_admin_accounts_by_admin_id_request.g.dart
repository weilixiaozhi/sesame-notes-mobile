// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_accounts_by_admin_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminAccountsByAdminIdRequest
    extends PatchAdminAccountsByAdminIdRequest {
  @override
  final int version;
  @override
  final String? displayName;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? groupId;
  @override
  final bool? isEnabled;
  @override
  final String? reason;

  factory _$PatchAdminAccountsByAdminIdRequest(
          [void Function(PatchAdminAccountsByAdminIdRequestBuilder)?
              updates]) =>
      (PatchAdminAccountsByAdminIdRequestBuilder()..update(updates))._build();

  _$PatchAdminAccountsByAdminIdRequest._(
      {required this.version,
      this.displayName,
      this.email,
      this.phone,
      this.groupId,
      this.isEnabled,
      this.reason})
      : super._();
  @override
  PatchAdminAccountsByAdminIdRequest rebuild(
          void Function(PatchAdminAccountsByAdminIdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminAccountsByAdminIdRequestBuilder toBuilder() =>
      PatchAdminAccountsByAdminIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminAccountsByAdminIdRequest &&
        version == other.version &&
        displayName == other.displayName &&
        email == other.email &&
        phone == other.phone &&
        groupId == other.groupId &&
        isEnabled == other.isEnabled &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatchAdminAccountsByAdminIdRequest')
          ..add('version', version)
          ..add('displayName', displayName)
          ..add('email', email)
          ..add('phone', phone)
          ..add('groupId', groupId)
          ..add('isEnabled', isEnabled)
          ..add('reason', reason))
        .toString();
  }
}

class PatchAdminAccountsByAdminIdRequestBuilder
    implements
        Builder<PatchAdminAccountsByAdminIdRequest,
            PatchAdminAccountsByAdminIdRequestBuilder> {
  _$PatchAdminAccountsByAdminIdRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _phone;
  String? get phone => _$this._phone;
  set phone(String? phone) => _$this._phone = phone;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PatchAdminAccountsByAdminIdRequestBuilder() {
    PatchAdminAccountsByAdminIdRequest._defaults(this);
  }

  PatchAdminAccountsByAdminIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _displayName = $v.displayName;
      _email = $v.email;
      _phone = $v.phone;
      _groupId = $v.groupId;
      _isEnabled = $v.isEnabled;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchAdminAccountsByAdminIdRequest other) {
    _$v = other as _$PatchAdminAccountsByAdminIdRequest;
  }

  @override
  void update(
      void Function(PatchAdminAccountsByAdminIdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminAccountsByAdminIdRequest build() => _build();

  _$PatchAdminAccountsByAdminIdRequest _build() {
    final _$result = _$v ??
        _$PatchAdminAccountsByAdminIdRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'PatchAdminAccountsByAdminIdRequest', 'version'),
          displayName: displayName,
          email: email,
          phone: phone,
          groupId: groupId,
          isEnabled: isEnabled,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
