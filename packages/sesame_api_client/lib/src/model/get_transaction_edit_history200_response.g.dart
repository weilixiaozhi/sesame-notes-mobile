// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_transaction_edit_history200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetTransactionEditHistory200Response
    extends GetTransactionEditHistory200Response {
  @override
  final BuiltList<GetTransactionEditHistory200ResponseItemsInner> items;
  @override
  final String? nextCursor;

  factory _$GetTransactionEditHistory200Response(
          [void Function(GetTransactionEditHistory200ResponseBuilder)?
              updates]) =>
      (GetTransactionEditHistory200ResponseBuilder()..update(updates))._build();

  _$GetTransactionEditHistory200Response._(
      {required this.items, this.nextCursor})
      : super._();
  @override
  GetTransactionEditHistory200Response rebuild(
          void Function(GetTransactionEditHistory200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetTransactionEditHistory200ResponseBuilder toBuilder() =>
      GetTransactionEditHistory200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetTransactionEditHistory200Response &&
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
    return (newBuiltValueToStringHelper(r'GetTransactionEditHistory200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetTransactionEditHistory200ResponseBuilder
    implements
        Builder<GetTransactionEditHistory200Response,
            GetTransactionEditHistory200ResponseBuilder> {
  _$GetTransactionEditHistory200Response? _$v;

  ListBuilder<GetTransactionEditHistory200ResponseItemsInner>? _items;
  ListBuilder<GetTransactionEditHistory200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<GetTransactionEditHistory200ResponseItemsInner>();
  set items(
          ListBuilder<GetTransactionEditHistory200ResponseItemsInner>? items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetTransactionEditHistory200ResponseBuilder() {
    GetTransactionEditHistory200Response._defaults(this);
  }

  GetTransactionEditHistory200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetTransactionEditHistory200Response other) {
    _$v = other as _$GetTransactionEditHistory200Response;
  }

  @override
  void update(
      void Function(GetTransactionEditHistory200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetTransactionEditHistory200Response build() => _build();

  _$GetTransactionEditHistory200Response _build() {
    _$GetTransactionEditHistory200Response _$result;
    try {
      _$result = _$v ??
          _$GetTransactionEditHistory200Response._(
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
            r'GetTransactionEditHistory200Response',
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
