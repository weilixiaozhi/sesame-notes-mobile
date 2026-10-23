// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_groups_by_group_id_members200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminGroupsByGroupIdMembers200Response
    extends GetAdminGroupsByGroupIdMembers200Response {
  @override
  final BuiltList<GetAdminGroupsByGroupIdMembers200ResponseItemsInner> items;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;

  factory _$GetAdminGroupsByGroupIdMembers200Response(
          [void Function(GetAdminGroupsByGroupIdMembers200ResponseBuilder)?
              updates]) =>
      (GetAdminGroupsByGroupIdMembers200ResponseBuilder()..update(updates))
          ._build();

  _$GetAdminGroupsByGroupIdMembers200Response._(
      {required this.items,
      required this.page,
      required this.pageSize,
      required this.total})
      : super._();
  @override
  GetAdminGroupsByGroupIdMembers200Response rebuild(
          void Function(GetAdminGroupsByGroupIdMembers200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminGroupsByGroupIdMembers200ResponseBuilder toBuilder() =>
      GetAdminGroupsByGroupIdMembers200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminGroupsByGroupIdMembers200Response &&
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
    return (newBuiltValueToStringHelper(
            r'GetAdminGroupsByGroupIdMembers200Response')
          ..add('items', items)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('total', total))
        .toString();
  }
}

class GetAdminGroupsByGroupIdMembers200ResponseBuilder
    implements
        Builder<GetAdminGroupsByGroupIdMembers200Response,
            GetAdminGroupsByGroupIdMembers200ResponseBuilder> {
  _$GetAdminGroupsByGroupIdMembers200Response? _$v;

  ListBuilder<GetAdminGroupsByGroupIdMembers200ResponseItemsInner>? _items;
  ListBuilder<GetAdminGroupsByGroupIdMembers200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<GetAdminGroupsByGroupIdMembers200ResponseItemsInner>();
  set items(
          ListBuilder<GetAdminGroupsByGroupIdMembers200ResponseItemsInner>?
              items) =>
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

  GetAdminGroupsByGroupIdMembers200ResponseBuilder() {
    GetAdminGroupsByGroupIdMembers200Response._defaults(this);
  }

  GetAdminGroupsByGroupIdMembers200ResponseBuilder get _$this {
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
  void replace(GetAdminGroupsByGroupIdMembers200Response other) {
    _$v = other as _$GetAdminGroupsByGroupIdMembers200Response;
  }

  @override
  void update(
      void Function(GetAdminGroupsByGroupIdMembers200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminGroupsByGroupIdMembers200Response build() => _build();

  _$GetAdminGroupsByGroupIdMembers200Response _build() {
    _$GetAdminGroupsByGroupIdMembers200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminGroupsByGroupIdMembers200Response._(
            items: items.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'GetAdminGroupsByGroupIdMembers200Response', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(pageSize,
                r'GetAdminGroupsByGroupIdMembers200Response', 'pageSize'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'GetAdminGroupsByGroupIdMembers200Response', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminGroupsByGroupIdMembers200Response',
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
