// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_users_by_user_id_disable_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminUsersByUserIdDisableRequest
    extends PatchAdminUsersByUserIdDisableRequest {
  @override
  final String reason;

  factory _$PatchAdminUsersByUserIdDisableRequest(
          [void Function(PatchAdminUsersByUserIdDisableRequestBuilder)?
              updates]) =>
      (PatchAdminUsersByUserIdDisableRequestBuilder()..update(updates))
          ._build();

  _$PatchAdminUsersByUserIdDisableRequest._({required this.reason}) : super._();
  @override
  PatchAdminUsersByUserIdDisableRequest rebuild(
          void Function(PatchAdminUsersByUserIdDisableRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminUsersByUserIdDisableRequestBuilder toBuilder() =>
      PatchAdminUsersByUserIdDisableRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminUsersByUserIdDisableRequest &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PatchAdminUsersByUserIdDisableRequest')
          ..add('reason', reason))
        .toString();
  }
}

class PatchAdminUsersByUserIdDisableRequestBuilder
    implements
        Builder<PatchAdminUsersByUserIdDisableRequest,
            PatchAdminUsersByUserIdDisableRequestBuilder> {
  _$PatchAdminUsersByUserIdDisableRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  PatchAdminUsersByUserIdDisableRequestBuilder() {
    PatchAdminUsersByUserIdDisableRequest._defaults(this);
  }

  PatchAdminUsersByUserIdDisableRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchAdminUsersByUserIdDisableRequest other) {
    _$v = other as _$PatchAdminUsersByUserIdDisableRequest;
  }

  @override
  void update(
      void Function(PatchAdminUsersByUserIdDisableRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminUsersByUserIdDisableRequest build() => _build();

  _$PatchAdminUsersByUserIdDisableRequest _build() {
    final _$result = _$v ??
        _$PatchAdminUsersByUserIdDisableRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'PatchAdminUsersByUserIdDisableRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
