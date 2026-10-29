// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_admin_banner_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteAdminBannerRequest extends DeleteAdminBannerRequest {
  @override
  final int version;

  factory _$DeleteAdminBannerRequest(
          [void Function(DeleteAdminBannerRequestBuilder)? updates]) =>
      (DeleteAdminBannerRequestBuilder()..update(updates))._build();

  _$DeleteAdminBannerRequest._({required this.version}) : super._();
  @override
  DeleteAdminBannerRequest rebuild(
          void Function(DeleteAdminBannerRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteAdminBannerRequestBuilder toBuilder() =>
      DeleteAdminBannerRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteAdminBannerRequest && version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteAdminBannerRequest')
          ..add('version', version))
        .toString();
  }
}

class DeleteAdminBannerRequestBuilder
    implements
        Builder<DeleteAdminBannerRequest, DeleteAdminBannerRequestBuilder> {
  _$DeleteAdminBannerRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  DeleteAdminBannerRequestBuilder() {
    DeleteAdminBannerRequest._defaults(this);
  }

  DeleteAdminBannerRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteAdminBannerRequest other) {
    _$v = other as _$DeleteAdminBannerRequest;
  }

  @override
  void update(void Function(DeleteAdminBannerRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteAdminBannerRequest build() => _build();

  _$DeleteAdminBannerRequest _build() {
    final _$result = _$v ??
        _$DeleteAdminBannerRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'DeleteAdminBannerRequest', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
