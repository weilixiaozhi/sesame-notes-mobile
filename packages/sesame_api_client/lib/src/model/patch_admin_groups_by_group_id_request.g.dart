// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_groups_by_group_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminGroupsByGroupIdRequest
    extends PatchAdminGroupsByGroupIdRequest {
  @override
  final int version;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final int? sort;
  @override
  final bool? isEnabled;
  @override
  final String? reason;

  factory _$PatchAdminGroupsByGroupIdRequest(
          [void Function(PatchAdminGroupsByGroupIdRequestBuilder)? updates]) =>
      (PatchAdminGroupsByGroupIdRequestBuilder()..update(updates))._build();

  _$PatchAdminGroupsByGroupIdRequest._(
      {required this.version,
      this.name,
      this.description,
      this.sort,
      this.isEnabled,
      this.reason})
      : super._();
  @override
  PatchAdminGroupsByGroupIdRequest rebuild(
          void Function(PatchAdminGroupsByGroupIdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminGroupsByGroupIdRequestBuilder toBuilder() =>
      PatchAdminGroupsByGroupIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminGroupsByGroupIdRequest &&
        version == other.version &&
        name == other.name &&
        description == other.description &&
        sort == other.sort &&
        isEnabled == other.isEnabled &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, sort.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatchAdminGroupsByGroupIdRequest')
          ..add('version', version)
          ..add('name', name)
          ..add('description', description)
          ..add('sort', sort)
          ..add('isEnabled', isEnabled)
          ..add('reason', reason))
        .toString();
  }
}

class PatchAdminGroupsByGroupIdRequestBuilder
    implements
        Builder<PatchAdminGroupsByGroupIdRequest,
            PatchAdminGroupsByGroupIdRequestBuilder> {
  _$PatchAdminGroupsByGroupIdRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

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

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PatchAdminGroupsByGroupIdRequestBuilder() {
    PatchAdminGroupsByGroupIdRequest._defaults(this);
  }

  PatchAdminGroupsByGroupIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _name = $v.name;
      _description = $v.description;
      _sort = $v.sort;
      _isEnabled = $v.isEnabled;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchAdminGroupsByGroupIdRequest other) {
    _$v = other as _$PatchAdminGroupsByGroupIdRequest;
  }

  @override
  void update(void Function(PatchAdminGroupsByGroupIdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminGroupsByGroupIdRequest build() => _build();

  _$PatchAdminGroupsByGroupIdRequest _build() {
    final _$result = _$v ??
        _$PatchAdminGroupsByGroupIdRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'PatchAdminGroupsByGroupIdRequest', 'version'),
          name: name,
          description: description,
          sort: sort,
          isEnabled: isEnabled,
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
