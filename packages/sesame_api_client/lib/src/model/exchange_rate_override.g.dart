// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rate_override.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExchangeRateOverride extends ExchangeRateOverride {
  @override
  final String id;
  @override
  final String baseCurrency;
  @override
  final String quoteCurrency;
  @override
  final String rate;
  @override
  final DateTime updatedAt;

  factory _$ExchangeRateOverride(
          [void Function(ExchangeRateOverrideBuilder)? updates]) =>
      (ExchangeRateOverrideBuilder()..update(updates))._build();

  _$ExchangeRateOverride._(
      {required this.id,
      required this.baseCurrency,
      required this.quoteCurrency,
      required this.rate,
      required this.updatedAt})
      : super._();
  @override
  ExchangeRateOverride rebuild(
          void Function(ExchangeRateOverrideBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ExchangeRateOverrideBuilder toBuilder() =>
      ExchangeRateOverrideBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExchangeRateOverride &&
        id == other.id &&
        baseCurrency == other.baseCurrency &&
        quoteCurrency == other.quoteCurrency &&
        rate == other.rate &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, baseCurrency.hashCode);
    _$hash = $jc(_$hash, quoteCurrency.hashCode);
    _$hash = $jc(_$hash, rate.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExchangeRateOverride')
          ..add('id', id)
          ..add('baseCurrency', baseCurrency)
          ..add('quoteCurrency', quoteCurrency)
          ..add('rate', rate)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ExchangeRateOverrideBuilder
    implements Builder<ExchangeRateOverride, ExchangeRateOverrideBuilder> {
  _$ExchangeRateOverride? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _baseCurrency;
  String? get baseCurrency => _$this._baseCurrency;
  set baseCurrency(String? baseCurrency) => _$this._baseCurrency = baseCurrency;

  String? _quoteCurrency;
  String? get quoteCurrency => _$this._quoteCurrency;
  set quoteCurrency(String? quoteCurrency) =>
      _$this._quoteCurrency = quoteCurrency;

  String? _rate;
  String? get rate => _$this._rate;
  set rate(String? rate) => _$this._rate = rate;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ExchangeRateOverrideBuilder() {
    ExchangeRateOverride._defaults(this);
  }

  ExchangeRateOverrideBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _baseCurrency = $v.baseCurrency;
      _quoteCurrency = $v.quoteCurrency;
      _rate = $v.rate;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExchangeRateOverride other) {
    _$v = other as _$ExchangeRateOverride;
  }

  @override
  void update(void Function(ExchangeRateOverrideBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExchangeRateOverride build() => _build();

  _$ExchangeRateOverride _build() {
    final _$result = _$v ??
        _$ExchangeRateOverride._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ExchangeRateOverride', 'id'),
          baseCurrency: BuiltValueNullFieldError.checkNotNull(
              baseCurrency, r'ExchangeRateOverride', 'baseCurrency'),
          quoteCurrency: BuiltValueNullFieldError.checkNotNull(
              quoteCurrency, r'ExchangeRateOverride', 'quoteCurrency'),
          rate: BuiltValueNullFieldError.checkNotNull(
              rate, r'ExchangeRateOverride', 'rate'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'ExchangeRateOverride', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
