// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_transaction_stats200_response_by_day_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner
    extends GetLedgersByLedgerIdTransactionStats200ResponseByDayInner {
  @override
  final String date;
  @override
  final String nativeTotal;
  @override
  final int transactionCount;

  factory _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner(
          [void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner._(
      {required this.date,
      required this.nativeTotal,
      required this.transactionCount})
      : super._();
  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByDayInner rebuild(
          void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder
      toBuilder() =>
          GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdTransactionStats200ResponseByDayInner &&
        date == other.date &&
        nativeTotal == other.nativeTotal &&
        transactionCount == other.transactionCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, nativeTotal.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdTransactionStats200ResponseByDayInner')
          ..add('date', date)
          ..add('nativeTotal', nativeTotal)
          ..add('transactionCount', transactionCount))
        .toString();
  }
}

class GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner,
            GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder> {
  _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  String? _nativeTotal;
  String? get nativeTotal => _$this._nativeTotal;
  set nativeTotal(String? nativeTotal) => _$this._nativeTotal = nativeTotal;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder() {
    GetLedgersByLedgerIdTransactionStats200ResponseByDayInner._defaults(this);
  }

  GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _nativeTotal = $v.nativeTotal;
      _transactionCount = $v.transactionCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetLedgersByLedgerIdTransactionStats200ResponseByDayInner other) {
    _$v = other as _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByDayInner build() => _build();

  _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner._(
          date: BuiltValueNullFieldError.checkNotNull(
              date,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByDayInner',
              'date'),
          nativeTotal: BuiltValueNullFieldError.checkNotNull(
              nativeTotal,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByDayInner',
              'nativeTotal'),
          transactionCount: BuiltValueNullFieldError.checkNotNull(
              transactionCount,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByDayInner',
              'transactionCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
