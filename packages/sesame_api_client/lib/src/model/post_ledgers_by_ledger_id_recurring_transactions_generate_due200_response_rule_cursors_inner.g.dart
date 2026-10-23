// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_recurring_transactions_generate_due200_response_rule_cursors_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
    extends PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner {
  @override
  final String id;
  @override
  final DateTime? lastGeneratedDate;

  factory _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner(
          [void Function(
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner._(
      {required this.id, this.lastGeneratedDate})
      : super._();
  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
      rebuild(
              void Function(
                      PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder
      toBuilder() =>
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner &&
        id == other.id &&
        lastGeneratedDate == other.lastGeneratedDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, lastGeneratedDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner')
          ..add('id', id)
          ..add('lastGeneratedDate', lastGeneratedDate))
        .toString();
  }
}

class PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder
    implements
        Builder<
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner,
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder> {
  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _lastGeneratedDate;
  DateTime? get lastGeneratedDate => _$this._lastGeneratedDate;
  set lastGeneratedDate(DateTime? lastGeneratedDate) =>
      _$this._lastGeneratedDate = lastGeneratedDate;

  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder() {
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
        ._defaults(this);
  }

  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _lastGeneratedDate = $v.lastGeneratedDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
          other) {
    _$v = other
        as _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
      build() => _build();

  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
      _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
            ._(
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner',
              'id'),
          lastGeneratedDate: lastGeneratedDate,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
