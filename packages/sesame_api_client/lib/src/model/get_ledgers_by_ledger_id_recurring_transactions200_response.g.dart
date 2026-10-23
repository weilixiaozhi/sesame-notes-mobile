// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_recurring_transactions200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdRecurringTransactions200Response
    extends GetLedgersByLedgerIdRecurringTransactions200Response {
  @override
  final BuiltList<RecurringTransaction> items;
  @override
  final String? nextCursor;

  factory _$GetLedgersByLedgerIdRecurringTransactions200Response(
          [void Function(
                  GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdRecurringTransactions200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetLedgersByLedgerIdRecurringTransactions200Response rebuild(
          void Function(
                  GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdRecurringTransactions200Response &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdRecurringTransactions200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdRecurringTransactions200Response,
            GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder> {
  _$GetLedgersByLedgerIdRecurringTransactions200Response? _$v;

  ListBuilder<RecurringTransaction>? _items;
  ListBuilder<RecurringTransaction> get items =>
      _$this._items ??= ListBuilder<RecurringTransaction>();
  set items(ListBuilder<RecurringTransaction>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder() {
    GetLedgersByLedgerIdRecurringTransactions200Response._defaults(this);
  }

  GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdRecurringTransactions200Response other) {
    _$v = other as _$GetLedgersByLedgerIdRecurringTransactions200Response;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdRecurringTransactions200Response build() => _build();

  _$GetLedgersByLedgerIdRecurringTransactions200Response _build() {
    _$GetLedgersByLedgerIdRecurringTransactions200Response _$result;
    try {
      _$result = _$v ??
          _$GetLedgersByLedgerIdRecurringTransactions200Response._(
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetLedgersByLedgerIdRecurringTransactions200Response',
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
