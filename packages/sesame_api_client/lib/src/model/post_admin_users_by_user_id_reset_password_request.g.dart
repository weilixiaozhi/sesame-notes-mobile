// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_users_by_user_id_reset_password_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminUsersByUserIdResetPasswordRequest
    extends PostAdminUsersByUserIdResetPasswordRequest {
  @override
  final String newPassword;
  @override
  final String reason;

  factory _$PostAdminUsersByUserIdResetPasswordRequest(
          [void Function(PostAdminUsersByUserIdResetPasswordRequestBuilder)?
              updates]) =>
      (PostAdminUsersByUserIdResetPasswordRequestBuilder()..update(updates))
          ._build();

  _$PostAdminUsersByUserIdResetPasswordRequest._(
      {required this.newPassword, required this.reason})
      : super._();
  @override
  PostAdminUsersByUserIdResetPasswordRequest rebuild(
          void Function(PostAdminUsersByUserIdResetPasswordRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminUsersByUserIdResetPasswordRequestBuilder toBuilder() =>
      PostAdminUsersByUserIdResetPasswordRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminUsersByUserIdResetPasswordRequest &&
        newPassword == other.newPassword &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, newPassword.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminUsersByUserIdResetPasswordRequest')
          ..add('newPassword', newPassword)
          ..add('reason', reason))
        .toString();
  }
}

class PostAdminUsersByUserIdResetPasswordRequestBuilder
    implements
        Builder<PostAdminUsersByUserIdResetPasswordRequest,
            PostAdminUsersByUserIdResetPasswordRequestBuilder> {
  _$PostAdminUsersByUserIdResetPasswordRequest? _$v;

  String? _newPassword;
  String? get newPassword => _$this._newPassword;
  set newPassword(String? newPassword) => _$this._newPassword = newPassword;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PostAdminUsersByUserIdResetPasswordRequestBuilder() {
    PostAdminUsersByUserIdResetPasswordRequest._defaults(this);
  }

  PostAdminUsersByUserIdResetPasswordRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _newPassword = $v.newPassword;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminUsersByUserIdResetPasswordRequest other) {
    _$v = other as _$PostAdminUsersByUserIdResetPasswordRequest;
  }

  @override
  void update(
      void Function(PostAdminUsersByUserIdResetPasswordRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminUsersByUserIdResetPasswordRequest build() => _build();

  _$PostAdminUsersByUserIdResetPasswordRequest _build() {
    final _$result = _$v ??
        _$PostAdminUsersByUserIdResetPasswordRequest._(
          newPassword: BuiltValueNullFieldError.checkNotNull(newPassword,
              r'PostAdminUsersByUserIdResetPasswordRequest', 'newPassword'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PostAdminUsersByUserIdResetPasswordRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
