// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_admin_audit_logs200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetAdminAuditLogs200Response extends GetAdminAuditLogs200Response {
  @override
  final BuiltList<GetAdminAuditLogs200ResponseItemsInner> items;
  @override
  final String? nextCursor;

  factory _$GetAdminAuditLogs200Response(
          [void Function(GetAdminAuditLogs200ResponseBuilder)? updates]) =>
      (GetAdminAuditLogs200ResponseBuilder()..update(updates))._build();

  _$GetAdminAuditLogs200Response._({required this.items, this.nextCursor})
      : super._();
  @override
  GetAdminAuditLogs200Response rebuild(
          void Function(GetAdminAuditLogs200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetAdminAuditLogs200ResponseBuilder toBuilder() =>
      GetAdminAuditLogs200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetAdminAuditLogs200Response &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetAdminAuditLogs200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class GetAdminAuditLogs200ResponseBuilder
    implements
        Builder<GetAdminAuditLogs200Response,
            GetAdminAuditLogs200ResponseBuilder> {
  _$GetAdminAuditLogs200Response? _$v;

  ListBuilder<GetAdminAuditLogs200ResponseItemsInner>? _items;
  ListBuilder<GetAdminAuditLogs200ResponseItemsInner> get items =>
      _$this._items ??= ListBuilder<GetAdminAuditLogs200ResponseItemsInner>();
  set items(ListBuilder<GetAdminAuditLogs200ResponseItemsInner>? items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  GetAdminAuditLogs200ResponseBuilder() {
    GetAdminAuditLogs200Response._defaults(this);
  }

  GetAdminAuditLogs200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetAdminAuditLogs200Response other) {
    _$v = other as _$GetAdminAuditLogs200Response;
  }

  @override
  void update(void Function(GetAdminAuditLogs200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetAdminAuditLogs200Response build() => _build();

  _$GetAdminAuditLogs200Response _build() {
    _$GetAdminAuditLogs200Response _$result;
    try {
      _$result = _$v ??
          _$GetAdminAuditLogs200Response._(
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetAdminAuditLogs200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
