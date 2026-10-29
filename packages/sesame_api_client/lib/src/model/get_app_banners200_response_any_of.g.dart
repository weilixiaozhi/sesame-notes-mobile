// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_app_banners200_response_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAppBanners200ResponseAnyOf extends GetAppBanners200ResponseAnyOf {
  @override
  final BuiltList<GetAppBanners200ResponseAnyOfItemsInner> items;

  factory _$GetAppBanners200ResponseAnyOf(
          [void Function(GetAppBanners200ResponseAnyOfBuilder)? updates]) =>
      (GetAppBanners200ResponseAnyOfBuilder()..update(updates))._build();

  _$GetAppBanners200ResponseAnyOf._({required this.items}) : super._();
  @override
  GetAppBanners200ResponseAnyOf rebuild(
          void Function(GetAppBanners200ResponseAnyOfBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAppBanners200ResponseAnyOfBuilder toBuilder() =>
      GetAppBanners200ResponseAnyOfBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAppBanners200ResponseAnyOf && items == other.items;
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
    return (newBuiltValueToStringHelper(r'GetAppBanners200ResponseAnyOf')
          ..add('items', items))
        .toString();
  }
}

class GetAppBanners200ResponseAnyOfBuilder
    implements
        Builder<GetAppBanners200ResponseAnyOf,
            GetAppBanners200ResponseAnyOfBuilder> {
  _$GetAppBanners200ResponseAnyOf? _$v;

  ListBuilder<GetAppBanners200ResponseAnyOfItemsInner>? _items;
  ListBuilder<GetAppBanners200ResponseAnyOfItemsInner> get items =>
      _$this._items ??= ListBuilder<GetAppBanners200ResponseAnyOfItemsInner>();
  set items(ListBuilder<GetAppBanners200ResponseAnyOfItemsInner>? items) =>
      _$this._items = items;

  GetAppBanners200ResponseAnyOfBuilder() {
    GetAppBanners200ResponseAnyOf._defaults(this);
  }

  GetAppBanners200ResponseAnyOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAppBanners200ResponseAnyOf other) {
    _$v = other as _$GetAppBanners200ResponseAnyOf;
  }

  @override
  void update(void Function(GetAppBanners200ResponseAnyOfBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAppBanners200ResponseAnyOf build() => _build();

  _$GetAppBanners200ResponseAnyOf _build() {
    _$GetAppBanners200ResponseAnyOf _$result;
    try {
      _$result = _$v ??
          _$GetAppBanners200ResponseAnyOf._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAppBanners200ResponseAnyOf', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
