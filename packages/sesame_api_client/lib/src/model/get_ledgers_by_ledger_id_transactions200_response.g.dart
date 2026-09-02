// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_transactions200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdTransactions200Response
    extends GetLedgersByLedgerIdTransactions200Response {
  @override
  final BuiltList<Transaction> items;
  @override
  final String? nextCursor;

  factory _$GetLedgersByLedgerIdTransactions200Response(
          [void Function(GetLedgersByLedgerIdTransactions200ResponseBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdTransactions200ResponseBuilder()..update(updates))
          ._build();

  _$GetLedgersByLedgerIdTransactions200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetLedgersByLedgerIdTransactions200Response rebuild(
          void Function(GetLedgersByLedgerIdTransactions200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdTransactions200ResponseBuilder toBuilder() =>
      GetLedgersByLedgerIdTransactions200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetLedgersByLedgerIdTransactions200Response &&
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
            r'GetLedgersByLedgerIdTransactions200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetLedgersByLedgerIdTransactions200ResponseBuilder
    implements
        Builder<GetLedgersByLedgerIdTransactions200Response,
            GetLedgersByLedgerIdTransactions200ResponseBuilder> {
  _$GetLedgersByLedgerIdTransactions200Response? _$v;

  ListBuilder<Transaction>? _items;
  ListBuilder<Transaction> get items =>
      _$this._items ??= ListBuilder<Transaction>();
  set items(ListBuilder<Transaction>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetLedgersByLedgerIdTransactions200ResponseBuilder() {
    GetLedgersByLedgerIdTransactions200Response._defaults(this);
  }

  GetLedgersByLedgerIdTransactions200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetLedgersByLedgerIdTransactions200Response other) {
    _$v = other as _$GetLedgersByLedgerIdTransactions200Response;
  }

  @override
  void update(
      void Function(GetLedgersByLedgerIdTransactions200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdTransactions200Response build() => _build();

  _$GetLedgersByLedgerIdTransactions200Response _build() {
    _$GetLedgersByLedgerIdTransactions200Response _$result;
    try {
      _$result = _$v ??
          _$GetLedgersByLedgerIdTransactions200Response._(
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
            r'GetLedgersByLedgerIdTransactions200Response',
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
