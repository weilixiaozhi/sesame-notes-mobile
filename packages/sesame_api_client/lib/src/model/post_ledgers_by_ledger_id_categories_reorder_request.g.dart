// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_reorder_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesReorderRequest
    extends PostLedgersByLedgerIdCategoriesReorderRequest {
  @override
  final BuiltList<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>
      items;

  factory _$PostLedgersByLedgerIdCategoriesReorderRequest(
          [void Function(PostLedgersByLedgerIdCategoriesReorderRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesReorderRequestBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesReorderRequest._({required this.items})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesReorderRequest rebuild(
          void Function(PostLedgersByLedgerIdCategoriesReorderRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesReorderRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesReorderRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesReorderRequest &&
        items == other.items;
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
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesReorderRequest')
          ..add('items', items))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesReorderRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesReorderRequest,
            PostLedgersByLedgerIdCategoriesReorderRequestBuilder> {
  _$PostLedgersByLedgerIdCategoriesReorderRequest? _$v;

  ListBuilder<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>? _items;
  ListBuilder<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>
      get items => _$this._items ??= ListBuilder<
          PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>();
  set items(
          ListBuilder<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>?
              items) =>
      _$this._items = items;

  PostLedgersByLedgerIdCategoriesReorderRequestBuilder() {
    PostLedgersByLedgerIdCategoriesReorderRequest._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesReorderRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesReorderRequest other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesReorderRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdCategoriesReorderRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesReorderRequest build() => _build();

  _$PostLedgersByLedgerIdCategoriesReorderRequest _build() {
    _$PostLedgersByLedgerIdCategoriesReorderRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdCategoriesReorderRequest._(
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdCategoriesReorderRequest',
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
