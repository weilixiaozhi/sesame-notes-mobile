// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_change_currency200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdChangeCurrency200Response
    extends PostLedgersByLedgerIdChangeCurrency200Response {
  @override
  final Ledger ledger;
  @override
  final int updatedTransactions;

  factory _$PostLedgersByLedgerIdChangeCurrency200Response(
          [void Function(PostLedgersByLedgerIdChangeCurrency200ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdChangeCurrency200ResponseBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdChangeCurrency200Response._(
      {required this.ledger, required this.updatedTransactions})
      : super._();
  @override
  PostLedgersByLedgerIdChangeCurrency200Response rebuild(
          void Function(PostLedgersByLedgerIdChangeCurrency200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdChangeCurrency200ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdChangeCurrency200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdChangeCurrency200Response &&
        ledger == other.ledger &&
        updatedTransactions == other.updatedTransactions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, ledger.hashCode);
    _$hash = $jc(_$hash, updatedTransactions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdChangeCurrency200Response')
          ..add('ledger', ledger)
          ..add('updatedTransactions', updatedTransactions))
        .toString();
  }
}

class PostLedgersByLedgerIdChangeCurrency200ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdChangeCurrency200Response,
            PostLedgersByLedgerIdChangeCurrency200ResponseBuilder> {
  _$PostLedgersByLedgerIdChangeCurrency200Response? _$v;

  LedgerBuilder? _ledger;
  LedgerBuilder get ledger => _$this._ledger ??= LedgerBuilder();
  set ledger(LedgerBuilder? ledger) => _$this._ledger = ledger;

  int? _updatedTransactions;
  int? get updatedTransactions => _$this._updatedTransactions;
  set updatedTransactions(int? updatedTransactions) =>
      _$this._updatedTransactions = updatedTransactions;

  PostLedgersByLedgerIdChangeCurrency200ResponseBuilder() {
    PostLedgersByLedgerIdChangeCurrency200Response._defaults(this);
  }

  PostLedgersByLedgerIdChangeCurrency200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _ledger = $v.ledger.toBuilder();
      _updatedTransactions = $v.updatedTransactions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdChangeCurrency200Response other) {
    _$v = other as _$PostLedgersByLedgerIdChangeCurrency200Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdChangeCurrency200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdChangeCurrency200Response build() => _build();

  _$PostLedgersByLedgerIdChangeCurrency200Response _build() {
    _$PostLedgersByLedgerIdChangeCurrency200Response _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdChangeCurrency200Response._(
            ledger: ledger.build(),
            updatedTransactions: BuiltValueNullFieldError.checkNotNull(
                updatedTransactions,
                r'PostLedgersByLedgerIdChangeCurrency200Response',
                'updatedTransactions'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'ledger';
        ledger.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdChangeCurrency200Response',
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
