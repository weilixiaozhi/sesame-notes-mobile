// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_permission_catalog200_response_pages_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminPermissionCatalog200ResponsePagesInner
    extends GetAdminPermissionCatalog200ResponsePagesInner {
  @override
  final String id;
  @override
  final String label;
  @override
  final String path;
  @override
  final BuiltList<String> requiredPermissions;
  @override
  final bool assignable;

  factory _$GetAdminPermissionCatalog200ResponsePagesInner(
          [void Function(GetAdminPermissionCatalog200ResponsePagesInnerBuilder)?
              updates]) =>
      (GetAdminPermissionCatalog200ResponsePagesInnerBuilder()..update(updates))
          ._build();

  _$GetAdminPermissionCatalog200ResponsePagesInner._(
      {required this.id,
      required this.label,
      required this.path,
      required this.requiredPermissions,
      required this.assignable})
      : super._();
  @override
  GetAdminPermissionCatalog200ResponsePagesInner rebuild(
          void Function(GetAdminPermissionCatalog200ResponsePagesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminPermissionCatalog200ResponsePagesInnerBuilder toBuilder() =>
      GetAdminPermissionCatalog200ResponsePagesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminPermissionCatalog200ResponsePagesInner &&
        id == other.id &&
        label == other.label &&
        path == other.path &&
        requiredPermissions == other.requiredPermissions &&
        assignable == other.assignable;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, requiredPermissions.hashCode);
    _$hash = $jc(_$hash, assignable.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetAdminPermissionCatalog200ResponsePagesInner')
          ..add('id', id)
          ..add('label', label)
          ..add('path', path)
          ..add('requiredPermissions', requiredPermissions)
          ..add('assignable', assignable))
        .toString();
  }
}

class GetAdminPermissionCatalog200ResponsePagesInnerBuilder
    implements
        Builder<GetAdminPermissionCatalog200ResponsePagesInner,
            GetAdminPermissionCatalog200ResponsePagesInnerBuilder> {
  _$GetAdminPermissionCatalog200ResponsePagesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  ListBuilder<String>? _requiredPermissions;
  ListBuilder<String> get requiredPermissions =>
      _$this._requiredPermissions ??= ListBuilder<String>();
  set requiredPermissions(ListBuilder<String>? requiredPermissions) =>
      _$this._requiredPermissions = requiredPermissions;

  bool? _assignable;
  bool? get assignable => _$this._assignable;
  set assignable(bool? assignable) => _$this._assignable = assignable;

  GetAdminPermissionCatalog200ResponsePagesInnerBuilder() {
    GetAdminPermissionCatalog200ResponsePagesInner._defaults(this);
  }

  GetAdminPermissionCatalog200ResponsePagesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _label = $v.label;
      _path = $v.path;
      _requiredPermissions = $v.requiredPermissions.toBuilder();
      _assignable = $v.assignable;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminPermissionCatalog200ResponsePagesInner other) {
    _$v = other as _$GetAdminPermissionCatalog200ResponsePagesInner;
  }

  @override
  void update(
      void Function(GetAdminPermissionCatalog200ResponsePagesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminPermissionCatalog200ResponsePagesInner build() => _build();

  _$GetAdminPermissionCatalog200ResponsePagesInner _build() {
    _$GetAdminPermissionCatalog200ResponsePagesInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminPermissionCatalog200ResponsePagesInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GetAdminPermissionCatalog200ResponsePagesInner', 'id'),
            label: BuiltValueNullFieldError.checkNotNull(label,
                r'GetAdminPermissionCatalog200ResponsePagesInner', 'label'),
            path: BuiltValueNullFieldError.checkNotNull(path,
                r'GetAdminPermissionCatalog200ResponsePagesInner', 'path'),
            requiredPermissions: requiredPermissions.build(),
            assignable: BuiltValueNullFieldError.checkNotNull(
                assignable,
                r'GetAdminPermissionCatalog200ResponsePagesInner',
                'assignable'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'requiredPermissions';
        requiredPermissions.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminPermissionCatalog200ResponsePagesInner',
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
