// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_groups200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminGroups200ResponseItemsInner
    extends GetAdminGroups200ResponseItemsInner {
  @override
  final String id;
  @override
  final bool isDefault;
  @override
  final String name;
  @override
  final String description;
  @override
  final int sort;
  @override
  final bool isEnabled;
  @override
  final BuiltList<String> permissions;
  @override
  final BuiltList<String> pageIds;
  @override
  final int version;
  @override
  final int memberCount;
  @override
  final String? createdBy;
  @override
  final String? updatedBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$GetAdminGroups200ResponseItemsInner(
          [void Function(GetAdminGroups200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetAdminGroups200ResponseItemsInnerBuilder()..update(updates))._build();

  _$GetAdminGroups200ResponseItemsInner._(
      {required this.id,
      required this.isDefault,
      required this.name,
      required this.description,
      required this.sort,
      required this.isEnabled,
      required this.permissions,
      required this.pageIds,
      required this.version,
      required this.memberCount,
      this.createdBy,
      this.updatedBy,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  GetAdminGroups200ResponseItemsInner rebuild(
          void Function(GetAdminGroups200ResponseItemsInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminGroups200ResponseItemsInnerBuilder toBuilder() =>
      GetAdminGroups200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminGroups200ResponseItemsInner &&
        id == other.id &&
        isDefault == other.isDefault &&
        name == other.name &&
        description == other.description &&
        sort == other.sort &&
        isEnabled == other.isEnabled &&
        permissions == other.permissions &&
        pageIds == other.pageIds &&
        version == other.version &&
        memberCount == other.memberCount &&
        createdBy == other.createdBy &&
        updatedBy == other.updatedBy &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, sort.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, permissions.hashCode);
    _$hash = $jc(_$hash, pageIds.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, memberCount.hashCode);
    _$hash = $jc(_$hash, createdBy.hashCode);
    _$hash = $jc(_$hash, updatedBy.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminGroups200ResponseItemsInner')
          ..add('id', id)
          ..add('isDefault', isDefault)
          ..add('name', name)
          ..add('description', description)
          ..add('sort', sort)
          ..add('isEnabled', isEnabled)
          ..add('permissions', permissions)
          ..add('pageIds', pageIds)
          ..add('version', version)
          ..add('memberCount', memberCount)
          ..add('createdBy', createdBy)
          ..add('updatedBy', updatedBy)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GetAdminGroups200ResponseItemsInnerBuilder
    implements
        Builder<GetAdminGroups200ResponseItemsInner,
            GetAdminGroups200ResponseItemsInnerBuilder> {
  _$GetAdminGroups200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _sort;
  int? get sort => _$this._sort;
  set sort(int? sort) => _$this._sort = sort;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  ListBuilder<String>? _permissions;
  ListBuilder<String> get permissions =>
      _$this._permissions ??= ListBuilder<String>();
  set permissions(ListBuilder<String>? permissions) =>
      _$this._permissions = permissions;

  ListBuilder<String>? _pageIds;
  ListBuilder<String> get pageIds => _$this._pageIds ??= ListBuilder<String>();
  set pageIds(ListBuilder<String>? pageIds) => _$this._pageIds = pageIds;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  int? _memberCount;
  int? get memberCount => _$this._memberCount;
  set memberCount(int? memberCount) => _$this._memberCount = memberCount;

  String? _createdBy;
  String? get createdBy => _$this._createdBy;
  set createdBy(String? createdBy) => _$this._createdBy = createdBy;

  String? _updatedBy;
  String? get updatedBy => _$this._updatedBy;
  set updatedBy(String? updatedBy) => _$this._updatedBy = updatedBy;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GetAdminGroups200ResponseItemsInnerBuilder() {
    GetAdminGroups200ResponseItemsInner._defaults(this);
  }

  GetAdminGroups200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _isDefault = $v.isDefault;
      _name = $v.name;
      _description = $v.description;
      _sort = $v.sort;
      _isEnabled = $v.isEnabled;
      _permissions = $v.permissions.toBuilder();
      _pageIds = $v.pageIds.toBuilder();
      _version = $v.version;
      _memberCount = $v.memberCount;
      _createdBy = $v.createdBy;
      _updatedBy = $v.updatedBy;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminGroups200ResponseItemsInner other) {
    _$v = other as _$GetAdminGroups200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetAdminGroups200ResponseItemsInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminGroups200ResponseItemsInner build() => _build();

  _$GetAdminGroups200ResponseItemsInner _build() {
    _$GetAdminGroups200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetAdminGroups200ResponseItemsInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GetAdminGroups200ResponseItemsInner', 'id'),
            isDefault: BuiltValueNullFieldError.checkNotNull(
                isDefault, r'GetAdminGroups200ResponseItemsInner', 'isDefault'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'GetAdminGroups200ResponseItemsInner', 'name'),
            description: BuiltValueNullFieldError.checkNotNull(description,
                r'GetAdminGroups200ResponseItemsInner', 'description'),
            sort: BuiltValueNullFieldError.checkNotNull(
                sort, r'GetAdminGroups200ResponseItemsInner', 'sort'),
            isEnabled: BuiltValueNullFieldError.checkNotNull(
                isEnabled, r'GetAdminGroups200ResponseItemsInner', 'isEnabled'),
            permissions: permissions.build(),
            pageIds: pageIds.build(),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'GetAdminGroups200ResponseItemsInner', 'version'),
            memberCount: BuiltValueNullFieldError.checkNotNull(memberCount,
                r'GetAdminGroups200ResponseItemsInner', 'memberCount'),
            createdBy: createdBy,
            updatedBy: updatedBy,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'GetAdminGroups200ResponseItemsInner', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'GetAdminGroups200ResponseItemsInner', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'permissions';
        permissions.build();
        _$failedField = 'pageIds';
        pageIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'GetAdminGroups200ResponseItemsInner',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
