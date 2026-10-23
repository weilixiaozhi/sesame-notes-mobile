// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_change_currency_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdChangeCurrencyRequest
    extends PostLedgersByLedgerIdChangeCurrencyRequest {
  @override
  final String currency;
  @override
  final String expectedCurrency;
  @override
  final BuiltMap<String, String> rates;

  factory _$PostLedgersByLedgerIdChangeCurrencyRequest(
          [void Function(PostLedgersByLedgerIdChangeCurrencyRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdChangeCurrencyRequestBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdChangeCurrencyRequest._(
      {required this.currency,
      required this.expectedCurrency,
      required this.rates})
      : super._();
  @override
  PostLedgersByLedgerIdChangeCurrencyRequest rebuild(
          void Function(PostLedgersByLedgerIdChangeCurrencyRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdChangeCurrencyRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdChangeCurrencyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdChangeCurrencyRequest &&
        currency == other.currency &&
        expectedCurrency == other.expectedCurrency &&
        rates == other.rates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, expectedCurrency.hashCode);
    _$hash = $jc(_$hash, rates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdChangeCurrencyRequest')
          ..add('currency', currency)
          ..add('expectedCurrency', expectedCurrency)
          ..add('rates', rates))
        .toString();
  }
}

class PostLedgersByLedgerIdChangeCurrencyRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdChangeCurrencyRequest,
            PostLedgersByLedgerIdChangeCurrencyRequestBuilder> {
  _$PostLedgersByLedgerIdChangeCurrencyRequest? _$v;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _expectedCurrency;
  String? get expectedCurrency => _$this._expectedCurrency;
  set expectedCurrency(String? expectedCurrency) =>
      _$this._expectedCurrency = expectedCurrency;

  MapBuilder<String, String>? _rates;
  MapBuilder<String, String> get rates =>
      _$this._rates ??= MapBuilder<String, String>();
  set rates(MapBuilder<String, String>? rates) => _$this._rates = rates;

  PostLedgersByLedgerIdChangeCurrencyRequestBuilder() {
    PostLedgersByLedgerIdChangeCurrencyRequest._defaults(this);
  }

  PostLedgersByLedgerIdChangeCurrencyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _currency = $v.currency;
      _expectedCurrency = $v.expectedCurrency;
      _rates = $v.rates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdChangeCurrencyRequest other) {
    _$v = other as _$PostLedgersByLedgerIdChangeCurrencyRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdChangeCurrencyRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdChangeCurrencyRequest build() => _build();

  _$PostLedgersByLedgerIdChangeCurrencyRequest _build() {
    _$PostLedgersByLedgerIdChangeCurrencyRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdChangeCurrencyRequest._(
            currency: BuiltValueNullFieldError.checkNotNull(currency,
                r'PostLedgersByLedgerIdChangeCurrencyRequest', 'currency'),
            expectedCurrency: BuiltValueNullFieldError.checkNotNull(
                expectedCurrency,
                r'PostLedgersByLedgerIdChangeCurrencyRequest',
                'expectedCurrency'),
            rates: rates.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rates';
        rates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdChangeCurrencyRequest',
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
