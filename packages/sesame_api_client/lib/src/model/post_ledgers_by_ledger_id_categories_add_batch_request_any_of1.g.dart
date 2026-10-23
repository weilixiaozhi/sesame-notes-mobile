// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_add_batch_request_any_of1.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1
    extends PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 {
  @override
  final BuiltList<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>
      items;
  @override
  final bool initializeDefaults;

  factory _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1(
          [void Function(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1._(
      {required this.items, required this.initializeDefaults})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 rebuild(
          void Function(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder toBuilder() =>
      PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 &&
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
            r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1')
          ..add('items', items)
          ..add('initializeDefaults', initializeDefaults))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder
    implements
        Builder<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1,
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder> {
  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1? _$v;

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

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder() {
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _initializeDefaults = $v.initializeDefaults;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 build() => _build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 _build() {
    _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1._(
            items: items.build(),
            initializeDefaults: BuiltValueNullFieldError.checkNotNull(
                initializeDefaults,
                r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1',
                'initializeDefaults'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1',
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
