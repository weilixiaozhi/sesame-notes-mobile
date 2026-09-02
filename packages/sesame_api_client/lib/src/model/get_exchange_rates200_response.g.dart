// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_exchange_rates200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetExchangeRates200Response extends GetExchangeRates200Response {
  @override
  final String baseCurrency;
  @override
  final Date? rateDate;
  @override
  final String source_;
  @override
  final DateTime fetchedAt;
  @override
  final BuiltMap<String, String> rates;

  factory _$GetExchangeRates200Response(
          [void Function(GetExchangeRates200ResponseBuilder)? updates]) =>
      (GetExchangeRates200ResponseBuilder()..update(updates))._build();

  _$GetExchangeRates200Response._(
      {required this.baseCurrency,
      this.rateDate,
      required this.source_,
      required this.fetchedAt,
      required this.rates})
      : super._();
  @override
  GetExchangeRates200Response rebuild(
          void Function(GetExchangeRates200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetExchangeRates200ResponseBuilder toBuilder() =>
      GetExchangeRates200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetExchangeRates200Response &&
        baseCurrency == other.baseCurrency &&
        rateDate == other.rateDate &&
        source_ == other.source_ &&
        fetchedAt == other.fetchedAt &&
        rates == other.rates;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, baseCurrency.hashCode);
    _$hash = $jc(_$hash, rateDate.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jc(_$hash, fetchedAt.hashCode);
    _$hash = $jc(_$hash, rates.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetExchangeRates200Response')
          ..add('baseCurrency', baseCurrency)
          ..add('rateDate', rateDate)
          ..add('source_', source_)
          ..add('fetchedAt', fetchedAt)
          ..add('rates', rates))
        .toString();
  }
}

class GetExchangeRates200ResponseBuilder
    implements
        Builder<GetExchangeRates200Response,
            GetExchangeRates200ResponseBuilder> {
  _$GetExchangeRates200Response? _$v;

  String? _baseCurrency;
  String? get baseCurrency => _$this._baseCurrency;
  set baseCurrency(String? baseCurrency) => _$this._baseCurrency = baseCurrency;

  Date? _rateDate;
  Date? get rateDate => _$this._rateDate;
  set rateDate(Date? rateDate) => _$this._rateDate = rateDate;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  DateTime? _fetchedAt;
  DateTime? get fetchedAt => _$this._fetchedAt;
  set fetchedAt(DateTime? fetchedAt) => _$this._fetchedAt = fetchedAt;

  MapBuilder<String, String>? _rates;
  MapBuilder<String, String> get rates =>
      _$this._rates ??= MapBuilder<String, String>();
  set rates(MapBuilder<String, String>? rates) => _$this._rates = rates;

  GetExchangeRates200ResponseBuilder() {
    GetExchangeRates200Response._defaults(this);
  }

  GetExchangeRates200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _baseCurrency = $v.baseCurrency;
      _rateDate = $v.rateDate;
      _source_ = $v.source_;
      _fetchedAt = $v.fetchedAt;
      _rates = $v.rates.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetExchangeRates200Response other) {
    _$v = other as _$GetExchangeRates200Response;
  }

  @override
  void update(void Function(GetExchangeRates200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetExchangeRates200Response build() => _build();

  _$GetExchangeRates200Response _build() {
    _$GetExchangeRates200Response _$result;
    try {
      _$result = _$v ??
          _$GetExchangeRates200Response._(
            baseCurrency: BuiltValueNullFieldError.checkNotNull(
                baseCurrency, r'GetExchangeRates200Response', 'baseCurrency'),
            rateDate: rateDate,
            source_: BuiltValueNullFieldError.checkNotNull(
                source_, r'GetExchangeRates200Response', 'source_'),
            fetchedAt: BuiltValueNullFieldError.checkNotNull(
                fetchedAt, r'GetExchangeRates200Response', 'fetchedAt'),
            rates: rates.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rates';
        rates.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetExchangeRates200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
