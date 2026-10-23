// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_templates200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListOfficialTemplates200Response
    extends ListOfficialTemplates200Response {
  @override
  final BuiltList<ListOfficialTemplates200ResponseItemsInner> items;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;
  @override
  final String? nextCursor;

  factory _$ListOfficialTemplates200Response(
          [void Function(ListOfficialTemplates200ResponseBuilder)? updates]) =>
      (ListOfficialTemplates200ResponseBuilder()..update(updates))._build();

  _$ListOfficialTemplates200Response._(
      {required this.items,
      required this.page,
      required this.pageSize,
      required this.total,
      this.nextCursor})
      : super._();
  @override
  ListOfficialTemplates200Response rebuild(
          void Function(ListOfficialTemplates200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialTemplates200ResponseBuilder toBuilder() =>
      ListOfficialTemplates200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialTemplates200Response &&
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
    return (newBuiltValueToStringHelper(r'ListOfficialTemplates200Response')
          ..add('items', items)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('total', total)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ListOfficialTemplates200ResponseBuilder
    implements
        Builder<ListOfficialTemplates200Response,
            ListOfficialTemplates200ResponseBuilder> {
  _$ListOfficialTemplates200Response? _$v;

  ListBuilder<ListOfficialTemplates200ResponseItemsInner>? _items;
  ListBuilder<ListOfficialTemplates200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<ListOfficialTemplates200ResponseItemsInner>();
  set items(ListBuilder<ListOfficialTemplates200ResponseItemsInner>? items) =>
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

  ListOfficialTemplates200ResponseBuilder() {
    ListOfficialTemplates200Response._defaults(this);
  }

  ListOfficialTemplates200ResponseBuilder get _$this {
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
  void replace(ListOfficialTemplates200Response other) {
    _$v = other as _$ListOfficialTemplates200Response;
  }

  @override
  void update(void Function(ListOfficialTemplates200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialTemplates200Response build() => _build();

  _$ListOfficialTemplates200Response _build() {
    _$ListOfficialTemplates200Response _$result;
    try {
      _$result = _$v ??
          _$ListOfficialTemplates200Response._(
            items: items.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'ListOfficialTemplates200Response', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(
                pageSize, r'ListOfficialTemplates200Response', 'pageSize'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'ListOfficialTemplates200Response', 'total'),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListOfficialTemplates200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
