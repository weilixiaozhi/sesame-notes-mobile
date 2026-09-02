// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_auth_password_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAuthPasswordRequest extends PatchAuthPasswordRequest {
  @override
  final String currentPassword;
  @override
  final String newPassword;

  factory _$PatchAuthPasswordRequest(
          [void Function(PatchAuthPasswordRequestBuilder)? updates]) =>
      (PatchAuthPasswordRequestBuilder()..update(updates))._build();

  _$PatchAuthPasswordRequest._(
      {required this.currentPassword, required this.newPassword})
      : super._();
  @override
  PatchAuthPasswordRequest rebuild(
          void Function(PatchAuthPasswordRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAuthPasswordRequestBuilder toBuilder() =>
      PatchAuthPasswordRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAuthPasswordRequest &&
        currentPassword == other.currentPassword &&
        newPassword == other.newPassword;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currentPassword.hashCode);
    _$hash = $jc(_$hash, newPassword.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatchAuthPasswordRequest')
          ..add('currentPassword', currentPassword)
          ..add('newPassword', newPassword))
        .toString();
  }
}

class PatchAuthPasswordRequestBuilder
    implements
        Builder<PatchAuthPasswordRequest, PatchAuthPasswordRequestBuilder> {
  _$PatchAuthPasswordRequest? _$v;

  String? _currentPassword;
  String? get currentPassword => _$this._currentPassword;
  set currentPassword(String? currentPassword) =>
      _$this._currentPassword = currentPassword;

  String? _newPassword;
  String? get newPassword => _$this._newPassword;
  set newPassword(String? newPassword) => _$this._newPassword = newPassword;

  PatchAuthPasswordRequestBuilder() {
    PatchAuthPasswordRequest._defaults(this);
  }

  PatchAuthPasswordRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currentPassword = $v.currentPassword;
      _newPassword = $v.newPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchAuthPasswordRequest other) {
    _$v = other as _$PatchAuthPasswordRequest;
  }

  @override
  void update(void Function(PatchAuthPasswordRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAuthPasswordRequest build() => _build();

  _$PatchAuthPasswordRequest _build() {
    final _$result = _$v ??
        _$PatchAuthPasswordRequest._(
          currentPassword: BuiltValueNullFieldError.checkNotNull(
              currentPassword, r'PatchAuthPasswordRequest', 'currentPassword'),
          newPassword: BuiltValueNullFieldError.checkNotNull(
              newPassword, r'PatchAuthPasswordRequest', 'newPassword'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
