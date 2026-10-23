// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'put_admin_groups_by_group_id_permissions_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PutAdminGroupsByGroupIdPermissionsRequest
    extends PutAdminGroupsByGroupIdPermissionsRequest {
  @override
  final int version;
  @override
  final BuiltSet<String> permissions;
  @override
  final BuiltSet<String> pageIds;
  @override
  final String reason;

  factory _$PutAdminGroupsByGroupIdPermissionsRequest(
          [void Function(PutAdminGroupsByGroupIdPermissionsRequestBuilder)?
              updates]) =>
      (PutAdminGroupsByGroupIdPermissionsRequestBuilder()..update(updates))
          ._build();

  _$PutAdminGroupsByGroupIdPermissionsRequest._(
      {required this.version,
      required this.permissions,
      required this.pageIds,
      required this.reason})
      : super._();
  @override
  PutAdminGroupsByGroupIdPermissionsRequest rebuild(
          void Function(PutAdminGroupsByGroupIdPermissionsRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PutAdminGroupsByGroupIdPermissionsRequestBuilder toBuilder() =>
      PutAdminGroupsByGroupIdPermissionsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PutAdminGroupsByGroupIdPermissionsRequest &&
        version == other.version &&
        permissions == other.permissions &&
        pageIds == other.pageIds &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, pageIds.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PutAdminGroupsByGroupIdPermissionsRequest')
          ..add('version', version)
          ..add('permissions', permissions)
          ..add('pageIds', pageIds)
          ..add('reason', reason))
        .toString();
  }
}

class PutAdminGroupsByGroupIdPermissionsRequestBuilder
    implements
        Builder<PutAdminGroupsByGroupIdPermissionsRequest,
            PutAdminGroupsByGroupIdPermissionsRequestBuilder> {
  _$PutAdminGroupsByGroupIdPermissionsRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  SetBuilder<String>? _permissions;
  SetBuilder<String> get permissions =>
      _$this._permissions ??= SetBuilder<String>();
  set permissions(SetBuilder<String>? permissions) =>
      _$this._permissions = permissions;

  SetBuilder<String>? _pageIds;
  SetBuilder<String> get pageIds => _$this._pageIds ??= SetBuilder<String>();
  set pageIds(SetBuilder<String>? pageIds) => _$this._pageIds = pageIds;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PutAdminGroupsByGroupIdPermissionsRequestBuilder() {
    PutAdminGroupsByGroupIdPermissionsRequest._defaults(this);
  }

  PutAdminGroupsByGroupIdPermissionsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _permissions = $v.permissions.toBuilder();
      _pageIds = $v.pageIds.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PutAdminGroupsByGroupIdPermissionsRequest other) {
    _$v = other as _$PutAdminGroupsByGroupIdPermissionsRequest;
  }

  @override
  void update(
      void Function(PutAdminGroupsByGroupIdPermissionsRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PutAdminGroupsByGroupIdPermissionsRequest build() => _build();

  _$PutAdminGroupsByGroupIdPermissionsRequest _build() {
    _$PutAdminGroupsByGroupIdPermissionsRequest _$result;
    try {
      _$result = _$v ??
          _$PutAdminGroupsByGroupIdPermissionsRequest._(
            version: BuiltValueNullFieldError.checkNotNull(version,
                r'PutAdminGroupsByGroupIdPermissionsRequest', 'version'),
            permissions: permissions.build(),
            pageIds: pageIds.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'PutAdminGroupsByGroupIdPermissionsRequest', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
        _$failedField = 'pageIds';
        pageIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PutAdminGroupsByGroupIdPermissionsRequest',
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
