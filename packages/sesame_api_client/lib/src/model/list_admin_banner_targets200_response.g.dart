// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_admin_banner_targets200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListAdminBannerTargets200Response
    extends ListAdminBannerTargets200Response {
  @override
  final BuiltList<ListAdminBannerTargets200ResponseItemsInner> items;

  factory _$ListAdminBannerTargets200Response(
          [void Function(ListAdminBannerTargets200ResponseBuilder)? updates]) =>
      (ListAdminBannerTargets200ResponseBuilder()..update(updates))._build();

  _$ListAdminBannerTargets200Response._({required this.items}) : super._();
  @override
  ListAdminBannerTargets200Response rebuild(
          void Function(ListAdminBannerTargets200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListAdminBannerTargets200ResponseBuilder toBuilder() =>
      ListAdminBannerTargets200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListAdminBannerTargets200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'ListAdminBannerTargets200Response')
          ..add('items', items))
        .toString();
  }
}

class ListAdminBannerTargets200ResponseBuilder
    implements
        Builder<ListAdminBannerTargets200Response,
            ListAdminBannerTargets200ResponseBuilder> {
  _$ListAdminBannerTargets200Response? _$v;

  ListBuilder<ListAdminBannerTargets200ResponseItemsInner>? _items;
  ListBuilder<ListAdminBannerTargets200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<ListAdminBannerTargets200ResponseItemsInner>();
  set items(ListBuilder<ListAdminBannerTargets200ResponseItemsInner>? items) =>
      _$this._items = items;

  ListAdminBannerTargets200ResponseBuilder() {
    ListAdminBannerTargets200Response._defaults(this);
  }

  ListAdminBannerTargets200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListAdminBannerTargets200Response other) {
    _$v = other as _$ListAdminBannerTargets200Response;
  }

  @override
  void update(
      void Function(ListAdminBannerTargets200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListAdminBannerTargets200Response build() => _build();

  _$ListAdminBannerTargets200Response _build() {
    _$ListAdminBannerTargets200Response _$result;
    try {
      _$result = _$v ??
          _$ListAdminBannerTargets200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListAdminBannerTargets200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
