// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_clear_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdClearRequest
    extends PostLedgersByLedgerIdClearRequest {
  @override
  final String mutationId;
  @override
  final String expectedSyncId;
  @override
  final String expectedFingerprint;

  factory _$PostLedgersByLedgerIdClearRequest(
          [void Function(PostLedgersByLedgerIdClearRequestBuilder)? updates]) =>
      (PostLedgersByLedgerIdClearRequestBuilder()..update(updates))._build();

  _$PostLedgersByLedgerIdClearRequest._(
      {required this.mutationId,
      required this.expectedSyncId,
      required this.expectedFingerprint})
      : super._();
  @override
  PostLedgersByLedgerIdClearRequest rebuild(
          void Function(PostLedgersByLedgerIdClearRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdClearRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdClearRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdClearRequest &&
        mutationId == other.mutationId &&
        expectedSyncId == other.expectedSyncId &&
        expectedFingerprint == other.expectedFingerprint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, expectedSyncId.hashCode);
    _$hash = $jc(_$hash, expectedFingerprint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostLedgersByLedgerIdClearRequest')
          ..add('mutationId', mutationId)
          ..add('expectedSyncId', expectedSyncId)
          ..add('expectedFingerprint', expectedFingerprint))
        .toString();
  }
}

class PostLedgersByLedgerIdClearRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdClearRequest,
            PostLedgersByLedgerIdClearRequestBuilder> {
  _$PostLedgersByLedgerIdClearRequest? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  String? _expectedSyncId;
  String? get expectedSyncId => _$this._expectedSyncId;
  set expectedSyncId(String? expectedSyncId) =>
      _$this._expectedSyncId = expectedSyncId;

  String? _expectedFingerprint;
  String? get expectedFingerprint => _$this._expectedFingerprint;
  set expectedFingerprint(String? expectedFingerprint) =>
      _$this._expectedFingerprint = expectedFingerprint;

  PostLedgersByLedgerIdClearRequestBuilder() {
    PostLedgersByLedgerIdClearRequest._defaults(this);
  }

  PostLedgersByLedgerIdClearRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _expectedSyncId = $v.expectedSyncId;
      _expectedFingerprint = $v.expectedFingerprint;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdClearRequest other) {
    _$v = other as _$PostLedgersByLedgerIdClearRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdClearRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdClearRequest build() => _build();

  _$PostLedgersByLedgerIdClearRequest _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdClearRequest._(
          mutationId: BuiltValueNullFieldError.checkNotNull(
              mutationId, r'PostLedgersByLedgerIdClearRequest', 'mutationId'),
          expectedSyncId: BuiltValueNullFieldError.checkNotNull(expectedSyncId,
              r'PostLedgersByLedgerIdClearRequest', 'expectedSyncId'),
          expectedFingerprint: BuiltValueNullFieldError.checkNotNull(
              expectedFingerprint,
              r'PostLedgersByLedgerIdClearRequest',
              'expectedFingerprint'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
