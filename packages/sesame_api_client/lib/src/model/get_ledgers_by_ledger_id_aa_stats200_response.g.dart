// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_aa_stats200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdAaStats200Response
    extends GetLedgersByLedgerIdAaStats200Response {
  @override
  final String ledgerCurrency;
  @override
  final bool aaEnabled;
  @override
  final int transactionCount;
  @override
  final int excludedCount;
  @override
  final int skippedCount;
  @override
  final BuiltList<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>
      participants;
  @override
  final BuiltList<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>
      transfers;

  factory _$GetLedgersByLedgerIdAaStats200Response(
          [void Function(GetLedgersByLedgerIdAaStats200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdAaStats200ResponseBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdAaStats200Response._(
      {required this.ledgerCurrency,
      required this.aaEnabled,
      required this.transactionCount,
      required this.excludedCount,
      required this.skippedCount,
      required this.participants,
      required this.transfers})
      : super._();
  @override
  GetLedgersByLedgerIdAaStats200Response rebuild(
          void Function(GetLedgersByLedgerIdAaStats200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdAaStats200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdAaStats200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdAaStats200Response &&
        ledgerCurrency == other.ledgerCurrency &&
        aaEnabled == other.aaEnabled &&
        transactionCount == other.transactionCount &&
        excludedCount == other.excludedCount &&
        skippedCount == other.skippedCount &&
        participants == other.participants &&
        transfers == other.transfers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledgerCurrency.hashCode);
    _$hash = $jc(_$hash, aaEnabled.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jc(_$hash, excludedCount.hashCode);
    _$hash = $jc(_$hash, skippedCount.hashCode);
    _$hash = $jc(_$hash, participants.hashCode);
    _$hash = $jc(_$hash, transfers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdAaStats200Response')
          ..add('ledgerCurrency', ledgerCurrency)
          ..add('aaEnabled', aaEnabled)
          ..add('transactionCount', transactionCount)
          ..add('excludedCount', excludedCount)
          ..add('skippedCount', skippedCount)
          ..add('participants', participants)
          ..add('transfers', transfers))
        .toString();
  }
}

class GetLedgersByLedgerIdAaStats200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdAaStats200Response,
            GetLedgersByLedgerIdAaStats200ResponseBuilder> {
  _$GetLedgersByLedgerIdAaStats200Response? _$v;

  String? _ledgerCurrency;
  String? get ledgerCurrency => _$this._ledgerCurrency;
  set ledgerCurrency(String? ledgerCurrency) =>
      _$this._ledgerCurrency = ledgerCurrency;

  bool? _aaEnabled;
  bool? get aaEnabled => _$this._aaEnabled;
  set aaEnabled(bool? aaEnabled) => _$this._aaEnabled = aaEnabled;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  int? _excludedCount;
  int? get excludedCount => _$this._excludedCount;
  set excludedCount(int? excludedCount) =>
      _$this._excludedCount = excludedCount;

  int? _skippedCount;
  int? get skippedCount => _$this._skippedCount;
  set skippedCount(int? skippedCount) => _$this._skippedCount = skippedCount;

  ListBuilder<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>?
      _participants;
  ListBuilder<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>
      get participants => _$this._participants ??= ListBuilder<
          GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>();
  set participants(
          ListBuilder<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>?
              participants) =>
      _$this._participants = participants;

  ListBuilder<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>? _transfers;
  ListBuilder<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>
      get transfers => _$this._transfers ??=
          ListBuilder<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>();
  set transfers(
          ListBuilder<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>?
              transfers) =>
      _$this._transfers = transfers;

  GetLedgersByLedgerIdAaStats200ResponseBuilder() {
    GetLedgersByLedgerIdAaStats200Response._defaults(this);
  }

  GetLedgersByLedgerIdAaStats200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledgerCurrency = $v.ledgerCurrency;
      _aaEnabled = $v.aaEnabled;
      _transactionCount = $v.transactionCount;
      _excludedCount = $v.excludedCount;
      _skippedCount = $v.skippedCount;
      _participants = $v.participants.toBuilder();
      _transfers = $v.transfers.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdAaStats200Response other) {
    _$v = other as _$GetLedgersByLedgerIdAaStats200Response;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdAaStats200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdAaStats200Response build() => _build();

  _$GetLedgersByLedgerIdAaStats200Response _build() {
    _$GetLedgersByLedgerIdAaStats200Response _$result;
    try {
      _$result = _$v ??
          _$GetLedgersByLedgerIdAaStats200Response._(
            ledgerCurrency: BuiltValueNullFieldError.checkNotNull(
                ledgerCurrency,
                r'GetLedgersByLedgerIdAaStats200Response',
                'ledgerCurrency'),
            aaEnabled: BuiltValueNullFieldError.checkNotNull(aaEnabled,
                r'GetLedgersByLedgerIdAaStats200Response', 'aaEnabled'),
            transactionCount: BuiltValueNullFieldError.checkNotNull(
                transactionCount,
                r'GetLedgersByLedgerIdAaStats200Response',
                'transactionCount'),
            excludedCount: BuiltValueNullFieldError.checkNotNull(excludedCount,
                r'GetLedgersByLedgerIdAaStats200Response', 'excludedCount'),
            skippedCount: BuiltValueNullFieldError.checkNotNull(skippedCount,
                r'GetLedgersByLedgerIdAaStats200Response', 'skippedCount'),
            participants: participants.build(),
            transfers: transfers.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'participants';
        participants.build();
        _$failedField = 'transfers';
        transfers.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetLedgersByLedgerIdAaStats200Response',
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
