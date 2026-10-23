// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_groups_by_group_id_members_request_members_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminGroupsByGroupIdMembersRequestMembersInner
    extends PostAdminGroupsByGroupIdMembersRequestMembersInner {
  @override
  final String adminId;
  @override
  final int version;
  @override
  final String groupId;
  @override
  final int groupVersion;

  factory _$PostAdminGroupsByGroupIdMembersRequestMembersInner(
          [void Function(
                  PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder)?
              updates]) =>
      (PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder()
            ..update(updates))
          ._build();

  _$PostAdminGroupsByGroupIdMembersRequestMembersInner._(
      {required this.adminId,
      required this.version,
      required this.groupId,
      required this.groupVersion})
      : super._();
  @override
  PostAdminGroupsByGroupIdMembersRequestMembersInner rebuild(
          void Function(
                  PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder toBuilder() =>
      PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminGroupsByGroupIdMembersRequestMembersInner &&
        adminId == other.adminId &&
        version == other.version &&
        groupId == other.groupId &&
        groupVersion == other.groupVersion;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, adminId.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, groupId.hashCode);
    _$hash = $jc(_$hash, groupVersion.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminGroupsByGroupIdMembersRequestMembersInner')
          ..add('adminId', adminId)
          ..add('version', version)
          ..add('groupId', groupId)
          ..add('groupVersion', groupVersion))
        .toString();
  }
}

class PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder
    implements
        Builder<PostAdminGroupsByGroupIdMembersRequestMembersInner,
            PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder> {
  _$PostAdminGroupsByGroupIdMembersRequestMembersInner? _$v;

  String? _adminId;
  String? get adminId => _$this._adminId;
  set adminId(String? adminId) => _$this._adminId = adminId;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _groupId;
  String? get groupId => _$this._groupId;
  set groupId(String? groupId) => _$this._groupId = groupId;

  int? _groupVersion;
  int? get groupVersion => _$this._groupVersion;
  set groupVersion(int? groupVersion) => _$this._groupVersion = groupVersion;

  PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder() {
    PostAdminGroupsByGroupIdMembersRequestMembersInner._defaults(this);
  }

  PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _adminId = $v.adminId;
      _version = $v.version;
      _groupId = $v.groupId;
      _groupVersion = $v.groupVersion;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminGroupsByGroupIdMembersRequestMembersInner other) {
    _$v = other as _$PostAdminGroupsByGroupIdMembersRequestMembersInner;
  }

  @override
  void update(
      void Function(PostAdminGroupsByGroupIdMembersRequestMembersInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminGroupsByGroupIdMembersRequestMembersInner build() => _build();

  _$PostAdminGroupsByGroupIdMembersRequestMembersInner _build() {
    final _$result = _$v ??
        _$PostAdminGroupsByGroupIdMembersRequestMembersInner._(
          adminId: BuiltValueNullFieldError.checkNotNull(adminId,
              r'PostAdminGroupsByGroupIdMembersRequestMembersInner', 'adminId'),
          version: BuiltValueNullFieldError.checkNotNull(version,
              r'PostAdminGroupsByGroupIdMembersRequestMembersInner', 'version'),
          groupId: BuiltValueNullFieldError.checkNotNull(groupId,
              r'PostAdminGroupsByGroupIdMembersRequestMembersInner', 'groupId'),
          groupVersion: BuiltValueNullFieldError.checkNotNull(
              groupVersion,
              r'PostAdminGroupsByGroupIdMembersRequestMembersInner',
              'groupVersion'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
