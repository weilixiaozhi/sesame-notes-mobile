// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_reorder_request_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner
    extends PostLedgersByLedgerIdCategoriesReorderRequestItemsInner {
  @override
  final String id;
  @override
  final int sortOrder;
  @override
  final DateTime expectedUpdatedAt;

  factory _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner(
          [void Function(
                  PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner._(
      {required this.id,
      required this.sortOrder,
      required this.expectedUpdatedAt})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesReorderRequestItemsInner rebuild(
          void Function(
                  PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesReorderRequestItemsInner &&
        id == other.id &&
        sortOrder == other.sortOrder &&
        expectedUpdatedAt == other.expectedUpdatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, expectedUpdatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesReorderRequestItemsInner')
          ..add('id', id)
          ..add('sortOrder', sortOrder)
          ..add('expectedUpdatedAt', expectedUpdatedAt))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner,
            PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder> {
  _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  DateTime? _expectedUpdatedAt;
  DateTime? get expectedUpdatedAt => _$this._expectedUpdatedAt;
  set expectedUpdatedAt(DateTime? expectedUpdatedAt) =>
      _$this._expectedUpdatedAt = expectedUpdatedAt;

  PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder() {
    PostLedgersByLedgerIdCategoriesReorderRequestItemsInner._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _sortOrder = $v.sortOrder;
      _expectedUpdatedAt = $v.expectedUpdatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesReorderRequestItemsInner other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesReorderRequestItemsInner build() => _build();

  _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(id,
              r'PostLedgersByLedgerIdCategoriesReorderRequestItemsInner', 'id'),
          sortOrder: BuiltValueNullFieldError.checkNotNull(
              sortOrder,
              r'PostLedgersByLedgerIdCategoriesReorderRequestItemsInner',
              'sortOrder'),
          expectedUpdatedAt: BuiltValueNullFieldError.checkNotNull(
              expectedUpdatedAt,
              r'PostLedgersByLedgerIdCategoriesReorderRequestItemsInner',
              'expectedUpdatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
