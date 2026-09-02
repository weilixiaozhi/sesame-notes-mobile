// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_transactions_request_splits_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdTransactionsRequestSplitsInner
    extends PostLedgersByLedgerIdTransactionsRequestSplitsInner {
  @override
  final String? memberId;
  @override
  final String amount;

  factory _$PostLedgersByLedgerIdTransactionsRequestSplitsInner(
          [void Function(
                  PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdTransactionsRequestSplitsInner._(
      {this.memberId, required this.amount})
      : super._();
  @override
  PostLedgersByLedgerIdTransactionsRequestSplitsInner rebuild(
          void Function(
                  PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder toBuilder() =>
      PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdTransactionsRequestSplitsInner &&
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
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdTransactionsRequestSplitsInner')
          ..add('memberId', memberId)
          ..add('amount', amount))
        .toString();
  }
}

class PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder
    implements
        Builder<PostLedgersByLedgerIdTransactionsRequestSplitsInner,
            PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder> {
  _$PostLedgersByLedgerIdTransactionsRequestSplitsInner? _$v;

  String? _memberId;
  String? get memberId => _$this._memberId;
  set memberId(String? memberId) => _$this._memberId = memberId;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder() {
    PostLedgersByLedgerIdTransactionsRequestSplitsInner._defaults(this);
  }

  PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _memberId = $v.memberId;
      _amount = $v.amount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdTransactionsRequestSplitsInner other) {
    _$v = other as _$PostLedgersByLedgerIdTransactionsRequestSplitsInner;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdTransactionsRequestSplitsInner build() => _build();

  _$PostLedgersByLedgerIdTransactionsRequestSplitsInner _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdTransactionsRequestSplitsInner._(
          memberId: memberId,
          amount: BuiltValueNullFieldError.checkNotNull(amount,
              r'PostLedgersByLedgerIdTransactionsRequestSplitsInner', 'amount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
