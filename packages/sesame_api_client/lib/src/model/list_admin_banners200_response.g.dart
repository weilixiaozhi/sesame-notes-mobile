// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_admin_banners200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListAdminBanners200Response extends ListAdminBanners200Response {
  @override
  final BuiltList<ListAdminBanners200ResponseItemsInner> items;

  factory _$ListAdminBanners200Response(
          [void Function(ListAdminBanners200ResponseBuilder)? updates]) =>
      (ListAdminBanners200ResponseBuilder()..update(updates))._build();

  _$ListAdminBanners200Response._({required this.items}) : super._();
  @override
  ListAdminBanners200Response rebuild(
          void Function(ListAdminBanners200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListAdminBanners200ResponseBuilder toBuilder() =>
      ListAdminBanners200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListAdminBanners200Response && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ListAdminBanners200Response')
          ..add('items', items))
        .toString();
  }
}

class ListAdminBanners200ResponseBuilder
    implements
        Builder<ListAdminBanners200Response,
            ListAdminBanners200ResponseBuilder> {
  _$ListAdminBanners200Response? _$v;

  ListBuilder<ListAdminBanners200ResponseItemsInner>? _items;
  ListBuilder<ListAdminBanners200ResponseItemsInner> get items =>
      _$this._items ??= ListBuilder<ListAdminBanners200ResponseItemsInner>();
  set items(ListBuilder<ListAdminBanners200ResponseItemsInner>? items) =>
      _$this._items = items;

  ListAdminBanners200ResponseBuilder() {
    ListAdminBanners200Response._defaults(this);
  }

  ListAdminBanners200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListAdminBanners200Response other) {
    _$v = other as _$ListAdminBanners200Response;
  }

  @override
  void update(void Function(ListAdminBanners200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListAdminBanners200Response build() => _build();

  _$ListAdminBanners200Response _build() {
    _$ListAdminBanners200Response _$result;
    try {
      _$result = _$v ??
          _$ListAdminBanners200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListAdminBanners200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
