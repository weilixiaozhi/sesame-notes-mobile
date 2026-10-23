// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_groups_by_group_id_members200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminGroupsByGroupIdMembers200Response
    extends PostAdminGroupsByGroupIdMembers200Response {
  @override
  final int transferred;
  @override
  final bool selfSessionRevoked;

  factory _$PostAdminGroupsByGroupIdMembers200Response(
          [void Function(PostAdminGroupsByGroupIdMembers200ResponseBuilder)?
              updates]) =>
      (PostAdminGroupsByGroupIdMembers200ResponseBuilder()..update(updates))
          ._build();

  _$PostAdminGroupsByGroupIdMembers200Response._(
      {required this.transferred, required this.selfSessionRevoked})
      : super._();
  @override
  PostAdminGroupsByGroupIdMembers200Response rebuild(
          void Function(PostAdminGroupsByGroupIdMembers200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminGroupsByGroupIdMembers200ResponseBuilder toBuilder() =>
      PostAdminGroupsByGroupIdMembers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminGroupsByGroupIdMembers200Response &&
        transferred == other.transferred &&
        selfSessionRevoked == other.selfSessionRevoked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, transferred.hashCode);
    _$hash = $jc(_$hash, selfSessionRevoked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminGroupsByGroupIdMembers200Response')
          ..add('transferred', transferred)
          ..add('selfSessionRevoked', selfSessionRevoked))
        .toString();
  }
}

class PostAdminGroupsByGroupIdMembers200ResponseBuilder
    implements
        Builder<PostAdminGroupsByGroupIdMembers200Response,
            PostAdminGroupsByGroupIdMembers200ResponseBuilder> {
  _$PostAdminGroupsByGroupIdMembers200Response? _$v;

  int? _transferred;
  int? get transferred => _$this._transferred;
  set transferred(int? transferred) => _$this._transferred = transferred;

  bool? _selfSessionRevoked;
  bool? get selfSessionRevoked => _$this._selfSessionRevoked;
  set selfSessionRevoked(bool? selfSessionRevoked) =>
      _$this._selfSessionRevoked = selfSessionRevoked;

  PostAdminGroupsByGroupIdMembers200ResponseBuilder() {
    PostAdminGroupsByGroupIdMembers200Response._defaults(this);
  }

  PostAdminGroupsByGroupIdMembers200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _transferred = $v.transferred;
      _selfSessionRevoked = $v.selfSessionRevoked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminGroupsByGroupIdMembers200Response other) {
    _$v = other as _$PostAdminGroupsByGroupIdMembers200Response;
  }

  @override
  void update(
      void Function(PostAdminGroupsByGroupIdMembers200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminGroupsByGroupIdMembers200Response build() => _build();

  _$PostAdminGroupsByGroupIdMembers200Response _build() {
    final _$result = _$v ??
        _$PostAdminGroupsByGroupIdMembers200Response._(
          transferred: BuiltValueNullFieldError.checkNotNull(transferred,
              r'PostAdminGroupsByGroupIdMembers200Response', 'transferred'),
          selfSessionRevoked: BuiltValueNullFieldError.checkNotNull(
              selfSessionRevoked,
              r'PostAdminGroupsByGroupIdMembers200Response',
              'selfSessionRevoked'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
