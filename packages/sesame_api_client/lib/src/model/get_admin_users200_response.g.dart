// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_users200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminUsers200Response extends GetAdminUsers200Response {
  @override
  final BuiltList<GetAdminUsers200ResponseItemsInner> items;
  @override
  final String? nextCursor;

  factory _$GetAdminUsers200Response(
          [void Function(GetAdminUsers200ResponseBuilder)? updates]) =>
      (GetAdminUsers200ResponseBuilder()..update(updates))._build();

  _$GetAdminUsers200Response._({required this.items, this.nextCursor})
      : super._();
  @override
  GetAdminUsers200Response rebuild(
          void Function(GetAdminUsers200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminUsers200ResponseBuilder toBuilder() =>
      GetAdminUsers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminUsers200Response &&
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
    return (newBuiltValueToStringHelper(r'GetAdminUsers200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetAdminUsers200ResponseBuilder
    implements
        Builder<GetAdminUsers200Response, GetAdminUsers200ResponseBuilder> {
  _$GetAdminUsers200Response? _$v;

  ListBuilder<GetAdminUsers200ResponseItemsInner>? _items;
  ListBuilder<GetAdminUsers200ResponseItemsInner> get items =>
      _$this._items ??= ListBuilder<GetAdminUsers200ResponseItemsInner>();
  set items(ListBuilder<GetAdminUsers200ResponseItemsInner>? items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetAdminUsers200ResponseBuilder() {
    GetAdminUsers200Response._defaults(this);
  }

  GetAdminUsers200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminUsers200Response other) {
    _$v = other as _$GetAdminUsers200Response;
  }

  @override
  void update(void Function(GetAdminUsers200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminUsers200Response build() => _build();

  _$GetAdminUsers200Response _build() {
    _$GetAdminUsers200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminUsers200Response._(
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
            r'GetAdminUsers200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
