// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_admin_users_by_user_id_avatar_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteAdminUsersByUserIdAvatarRequest
    extends DeleteAdminUsersByUserIdAvatarRequest {
  @override
  final int avatarVersion;
  @override
  final String reason;

  factory _$DeleteAdminUsersByUserIdAvatarRequest(
          [void Function(DeleteAdminUsersByUserIdAvatarRequestBuilder)?
              updates]) =>
      (DeleteAdminUsersByUserIdAvatarRequestBuilder()..update(updates))
          ._build();

  _$DeleteAdminUsersByUserIdAvatarRequest._(
      {required this.avatarVersion, required this.reason})
      : super._();
  @override
  DeleteAdminUsersByUserIdAvatarRequest rebuild(
          void Function(DeleteAdminUsersByUserIdAvatarRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteAdminUsersByUserIdAvatarRequestBuilder toBuilder() =>
      DeleteAdminUsersByUserIdAvatarRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteAdminUsersByUserIdAvatarRequest &&
        avatarVersion == other.avatarVersion &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, avatarVersion.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'DeleteAdminUsersByUserIdAvatarRequest')
          ..add('avatarVersion', avatarVersion)
          ..add('reason', reason))
        .toString();
  }
}

class DeleteAdminUsersByUserIdAvatarRequestBuilder
    implements
        Builder<DeleteAdminUsersByUserIdAvatarRequest,
            DeleteAdminUsersByUserIdAvatarRequestBuilder> {
  _$DeleteAdminUsersByUserIdAvatarRequest? _$v;

  int? _avatarVersion;
  int? get avatarVersion => _$this._avatarVersion;
  set avatarVersion(int? avatarVersion) =>
      _$this._avatarVersion = avatarVersion;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DeleteAdminUsersByUserIdAvatarRequestBuilder() {
    DeleteAdminUsersByUserIdAvatarRequest._defaults(this);
  }

  DeleteAdminUsersByUserIdAvatarRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _avatarVersion = $v.avatarVersion;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteAdminUsersByUserIdAvatarRequest other) {
    _$v = other as _$DeleteAdminUsersByUserIdAvatarRequest;
  }

  @override
  void update(
      void Function(DeleteAdminUsersByUserIdAvatarRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteAdminUsersByUserIdAvatarRequest build() => _build();

  _$DeleteAdminUsersByUserIdAvatarRequest _build() {
    final _$result = _$v ??
        _$DeleteAdminUsersByUserIdAvatarRequest._(
          avatarVersion: BuiltValueNullFieldError.checkNotNull(avatarVersion,
              r'DeleteAdminUsersByUserIdAvatarRequest', 'avatarVersion'),
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'DeleteAdminUsersByUserIdAvatarRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
