// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_plans200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListOfficialPlans200Response extends ListOfficialPlans200Response {
  @override
  final BuiltList<ListOfficialPlans200ResponseItemsInner> items;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;
  @override
  final String? nextCursor;

  factory _$ListOfficialPlans200Response(
          [void Function(ListOfficialPlans200ResponseBuilder)? updates]) =>
      (ListOfficialPlans200ResponseBuilder()..update(updates))._build();

  _$ListOfficialPlans200Response._(
      {required this.items,
      required this.page,
      required this.pageSize,
      required this.total,
      this.nextCursor})
      : super._();
  @override
  ListOfficialPlans200Response rebuild(
          void Function(ListOfficialPlans200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialPlans200ResponseBuilder toBuilder() =>
      ListOfficialPlans200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialPlans200Response &&
        items == other.items &&
        page == other.page &&
        pageSize == other.pageSize &&
        total == other.total &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, page.hashCode);
    _$hash = $jc(_$hash, pageSize.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ListOfficialPlans200Response')
          ..add('items', items)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('total', total)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ListOfficialPlans200ResponseBuilder
    implements
        Builder<ListOfficialPlans200Response,
            ListOfficialPlans200ResponseBuilder> {
  _$ListOfficialPlans200Response? _$v;

  ListBuilder<ListOfficialPlans200ResponseItemsInner>? _items;
  ListBuilder<ListOfficialPlans200ResponseItemsInner> get items =>
      _$this._items ??= ListBuilder<ListOfficialPlans200ResponseItemsInner>();
  set items(ListBuilder<ListOfficialPlans200ResponseItemsInner>? items) =>
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

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ListOfficialPlans200ResponseBuilder() {
    ListOfficialPlans200Response._defaults(this);
  }

  ListOfficialPlans200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _page = $v.page;
      _pageSize = $v.pageSize;
      _total = $v.total;
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListOfficialPlans200Response other) {
    _$v = other as _$ListOfficialPlans200Response;
  }

  @override
  void update(void Function(ListOfficialPlans200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialPlans200Response build() => _build();

  _$ListOfficialPlans200Response _build() {
    _$ListOfficialPlans200Response _$result;
    try {
      _$result = _$v ??
          _$ListOfficialPlans200Response._(
            items: items.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ListOfficialPlans200Response', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(
                pageSize, r'ListOfficialPlans200Response', 'pageSize'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'ListOfficialPlans200Response', 'total'),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialPlans200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
