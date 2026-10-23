// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_groups_by_group_id_members_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminGroupsByGroupIdMembersRequest
    extends PostAdminGroupsByGroupIdMembersRequest {
  @override
  final int version;
  @override
  final BuiltList<PostAdminGroupsByGroupIdMembersRequestMembersInner> members;
  @override
  final String reason;

  factory _$PostAdminGroupsByGroupIdMembersRequest(
          [void Function(PostAdminGroupsByGroupIdMembersRequestBuilder)?
              updates]) =>
      (PostAdminGroupsByGroupIdMembersRequestBuilder()..update(updates))
          ._build();

  _$PostAdminGroupsByGroupIdMembersRequest._(
      {required this.version, required this.members, required this.reason})
      : super._();
  @override
  PostAdminGroupsByGroupIdMembersRequest rebuild(
          void Function(PostAdminGroupsByGroupIdMembersRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminGroupsByGroupIdMembersRequestBuilder toBuilder() =>
      PostAdminGroupsByGroupIdMembersRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminGroupsByGroupIdMembersRequest &&
        version == other.version &&
        members == other.members &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminGroupsByGroupIdMembersRequest')
          ..add('version', version)
          ..add('members', members)
          ..add('reason', reason))
        .toString();
  }
}

class PostAdminGroupsByGroupIdMembersRequestBuilder
    implements
        Builder<PostAdminGroupsByGroupIdMembersRequest,
            PostAdminGroupsByGroupIdMembersRequestBuilder> {
  _$PostAdminGroupsByGroupIdMembersRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ListBuilder<PostAdminGroupsByGroupIdMembersRequestMembersInner>? _members;
  ListBuilder<PostAdminGroupsByGroupIdMembersRequestMembersInner> get members =>
      _$this._members ??=
          ListBuilder<PostAdminGroupsByGroupIdMembersRequestMembersInner>();
  set members(
          ListBuilder<PostAdminGroupsByGroupIdMembersRequestMembersInner>?
              members) =>
      _$this._members = members;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PostAdminGroupsByGroupIdMembersRequestBuilder() {
    PostAdminGroupsByGroupIdMembersRequest._defaults(this);
  }

  PostAdminGroupsByGroupIdMembersRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _members = $v.members.toBuilder();
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminGroupsByGroupIdMembersRequest other) {
    _$v = other as _$PostAdminGroupsByGroupIdMembersRequest;
  }

  @override
  void update(
      void Function(PostAdminGroupsByGroupIdMembersRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminGroupsByGroupIdMembersRequest build() => _build();

  _$PostAdminGroupsByGroupIdMembersRequest _build() {
    _$PostAdminGroupsByGroupIdMembersRequest _$result;
    try {
      _$result = _$v ??
          _$PostAdminGroupsByGroupIdMembersRequest._(
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'PostAdminGroupsByGroupIdMembersRequest', 'version'),
            members: members.build(),
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'PostAdminGroupsByGroupIdMembersRequest', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'members';
        members.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAdminGroupsByGroupIdMembersRequest',
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
