// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_accounts_by_admin_id_reset_password_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAccountsByAdminIdResetPasswordRequest
    extends PostAdminAccountsByAdminIdResetPasswordRequest {
  @override
  final int version;
  @override
  final String newPassword;
  @override
  final String reason;

  factory _$PostAdminAccountsByAdminIdResetPasswordRequest(
          [void Function(PostAdminAccountsByAdminIdResetPasswordRequestBuilder)?
              updates]) =>
      (PostAdminAccountsByAdminIdResetPasswordRequestBuilder()..update(updates))
          ._build();

  _$PostAdminAccountsByAdminIdResetPasswordRequest._(
      {required this.version, required this.newPassword, required this.reason})
      : super._();
  @override
  PostAdminAccountsByAdminIdResetPasswordRequest rebuild(
          void Function(PostAdminAccountsByAdminIdResetPasswordRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAccountsByAdminIdResetPasswordRequestBuilder toBuilder() =>
      PostAdminAccountsByAdminIdResetPasswordRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAccountsByAdminIdResetPasswordRequest &&
        version == other.version &&
        newPassword == other.newPassword &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, newPassword.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminAccountsByAdminIdResetPasswordRequest')
          ..add('version', version)
          ..add('newPassword', newPassword)
          ..add('reason', reason))
        .toString();
  }
}

class PostAdminAccountsByAdminIdResetPasswordRequestBuilder
    implements
        Builder<PostAdminAccountsByAdminIdResetPasswordRequest,
            PostAdminAccountsByAdminIdResetPasswordRequestBuilder> {
  _$PostAdminAccountsByAdminIdResetPasswordRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _newPassword;
  String? get newPassword => _$this._newPassword;
  set newPassword(String? newPassword) => _$this._newPassword = newPassword;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PostAdminAccountsByAdminIdResetPasswordRequestBuilder() {
    PostAdminAccountsByAdminIdResetPasswordRequest._defaults(this);
  }

  PostAdminAccountsByAdminIdResetPasswordRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _newPassword = $v.newPassword;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAccountsByAdminIdResetPasswordRequest other) {
    _$v = other as _$PostAdminAccountsByAdminIdResetPasswordRequest;
  }

  @override
  void update(
      void Function(PostAdminAccountsByAdminIdResetPasswordRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAccountsByAdminIdResetPasswordRequest build() => _build();

  _$PostAdminAccountsByAdminIdResetPasswordRequest _build() {
    final _$result = _$v ??
        _$PostAdminAccountsByAdminIdResetPasswordRequest._(
          version: BuiltValueNullFieldError.checkNotNull(version,
              r'PostAdminAccountsByAdminIdResetPasswordRequest', 'version'),
          newPassword: BuiltValueNullFieldError.checkNotNull(newPassword,
              r'PostAdminAccountsByAdminIdResetPasswordRequest', 'newPassword'),
          reason: BuiltValueNullFieldError.checkNotNull(reason,
              r'PostAdminAccountsByAdminIdResetPasswordRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
