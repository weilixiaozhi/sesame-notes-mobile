// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_clear200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdClear200Response
    extends PostLedgersByLedgerIdClear200Response {
  @override
  final int deletedCount;
  @override
  final String syncId;
  @override
  final bool replayed;

  factory _$PostLedgersByLedgerIdClear200Response(
          [void Function(PostLedgersByLedgerIdClear200ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdClear200ResponseBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdClear200Response._(
      {required this.deletedCount,
      required this.syncId,
      required this.replayed})
      : super._();
  @override
  PostLedgersByLedgerIdClear200Response rebuild(
          void Function(PostLedgersByLedgerIdClear200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdClear200ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdClear200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdClear200Response &&
        deletedCount == other.deletedCount &&
        syncId == other.syncId &&
        replayed == other.replayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deletedCount.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, replayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdClear200Response')
          ..add('deletedCount', deletedCount)
          ..add('syncId', syncId)
          ..add('replayed', replayed))
        .toString();
  }
}

class PostLedgersByLedgerIdClear200ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdClear200Response,
            PostLedgersByLedgerIdClear200ResponseBuilder> {
  _$PostLedgersByLedgerIdClear200Response? _$v;

  int? _deletedCount;
  int? get deletedCount => _$this._deletedCount;
  set deletedCount(int? deletedCount) => _$this._deletedCount = deletedCount;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  bool? _replayed;
  bool? get replayed => _$this._replayed;
  set replayed(bool? replayed) => _$this._replayed = replayed;

  PostLedgersByLedgerIdClear200ResponseBuilder() {
    PostLedgersByLedgerIdClear200Response._defaults(this);
  }

  PostLedgersByLedgerIdClear200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deletedCount = $v.deletedCount;
      _syncId = $v.syncId;
      _replayed = $v.replayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdClear200Response other) {
    _$v = other as _$PostLedgersByLedgerIdClear200Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdClear200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdClear200Response build() => _build();

  _$PostLedgersByLedgerIdClear200Response _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdClear200Response._(
          deletedCount: BuiltValueNullFieldError.checkNotNull(deletedCount,
              r'PostLedgersByLedgerIdClear200Response', 'deletedCount'),
          syncId: BuiltValueNullFieldError.checkNotNull(
              syncId, r'PostLedgersByLedgerIdClear200Response', 'syncId'),
          replayed: BuiltValueNullFieldError.checkNotNull(
              replayed, r'PostLedgersByLedgerIdClear200Response', 'replayed'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
