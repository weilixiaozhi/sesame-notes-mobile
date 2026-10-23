// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_category_conflicts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetCategoryConflicts200Response
    extends GetCategoryConflicts200Response {
  @override
  final BuiltList<CategoryConflict> items;
  @override
  final String? nextCursor;
  @override
  final bool hasMore;

  factory _$GetCategoryConflicts200Response(
          [void Function(GetCategoryConflicts200ResponseBuilder)? updates]) =>
      (GetCategoryConflicts200ResponseBuilder()..update(updates))._build();

  _$GetCategoryConflicts200Response._(
      {required this.items, this.nextCursor, required this.hasMore})
      : super._();
  @override
  GetCategoryConflicts200Response rebuild(
          void Function(GetCategoryConflicts200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetCategoryConflicts200ResponseBuilder toBuilder() =>
      GetCategoryConflicts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetCategoryConflicts200Response &&
        items == other.items &&
        nextCursor == other.nextCursor &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetCategoryConflicts200Response')
          ..add('items', items)
          ..add('nextCursor', nextCursor)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class GetCategoryConflicts200ResponseBuilder
    implements
        Builder<GetCategoryConflicts200Response,
            GetCategoryConflicts200ResponseBuilder> {
  _$GetCategoryConflicts200Response? _$v;

  ListBuilder<CategoryConflict>? _items;
  ListBuilder<CategoryConflict> get items =>
      _$this._items ??= ListBuilder<CategoryConflict>();
  set items(ListBuilder<CategoryConflict>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  GetCategoryConflicts200ResponseBuilder() {
    GetCategoryConflicts200Response._defaults(this);
  }

  GetCategoryConflicts200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetCategoryConflicts200Response other) {
    _$v = other as _$GetCategoryConflicts200Response;
  }

  @override
  void update(void Function(GetCategoryConflicts200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetCategoryConflicts200Response build() => _build();

  _$GetCategoryConflicts200Response _build() {
    _$GetCategoryConflicts200Response _$result;
    try {
      _$result = _$v ??
          _$GetCategoryConflicts200Response._(
            items: items.build(),
            nextCursor: nextCursor,
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'GetCategoryConflicts200Response', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetCategoryConflicts200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
