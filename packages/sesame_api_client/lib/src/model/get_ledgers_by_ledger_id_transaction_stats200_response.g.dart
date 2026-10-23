// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_transaction_stats200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdTransactionStats200Response
    extends GetLedgersByLedgerIdTransactionStats200Response {
  @override
  final String ledgerCurrency;
  @override
  final String expenseTotal;
  @override
  final int transactionCount;
  @override
  final BuiltList<
          GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>
      byCurrency;
  @override
  final BuiltList<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>
      byDay;
  @override
  final BuiltList<
          GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>
      byCategory;

  factory _$GetLedgersByLedgerIdTransactionStats200Response(
          [void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdTransactionStats200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdTransactionStats200Response._(
      {required this.ledgerCurrency,
      required this.expenseTotal,
      required this.transactionCount,
      required this.byCurrency,
      required this.byDay,
      required this.byCategory})
      : super._();
  @override
  GetLedgersByLedgerIdTransactionStats200Response rebuild(
          void Function(GetLedgersByLedgerIdTransactionStats200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdTransactionStats200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdTransactionStats200Response &&
        ledgerCurrency == other.ledgerCurrency &&
        expenseTotal == other.expenseTotal &&
        transactionCount == other.transactionCount &&
        byCurrency == other.byCurrency &&
        byDay == other.byDay &&
        byCategory == other.byCategory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledgerCurrency.hashCode);
    _$hash = $jc(_$hash, expenseTotal.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jc(_$hash, byCurrency.hashCode);
    _$hash = $jc(_$hash, byDay.hashCode);
    _$hash = $jc(_$hash, byCategory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdTransactionStats200Response')
          ..add('ledgerCurrency', ledgerCurrency)
          ..add('expenseTotal', expenseTotal)
          ..add('transactionCount', transactionCount)
          ..add('byCurrency', byCurrency)
          ..add('byDay', byDay)
          ..add('byCategory', byCategory))
        .toString();
  }
}

class GetLedgersByLedgerIdTransactionStats200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdTransactionStats200Response,
            GetLedgersByLedgerIdTransactionStats200ResponseBuilder> {
  _$GetLedgersByLedgerIdTransactionStats200Response? _$v;

  String? _ledgerCurrency;
  String? get ledgerCurrency => _$this._ledgerCurrency;
  set ledgerCurrency(String? ledgerCurrency) =>
      _$this._ledgerCurrency = ledgerCurrency;

  String? _expenseTotal;
  String? get expenseTotal => _$this._expenseTotal;
  set expenseTotal(String? expenseTotal) => _$this._expenseTotal = expenseTotal;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  ListBuilder<GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>?
      _byCurrency;
  ListBuilder<GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>
      get byCurrency => _$this._byCurrency ??= ListBuilder<
          GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>();
  set byCurrency(
          ListBuilder<
                  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>?
              byCurrency) =>
      _$this._byCurrency = byCurrency;

  ListBuilder<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>?
      _byDay;
  ListBuilder<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>
      get byDay => _$this._byDay ??= ListBuilder<
          GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>();
  set byDay(
          ListBuilder<
                  GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>?
              byDay) =>
      _$this._byDay = byDay;

  ListBuilder<GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>?
      _byCategory;
  ListBuilder<GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>
      get byCategory => _$this._byCategory ??= ListBuilder<
          GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>();
  set byCategory(
          ListBuilder<
                  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>?
              byCategory) =>
      _$this._byCategory = byCategory;

  GetLedgersByLedgerIdTransactionStats200ResponseBuilder() {
    GetLedgersByLedgerIdTransactionStats200Response._defaults(this);
  }

  GetLedgersByLedgerIdTransactionStats200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledgerCurrency = $v.ledgerCurrency;
      _expenseTotal = $v.expenseTotal;
      _transactionCount = $v.transactionCount;
      _byCurrency = $v.byCurrency.toBuilder();
      _byDay = $v.byDay.toBuilder();
      _byCategory = $v.byCategory.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdTransactionStats200Response other) {
    _$v = other as _$GetLedgersByLedgerIdTransactionStats200Response;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdTransactionStats200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdTransactionStats200Response build() => _build();

  _$GetLedgersByLedgerIdTransactionStats200Response _build() {
    _$GetLedgersByLedgerIdTransactionStats200Response _$result;
    try {
      _$result = _$v ??
          _$GetLedgersByLedgerIdTransactionStats200Response._(
            ledgerCurrency: BuiltValueNullFieldError.checkNotNull(
                ledgerCurrency,
                r'GetLedgersByLedgerIdTransactionStats200Response',
                'ledgerCurrency'),
            expenseTotal: BuiltValueNullFieldError.checkNotNull(
                expenseTotal,
                r'GetLedgersByLedgerIdTransactionStats200Response',
                'expenseTotal'),
            transactionCount: BuiltValueNullFieldError.checkNotNull(
                transactionCount,
                r'GetLedgersByLedgerIdTransactionStats200Response',
                'transactionCount'),
            byCurrency: byCurrency.build(),
            byDay: byDay.build(),
            byCategory: byCategory.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'byCurrency';
        byCurrency.build();
        _$failedField = 'byDay';
        byDay.build();
        _$failedField = 'byCategory';
        byCategory.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetLedgersByLedgerIdTransactionStats200Response',
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
