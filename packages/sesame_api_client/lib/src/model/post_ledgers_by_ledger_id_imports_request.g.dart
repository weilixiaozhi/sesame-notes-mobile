// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_imports_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdImportsRequest
    extends PostLedgersByLedgerIdImportsRequest {
  @override
  final BuiltList<PostLedgersByLedgerIdCategoriesRequest>? categories;
  @override
  final BuiltList<PostLedgersByLedgerIdTransactionsRequest>? transactions;

  factory _$PostLedgersByLedgerIdImportsRequest(
          [void Function(PostLedgersByLedgerIdImportsRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdImportsRequestBuilder()..update(updates))._build();

  _$PostLedgersByLedgerIdImportsRequest._({this.categories, this.transactions})
      : super._();
  @override
  PostLedgersByLedgerIdImportsRequest rebuild(
          void Function(PostLedgersByLedgerIdImportsRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdImportsRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdImportsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdImportsRequest &&
        categories == other.categories &&
        transactions == other.transactions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, transactions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostLedgersByLedgerIdImportsRequest')
          ..add('categories', categories)
          ..add('transactions', transactions))
        .toString();
  }
}

class PostLedgersByLedgerIdImportsRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdImportsRequest,
            PostLedgersByLedgerIdImportsRequestBuilder> {
  _$PostLedgersByLedgerIdImportsRequest? _$v;

  ListBuilder<PostLedgersByLedgerIdCategoriesRequest>? _categories;
  ListBuilder<PostLedgersByLedgerIdCategoriesRequest> get categories =>
      _$this._categories ??=
          ListBuilder<PostLedgersByLedgerIdCategoriesRequest>();
  set categories(
          ListBuilder<PostLedgersByLedgerIdCategoriesRequest>? categories) =>
      _$this._categories = categories;

  ListBuilder<PostLedgersByLedgerIdTransactionsRequest>? _transactions;
  ListBuilder<PostLedgersByLedgerIdTransactionsRequest> get transactions =>
      _$this._transactions ??=
          ListBuilder<PostLedgersByLedgerIdTransactionsRequest>();
  set transactions(
          ListBuilder<PostLedgersByLedgerIdTransactionsRequest>?
              transactions) =>
      _$this._transactions = transactions;

  PostLedgersByLedgerIdImportsRequestBuilder() {
    PostLedgersByLedgerIdImportsRequest._defaults(this);
  }

  PostLedgersByLedgerIdImportsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _categories = $v.categories?.toBuilder();
      _transactions = $v.transactions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdImportsRequest other) {
    _$v = other as _$PostLedgersByLedgerIdImportsRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdImportsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdImportsRequest build() => _build();

  _$PostLedgersByLedgerIdImportsRequest _build() {
    _$PostLedgersByLedgerIdImportsRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdImportsRequest._(
            categories: _categories?.build(),
            transactions: _transactions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categories';
        _categories?.build();
        _$failedField = 'transactions';
        _transactions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(r'PostLedgersByLedgerIdImportsRequest',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
