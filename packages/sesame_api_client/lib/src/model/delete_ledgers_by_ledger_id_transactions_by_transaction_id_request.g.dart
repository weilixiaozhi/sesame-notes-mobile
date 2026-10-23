// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_ledgers_by_ledger_id_transactions_by_transaction_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest
    extends DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest {
  @override
  final int baseRevision;

  factory _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest(
          [void Function(
                  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder)?
              updates]) =>
      (DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder()
            ..update(updates))
          ._build();

  _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest._(
      {required this.baseRevision})
      : super._();
  @override
  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest rebuild(
          void Function(
                  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
      toBuilder() =>
          DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest &&
        baseRevision == other.baseRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest')
          ..add('baseRevision', baseRevision))
        .toString();
  }
}

class DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
    implements
        Builder<DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest,
            DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder> {
  _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest? _$v;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder() {
    DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest._defaults(this);
  }

  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _baseRevision = $v.baseRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest other) {
    _$v = other as _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest;
  }

  @override
  void update(
      void Function(
              DeleteLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest build() => _build();

  _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest _build() {
    final _$result = _$v ??
        _$DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest._(
          baseRevision: BuiltValueNullFieldError.checkNotNull(
              baseRevision,
              r'DeleteLedgersByLedgerIdTransactionsByTransactionIdRequest',
              'baseRevision'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
