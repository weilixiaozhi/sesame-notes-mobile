// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_imports201_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostLedgersByLedgerIdImports201Response
    extends PostLedgersByLedgerIdImports201Response {
  @override
  final int importedCategories;
  @override
  final int importedTransactions;

  factory _$PostLedgersByLedgerIdImports201Response(
          [void Function(PostLedgersByLedgerIdImports201ResponseBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdImports201ResponseBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdImports201Response._(
      {required this.importedCategories, required this.importedTransactions})
      : super._();
  @override
  PostLedgersByLedgerIdImports201Response rebuild(
          void Function(PostLedgersByLedgerIdImports201ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdImports201ResponseBuilder toBuilder() =>
      PostLedgersByLedgerIdImports201ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdImports201Response &&
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
            r'PostLedgersByLedgerIdImports201Response')
          ..add('importedCategories', importedCategories)
          ..add('importedTransactions', importedTransactions))
        .toString();
  }
}

class PostLedgersByLedgerIdImports201ResponseBuilder
    implements
        Builder<PostLedgersByLedgerIdImports201Response,
            PostLedgersByLedgerIdImports201ResponseBuilder> {
  _$PostLedgersByLedgerIdImports201Response? _$v;

  int? _importedCategories;
  int? get importedCategories => _$this._importedCategories;
  set importedCategories(int? importedCategories) =>
      _$this._importedCategories = importedCategories;

  int? _importedTransactions;
  int? get importedTransactions => _$this._importedTransactions;
  set importedTransactions(int? importedTransactions) =>
      _$this._importedTransactions = importedTransactions;

  PostLedgersByLedgerIdImports201ResponseBuilder() {
    PostLedgersByLedgerIdImports201Response._defaults(this);
  }

  PostLedgersByLedgerIdImports201ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _importedCategories = $v.importedCategories;
      _importedTransactions = $v.importedTransactions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostLedgersByLedgerIdImports201Response other) {
    _$v = other as _$PostLedgersByLedgerIdImports201Response;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdImports201ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdImports201Response build() => _build();

  _$PostLedgersByLedgerIdImports201Response _build() {
    final _$result = _$v ??
        _$PostLedgersByLedgerIdImports201Response._(
          importedCategories: BuiltValueNullFieldError.checkNotNull(
              importedCategories,
              r'PostLedgersByLedgerIdImports201Response',
              'importedCategories'),
          importedTransactions: BuiltValueNullFieldError.checkNotNull(
              importedTransactions,
              r'PostLedgersByLedgerIdImports201Response',
              'importedTransactions'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
