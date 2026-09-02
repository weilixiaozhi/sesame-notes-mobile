// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_refresh_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthRefreshRequest extends PostAuthRefreshRequest {
  @override
  final String? refreshToken;

  factory _$PostAuthRefreshRequest(
          [void Function(PostAuthRefreshRequestBuilder)? updates]) =>
      (PostAuthRefreshRequestBuilder()..update(updates))._build();

  _$PostAuthRefreshRequest._({this.refreshToken}) : super._();
  @override
  PostAuthRefreshRequest rebuild(
          void Function(PostAuthRefreshRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthRefreshRequestBuilder toBuilder() =>
      PostAuthRefreshRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthRefreshRequest &&
        refreshToken == other.refreshToken;
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
    return (newBuiltValueToStringHelper(r'PostAuthRefreshRequest')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class PostAuthRefreshRequestBuilder
    implements Builder<PostAuthRefreshRequest, PostAuthRefreshRequestBuilder> {
  _$PostAuthRefreshRequest? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  PostAuthRefreshRequestBuilder() {
    PostAuthRefreshRequest._defaults(this);
  }

  PostAuthRefreshRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthRefreshRequest other) {
    _$v = other as _$PostAuthRefreshRequest;
  }

  @override
  void update(void Function(PostAuthRefreshRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthRefreshRequest build() => _build();

  _$PostAuthRefreshRequest _build() {
    final _$result = _$v ??
        _$PostAuthRefreshRequest._(
          refreshToken: refreshToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
