// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_admin_users_by_user_id_avatar200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PutAdminUsersByUserIdAvatar200Response
    extends PutAdminUsersByUserIdAvatar200Response {
  @override
  final String avatarUrl;
  @override
  final int avatarVersion;

  factory _$PutAdminUsersByUserIdAvatar200Response(
          [void Function(PutAdminUsersByUserIdAvatar200ResponseBuilder)?
              updates]) =>
      (PutAdminUsersByUserIdAvatar200ResponseBuilder()..update(updates))
          ._build();

  _$PutAdminUsersByUserIdAvatar200Response._(
      {required this.avatarUrl, required this.avatarVersion})
      : super._();
  @override
  PutAdminUsersByUserIdAvatar200Response rebuild(
          void Function(PutAdminUsersByUserIdAvatar200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutAdminUsersByUserIdAvatar200ResponseBuilder toBuilder() =>
      PutAdminUsersByUserIdAvatar200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutAdminUsersByUserIdAvatar200Response &&
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
    return (newBuiltValueToStringHelper(
            r'PutAdminUsersByUserIdAvatar200Response')
          ..add('avatarUrl', avatarUrl)
          ..add('avatarVersion', avatarVersion))
        .toString();
  }
}

class PutAdminUsersByUserIdAvatar200ResponseBuilder
    implements
        Builder<PutAdminUsersByUserIdAvatar200Response,
            PutAdminUsersByUserIdAvatar200ResponseBuilder> {
  _$PutAdminUsersByUserIdAvatar200Response? _$v;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  PutAdminUsersByUserIdAvatar200ResponseBuilder() {
    PutAdminUsersByUserIdAvatar200Response._defaults(this);
  }

  PutAdminUsersByUserIdAvatar200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarUrl = $v.avatarUrl;
      _avatarVersion = $v.avatarVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutAdminUsersByUserIdAvatar200Response other) {
    _$v = other as _$PutAdminUsersByUserIdAvatar200Response;
  }

  @override
  void update(
      void Function(PutAdminUsersByUserIdAvatar200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PutAdminUsersByUserIdAvatar200Response build() => _build();

  _$PutAdminUsersByUserIdAvatar200Response _build() {
    final _$result = _$v ??
        _$PutAdminUsersByUserIdAvatar200Response._(
          avatarUrl: BuiltValueNullFieldError.checkNotNull(avatarUrl,
              r'PutAdminUsersByUserIdAvatar200Response', 'avatarUrl'),
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'PutAdminUsersByUserIdAvatar200Response', 'avatarVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
