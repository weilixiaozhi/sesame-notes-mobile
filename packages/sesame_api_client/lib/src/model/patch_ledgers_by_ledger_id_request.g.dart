// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_ledgers_by_ledger_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchLedgersByLedgerIdRequest extends PatchLedgersByLedgerIdRequest {
  @override
  final String? name;
  @override
  final String? currency;
  @override
  final int? monthStartDay;
  @override
  final bool? aaEnabled;

  factory _$PatchLedgersByLedgerIdRequest(
          [void Function(PatchLedgersByLedgerIdRequestBuilder)? updates]) =>
      (PatchLedgersByLedgerIdRequestBuilder()..update(updates))._build();

  _$PatchLedgersByLedgerIdRequest._(
      {this.name, this.currency, this.monthStartDay, this.aaEnabled})
      : super._();
  @override
  PatchLedgersByLedgerIdRequest rebuild(
          void Function(PatchLedgersByLedgerIdRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchLedgersByLedgerIdRequestBuilder toBuilder() =>
      PatchLedgersByLedgerIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchLedgersByLedgerIdRequest &&
        name == other.name &&
        currency == other.currency &&
        monthStartDay == other.monthStartDay &&
        aaEnabled == other.aaEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, monthStartDay.hashCode);
    _$hash = $jc(_$hash, aaEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PatchLedgersByLedgerIdRequest')
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled))
        .toString();
  }
}

class PatchLedgersByLedgerIdRequestBuilder
    implements
        Builder<PatchLedgersByLedgerIdRequest,
            PatchLedgersByLedgerIdRequestBuilder> {
  _$PatchLedgersByLedgerIdRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _monthStartDay;
  int? get monthStartDay => _$this._monthStartDay;
  set monthStartDay(int? monthStartDay) =>
      _$this._monthStartDay = monthStartDay;

  bool? _aaEnabled;
  bool? get aaEnabled => _$this._aaEnabled;
  set aaEnabled(bool? aaEnabled) => _$this._aaEnabled = aaEnabled;

  PatchLedgersByLedgerIdRequestBuilder() {
    PatchLedgersByLedgerIdRequest._defaults(this);
  }

  PatchLedgersByLedgerIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _currency = $v.currency;
      _monthStartDay = $v.monthStartDay;
      _aaEnabled = $v.aaEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchLedgersByLedgerIdRequest other) {
    _$v = other as _$PatchLedgersByLedgerIdRequest;
  }

  @override
  void update(void Function(PatchLedgersByLedgerIdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchLedgersByLedgerIdRequest build() => _build();

  _$PatchLedgersByLedgerIdRequest _build() {
    final _$result = _$v ??
        _$PatchLedgersByLedgerIdRequest._(
          name: name,
          currency: currency,
          monthStartDay: monthStartDay,
          aaEnabled: aaEnabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
