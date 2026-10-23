// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_permission_catalog200_response_identities_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminPermissionCatalog200ResponseIdentitiesInner
    extends GetAdminPermissionCatalog200ResponseIdentitiesInner {
  @override
  final String value;
  @override
  final String label;

  factory _$GetAdminPermissionCatalog200ResponseIdentitiesInner(
          [void Function(
                  GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder)?
              updates]) =>
      (GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetAdminPermissionCatalog200ResponseIdentitiesInner._(
      {required this.value, required this.label})
      : super._();
  @override
  GetAdminPermissionCatalog200ResponseIdentitiesInner rebuild(
          void Function(
                  GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder toBuilder() =>
      GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminPermissionCatalog200ResponseIdentitiesInner &&
        value == other.value &&
        label == other.label;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminPermissionCatalog200ResponseIdentitiesInner')
          ..add('value', value)
          ..add('label', label))
        .toString();
  }
}

class GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder
    implements
        Builder<GetAdminPermissionCatalog200ResponseIdentitiesInner,
            GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder> {
  _$GetAdminPermissionCatalog200ResponseIdentitiesInner? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder() {
    GetAdminPermissionCatalog200ResponseIdentitiesInner._defaults(this);
  }

  GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _label = $v.label;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminPermissionCatalog200ResponseIdentitiesInner other) {
    _$v = other as _$GetAdminPermissionCatalog200ResponseIdentitiesInner;
  }

  @override
  void update(
      void Function(GetAdminPermissionCatalog200ResponseIdentitiesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminPermissionCatalog200ResponseIdentitiesInner build() => _build();

  _$GetAdminPermissionCatalog200ResponseIdentitiesInner _build() {
    final _$result = _$v ??
        _$GetAdminPermissionCatalog200ResponseIdentitiesInner._(
          value: BuiltValueNullFieldError.checkNotNull(value,
              r'GetAdminPermissionCatalog200ResponseIdentitiesInner', 'value'),
          label: BuiltValueNullFieldError.checkNotNull(label,
              r'GetAdminPermissionCatalog200ResponseIdentitiesInner', 'label'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
