// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_users_by_user_id_devices200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminUsersByUserIdDevices200Response
    extends GetAdminUsersByUserIdDevices200Response {
  @override
  final BuiltList<GetAdminUsersByUserIdDevices200ResponseItemsInner> items;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int total;

  factory _$GetAdminUsersByUserIdDevices200Response(
          [void Function(GetAdminUsersByUserIdDevices200ResponseBuilder)?
              updates]) =>
      (GetAdminUsersByUserIdDevices200ResponseBuilder()..update(updates))
          ._build();

  _$GetAdminUsersByUserIdDevices200Response._(
      {required this.items,
      required this.page,
      required this.pageSize,
      required this.total})
      : super._();
  @override
  GetAdminUsersByUserIdDevices200Response rebuild(
          void Function(GetAdminUsersByUserIdDevices200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminUsersByUserIdDevices200ResponseBuilder toBuilder() =>
      GetAdminUsersByUserIdDevices200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminUsersByUserIdDevices200Response &&
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
            r'GetAdminUsersByUserIdDevices200Response')
          ..add('items', items)
          ..add('page', page)
          ..add('pageSize', pageSize)
          ..add('total', total))
        .toString();
  }
}

class GetAdminUsersByUserIdDevices200ResponseBuilder
    implements
        Builder<GetAdminUsersByUserIdDevices200Response,
            GetAdminUsersByUserIdDevices200ResponseBuilder> {
  _$GetAdminUsersByUserIdDevices200Response? _$v;

  ListBuilder<GetAdminUsersByUserIdDevices200ResponseItemsInner>? _items;
  ListBuilder<GetAdminUsersByUserIdDevices200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<GetAdminUsersByUserIdDevices200ResponseItemsInner>();
  set items(
          ListBuilder<GetAdminUsersByUserIdDevices200ResponseItemsInner>?
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

  GetAdminUsersByUserIdDevices200ResponseBuilder() {
    GetAdminUsersByUserIdDevices200Response._defaults(this);
  }

  GetAdminUsersByUserIdDevices200ResponseBuilder get _$this {
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
  void replace(GetAdminUsersByUserIdDevices200Response other) {
    _$v = other as _$GetAdminUsersByUserIdDevices200Response;
  }

  @override
  void update(
      void Function(GetAdminUsersByUserIdDevices200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminUsersByUserIdDevices200Response build() => _build();

  _$GetAdminUsersByUserIdDevices200Response _build() {
    _$GetAdminUsersByUserIdDevices200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminUsersByUserIdDevices200Response._(
            items: items.build(),
            page: BuiltValueNullFieldError.checkNotNull(
                page, r'GetAdminUsersByUserIdDevices200Response', 'page'),
            pageSize: BuiltValueNullFieldError.checkNotNull(pageSize,
                r'GetAdminUsersByUserIdDevices200Response', 'pageSize'),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'GetAdminUsersByUserIdDevices200Response', 'total'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminUsersByUserIdDevices200Response',
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
