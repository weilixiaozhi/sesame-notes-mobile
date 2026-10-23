// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_recurring_transactions_generate_due_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest
    extends PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest {
  @override
  final String mutationId;
  @override
  final String expectedSyncId;
  @override
  final String expectedCurrency;
  @override
  final BuiltMap<String, String>? rates;
  @override
  final int? limit;

  factory _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest(
          [void Function(
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest._(
      {required this.mutationId,
      required this.expectedSyncId,
      required this.expectedCurrency,
      this.rates,
      this.limit})
      : super._();
  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest rebuild(
          void Function(
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder
      toBuilder() =>
          PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest &&
        mutationId == other.mutationId &&
        expectedSyncId == other.expectedSyncId &&
        expectedCurrency == other.expectedCurrency &&
        rates == other.rates &&
        limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, expectedSyncId.hashCode);
    _$hash = $jc(_$hash, expectedCurrency.hashCode);
    _$hash = $jc(_$hash, rates.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest')
          ..add('mutationId', mutationId)
          ..add('expectedSyncId', expectedSyncId)
          ..add('expectedCurrency', expectedCurrency)
          ..add('rates', rates)
          ..add('limit', limit))
        .toString();
  }
}

class PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest,
            PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder> {
  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest? _$v;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  String? _expectedSyncId;
  String? get expectedSyncId => _$this._expectedSyncId;
  set expectedSyncId(String? expectedSyncId) =>
      _$this._expectedSyncId = expectedSyncId;

  String? _expectedCurrency;
  String? get expectedCurrency => _$this._expectedCurrency;
  set expectedCurrency(String? expectedCurrency) =>
      _$this._expectedCurrency = expectedCurrency;

  MapBuilder<String, String>? _rates;
  MapBuilder<String, String> get rates =>
      _$this._rates ??= MapBuilder<String, String>();
  set rates(MapBuilder<String, String>? rates) => _$this._rates = rates;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder() {
    PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest._defaults(
        this);
  }

  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _mutationId = $v.mutationId;
      _expectedSyncId = $v.expectedSyncId;
      _expectedCurrency = $v.expectedCurrency;
      _rates = $v.rates?.toBuilder();
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest other) {
    _$v =
        other as _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest build() =>
      _build();

  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest _build() {
    _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest._(
            mutationId: BuiltValueNullFieldError.checkNotNull(
                mutationId,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest',
                'mutationId'),
            expectedSyncId: BuiltValueNullFieldError.checkNotNull(
                expectedSyncId,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest',
                'expectedSyncId'),
            expectedCurrency: BuiltValueNullFieldError.checkNotNull(
                expectedCurrency,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest',
                'expectedCurrency'),
            rates: _rates?.build(),
            limit: limit,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'rates';
        _rates?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest',
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
