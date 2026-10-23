// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_identity_types200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminIdentityTypes200Response
    extends GetAdminIdentityTypes200Response {
  @override
  final BuiltList<GetAdminIdentityTypes200ResponseItemsInner> items;

  factory _$GetAdminIdentityTypes200Response(
          [void Function(GetAdminIdentityTypes200ResponseBuilder)? updates]) =>
      (GetAdminIdentityTypes200ResponseBuilder()..update(updates))._build();

  _$GetAdminIdentityTypes200Response._({required this.items}) : super._();
  @override
  GetAdminIdentityTypes200Response rebuild(
          void Function(GetAdminIdentityTypes200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminIdentityTypes200ResponseBuilder toBuilder() =>
      GetAdminIdentityTypes200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminIdentityTypes200Response && items == other.items;
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
    return (newBuiltValueToStringHelper(r'GetAdminIdentityTypes200Response')
          ..add('items', items))
        .toString();
  }
}

class GetAdminIdentityTypes200ResponseBuilder
    implements
        Builder<GetAdminIdentityTypes200Response,
            GetAdminIdentityTypes200ResponseBuilder> {
  _$GetAdminIdentityTypes200Response? _$v;

  ListBuilder<GetAdminIdentityTypes200ResponseItemsInner>? _items;
  ListBuilder<GetAdminIdentityTypes200ResponseItemsInner> get items =>
      _$this._items ??=
          ListBuilder<GetAdminIdentityTypes200ResponseItemsInner>();
  set items(ListBuilder<GetAdminIdentityTypes200ResponseItemsInner>? items) =>
      _$this._items = items;

  GetAdminIdentityTypes200ResponseBuilder() {
    GetAdminIdentityTypes200Response._defaults(this);
  }

  GetAdminIdentityTypes200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminIdentityTypes200Response other) {
    _$v = other as _$GetAdminIdentityTypes200Response;
  }

  @override
  void update(void Function(GetAdminIdentityTypes200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminIdentityTypes200Response build() => _build();

  _$GetAdminIdentityTypes200Response _build() {
    _$GetAdminIdentityTypes200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminIdentityTypes200Response._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminIdentityTypes200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
