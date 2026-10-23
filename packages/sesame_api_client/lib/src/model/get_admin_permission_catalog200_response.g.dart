// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_permission_catalog200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminPermissionCatalog200Response
    extends GetAdminPermissionCatalog200Response {
  @override
  final BuiltList<GetAdminPermissionCatalog200ResponsePermissionsInner>
      permissions;
  @override
  final BuiltList<GetAdminPermissionCatalog200ResponsePagesInner> pages;
  @override
  final BuiltList<GetAdminPermissionCatalog200ResponseIdentitiesInner>
      identities;

  factory _$GetAdminPermissionCatalog200Response(
          [void Function(GetAdminPermissionCatalog200ResponseBuilder)?
              updates]) =>
      (GetAdminPermissionCatalog200ResponseBuilder()..update(updates))._build();

  _$GetAdminPermissionCatalog200Response._(
      {required this.permissions,
      required this.pages,
      required this.identities})
      : super._();
  @override
  GetAdminPermissionCatalog200Response rebuild(
          void Function(GetAdminPermissionCatalog200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminPermissionCatalog200ResponseBuilder toBuilder() =>
      GetAdminPermissionCatalog200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminPermissionCatalog200Response &&
        permissions == other.permissions &&
        pages == other.pages &&
        identities == other.identities;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, pages.hashCode);
    _$hash = $jc(_$hash, identities.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminPermissionCatalog200Response')
          ..add('permissions', permissions)
          ..add('pages', pages)
          ..add('identities', identities))
        .toString();
  }
}

class GetAdminPermissionCatalog200ResponseBuilder
    implements
        Builder<GetAdminPermissionCatalog200Response,
            GetAdminPermissionCatalog200ResponseBuilder> {
  _$GetAdminPermissionCatalog200Response? _$v;

  ListBuilder<GetAdminPermissionCatalog200ResponsePermissionsInner>?
      _permissions;
  ListBuilder<GetAdminPermissionCatalog200ResponsePermissionsInner>
      get permissions => _$this._permissions ??=
          ListBuilder<GetAdminPermissionCatalog200ResponsePermissionsInner>();
  set permissions(
          ListBuilder<GetAdminPermissionCatalog200ResponsePermissionsInner>?
              permissions) =>
      _$this._permissions = permissions;

  ListBuilder<GetAdminPermissionCatalog200ResponsePagesInner>? _pages;
  ListBuilder<GetAdminPermissionCatalog200ResponsePagesInner> get pages =>
      _$this._pages ??=
          ListBuilder<GetAdminPermissionCatalog200ResponsePagesInner>();
  set pages(
          ListBuilder<GetAdminPermissionCatalog200ResponsePagesInner>? pages) =>
      _$this._pages = pages;

  ListBuilder<GetAdminPermissionCatalog200ResponseIdentitiesInner>? _identities;
  ListBuilder<GetAdminPermissionCatalog200ResponseIdentitiesInner>
      get identities => _$this._identities ??=
          ListBuilder<GetAdminPermissionCatalog200ResponseIdentitiesInner>();
  set identities(
          ListBuilder<GetAdminPermissionCatalog200ResponseIdentitiesInner>?
              identities) =>
      _$this._identities = identities;

  GetAdminPermissionCatalog200ResponseBuilder() {
    GetAdminPermissionCatalog200Response._defaults(this);
  }

  GetAdminPermissionCatalog200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _permissions = $v.permissions.toBuilder();
      _pages = $v.pages.toBuilder();
      _identities = $v.identities.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminPermissionCatalog200Response other) {
    _$v = other as _$GetAdminPermissionCatalog200Response;
  }

  @override
  void update(
      void Function(GetAdminPermissionCatalog200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminPermissionCatalog200Response build() => _build();

  _$GetAdminPermissionCatalog200Response _build() {
    _$GetAdminPermissionCatalog200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminPermissionCatalog200Response._(
            permissions: permissions.build(),
            pages: pages.build(),
            identities: identities.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
        _$failedField = 'pages';
        pages.build();
        _$failedField = 'identities';
        identities.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminPermissionCatalog200Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
