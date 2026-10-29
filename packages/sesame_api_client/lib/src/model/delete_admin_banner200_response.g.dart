// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_admin_banner200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteAdminBanner200Response extends DeleteAdminBanner200Response {
  @override
  final bool ok;

  factory _$DeleteAdminBanner200Response(
          [void Function(DeleteAdminBanner200ResponseBuilder)? updates]) =>
      (DeleteAdminBanner200ResponseBuilder()..update(updates))._build();

  _$DeleteAdminBanner200Response._({required this.ok}) : super._();
  @override
  DeleteAdminBanner200Response rebuild(
          void Function(DeleteAdminBanner200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteAdminBanner200ResponseBuilder toBuilder() =>
      DeleteAdminBanner200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteAdminBanner200Response && ok == other.ok;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ok.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteAdminBanner200Response')
          ..add('ok', ok))
        .toString();
  }
}

class DeleteAdminBanner200ResponseBuilder
    implements
        Builder<DeleteAdminBanner200Response,
            DeleteAdminBanner200ResponseBuilder> {
  _$DeleteAdminBanner200Response? _$v;

  bool? _ok;
  bool? get ok => _$this._ok;
  set ok(bool? ok) => _$this._ok = ok;

  DeleteAdminBanner200ResponseBuilder() {
    DeleteAdminBanner200Response._defaults(this);
  }

  DeleteAdminBanner200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ok = $v.ok;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteAdminBanner200Response other) {
    _$v = other as _$DeleteAdminBanner200Response;
  }

  @override
  void update(void Function(DeleteAdminBanner200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteAdminBanner200Response build() => _build();

  _$DeleteAdminBanner200Response _build() {
    final _$result = _$v ??
        _$DeleteAdminBanner200Response._(
          ok: BuiltValueNullFieldError.checkNotNull(
              ok, r'DeleteAdminBanner200Response', 'ok'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
