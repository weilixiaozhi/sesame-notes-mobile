// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_memo_books_by_memo_book_id_entries200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetMemoBooksByMemoBookIdEntries200Response
    extends GetMemoBooksByMemoBookIdEntries200Response {
  @override
  final BuiltList<MemoEntry> items;
  @override
  final String? nextCursor;

  factory _$GetMemoBooksByMemoBookIdEntries200Response(
          [void Function(GetMemoBooksByMemoBookIdEntries200ResponseBuilder)?
              updates]) =>
      (GetMemoBooksByMemoBookIdEntries200ResponseBuilder()..update(updates))
          ._build();

  _$GetMemoBooksByMemoBookIdEntries200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetMemoBooksByMemoBookIdEntries200Response rebuild(
          void Function(GetMemoBooksByMemoBookIdEntries200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetMemoBooksByMemoBookIdEntries200ResponseBuilder toBuilder() =>
      GetMemoBooksByMemoBookIdEntries200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetMemoBooksByMemoBookIdEntries200Response &&
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
            r'GetMemoBooksByMemoBookIdEntries200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetMemoBooksByMemoBookIdEntries200ResponseBuilder
    implements
        Builder<GetMemoBooksByMemoBookIdEntries200Response,
            GetMemoBooksByMemoBookIdEntries200ResponseBuilder> {
  _$GetMemoBooksByMemoBookIdEntries200Response? _$v;

  ListBuilder<MemoEntry>? _items;
  ListBuilder<MemoEntry> get items =>
      _$this._items ??= ListBuilder<MemoEntry>();
  set items(ListBuilder<MemoEntry>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetMemoBooksByMemoBookIdEntries200ResponseBuilder() {
    GetMemoBooksByMemoBookIdEntries200Response._defaults(this);
  }

  GetMemoBooksByMemoBookIdEntries200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetMemoBooksByMemoBookIdEntries200Response other) {
    _$v = other as _$GetMemoBooksByMemoBookIdEntries200Response;
  }

  @override
  void update(
      void Function(GetMemoBooksByMemoBookIdEntries200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetMemoBooksByMemoBookIdEntries200Response build() => _build();

  _$GetMemoBooksByMemoBookIdEntries200Response _build() {
    _$GetMemoBooksByMemoBookIdEntries200Response _$result;
    try {
      _$result = _$v ??
          _$GetMemoBooksByMemoBookIdEntries200Response._(
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
            r'GetMemoBooksByMemoBookIdEntries200Response',
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
