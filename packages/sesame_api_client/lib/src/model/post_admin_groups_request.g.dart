// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_groups_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminGroupsRequest extends PostAdminGroupsRequest {
  @override
  final String name;
  @override
  final String? description;
  @override
  final int? sort;
  @override
  final bool? isEnabled;

  factory _$PostAdminGroupsRequest(
          [void Function(PostAdminGroupsRequestBuilder)? updates]) =>
      (PostAdminGroupsRequestBuilder()..update(updates))._build();

  _$PostAdminGroupsRequest._(
      {required this.name, this.description, this.sort, this.isEnabled})
      : super._();
  @override
  PostAdminGroupsRequest rebuild(
          void Function(PostAdminGroupsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminGroupsRequestBuilder toBuilder() =>
      PostAdminGroupsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminGroupsRequest &&
        name == other.name &&
        description == other.description &&
        sort == other.sort &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, sort.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminGroupsRequest')
          ..add('name', name)
          ..add('description', description)
          ..add('sort', sort)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PostAdminGroupsRequestBuilder
    implements Builder<PostAdminGroupsRequest, PostAdminGroupsRequestBuilder> {
  _$PostAdminGroupsRequest? _$v;

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

  PostAdminGroupsRequestBuilder() {
    PostAdminGroupsRequest._defaults(this);
  }

  PostAdminGroupsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _description = $v.description;
      _sort = $v.sort;
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminGroupsRequest other) {
    _$v = other as _$PostAdminGroupsRequest;
  }

  @override
  void update(void Function(PostAdminGroupsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminGroupsRequest build() => _build();

  _$PostAdminGroupsRequest _build() {
    final _$result = _$v ??
        _$PostAdminGroupsRequest._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'PostAdminGroupsRequest', 'name'),
          description: description,
          sort: sort,
          isEnabled: isEnabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
