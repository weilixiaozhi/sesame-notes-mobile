// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_app_banners200_response_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAppBanners200ResponseAnyOf1 extends GetAppBanners200ResponseAnyOf1 {
  @override
  final BuiltList<GetAppBanners200ResponseAnyOf1ItemsInner> items;

  factory _$GetAppBanners200ResponseAnyOf1(
          [void Function(GetAppBanners200ResponseAnyOf1Builder)? updates]) =>
      (GetAppBanners200ResponseAnyOf1Builder()..update(updates))._build();

  _$GetAppBanners200ResponseAnyOf1._({required this.items}) : super._();
  @override
  GetAppBanners200ResponseAnyOf1 rebuild(
          void Function(GetAppBanners200ResponseAnyOf1Builder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAppBanners200ResponseAnyOf1Builder toBuilder() =>
      GetAppBanners200ResponseAnyOf1Builder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAppBanners200ResponseAnyOf1 && items == other.items;
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
    return (newBuiltValueToStringHelper(r'GetAppBanners200ResponseAnyOf1')
          ..add('items', items))
        .toString();
  }
}

class GetAppBanners200ResponseAnyOf1Builder
    implements
        Builder<GetAppBanners200ResponseAnyOf1,
            GetAppBanners200ResponseAnyOf1Builder> {
  _$GetAppBanners200ResponseAnyOf1? _$v;

  ListBuilder<GetAppBanners200ResponseAnyOf1ItemsInner>? _items;
  ListBuilder<GetAppBanners200ResponseAnyOf1ItemsInner> get items =>
      _$this._items ??= ListBuilder<GetAppBanners200ResponseAnyOf1ItemsInner>();
  set items(ListBuilder<GetAppBanners200ResponseAnyOf1ItemsInner>? items) =>
      _$this._items = items;

  GetAppBanners200ResponseAnyOf1Builder() {
    GetAppBanners200ResponseAnyOf1._defaults(this);
  }

  GetAppBanners200ResponseAnyOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAppBanners200ResponseAnyOf1 other) {
    _$v = other as _$GetAppBanners200ResponseAnyOf1;
  }

  @override
  void update(void Function(GetAppBanners200ResponseAnyOf1Builder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAppBanners200ResponseAnyOf1 build() => _build();

  _$GetAppBanners200ResponseAnyOf1 _build() {
    _$GetAppBanners200ResponseAnyOf1 _$result;
    try {
      _$result = _$v ??
          _$GetAppBanners200ResponseAnyOf1._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAppBanners200ResponseAnyOf1', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
