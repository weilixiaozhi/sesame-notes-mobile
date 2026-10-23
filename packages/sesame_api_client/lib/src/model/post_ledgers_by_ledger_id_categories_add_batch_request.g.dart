// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_add_batch_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesAddBatchRequest
    extends PostLedgersByLedgerIdCategoriesAddBatchRequest {
  @override
  final AnyOf anyOf;

  factory _$PostLedgersByLedgerIdCategoriesAddBatchRequest(
          [void Function(PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequest._({required this.anyOf})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequest rebuild(
          void Function(PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesAddBatchRequest &&
        anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesAddBatchRequest')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesAddBatchRequest,
            PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder> {
  _$PostLedgersByLedgerIdCategoriesAddBatchRequest? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder() {
    PostLedgersByLedgerIdCategoriesAddBatchRequest._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesAddBatchRequest other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesAddBatchRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequest build() => _build();

  _$PostLedgersByLedgerIdCategoriesAddBatchRequest _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdCategoriesAddBatchRequest._(
          anyOf: BuiltValueNullFieldError.checkNotNull(anyOf,
              r'PostLedgersByLedgerIdCategoriesAddBatchRequest', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
