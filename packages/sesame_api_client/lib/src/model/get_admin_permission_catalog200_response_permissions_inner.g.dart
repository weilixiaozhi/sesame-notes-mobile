// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_permission_catalog200_response_permissions_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminPermissionCatalog200ResponsePermissionsInner
    extends GetAdminPermissionCatalog200ResponsePermissionsInner {
  @override
  final String id;
  @override
  final String label;
  @override
  final BuiltList<String> dependencies;

  factory _$GetAdminPermissionCatalog200ResponsePermissionsInner(
          [void Function(
                  GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder)?
              updates]) =>
      (GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetAdminPermissionCatalog200ResponsePermissionsInner._(
      {required this.id, required this.label, required this.dependencies})
      : super._();
  @override
  GetAdminPermissionCatalog200ResponsePermissionsInner rebuild(
          void Function(
                  GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder toBuilder() =>
      GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminPermissionCatalog200ResponsePermissionsInner &&
        id == other.id &&
        label == other.label &&
        dependencies == other.dependencies;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, dependencies.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminPermissionCatalog200ResponsePermissionsInner')
          ..add('id', id)
          ..add('label', label)
          ..add('dependencies', dependencies))
        .toString();
  }
}

class GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder
    implements
        Builder<GetAdminPermissionCatalog200ResponsePermissionsInner,
            GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder> {
  _$GetAdminPermissionCatalog200ResponsePermissionsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  ListBuilder<String>? _dependencies;
  ListBuilder<String> get dependencies =>
      _$this._dependencies ??= ListBuilder<String>();
  set dependencies(ListBuilder<String>? dependencies) =>
      _$this._dependencies = dependencies;

  GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder() {
    GetAdminPermissionCatalog200ResponsePermissionsInner._defaults(this);
  }

  GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _dependencies = $v.dependencies.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminPermissionCatalog200ResponsePermissionsInner other) {
    _$v = other as _$GetAdminPermissionCatalog200ResponsePermissionsInner;
  }

  @override
  void update(
      void Function(
              GetAdminPermissionCatalog200ResponsePermissionsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminPermissionCatalog200ResponsePermissionsInner build() => _build();

  _$GetAdminPermissionCatalog200ResponsePermissionsInner _build() {
    _$GetAdminPermissionCatalog200ResponsePermissionsInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminPermissionCatalog200ResponsePermissionsInner._(
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'GetAdminPermissionCatalog200ResponsePermissionsInner', 'id'),
            label: BuiltValueNullFieldError.checkNotNull(
                label,
                r'GetAdminPermissionCatalog200ResponsePermissionsInner',
                'label'),
            dependencies: dependencies.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dependencies';
        dependencies.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminPermissionCatalog200ResponsePermissionsInner',
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
