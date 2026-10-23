// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_day_books_by_day_book_id_events200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetDayBooksByDayBookIdEvents200Response
    extends GetDayBooksByDayBookIdEvents200Response {
  @override
  final BuiltList<DayEvent> items;
  @override
  final String? nextCursor;

  factory _$GetDayBooksByDayBookIdEvents200Response(
          [void Function(GetDayBooksByDayBookIdEvents200ResponseBuilder)?
              updates]) =>
      (GetDayBooksByDayBookIdEvents200ResponseBuilder()..update(updates))
          ._build();

  _$GetDayBooksByDayBookIdEvents200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetDayBooksByDayBookIdEvents200Response rebuild(
          void Function(GetDayBooksByDayBookIdEvents200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetDayBooksByDayBookIdEvents200ResponseBuilder toBuilder() =>
      GetDayBooksByDayBookIdEvents200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetDayBooksByDayBookIdEvents200Response &&
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
            r'GetDayBooksByDayBookIdEvents200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetDayBooksByDayBookIdEvents200ResponseBuilder
    implements
        Builder<GetDayBooksByDayBookIdEvents200Response,
            GetDayBooksByDayBookIdEvents200ResponseBuilder> {
  _$GetDayBooksByDayBookIdEvents200Response? _$v;

  ListBuilder<DayEvent>? _items;
  ListBuilder<DayEvent> get items => _$this._items ??= ListBuilder<DayEvent>();
  set items(ListBuilder<DayEvent>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetDayBooksByDayBookIdEvents200ResponseBuilder() {
    GetDayBooksByDayBookIdEvents200Response._defaults(this);
  }

  GetDayBooksByDayBookIdEvents200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetDayBooksByDayBookIdEvents200Response other) {
    _$v = other as _$GetDayBooksByDayBookIdEvents200Response;
  }

  @override
  void update(
      void Function(GetDayBooksByDayBookIdEvents200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetDayBooksByDayBookIdEvents200Response build() => _build();

  _$GetDayBooksByDayBookIdEvents200Response _build() {
    _$GetDayBooksByDayBookIdEvents200Response _$result;
    try {
      _$result = _$v ??
          _$GetDayBooksByDayBookIdEvents200Response._(
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
            r'GetDayBooksByDayBookIdEvents200Response',
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
