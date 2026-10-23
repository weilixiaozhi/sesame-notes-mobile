// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_logout_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthLogoutRequest extends PostAuthLogoutRequest {
  @override
  final String refreshToken;

  factory _$PostAuthLogoutRequest(
          [void Function(PostAuthLogoutRequestBuilder)? updates]) =>
      (PostAuthLogoutRequestBuilder()..update(updates))._build();

  _$PostAuthLogoutRequest._({required this.refreshToken}) : super._();
  @override
  PostAuthLogoutRequest rebuild(
          void Function(PostAuthLogoutRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthLogoutRequestBuilder toBuilder() =>
      PostAuthLogoutRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthLogoutRequest && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAuthLogoutRequest')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class PostAuthLogoutRequestBuilder
    implements Builder<PostAuthLogoutRequest, PostAuthLogoutRequestBuilder> {
  _$PostAuthLogoutRequest? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  PostAuthLogoutRequestBuilder() {
    PostAuthLogoutRequest._defaults(this);
  }

  PostAuthLogoutRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthLogoutRequest other) {
    _$v = other as _$PostAuthLogoutRequest;
  }

  @override
  void update(void Function(PostAuthLogoutRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthLogoutRequest build() => _build();

  _$PostAuthLogoutRequest _build() {
    final _$result = _$v ??
        _$PostAuthLogoutRequest._(
          refreshToken: BuiltValueNullFieldError.checkNotNull(
              refreshToken, r'PostAuthLogoutRequest', 'refreshToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
