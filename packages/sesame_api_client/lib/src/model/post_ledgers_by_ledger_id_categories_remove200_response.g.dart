// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_categories_remove200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdCategoriesRemove200Response
    extends PostLedgersByLedgerIdCategoriesRemove200Response {
  @override
  final int removedCategories;
  @override
  final int promotedCategories;
  @override
  final int affectedTransactions;
  @override
  final int affectedRecurringRules;

  factory _$PostLedgersByLedgerIdCategoriesRemove200Response(
          [void Function(
                  PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder()
            ..update(updates))
          ._build();

  _$PostLedgersByLedgerIdCategoriesRemove200Response._(
      {required this.removedCategories,
      required this.promotedCategories,
      required this.affectedTransactions,
      required this.affectedRecurringRules})
      : super._();
  @override
  PostLedgersByLedgerIdCategoriesRemove200Response rebuild(
          void Function(PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdCategoriesRemove200Response &&
        removedCategories == other.removedCategories &&
        promotedCategories == other.promotedCategories &&
        affectedTransactions == other.affectedTransactions &&
        affectedRecurringRules == other.affectedRecurringRules;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, removedCategories.hashCode);
    _$hash = $jc(_$hash, promotedCategories.hashCode);
    _$hash = $jc(_$hash, affectedTransactions.hashCode);
    _$hash = $jc(_$hash, affectedRecurringRules.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdCategoriesRemove200Response')
          ..add('removedCategories', removedCategories)
          ..add('promotedCategories', promotedCategories)
          ..add('affectedTransactions', affectedTransactions)
          ..add('affectedRecurringRules', affectedRecurringRules))
        .toString();
  }
}

class PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdCategoriesRemove200Response,
            PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder> {
  _$PostLedgersByLedgerIdCategoriesRemove200Response? _$v;

  int? _removedCategories;
  int? get removedCategories => _$this._removedCategories;
  set removedCategories(int? removedCategories) =>
      _$this._removedCategories = removedCategories;

  int? _promotedCategories;
  int? get promotedCategories => _$this._promotedCategories;
  set promotedCategories(int? promotedCategories) =>
      _$this._promotedCategories = promotedCategories;

  int? _affectedTransactions;
  int? get affectedTransactions => _$this._affectedTransactions;
  set affectedTransactions(int? affectedTransactions) =>
      _$this._affectedTransactions = affectedTransactions;

  int? _affectedRecurringRules;
  int? get affectedRecurringRules => _$this._affectedRecurringRules;
  set affectedRecurringRules(int? affectedRecurringRules) =>
      _$this._affectedRecurringRules = affectedRecurringRules;

  PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder() {
    PostLedgersByLedgerIdCategoriesRemove200Response._defaults(this);
  }

  PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _removedCategories = $v.removedCategories;
      _promotedCategories = $v.promotedCategories;
      _affectedTransactions = $v.affectedTransactions;
      _affectedRecurringRules = $v.affectedRecurringRules;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdCategoriesRemove200Response other) {
    _$v = other as _$PostLedgersByLedgerIdCategoriesRemove200Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdCategoriesRemove200Response build() => _build();

  _$PostLedgersByLedgerIdCategoriesRemove200Response _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdCategoriesRemove200Response._(
          removedCategories: BuiltValueNullFieldError.checkNotNull(
              removedCategories,
              r'PostLedgersByLedgerIdCategoriesRemove200Response',
              'removedCategories'),
          promotedCategories: BuiltValueNullFieldError.checkNotNull(
              promotedCategories,
              r'PostLedgersByLedgerIdCategoriesRemove200Response',
              'promotedCategories'),
          affectedTransactions: BuiltValueNullFieldError.checkNotNull(
              affectedTransactions,
              r'PostLedgersByLedgerIdCategoriesRemove200Response',
              'affectedTransactions'),
          affectedRecurringRules: BuiltValueNullFieldError.checkNotNull(
              affectedRecurringRules,
              r'PostLedgersByLedgerIdCategoriesRemove200Response',
              'affectedRecurringRules'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
