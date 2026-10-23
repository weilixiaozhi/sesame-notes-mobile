// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_removal_preview200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response
    extends PostLedgersByLedgerIdCategoriesRemovalPreview200Response {
  @override
  final String previewToken;
  @override
  final BuiltList<Category> categories;
  @override
  final int transactionCount;
  @override
  final int recurringCount;

  factory _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response(
          [void Function(
                  PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response._(
      {required this.previewToken,
      required this.categories,
      required this.transactionCount,
      required this.recurringCount})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesRemovalPreview200Response rebuild(
          void Function(
                  PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesRemovalPreview200Response &&
        previewToken == other.previewToken &&
        categories == other.categories &&
        transactionCount == other.transactionCount &&
        recurringCount == other.recurringCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, previewToken.hashCode);
    _$hash = $jc(_$hash, categories.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jc(_$hash, recurringCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesRemovalPreview200Response')
          ..add('previewToken', previewToken)
          ..add('categories', categories)
          ..add('transactionCount', transactionCount)
          ..add('recurringCount', recurringCount))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesRemovalPreview200Response,
            PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder> {
  _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response? _$v;

  String? _previewToken;
  String? get previewToken => _$this._previewToken;
  set previewToken(String? previewToken) => _$this._previewToken = previewToken;

  ListBuilder<Category>? _categories;
  ListBuilder<Category> get categories =>
      _$this._categories ??= ListBuilder<Category>();
  set categories(ListBuilder<Category>? categories) =>
      _$this._categories = categories;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  int? _recurringCount;
  int? get recurringCount => _$this._recurringCount;
  set recurringCount(int? recurringCount) =>
      _$this._recurringCount = recurringCount;

  PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder() {
    PostLedgersByLedgerIdCategoriesRemovalPreview200Response._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _previewToken = $v.previewToken;
      _categories = $v.categories.toBuilder();
      _transactionCount = $v.transactionCount;
      _recurringCount = $v.recurringCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesRemovalPreview200Response other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesRemovalPreview200Response build() => _build();

  _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response _build() {
    _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response._(
            previewToken: BuiltValueNullFieldError.checkNotNull(
                previewToken,
                r'PostLedgersByLedgerIdCategoriesRemovalPreview200Response',
                'previewToken'),
            categories: categories.build(),
            transactionCount: BuiltValueNullFieldError.checkNotNull(
                transactionCount,
                r'PostLedgersByLedgerIdCategoriesRemovalPreview200Response',
                'transactionCount'),
            recurringCount: BuiltValueNullFieldError.checkNotNull(
                recurringCount,
                r'PostLedgersByLedgerIdCategoriesRemovalPreview200Response',
                'recurringCount'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categories';
        categories.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdCategoriesRemovalPreview200Response',
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
