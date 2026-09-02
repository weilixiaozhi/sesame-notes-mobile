// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_profile_avatar200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PutProfileAvatar200Response extends PutProfileAvatar200Response {
  @override
  final String avatarUrl;
  @override
  final int avatarVersion;

  factory _$PutProfileAvatar200Response(
          [void Function(PutProfileAvatar200ResponseBuilder)? updates]) =>
      (PutProfileAvatar200ResponseBuilder()..update(updates))._build();

  _$PutProfileAvatar200Response._(
      {required this.avatarUrl, required this.avatarVersion})
      : super._();
  @override
  PutProfileAvatar200Response rebuild(
          void Function(PutProfileAvatar200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutProfileAvatar200ResponseBuilder toBuilder() =>
      PutProfileAvatar200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutProfileAvatar200Response &&
        avatarUrl == other.avatarUrl &&
        avatarVersion == other.avatarVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PutProfileAvatar200Response')
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion))
        .toString();
  }
}

class PutProfileAvatar200ResponseBuilder
    implements
        Builder<PutProfileAvatar200Response,
            PutProfileAvatar200ResponseBuilder> {
  _$PutProfileAvatar200Response? _$v;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  PutProfileAvatar200ResponseBuilder() {
    PutProfileAvatar200Response._defaults(this);
  }

  PutProfileAvatar200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutProfileAvatar200Response other) {
    _$v = other as _$PutProfileAvatar200Response;
  }

  @override
  void update(void Function(PutProfileAvatar200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutProfileAvatar200Response build() => _build();

  _$PutProfileAvatar200Response _build() {
    final _$result = _$v ??
        _$PutProfileAvatar200Response._(
          avatarUrl: BuiltValueNullFieldError.checkNotNull(
              avatarUrl, r'PutProfileAvatar200Response', 'avatarUrl'),
          avatarVersion: BuiltValueNullFieldError.checkNotNull(
              avatarVersion, r'PutProfileAvatar200Response', 'avatarVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
