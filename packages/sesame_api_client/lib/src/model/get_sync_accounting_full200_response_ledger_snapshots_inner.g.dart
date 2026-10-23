// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_accounting_full200_response_ledger_snapshots_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner
    extends GetSyncAccountingFull200ResponseLedgerSnapshotsInner {
  @override
  final GetSyncFull200ResponseLedger ledger;
  @override
  final BuiltList<Member> members;
  @override
  final BuiltList<Transaction> transactions;
  @override
  final BuiltList<Category> categories;
  @override
  final BuiltList<Category> categoryTombstones;
  @override
  final BuiltList<RecurringTransaction> recurringTransactions;
  @override
  final BuiltList<ExchangeRateOverride> exchangeRateOverrides;
  @override
  final GetSyncFull200ResponseRecurringState? recurringState;

  factory _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner(
          [void Function(
                  GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder)?
              updates]) =>
      (GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner._(
      {required this.ledger,
      required this.members,
      required this.transactions,
      required this.categories,
      required this.categoryTombstones,
      required this.recurringTransactions,
      required this.exchangeRateOverrides,
      this.recurringState})
      : super._();
  @override
  GetSyncAccountingFull200ResponseLedgerSnapshotsInner rebuild(
          void Function(
                  GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder toBuilder() =>
      GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncAccountingFull200ResponseLedgerSnapshotsInner &&
        ledger == other.ledger &&
        members == other.members &&
        transactions == other.transactions &&
        categories == other.categories &&
        categoryTombstones == other.categoryTombstones &&
        recurringTransactions == other.recurringTransactions &&
        exchangeRateOverrides == other.exchangeRateOverrides &&
        recurringState == other.recurringState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledger.hashCode);
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, transactions.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, categoryTombstones.hashCode);
    _$hash = $jc(_$hash, recurringTransactions.hashCode);
    _$hash = $jc(_$hash, exchangeRateOverrides.hashCode);
    _$hash = $jc(_$hash, recurringState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetSyncAccountingFull200ResponseLedgerSnapshotsInner')
          ..add('ledger', ledger)
          ..add('members', members)
          ..add('transactions', transactions)
          ..add('categories', categories)
          ..add('categoryTombstones', categoryTombstones)
          ..add('recurringTransactions', recurringTransactions)
          ..add('exchangeRateOverrides', exchangeRateOverrides)
          ..add('recurringState', recurringState))
        .toString();
  }
}

class GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder
    implements
        Builder<GetSyncAccountingFull200ResponseLedgerSnapshotsInner,
            GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder> {
  _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner? _$v;

  GetSyncFull200ResponseLedgerBuilder? _ledger;
  GetSyncFull200ResponseLedgerBuilder get ledger =>
      _$this._ledger ??= GetSyncFull200ResponseLedgerBuilder();
  set ledger(GetSyncFull200ResponseLedgerBuilder? ledger) =>
      _$this._ledger = ledger;

  ListBuilder<Member>? _members;
  ListBuilder<Member> get members => _$this._members ??= ListBuilder<Member>();
  set members(ListBuilder<Member>? members) => _$this._members = members;

  ListBuilder<Transaction>? _transactions;
  ListBuilder<Transaction> get transactions =>
      _$this._transactions ??= ListBuilder<Transaction>();
  set transactions(ListBuilder<Transaction>? transactions) =>
      _$this._transactions = transactions;

  ListBuilder<Category>? _categories;
  ListBuilder<Category> get categories =>
      _$this._categories ??= ListBuilder<Category>();
  set categories(ListBuilder<Category>? categories) =>
      _$this._categories = categories;

  ListBuilder<Category>? _categoryTombstones;
  ListBuilder<Category> get categoryTombstones =>
      _$this._categoryTombstones ??= ListBuilder<Category>();
  set categoryTombstones(ListBuilder<Category>? categoryTombstones) =>
      _$this._categoryTombstones = categoryTombstones;

  ListBuilder<RecurringTransaction>? _recurringTransactions;
  ListBuilder<RecurringTransaction> get recurringTransactions =>
      _$this._recurringTransactions ??= ListBuilder<RecurringTransaction>();
  set recurringTransactions(
          ListBuilder<RecurringTransaction>? recurringTransactions) =>
      _$this._recurringTransactions = recurringTransactions;

  ListBuilder<ExchangeRateOverride>? _exchangeRateOverrides;
  ListBuilder<ExchangeRateOverride> get exchangeRateOverrides =>
      _$this._exchangeRateOverrides ??= ListBuilder<ExchangeRateOverride>();
  set exchangeRateOverrides(
          ListBuilder<ExchangeRateOverride>? exchangeRateOverrides) =>
      _$this._exchangeRateOverrides = exchangeRateOverrides;

  GetSyncFull200ResponseRecurringStateBuilder? _recurringState;
  GetSyncFull200ResponseRecurringStateBuilder get recurringState =>
      _$this._recurringState ??= GetSyncFull200ResponseRecurringStateBuilder();
  set recurringState(
          GetSyncFull200ResponseRecurringStateBuilder? recurringState) =>
      _$this._recurringState = recurringState;

  GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder() {
    GetSyncAccountingFull200ResponseLedgerSnapshotsInner._defaults(this);
  }

  GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledger = $v.ledger.toBuilder();
      _members = $v.members.toBuilder();
      _transactions = $v.transactions.toBuilder();
      _categories = $v.categories.toBuilder();
      _categoryTombstones = $v.categoryTombstones.toBuilder();
      _recurringTransactions = $v.recurringTransactions.toBuilder();
      _exchangeRateOverrides = $v.exchangeRateOverrides.toBuilder();
      _recurringState = $v.recurringState?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncAccountingFull200ResponseLedgerSnapshotsInner other) {
    _$v = other as _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner;
  }

  @override
  void update(
      void Function(
              GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncAccountingFull200ResponseLedgerSnapshotsInner build() => _build();

  _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner _build() {
    _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner _$result;
    try {
      _$result = _$v ??
          _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner._(
            ledger: ledger.build(),
            members: members.build(),
            transactions: transactions.build(),
            categories: categories.build(),
            categoryTombstones: categoryTombstones.build(),
            recurringTransactions: recurringTransactions.build(),
            exchangeRateOverrides: exchangeRateOverrides.build(),
            recurringState: _recurringState?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ledger';
        ledger.build();
        _$failedField = 'members';
        members.build();
        _$failedField = 'transactions';
        transactions.build();
        _$failedField = 'categories';
        categories.build();
        _$failedField = 'categoryTombstones';
        categoryTombstones.build();
        _$failedField = 'recurringTransactions';
        recurringTransactions.build();
        _$failedField = 'exchangeRateOverrides';
        exchangeRateOverrides.build();
        _$failedField = 'recurringState';
        _recurringState?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncAccountingFull200ResponseLedgerSnapshotsInner',
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
