// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_auth_login200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAuthLogin200Response extends PostAdminAuthLogin200Response {
  @override
  final PostAdminAuthLogin200ResponseAdmin admin;
  @override
  final DateTime expiresAt;

  factory _$PostAdminAuthLogin200Response(
          [void Function(PostAdminAuthLogin200ResponseBuilder)? updates]) =>
      (PostAdminAuthLogin200ResponseBuilder()..update(updates))._build();

  _$PostAdminAuthLogin200Response._(
      {required this.admin, required this.expiresAt})
      : super._();
  @override
  PostAdminAuthLogin200Response rebuild(
          void Function(PostAdminAuthLogin200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAuthLogin200ResponseBuilder toBuilder() =>
      PostAdminAuthLogin200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAuthLogin200Response &&
        admin == other.admin &&
        expiresAt == other.expiresAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, admin.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminAuthLogin200Response')
          ..add('admin', admin)
          ..add('expiresAt', expiresAt))
        .toString();
  }
}

class PostAdminAuthLogin200ResponseBuilder
    implements
        Builder<PostAdminAuthLogin200Response,
            PostAdminAuthLogin200ResponseBuilder> {
  _$PostAdminAuthLogin200Response? _$v;

  PostAdminAuthLogin200ResponseAdminBuilder? _admin;
  PostAdminAuthLogin200ResponseAdminBuilder get admin =>
      _$this._admin ??= PostAdminAuthLogin200ResponseAdminBuilder();
  set admin(PostAdminAuthLogin200ResponseAdminBuilder? admin) =>
      _$this._admin = admin;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  PostAdminAuthLogin200ResponseBuilder() {
    PostAdminAuthLogin200Response._defaults(this);
  }

  PostAdminAuthLogin200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _admin = $v.admin.toBuilder();
      _expiresAt = $v.expiresAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAuthLogin200Response other) {
    _$v = other as _$PostAdminAuthLogin200Response;
  }

  @override
  void update(void Function(PostAdminAuthLogin200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAuthLogin200Response build() => _build();

  _$PostAdminAuthLogin200Response _build() {
    _$PostAdminAuthLogin200Response _$result;
    try {
      _$result = _$v ??
          _$PostAdminAuthLogin200Response._(
            admin: admin.build(),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'PostAdminAuthLogin200Response', 'expiresAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'admin';
        admin.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAdminAuthLogin200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
