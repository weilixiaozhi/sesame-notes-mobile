// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_imports200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdImports200Response
    extends PostLedgersByLedgerIdImports200Response {
  @override
  final int importedCategories;
  @override
  final int importedTransactions;

  factory _$PostLedgersByLedgerIdImports200Response(
          [void Function(PostLedgersByLedgerIdImports200ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdImports200ResponseBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdImports200Response._(
      {required this.importedCategories, required this.importedTransactions})
      : super._();
  @override
  PostLedgersByLedgerIdImports200Response rebuild(
          void Function(PostLedgersByLedgerIdImports200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdImports200ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdImports200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdImports200Response &&
        importedCategories == other.importedCategories &&
        importedTransactions == other.importedTransactions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, importedCategories.hashCode);
    _$hash = $jc(_$hash, importedTransactions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostLedgersByLedgerIdImports200Response')
          ..add('importedCategories', importedCategories)
          ..add('importedTransactions', importedTransactions))
        .toString();
  }
}

class PostLedgersByLedgerIdImports200ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdImports200Response,
            PostLedgersByLedgerIdImports200ResponseBuilder> {
  _$PostLedgersByLedgerIdImports200Response? _$v;

  int? _importedCategories;
  int? get importedCategories => _$this._importedCategories;
  set importedCategories(int? importedCategories) =>
      _$this._importedCategories = importedCategories;

  int? _importedTransactions;
  int? get importedTransactions => _$this._importedTransactions;
  set importedTransactions(int? importedTransactions) =>
      _$this._importedTransactions = importedTransactions;

  PostLedgersByLedgerIdImports200ResponseBuilder() {
    PostLedgersByLedgerIdImports200Response._defaults(this);
  }

  PostLedgersByLedgerIdImports200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _importedCategories = $v.importedCategories;
      _importedTransactions = $v.importedTransactions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdImports200Response other) {
    _$v = other as _$PostLedgersByLedgerIdImports200Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdImports200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdImports200Response build() => _build();

  _$PostLedgersByLedgerIdImports200Response _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdImports200Response._(
          importedCategories: BuiltValueNullFieldError.checkNotNull(
              importedCategories,
              r'PostLedgersByLedgerIdImports200Response',
              'importedCategories'),
          importedTransactions: BuiltValueNullFieldError.checkNotNull(
              importedTransactions,
              r'PostLedgersByLedgerIdImports200Response',
              'importedTransactions'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
