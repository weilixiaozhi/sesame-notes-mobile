// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_full200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFull200Response extends GetSyncFull200Response {
  @override
  final GetSyncFull200ResponseLedger ledger;
  @override
  final BuiltList<Member> members;
  @override
  final BuiltList<Transaction> transactions;
  @override
  final BuiltList<Category> categories;
  @override
  final BuiltList<RecurringTransaction> recurringTransactions;
  @override
  final BuiltList<ExchangeRateOverride> exchangeRateOverrides;
  @override
  final String serverCursor;

  factory _$GetSyncFull200Response(
          [void Function(GetSyncFull200ResponseBuilder)? updates]) =>
      (GetSyncFull200ResponseBuilder()..update(updates))._build();

  _$GetSyncFull200Response._(
      {required this.ledger,
      required this.members,
      required this.transactions,
      required this.categories,
      required this.recurringTransactions,
      required this.exchangeRateOverrides,
      required this.serverCursor})
      : super._();
  @override
  GetSyncFull200Response rebuild(
          void Function(GetSyncFull200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFull200ResponseBuilder toBuilder() =>
      GetSyncFull200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFull200Response &&
        ledger == other.ledger &&
        members == other.members &&
        transactions == other.transactions &&
        categories == other.categories &&
        recurringTransactions == other.recurringTransactions &&
        exchangeRateOverrides == other.exchangeRateOverrides &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledger.hashCode);
    _$hash = $jc(_$hash, members.hashCode);
    _$hash = $jc(_$hash, transactions.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, recurringTransactions.hashCode);
    _$hash = $jc(_$hash, exchangeRateOverrides.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncFull200Response')
          ..add('ledger', ledger)
          ..add('members', members)
          ..add('transactions', transactions)
          ..add('categories', categories)
          ..add('recurringTransactions', recurringTransactions)
          ..add('exchangeRateOverrides', exchangeRateOverrides)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncFull200ResponseBuilder
    implements Builder<GetSyncFull200Response, GetSyncFull200ResponseBuilder> {
  _$GetSyncFull200Response? _$v;

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

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncFull200ResponseBuilder() {
    GetSyncFull200Response._defaults(this);
  }

  GetSyncFull200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledger = $v.ledger.toBuilder();
      _members = $v.members.toBuilder();
      _transactions = $v.transactions.toBuilder();
      _categories = $v.categories.toBuilder();
      _recurringTransactions = $v.recurringTransactions.toBuilder();
      _exchangeRateOverrides = $v.exchangeRateOverrides.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFull200Response other) {
    _$v = other as _$GetSyncFull200Response;
  }

  @override
  void update(void Function(GetSyncFull200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFull200Response build() => _build();

  _$GetSyncFull200Response _build() {
    _$GetSyncFull200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncFull200Response._(
            ledger: ledger.build(),
            members: members.build(),
            transactions: transactions.build(),
            categories: categories.build(),
            recurringTransactions: recurringTransactions.build(),
            exchangeRateOverrides: exchangeRateOverrides.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(
                serverCursor, r'GetSyncFull200Response', 'serverCursor'),
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
        _$failedField = 'recurringTransactions';
        recurringTransactions.build();
        _$failedField = 'exchangeRateOverrides';
        exchangeRateOverrides.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncFull200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
