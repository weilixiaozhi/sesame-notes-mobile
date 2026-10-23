// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_transaction_stats200_response_by_currency_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner
    extends GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner {
  @override
  final String currencyCode;
  @override
  final String amountTotal;
  @override
  final String nativeTotal;
  @override
  final int transactionCount;

  factory _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner(
          [void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner._(
      {required this.currencyCode,
      required this.amountTotal,
      required this.nativeTotal,
      required this.transactionCount})
      : super._();
  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner rebuild(
          void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder
      toBuilder() =>
          GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner &&
        currencyCode == other.currencyCode &&
        amountTotal == other.amountTotal &&
        nativeTotal == other.nativeTotal &&
        transactionCount == other.transactionCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currencyCode.hashCode);
    _$hash = $jc(_$hash, amountTotal.hashCode);
    _$hash = $jc(_$hash, nativeTotal.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner')
          ..add('currencyCode', currencyCode)
          ..add('amountTotal', amountTotal)
          ..add('nativeTotal', nativeTotal)
          ..add('transactionCount', transactionCount))
        .toString();
  }
}

class GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner,
            GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder> {
  _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner? _$v;

  String? _currencyCode;
  String? get currencyCode => _$this._currencyCode;
  set currencyCode(String? currencyCode) => _$this._currencyCode = currencyCode;

  String? _amountTotal;
  String? get amountTotal => _$this._amountTotal;
  set amountTotal(String? amountTotal) => _$this._amountTotal = amountTotal;

  String? _nativeTotal;
  String? get nativeTotal => _$this._nativeTotal;
  set nativeTotal(String? nativeTotal) => _$this._nativeTotal = nativeTotal;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder() {
    GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner._defaults(
        this);
  }

  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _currencyCode = $v.currencyCode;
      _amountTotal = $v.amountTotal;
      _nativeTotal = $v.nativeTotal;
      _transactionCount = $v.transactionCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner other) {
    _$v = other
        as _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner build() =>
      _build();

  _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner._(
          currencyCode: BuiltValueNullFieldError.checkNotNull(
              currencyCode,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner',
              'currencyCode'),
          amountTotal: BuiltValueNullFieldError.checkNotNull(
              amountTotal,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner',
              'amountTotal'),
          nativeTotal: BuiltValueNullFieldError.checkNotNull(
              nativeTotal,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner',
              'nativeTotal'),
          transactionCount: BuiltValueNullFieldError.checkNotNull(
              transactionCount,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner',
              'transactionCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
