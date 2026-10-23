// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_auth_login200_response_admin_group.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminAuthLogin200ResponseAdminGroup
    extends PostAdminAuthLogin200ResponseAdminGroup {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isEnabled;
  @override
  final bool isDefault;
  @override
  final int version;

  factory _$PostAdminAuthLogin200ResponseAdminGroup(
          [void Function(PostAdminAuthLogin200ResponseAdminGroupBuilder)?
              updates]) =>
      (PostAdminAuthLogin200ResponseAdminGroupBuilder()..update(updates))
          ._build();

  _$PostAdminAuthLogin200ResponseAdminGroup._(
      {required this.id,
      required this.name,
      required this.isEnabled,
      required this.isDefault,
      required this.version})
      : super._();
  @override
  PostAdminAuthLogin200ResponseAdminGroup rebuild(
          void Function(PostAdminAuthLogin200ResponseAdminGroupBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminAuthLogin200ResponseAdminGroupBuilder toBuilder() =>
      PostAdminAuthLogin200ResponseAdminGroupBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminAuthLogin200ResponseAdminGroup &&
        id == other.id &&
        name == other.name &&
        isEnabled == other.isEnabled &&
        isDefault == other.isDefault &&
        version == other.version;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminAuthLogin200ResponseAdminGroup')
          ..add('id', id)
          ..add('name', name)
          ..add('isEnabled', isEnabled)
          ..add('isDefault', isDefault)
          ..add('version', version))
        .toString();
  }
}

class PostAdminAuthLogin200ResponseAdminGroupBuilder
    implements
        Builder<PostAdminAuthLogin200ResponseAdminGroup,
            PostAdminAuthLogin200ResponseAdminGroupBuilder> {
  _$PostAdminAuthLogin200ResponseAdminGroup? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PostAdminAuthLogin200ResponseAdminGroupBuilder() {
    PostAdminAuthLogin200ResponseAdminGroup._defaults(this);
  }

  PostAdminAuthLogin200ResponseAdminGroupBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _isEnabled = $v.isEnabled;
      _isDefault = $v.isDefault;
      _version = $v.version;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminAuthLogin200ResponseAdminGroup other) {
    _$v = other as _$PostAdminAuthLogin200ResponseAdminGroup;
  }

  @override
  void update(
      void Function(PostAdminAuthLogin200ResponseAdminGroupBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminAuthLogin200ResponseAdminGroup build() => _build();

  _$PostAdminAuthLogin200ResponseAdminGroup _build() {
    final _$result = _$v ??
        _$PostAdminAuthLogin200ResponseAdminGroup._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PostAdminAuthLogin200ResponseAdminGroup', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PostAdminAuthLogin200ResponseAdminGroup', 'name'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(isEnabled,
              r'PostAdminAuthLogin200ResponseAdminGroup', 'isEnabled'),
          isDefault: BuiltValueNullFieldError.checkNotNull(isDefault,
              r'PostAdminAuthLogin200ResponseAdminGroup', 'isDefault'),
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'PostAdminAuthLogin200ResponseAdminGroup', 'version'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
