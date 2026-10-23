// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_aa_stats200_response_transfers_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner
    extends GetLedgersByLedgerIdAaStats200ResponseTransfersInner {
  @override
  final String fromMemberId;
  @override
  final String toMemberId;
  @override
  final String amount;
  @override
  final String exactAmount;

  factory _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner(
          [void Function(
                  GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner._(
      {required this.fromMemberId,
      required this.toMemberId,
      required this.amount,
      required this.exactAmount})
      : super._();
  @override
  GetLedgersByLedgerIdAaStats200ResponseTransfersInner rebuild(
          void Function(
                  GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder toBuilder() =>
      GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdAaStats200ResponseTransfersInner &&
        fromMemberId == other.fromMemberId &&
        toMemberId == other.toMemberId &&
        amount == other.amount &&
        exactAmount == other.exactAmount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fromMemberId.hashCode);
    _$hash = $jc(_$hash, toMemberId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, exactAmount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdAaStats200ResponseTransfersInner')
          ..add('fromMemberId', fromMemberId)
          ..add('toMemberId', toMemberId)
          ..add('amount', amount)
          ..add('exactAmount', exactAmount))
        .toString();
  }
}

class GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdAaStats200ResponseTransfersInner,
            GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder> {
  _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner? _$v;

  String? _fromMemberId;
  String? get fromMemberId => _$this._fromMemberId;
  set fromMemberId(String? fromMemberId) => _$this._fromMemberId = fromMemberId;

  String? _toMemberId;
  String? get toMemberId => _$this._toMemberId;
  set toMemberId(String? toMemberId) => _$this._toMemberId = toMemberId;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _exactAmount;
  String? get exactAmount => _$this._exactAmount;
  set exactAmount(String? exactAmount) => _$this._exactAmount = exactAmount;

  GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder() {
    GetLedgersByLedgerIdAaStats200ResponseTransfersInner._defaults(this);
  }

  GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fromMemberId = $v.fromMemberId;
      _toMemberId = $v.toMemberId;
      _amount = $v.amount;
      _exactAmount = $v.exactAmount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdAaStats200ResponseTransfersInner other) {
    _$v = other as _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdAaStats200ResponseTransfersInner build() => _build();

  _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner._(
          fromMemberId: BuiltValueNullFieldError.checkNotNull(
              fromMemberId,
              r'GetLedgersByLedgerIdAaStats200ResponseTransfersInner',
              'fromMemberId'),
          toMemberId: BuiltValueNullFieldError.checkNotNull(
              toMemberId,
              r'GetLedgersByLedgerIdAaStats200ResponseTransfersInner',
              'toMemberId'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount,
              r'GetLedgersByLedgerIdAaStats200ResponseTransfersInner',
              'amount'),
          exactAmount: BuiltValueNullFieldError.checkNotNull(
              exactAmount,
              r'GetLedgersByLedgerIdAaStats200ResponseTransfersInner',
              'exactAmount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
