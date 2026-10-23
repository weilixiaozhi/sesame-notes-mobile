// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_action_preview200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdActionPreview200Response
    extends GetLedgersByLedgerIdActionPreview200Response {
  @override
  final String name;
  @override
  final String currency;
  @override
  final String syncId;
  @override
  final String fingerprint;
  @override
  final int transactionCount;
  @override
  final int recurringCount;
  @override
  final int memberCount;

  factory _$GetLedgersByLedgerIdActionPreview200Response(
          [void Function(GetLedgersByLedgerIdActionPreview200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdActionPreview200ResponseBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdActionPreview200Response._(
      {required this.name,
      required this.currency,
      required this.syncId,
      required this.fingerprint,
      required this.transactionCount,
      required this.recurringCount,
      required this.memberCount})
      : super._();
  @override
  GetLedgersByLedgerIdActionPreview200Response rebuild(
          void Function(GetLedgersByLedgerIdActionPreview200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdActionPreview200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdActionPreview200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdActionPreview200Response &&
        name == other.name &&
        currency == other.currency &&
        syncId == other.syncId &&
        fingerprint == other.fingerprint &&
        transactionCount == other.transactionCount &&
        recurringCount == other.recurringCount &&
        memberCount == other.memberCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, fingerprint.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jc(_$hash, recurringCount.hashCode);
    _$hash = $jc(_$hash, memberCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdActionPreview200Response')
          ..add('name', name)
          ..add('currency', currency)
          ..add('syncId', syncId)
          ..add('fingerprint', fingerprint)
          ..add('transactionCount', transactionCount)
          ..add('recurringCount', recurringCount)
          ..add('memberCount', memberCount))
        .toString();
  }
}

class GetLedgersByLedgerIdActionPreview200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdActionPreview200Response,
            GetLedgersByLedgerIdActionPreview200ResponseBuilder> {
  _$GetLedgersByLedgerIdActionPreview200Response? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  String? _fingerprint;
  String? get fingerprint => _$this._fingerprint;
  set fingerprint(String? fingerprint) => _$this._fingerprint = fingerprint;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  int? _recurringCount;
  int? get recurringCount => _$this._recurringCount;
  set recurringCount(int? recurringCount) =>
      _$this._recurringCount = recurringCount;

  int? _memberCount;
  int? get memberCount => _$this._memberCount;
  set memberCount(int? memberCount) => _$this._memberCount = memberCount;

  GetLedgersByLedgerIdActionPreview200ResponseBuilder() {
    GetLedgersByLedgerIdActionPreview200Response._defaults(this);
  }

  GetLedgersByLedgerIdActionPreview200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _currency = $v.currency;
      _syncId = $v.syncId;
      _fingerprint = $v.fingerprint;
      _transactionCount = $v.transactionCount;
      _recurringCount = $v.recurringCount;
      _memberCount = $v.memberCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdActionPreview200Response other) {
    _$v = other as _$GetLedgersByLedgerIdActionPreview200Response;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdActionPreview200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdActionPreview200Response build() => _build();

  _$GetLedgersByLedgerIdActionPreview200Response _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdActionPreview200Response._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetLedgersByLedgerIdActionPreview200Response', 'name'),
          currency: BuiltValueNullFieldError.checkNotNull(currency,
              r'GetLedgersByLedgerIdActionPreview200Response', 'currency'),
          syncId: BuiltValueNullFieldError.checkNotNull(syncId,
              r'GetLedgersByLedgerIdActionPreview200Response', 'syncId'),
          fingerprint: BuiltValueNullFieldError.checkNotNull(fingerprint,
              r'GetLedgersByLedgerIdActionPreview200Response', 'fingerprint'),
          transactionCount: BuiltValueNullFieldError.checkNotNull(
              transactionCount,
              r'GetLedgersByLedgerIdActionPreview200Response',
              'transactionCount'),
          recurringCount: BuiltValueNullFieldError.checkNotNull(
              recurringCount,
              r'GetLedgersByLedgerIdActionPreview200Response',
              'recurringCount'),
          memberCount: BuiltValueNullFieldError.checkNotNull(memberCount,
              r'GetLedgersByLedgerIdActionPreview200Response', 'memberCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
