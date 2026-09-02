// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_ledgers_by_ledger_id_transactions_by_transaction_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_expense =
    const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum._(
        'expense');
const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_income =
    const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum._(
        'income');
const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_transfer =
    const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum._(
        'transfer');

PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_expense;
    case 'income':
      return _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_income;
    case 'transfer':
      return _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum>
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumValues =
    BuiltSet<
        PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum>(const <PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum>[
  _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_expense,
  _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_income,
  _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_transfer,
]);

const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n0 =
    const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum._(
        'n0');
const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n1 =
    const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum._(
        'n1');
const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n2 =
    const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum._(
        'n2');

PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumValueOf(
        String name) {
  switch (name) {
    case 'n0':
      return _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n0;
    case 'n1':
      return _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n1;
    case 'n2':
      return _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum>
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumValues =
    BuiltSet<
        PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum>(const <PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum>[
  _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n0,
  _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n1,
  _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n2,
]);

Serializer<PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum>
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumSerializer =
    _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumSerializer();
Serializer<PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum>
    _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumSerializer =
    _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumSerializer();

class _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
    'income': 'income',
    'transfer': 'transfer',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
    'income': 'income',
    'transfer': 'transfer',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
  ];
  @override
  final String wireName =
      'PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumSerializer
    implements
        PrimitiveSerializer<
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'n0': '0',
    'n1': '1',
    'n2': '2',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    '0': 'n0',
    '1': 'n1',
    '2': 'n2',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
  ];
  @override
  final String wireName =
      'PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum';

  @override
  Object serialize(
          Serializers serializers,
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest
    extends PatchLedgersByLedgerIdTransactionsByTransactionIdRequest {
  @override
  final PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum?
      txType;
  @override
  final String? amount;
  @override
  final DateTime? happenedAt;
  @override
  final String? note;
  @override
  final String? categoryId;
  @override
  final bool? excludeFromStats;
  @override
  final String? currencyCode;
  @override
  final String? nativeAmount;
  @override
  final String? recurringId;
  @override
  final String? payerMemberId;
  @override
  final PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum?
      aaMode;
  @override
  final BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? splits;
  @override
  final int baseRevision;

  factory _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest(
          [void Function(
                  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder)?
              updates]) =>
      (PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder()
            ..update(updates))
          ._build();

  _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest._(
      {this.txType,
      this.amount,
      this.happenedAt,
      this.note,
      this.categoryId,
      this.excludeFromStats,
      this.currencyCode,
      this.nativeAmount,
      this.recurringId,
      this.payerMemberId,
      this.aaMode,
      this.splits,
      required this.baseRevision})
      : super._();
  @override
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequest rebuild(
          void Function(
                  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder toBuilder() =>
      PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchLedgersByLedgerIdTransactionsByTransactionIdRequest &&
        txType == other.txType &&
        amount == other.amount &&
        happenedAt == other.happenedAt &&
        note == other.note &&
        categoryId == other.categoryId &&
        excludeFromStats == other.excludeFromStats &&
        currencyCode == other.currencyCode &&
        nativeAmount == other.nativeAmount &&
        recurringId == other.recurringId &&
        payerMemberId == other.payerMemberId &&
        aaMode == other.aaMode &&
        splits == other.splits &&
        baseRevision == other.baseRevision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, txType.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, happenedAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, excludeFromStats.hashCode);
    _$hash = $jc(_$hash, currencyCode.hashCode);
    _$hash = $jc(_$hash, nativeAmount.hashCode);
    _$hash = $jc(_$hash, recurringId.hashCode);
    _$hash = $jc(_$hash, payerMemberId.hashCode);
    _$hash = $jc(_$hash, aaMode.hashCode);
    _$hash = $jc(_$hash, splits.hashCode);
    _$hash = $jc(_$hash, baseRevision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PatchLedgersByLedgerIdTransactionsByTransactionIdRequest')
          ..add('txType', txType)
          ..add('amount', amount)
          ..add('happenedAt', happenedAt)
          ..add('note', note)
          ..add('categoryId', categoryId)
          ..add('excludeFromStats', excludeFromStats)
          ..add('currencyCode', currencyCode)
          ..add('nativeAmount', nativeAmount)
          ..add('recurringId', recurringId)
          ..add('payerMemberId', payerMemberId)
          ..add('aaMode', aaMode)
          ..add('splits', splits)
          ..add('baseRevision', baseRevision))
        .toString();
  }
}

class PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
    implements
        Builder<PatchLedgersByLedgerIdTransactionsByTransactionIdRequest,
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder> {
  _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest? _$v;

  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum? _txType;
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum?
      get txType => _$this._txType;
  set txType(
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum?
              txType) =>
      _$this._txType = txType;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  DateTime? _happenedAt;
  DateTime? get happenedAt => _$this._happenedAt;
  set happenedAt(DateTime? happenedAt) => _$this._happenedAt = happenedAt;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _categoryId;
  String? get categoryId => _$this._categoryId;
  set categoryId(String? categoryId) => _$this._categoryId = categoryId;

  bool? _excludeFromStats;
  bool? get excludeFromStats => _$this._excludeFromStats;
  set excludeFromStats(bool? excludeFromStats) =>
      _$this._excludeFromStats = excludeFromStats;

  String? _currencyCode;
  String? get currencyCode => _$this._currencyCode;
  set currencyCode(String? currencyCode) => _$this._currencyCode = currencyCode;

  String? _nativeAmount;
  String? get nativeAmount => _$this._nativeAmount;
  set nativeAmount(String? nativeAmount) => _$this._nativeAmount = nativeAmount;

  String? _recurringId;
  String? get recurringId => _$this._recurringId;
  set recurringId(String? recurringId) => _$this._recurringId = recurringId;

  String? _payerMemberId;
  String? get payerMemberId => _$this._payerMemberId;
  set payerMemberId(String? payerMemberId) =>
      _$this._payerMemberId = payerMemberId;

  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum? _aaMode;
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum?
      get aaMode => _$this._aaMode;
  set aaMode(
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum?
              aaMode) =>
      _$this._aaMode = aaMode;

  ListBuilder<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? _splits;
  ListBuilder<PostLedgersByLedgerIdTransactionsRequestSplitsInner> get splits =>
      _$this._splits ??=
          ListBuilder<PostLedgersByLedgerIdTransactionsRequestSplitsInner>();
  set splits(
          ListBuilder<PostLedgersByLedgerIdTransactionsRequestSplitsInner>?
              splits) =>
      _$this._splits = splits;

  int? _baseRevision;
  int? get baseRevision => _$this._baseRevision;
  set baseRevision(int? baseRevision) => _$this._baseRevision = baseRevision;

  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder() {
    PatchLedgersByLedgerIdTransactionsByTransactionIdRequest._defaults(this);
  }

  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _txType = $v.txType;
      _amount = $v.amount;
      _happenedAt = $v.happenedAt;
      _note = $v.note;
      _categoryId = $v.categoryId;
      _excludeFromStats = $v.excludeFromStats;
      _currencyCode = $v.currencyCode;
      _nativeAmount = $v.nativeAmount;
      _recurringId = $v.recurringId;
      _payerMemberId = $v.payerMemberId;
      _aaMode = $v.aaMode;
      _splits = $v.splits?.toBuilder();
      _baseRevision = $v.baseRevision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchLedgersByLedgerIdTransactionsByTransactionIdRequest other) {
    _$v = other as _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest;
  }

  @override
  void update(
      void Function(
              PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequest build() => _build();

  _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest _build() {
    _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest _$result;
    try {
      _$result = _$v ??
          _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest._(
            txType: txType,
            amount: amount,
            happenedAt: happenedAt,
            note: note,
            categoryId: categoryId,
            excludeFromStats: excludeFromStats,
            currencyCode: currencyCode,
            nativeAmount: nativeAmount,
            recurringId: recurringId,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: _splits?.build(),
            baseRevision: BuiltValueNullFieldError.checkNotNull(
                baseRevision,
                r'PatchLedgersByLedgerIdTransactionsByTransactionIdRequest',
                'baseRevision'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splits';
        _splits?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatchLedgersByLedgerIdTransactionsByTransactionIdRequest',
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
