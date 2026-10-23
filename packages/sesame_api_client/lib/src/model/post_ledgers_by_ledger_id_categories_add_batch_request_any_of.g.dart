// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_add_batch_request_any_of.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf
    extends PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf {
  @override
  final BuiltList<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>
      items;
  @override
  final bool? initializeDefaults;

  factory _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf(
          [void Function(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf._(
      {required this.items, this.initializeDefaults})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf rebuild(
          void Function(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf &&
        items == other.items &&
        initializeDefaults == other.initializeDefaults;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, initializeDefaults.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf')
          ..add('items', items)
          ..add('initializeDefaults', initializeDefaults))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf,
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder> {
  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf? _$v;

  ListBuilder<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>?
      _items;
  ListBuilder<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>
      get items => _$this._items ??= ListBuilder<
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>();
  set items(
          ListBuilder<
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>?
              items) =>
      _$this._items = items;

  bool? _initializeDefaults;
  bool? get initializeDefaults => _$this._initializeDefaults;
  set initializeDefaults(bool? initializeDefaults) =>
      _$this._initializeDefaults = initializeDefaults;

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder() {
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _initializeDefaults = $v.initializeDefaults;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf build() => _build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf _build() {
    _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf._(
            items: items.build(),
            initializeDefaults: initializeDefaults,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf',
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
