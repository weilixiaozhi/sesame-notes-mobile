// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_admin_groups_by_group_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteAdminGroupsByGroupIdRequest
    extends DeleteAdminGroupsByGroupIdRequest {
  @override
  final int version;
  @override
  final String reason;

  factory _$DeleteAdminGroupsByGroupIdRequest(
          [void Function(DeleteAdminGroupsByGroupIdRequestBuilder)? updates]) =>
      (DeleteAdminGroupsByGroupIdRequestBuilder()..update(updates))._build();

  _$DeleteAdminGroupsByGroupIdRequest._(
      {required this.version, required this.reason})
      : super._();
  @override
  DeleteAdminGroupsByGroupIdRequest rebuild(
          void Function(DeleteAdminGroupsByGroupIdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteAdminGroupsByGroupIdRequestBuilder toBuilder() =>
      DeleteAdminGroupsByGroupIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteAdminGroupsByGroupIdRequest &&
        version == other.version &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteAdminGroupsByGroupIdRequest')
          ..add('version', version)
          ..add('reason', reason))
        .toString();
  }
}

class DeleteAdminGroupsByGroupIdRequestBuilder
    implements
        Builder<DeleteAdminGroupsByGroupIdRequest,
            DeleteAdminGroupsByGroupIdRequestBuilder> {
  _$DeleteAdminGroupsByGroupIdRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DeleteAdminGroupsByGroupIdRequestBuilder() {
    DeleteAdminGroupsByGroupIdRequest._defaults(this);
  }

  DeleteAdminGroupsByGroupIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteAdminGroupsByGroupIdRequest other) {
    _$v = other as _$DeleteAdminGroupsByGroupIdRequest;
  }

  @override
  void update(
      void Function(DeleteAdminGroupsByGroupIdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteAdminGroupsByGroupIdRequest build() => _build();

  _$DeleteAdminGroupsByGroupIdRequest _build() {
    final _$result = _$v ??
        _$DeleteAdminGroupsByGroupIdRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'DeleteAdminGroupsByGroupIdRequest', 'version'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'DeleteAdminGroupsByGroupIdRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
