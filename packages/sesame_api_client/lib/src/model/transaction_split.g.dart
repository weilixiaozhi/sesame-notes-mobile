// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_split.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TransactionSplit extends TransactionSplit {
  @override
  final String? memberId;
  @override
  final String amount;

  factory _$TransactionSplit(
          [void Function(TransactionSplitBuilder)? updates]) =>
      (TransactionSplitBuilder()..update(updates))._build();

  _$TransactionSplit._({this.memberId, required this.amount}) : super._();
  @override
  TransactionSplit rebuild(void Function(TransactionSplitBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionSplitBuilder toBuilder() =>
      TransactionSplitBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TransactionSplit &&
        memberId == other.memberId &&
        amount == other.amount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, memberId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TransactionSplit')
          ..add('memberId', memberId)
          ..add('amount', amount))
        .toString();
  }
}

class TransactionSplitBuilder
    implements Builder<TransactionSplit, TransactionSplitBuilder> {
  _$TransactionSplit? _$v;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  TransactionSplitBuilder() {
    TransactionSplit._defaults(this);
  }

  TransactionSplitBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _memberId = $v.memberId;
      _amount = $v.amount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TransactionSplit other) {
    _$v = other as _$TransactionSplit;
  }

  @override
  void update(void Function(TransactionSplitBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TransactionSplit build() => _build();

  _$TransactionSplit _build() {
    final _$result = _$v ??
        _$TransactionSplit._(
          memberId: memberId,
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'TransactionSplit', 'amount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
