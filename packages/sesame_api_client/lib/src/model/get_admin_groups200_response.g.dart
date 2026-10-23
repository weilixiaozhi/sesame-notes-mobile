// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_groups200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminGroups200Response extends GetAdminGroups200Response {
  @override
  final BuiltList<GetAdminGroups200ResponseItemsInner> items;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;

  factory _$GetAdminGroups200Response(
          [void Function(GetAdminGroups200ResponseBuilder)? updates]) =>
      (GetAdminGroups200ResponseBuilder()..update(updates))._build();

  _$GetAdminGroups200Response._(
      {required this.items,
      required this.page,
      required this.pageSize,
      required this.total})
      : super._();
  @override
  GetAdminGroups200Response rebuild(
          void Function(GetAdminGroups200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminGroups200ResponseBuilder toBuilder() =>
      GetAdminGroups200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminGroups200Response &&
        items == other.items &&
        page == other.page &&
        pageSize == other.pageSize &&
        total == other.total;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, pageSize.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminGroups200Response')
          ..add('items', items)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('total', total))
        .toString();
  }
}

class GetAdminGroups200ResponseBuilder
    implements
        Builder<GetAdminGroups200Response, GetAdminGroups200ResponseBuilder> {
  _$GetAdminGroups200Response? _$v;

  ListBuilder<GetAdminGroups200ResponseItemsInner>? _items;
  ListBuilder<GetAdminGroups200ResponseItemsInner> get items =>
      _$this._items ??= ListBuilder<GetAdminGroups200ResponseItemsInner>();
  set items(ListBuilder<GetAdminGroups200ResponseItemsInner>? items) =>
      _$this._items = items;

  int? _page;
  int? get page => _$this._page;
  set page(int? page) => _$this._page = page;

  int? _pageSize;
  int? get pageSize => _$this._pageSize;
  set pageSize(int? pageSize) => _$this._pageSize = pageSize;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  GetAdminGroups200ResponseBuilder() {
    GetAdminGroups200Response._defaults(this);
  }

  GetAdminGroups200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page;
      _pageSize = $v.pageSize;
      _total = $v.total;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminGroups200Response other) {
    _$v = other as _$GetAdminGroups200Response;
  }

  @override
  void update(void Function(GetAdminGroups200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminGroups200Response build() => _build();

  _$GetAdminGroups200Response _build() {
    _$GetAdminGroups200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminGroups200Response._(
            items: items.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'GetAdminGroups200Response', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(
                pageSize, r'GetAdminGroups200Response', 'pageSize'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'GetAdminGroups200Response', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminGroups200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
