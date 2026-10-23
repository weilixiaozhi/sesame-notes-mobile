// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_ledgers_by_ledger_id_transaction_stats200_response_by_category_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner
    extends GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner {
  @override
  final String? categoryId;
  @override
  final String? categoryName;
  @override
  final String nativeTotal;
  @override
  final int transactionCount;

  factory _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner(
          [void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder)?
              updates]) =>
      (GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder()
            ..update(updates))
          ._build();

  _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner._(
      {this.categoryId,
      this.categoryName,
      required this.nativeTotal,
      required this.transactionCount})
      : super._();
  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner rebuild(
          void Function(
                  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder
      toBuilder() =>
          GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner &&
        categoryId == other.categoryId &&
        categoryName == other.categoryName &&
        nativeTotal == other.nativeTotal &&
        transactionCount == other.transactionCount;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, categoryName.hashCode);
    _$hash = $jc(_$hash, nativeTotal.hashCode);
    _$hash = $jc(_$hash, transactionCount.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner')
          ..add('categoryId', categoryId)
          ..add('categoryName', categoryName)
          ..add('nativeTotal', nativeTotal)
          ..add('transactionCount', transactionCount))
        .toString();
  }
}

class GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder
    implements
        Builder<GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner,
            GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder> {
  _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner? _$v;

  String? _categoryId;
  String? get categoryId => _$this._categoryId;
  set categoryId(String? categoryId) => _$this._categoryId = categoryId;

  String? _categoryName;
  String? get categoryName => _$this._categoryName;
  set categoryName(String? categoryName) => _$this._categoryName = categoryName;

  String? _nativeTotal;
  String? get nativeTotal => _$this._nativeTotal;
  set nativeTotal(String? nativeTotal) => _$this._nativeTotal = nativeTotal;

  int? _transactionCount;
  int? get transactionCount => _$this._transactionCount;
  set transactionCount(int? transactionCount) =>
      _$this._transactionCount = transactionCount;

  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder() {
    GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner._defaults(
        this);
  }

  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _categoryId = $v.categoryId;
      _categoryName = $v.categoryName;
      _nativeTotal = $v.nativeTotal;
      _transactionCount = $v.transactionCount;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner other) {
    _$v = other
        as _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner;
  }

  @override
  void update(
      void Function(
              GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner build() =>
      _build();

  _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner _build() {
    final _$result = _$v ??
        _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner._(
          categoryId: categoryId,
          categoryName: categoryName,
          nativeTotal: BuiltValueNullFieldError.checkNotNull(
              nativeTotal,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner',
              'nativeTotal'),
          transactionCount: BuiltValueNullFieldError.checkNotNull(
              transactionCount,
              r'GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner',
              'transactionCount'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
