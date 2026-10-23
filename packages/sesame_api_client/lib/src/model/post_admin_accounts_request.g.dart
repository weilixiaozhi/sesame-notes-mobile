// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_accounts_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAccountsRequest extends PostAdminAccountsRequest {
  @override
  final String username;
  @override
  final String password;
  @override
  final String displayName;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final String? groupId;

  factory _$PostAdminAccountsRequest(
          [void Function(PostAdminAccountsRequestBuilder)? updates]) =>
      (PostAdminAccountsRequestBuilder()..update(updates))._build();

  _$PostAdminAccountsRequest._(
      {required this.username,
      required this.password,
      required this.displayName,
      this.email,
      this.phone,
      this.groupId})
      : super._();
  @override
  PostAdminAccountsRequest rebuild(
          void Function(PostAdminAccountsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAccountsRequestBuilder toBuilder() =>
      PostAdminAccountsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAccountsRequest &&
        username == other.username &&
        password == other.password &&
        displayName == other.displayName &&
        email == other.email &&
        phone == other.phone &&
        groupId == other.groupId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, phone.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAccountsRequest')
          ..add('username', username)
          ..add('password', password)
          ..add('displayName', displayName)
          ..add('email', email)
          ..add('phone', phone)
          ..add('groupId', groupId))
        .toString();
  }
}

class PostAdminAccountsRequestBuilder
    implements
        Builder<PostAdminAccountsRequest, PostAdminAccountsRequestBuilder> {
  _$PostAdminAccountsRequest? _$v;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

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

  PostAdminAccountsRequestBuilder() {
    PostAdminAccountsRequest._defaults(this);
  }

  PostAdminAccountsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _username = $v.username;
      _password = $v.password;
      _displayName = $v.displayName;
      _email = $v.email;
      _phone = $v.phone;
      _groupId = $v.groupId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAccountsRequest other) {
    _$v = other as _$PostAdminAccountsRequest;
  }

  @override
  void update(void Function(PostAdminAccountsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAccountsRequest build() => _build();

  _$PostAdminAccountsRequest _build() {
    final _$result = _$v ??
        _$PostAdminAccountsRequest._(
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'PostAdminAccountsRequest', 'username'),
          password: BuiltValueNullFieldError.checkNotNull(
              password, r'PostAdminAccountsRequest', 'password'),
          displayName: BuiltValueNullFieldError.checkNotNull(
              displayName, r'PostAdminAccountsRequest', 'displayName'),
          email: email,
          phone: phone,
          groupId: groupId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
