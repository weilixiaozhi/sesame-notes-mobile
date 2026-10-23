// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_auth_browser_refresh_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAuthBrowserRefreshRequest extends PostAuthBrowserRefreshRequest {
  @override
  final JsonObject? device;

  factory _$PostAuthBrowserRefreshRequest(
          [void Function(PostAuthBrowserRefreshRequestBuilder)? updates]) =>
      (PostAuthBrowserRefreshRequestBuilder()..update(updates))._build();

  _$PostAuthBrowserRefreshRequest._({this.device}) : super._();
  @override
  PostAuthBrowserRefreshRequest rebuild(
          void Function(PostAuthBrowserRefreshRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAuthBrowserRefreshRequestBuilder toBuilder() =>
      PostAuthBrowserRefreshRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAuthBrowserRefreshRequest && device == other.device;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, device.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAuthBrowserRefreshRequest')
          ..add('device', device))
        .toString();
  }
}

class PostAuthBrowserRefreshRequestBuilder
    implements
        Builder<PostAuthBrowserRefreshRequest,
            PostAuthBrowserRefreshRequestBuilder> {
  _$PostAuthBrowserRefreshRequest? _$v;

  JsonObject? _device;
  JsonObject? get device => _$this._device;
  set device(JsonObject? device) => _$this._device = device;

  PostAuthBrowserRefreshRequestBuilder() {
    PostAuthBrowserRefreshRequest._defaults(this);
  }

  PostAuthBrowserRefreshRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _device = $v.device;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAuthBrowserRefreshRequest other) {
    _$v = other as _$PostAuthBrowserRefreshRequest;
  }

  @override
  void update(void Function(PostAuthBrowserRefreshRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAuthBrowserRefreshRequest build() => _build();

  _$PostAuthBrowserRefreshRequest _build() {
    final _$result = _$v ??
        _$PostAuthBrowserRefreshRequest._(
          device: device,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
