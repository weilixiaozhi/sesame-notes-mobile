// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_removal_preview_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest
    extends PostLedgersByLedgerIdCategoriesRemovalPreviewRequest {
  @override
  final BuiltSet<String> categoryIds;

  factory _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest(
          [void Function(
                  PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest._(
      {required this.categoryIds})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesRemovalPreviewRequest rebuild(
          void Function(
                  PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesRemovalPreviewRequest &&
        categoryIds == other.categoryIds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, categoryIds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesRemovalPreviewRequest')
          ..add('categoryIds', categoryIds))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesRemovalPreviewRequest,
            PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder> {
  _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest? _$v;

  SetBuilder<String>? _categoryIds;
  SetBuilder<String> get categoryIds =>
      _$this._categoryIds ??= SetBuilder<String>();
  set categoryIds(SetBuilder<String>? categoryIds) =>
      _$this._categoryIds = categoryIds;

  PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder() {
    PostLedgersByLedgerIdCategoriesRemovalPreviewRequest._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _categoryIds = $v.categoryIds.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesRemovalPreviewRequest other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest;
  }

  @override
  void update(
      void Function(
              PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesRemovalPreviewRequest build() => _build();

  _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest _build() {
    _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest._(
            categoryIds: categoryIds.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'categoryIds';
        categoryIds.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdCategoriesRemovalPreviewRequest',
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
