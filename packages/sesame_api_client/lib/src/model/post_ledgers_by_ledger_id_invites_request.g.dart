// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_invites_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdInvitesRequest
    extends PostLedgersByLedgerIdInvitesRequest {
  @override
  final int? expiresInHours;

  factory _$PostLedgersByLedgerIdInvitesRequest(
          [void Function(PostLedgersByLedgerIdInvitesRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdInvitesRequestBuilder()..update(updates))._build();

  _$PostLedgersByLedgerIdInvitesRequest._({this.expiresInHours}) : super._();
  @override
  PostLedgersByLedgerIdInvitesRequest rebuild(
          void Function(PostLedgersByLedgerIdInvitesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdInvitesRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdInvitesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdInvitesRequest &&
        expiresInHours == other.expiresInHours;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expiresInHours.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostLedgersByLedgerIdInvitesRequest')
          ..add('expiresInHours', expiresInHours))
        .toString();
  }
}

class PostLedgersByLedgerIdInvitesRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdInvitesRequest,
            PostLedgersByLedgerIdInvitesRequestBuilder> {
  _$PostLedgersByLedgerIdInvitesRequest? _$v;

  int? _expiresInHours;
  int? get expiresInHours => _$this._expiresInHours;
  set expiresInHours(int? expiresInHours) =>
      _$this._expiresInHours = expiresInHours;

  PostLedgersByLedgerIdInvitesRequestBuilder() {
    PostLedgersByLedgerIdInvitesRequest._defaults(this);
  }

  PostLedgersByLedgerIdInvitesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expiresInHours = $v.expiresInHours;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdInvitesRequest other) {
    _$v = other as _$PostLedgersByLedgerIdInvitesRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdInvitesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdInvitesRequest build() => _build();

  _$PostLedgersByLedgerIdInvitesRequest _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdInvitesRequest._(
          expiresInHours: expiresInHours,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
