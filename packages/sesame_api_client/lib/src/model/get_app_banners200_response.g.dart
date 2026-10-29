// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_app_banners200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAppBanners200Response extends GetAppBanners200Response {
  @override
  final BuiltList<GetAppBanners200ResponseItemsInner> items;

  factory _$GetAppBanners200Response(
          [void Function(GetAppBanners200ResponseBuilder)? updates]) =>
      (GetAppBanners200ResponseBuilder()..update(updates))._build();

  _$GetAppBanners200Response._({required this.items}) : super._();
  @override
  GetAppBanners200Response rebuild(
          void Function(GetAppBanners200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAppBanners200ResponseBuilder toBuilder() =>
      GetAppBanners200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAppBanners200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'GetAppBanners200Response')
          ..add('items', items))
        .toString();
  }
}

class GetAppBanners200ResponseBuilder
    implements
        Builder<GetAppBanners200Response, GetAppBanners200ResponseBuilder> {
  _$GetAppBanners200Response? _$v;

  ListBuilder<GetAppBanners200ResponseItemsInner>? _items;
  ListBuilder<GetAppBanners200ResponseItemsInner> get items =>
      _$this._items ??= ListBuilder<GetAppBanners200ResponseItemsInner>();
  set items(ListBuilder<GetAppBanners200ResponseItemsInner>? items) =>
      _$this._items = items;

  GetAppBanners200ResponseBuilder() {
    GetAppBanners200Response._defaults(this);
  }

  GetAppBanners200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAppBanners200Response other) {
    _$v = other as _$GetAppBanners200Response;
  }

  @override
  void update(void Function(GetAppBanners200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAppBanners200Response build() => _build();

  _$GetAppBanners200Response _build() {
    _$GetAppBanners200Response _$result;
    try {
      _$result = _$v ??
          _$GetAppBanners200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAppBanners200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
