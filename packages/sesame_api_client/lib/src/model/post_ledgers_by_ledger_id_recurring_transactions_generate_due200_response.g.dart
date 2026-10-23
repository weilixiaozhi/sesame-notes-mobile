// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_recurring_transactions_generate_due200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response
    extends PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response {
  @override
  final int generatedCount;
  @override
  final int skippedCount;
  @override
  final bool hasMore;
  @override
  final BuiltList<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>
      ruleCursors;
  @override
  final bool replayed;

  factory _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response(
          [void Function(
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response._(
      {required this.generatedCount,
      required this.skippedCount,
      required this.hasMore,
      required this.ruleCursors,
      required this.replayed})
      : super._();
  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response rebuild(
          void Function(
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder
      toBuilder() =>
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response &&
        generatedCount == other.generatedCount &&
        skippedCount == other.skippedCount &&
        hasMore == other.hasMore &&
        ruleCursors == other.ruleCursors &&
        replayed == other.replayed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, generatedCount.hashCode);
    _$hash = $jc(_$hash, skippedCount.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jc(_$hash, ruleCursors.hashCode);
    _$hash = $jc(_$hash, replayed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response')
          ..add('generatedCount', generatedCount)
          ..add('skippedCount', skippedCount)
          ..add('hasMore', hasMore)
          ..add('ruleCursors', ruleCursors)
          ..add('replayed', replayed))
        .toString();
  }
}

class PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder
    implements
        Builder<
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response,
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder> {
  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response? _$v;

  int? _generatedCount;
  int? get generatedCount => _$this._generatedCount;
  set generatedCount(int? generatedCount) =>
      _$this._generatedCount = generatedCount;

  int? _skippedCount;
  int? get skippedCount => _$this._skippedCount;
  set skippedCount(int? skippedCount) => _$this._skippedCount = skippedCount;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  ListBuilder<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>?
      _ruleCursors;
  ListBuilder<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>
      get ruleCursors => _$this._ruleCursors ??= ListBuilder<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>();
  set ruleCursors(
          ListBuilder<
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>?
              ruleCursors) =>
      _$this._ruleCursors = ruleCursors;

  bool? _replayed;
  bool? get replayed => _$this._replayed;
  set replayed(bool? replayed) => _$this._replayed = replayed;

  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder() {
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response._defaults(
        this);
  }

  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _generatedCount = $v.generatedCount;
      _skippedCount = $v.skippedCount;
      _hasMore = $v.hasMore;
      _ruleCursors = $v.ruleCursors.toBuilder();
      _replayed = $v.replayed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response other) {
    _$v = other
        as _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response build() =>
      _build();

  _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response _build() {
    _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response._(
            generatedCount: BuiltValueNullFieldError.checkNotNull(
                generatedCount,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response',
                'generatedCount'),
            skippedCount: BuiltValueNullFieldError.checkNotNull(
                skippedCount,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response',
                'skippedCount'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response',
                'hasMore'),
            ruleCursors: ruleCursors.build(),
            replayed: BuiltValueNullFieldError.checkNotNull(
                replayed,
                r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response',
                'replayed'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ruleCursors';
        ruleCursors.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response',
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
