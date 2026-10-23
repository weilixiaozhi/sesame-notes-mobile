// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_auth_password_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAuthPasswordRequest extends PostAdminAuthPasswordRequest {
  @override
  final String oldPassword;
  @override
  final String newPassword;

  factory _$PostAdminAuthPasswordRequest(
          [void Function(PostAdminAuthPasswordRequestBuilder)? updates]) =>
      (PostAdminAuthPasswordRequestBuilder()..update(updates))._build();

  _$PostAdminAuthPasswordRequest._(
      {required this.oldPassword, required this.newPassword})
      : super._();
  @override
  PostAdminAuthPasswordRequest rebuild(
          void Function(PostAdminAuthPasswordRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAuthPasswordRequestBuilder toBuilder() =>
      PostAdminAuthPasswordRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAuthPasswordRequest &&
        oldPassword == other.oldPassword &&
        newPassword == other.newPassword;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, oldPassword.hashCode);
    _$hash = $jc(_$hash, newPassword.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAuthPasswordRequest')
          ..add('oldPassword', oldPassword)
          ..add('newPassword', newPassword))
        .toString();
  }
}

class PostAdminAuthPasswordRequestBuilder
    implements
        Builder<PostAdminAuthPasswordRequest,
            PostAdminAuthPasswordRequestBuilder> {
  _$PostAdminAuthPasswordRequest? _$v;

  String? _oldPassword;
  String? get oldPassword => _$this._oldPassword;
  set oldPassword(String? oldPassword) => _$this._oldPassword = oldPassword;

  String? _newPassword;
  String? get newPassword => _$this._newPassword;
  set newPassword(String? newPassword) => _$this._newPassword = newPassword;

  PostAdminAuthPasswordRequestBuilder() {
    PostAdminAuthPasswordRequest._defaults(this);
  }

  PostAdminAuthPasswordRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _oldPassword = $v.oldPassword;
      _newPassword = $v.newPassword;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAuthPasswordRequest other) {
    _$v = other as _$PostAdminAuthPasswordRequest;
  }

  @override
  void update(void Function(PostAdminAuthPasswordRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAuthPasswordRequest build() => _build();

  _$PostAdminAuthPasswordRequest _build() {
    final _$result = _$v ??
        _$PostAdminAuthPasswordRequest._(
          oldPassword: BuiltValueNullFieldError.checkNotNull(
              oldPassword, r'PostAdminAuthPasswordRequest', 'oldPassword'),
          newPassword: BuiltValueNullFieldError.checkNotNull(
              newPassword, r'PostAdminAuthPasswordRequest', 'newPassword'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
