// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_auth_login_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAuthLoginRequest extends PostAdminAuthLoginRequest {
  @override
  final String username;
  @override
  final String password;

  factory _$PostAdminAuthLoginRequest(
          [void Function(PostAdminAuthLoginRequestBuilder)? updates]) =>
      (PostAdminAuthLoginRequestBuilder()..update(updates))._build();

  _$PostAdminAuthLoginRequest._(
      {required this.username, required this.password})
      : super._();
  @override
  PostAdminAuthLoginRequest rebuild(
          void Function(PostAdminAuthLoginRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAuthLoginRequestBuilder toBuilder() =>
      PostAdminAuthLoginRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAuthLoginRequest &&
        username == other.username &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAuthLoginRequest')
          ..add('username', username)
          ..add('password', password))
        .toString();
  }
}

class PostAdminAuthLoginRequestBuilder
    implements
        Builder<PostAdminAuthLoginRequest, PostAdminAuthLoginRequestBuilder> {
  _$PostAdminAuthLoginRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  PostAdminAuthLoginRequestBuilder() {
    PostAdminAuthLoginRequest._defaults(this);
  }

  PostAdminAuthLoginRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAuthLoginRequest other) {
    _$v = other as _$PostAdminAuthLoginRequest;
  }

  @override
  void update(void Function(PostAdminAuthLoginRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAuthLoginRequest build() => _build();

  _$PostAdminAuthLoginRequest _build() {
    final _$result = _$v ??
        _$PostAdminAuthLoginRequest._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'PostAdminAuthLoginRequest', 'username'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'PostAdminAuthLoginRequest', 'password'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
