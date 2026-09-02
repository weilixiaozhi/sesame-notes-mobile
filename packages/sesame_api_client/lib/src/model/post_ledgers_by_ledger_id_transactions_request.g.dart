// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_ledgers_by_ledger_id_transactions_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum
    _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_expense =
    const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum._('expense');
const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum
    _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_income =
    const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum._('income');
const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum
    _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_transfer =
    const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum._('transfer');

PostLedgersByLedgerIdTransactionsRequestTxTypeEnum
    _$postLedgersByLedgerIdTransactionsRequestTxTypeEnumValueOf(String name) {
  switch (name) {
    case 'expense':
      return _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_expense;
    case 'income':
      return _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_income;
    case 'transfer':
      return _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdTransactionsRequestTxTypeEnum>
    _$postLedgersByLedgerIdTransactionsRequestTxTypeEnumValues = BuiltSet<
        PostLedgersByLedgerIdTransactionsRequestTxTypeEnum>(const <PostLedgersByLedgerIdTransactionsRequestTxTypeEnum>[
  _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_expense,
  _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_income,
  _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_transfer,
]);

const PostLedgersByLedgerIdTransactionsRequestAaModeEnum
    _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n0 =
    const PostLedgersByLedgerIdTransactionsRequestAaModeEnum._('n0');
const PostLedgersByLedgerIdTransactionsRequestAaModeEnum
    _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n1 =
    const PostLedgersByLedgerIdTransactionsRequestAaModeEnum._('n1');
const PostLedgersByLedgerIdTransactionsRequestAaModeEnum
    _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n2 =
    const PostLedgersByLedgerIdTransactionsRequestAaModeEnum._('n2');

PostLedgersByLedgerIdTransactionsRequestAaModeEnum
    _$postLedgersByLedgerIdTransactionsRequestAaModeEnumValueOf(String name) {
  switch (name) {
    case 'n0':
      return _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n0;
    case 'n1':
      return _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n1;
    case 'n2':
      return _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostLedgersByLedgerIdTransactionsRequestAaModeEnum>
    _$postLedgersByLedgerIdTransactionsRequestAaModeEnumValues = BuiltSet<
        PostLedgersByLedgerIdTransactionsRequestAaModeEnum>(const <PostLedgersByLedgerIdTransactionsRequestAaModeEnum>[
  _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n0,
  _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n1,
  _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n2,
]);

Serializer<PostLedgersByLedgerIdTransactionsRequestTxTypeEnum>
    _$postLedgersByLedgerIdTransactionsRequestTxTypeEnumSerializer =
    _$PostLedgersByLedgerIdTransactionsRequestTxTypeEnumSerializer();
Serializer<PostLedgersByLedgerIdTransactionsRequestAaModeEnum>
    _$postLedgersByLedgerIdTransactionsRequestAaModeEnumSerializer =
    _$PostLedgersByLedgerIdTransactionsRequestAaModeEnumSerializer();

class _$PostLedgersByLedgerIdTransactionsRequestTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdTransactionsRequestTxTypeEnum> {
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
    PostLedgersByLedgerIdTransactionsRequestTxTypeEnum
  ];
  @override
  final String wireName = 'PostLedgersByLedgerIdTransactionsRequestTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdTransactionsRequestTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdTransactionsRequestTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdTransactionsRequestTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdTransactionsRequestAaModeEnumSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdTransactionsRequestAaModeEnum> {
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
    PostLedgersByLedgerIdTransactionsRequestAaModeEnum
  ];
  @override
  final String wireName = 'PostLedgersByLedgerIdTransactionsRequestAaModeEnum';

  @override
  Object serialize(Serializers serializers,
          PostLedgersByLedgerIdTransactionsRequestAaModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostLedgersByLedgerIdTransactionsRequestAaModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostLedgersByLedgerIdTransactionsRequestAaModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostLedgersByLedgerIdTransactionsRequest
    extends PostLedgersByLedgerIdTransactionsRequest {
  @override
  final String? id;
  @override
  final PostLedgersByLedgerIdTransactionsRequestTxTypeEnum txType;
  @override
  final String amount;
  @override
  final DateTime happenedAt;
  @override
  final String? note;
  @override
  final String? categoryId;
  @override
  final bool? excludeFromStats;
  @override
  final String currencyCode;
  @override
  final String nativeAmount;
  @override
  final String? recurringId;
  @override
  final String? payerMemberId;
  @override
  final PostLedgersByLedgerIdTransactionsRequestAaModeEnum? aaMode;
  @override
  final BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? splits;
  @override
  final int? baseRevision;

  factory _$PostLedgersByLedgerIdTransactionsRequest(
          [void Function(PostLedgersByLedgerIdTransactionsRequestBuilder)?
              updates]) =>
      (PostLedgersByLedgerIdTransactionsRequestBuilder()..update(updates))
          ._build();

  _$PostLedgersByLedgerIdTransactionsRequest._(
      {this.id,
      required this.txType,
      required this.amount,
      required this.happenedAt,
      this.note,
      this.categoryId,
      this.excludeFromStats,
      required this.currencyCode,
      required this.nativeAmount,
      this.recurringId,
      this.payerMemberId,
      this.aaMode,
      this.splits,
      this.baseRevision})
      : super._();
  @override
  PostLedgersByLedgerIdTransactionsRequest rebuild(
          void Function(PostLedgersByLedgerIdTransactionsRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostLedgersByLedgerIdTransactionsRequestBuilder toBuilder() =>
      PostLedgersByLedgerIdTransactionsRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostLedgersByLedgerIdTransactionsRequest &&
        id == other.id &&
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
    _$hash = $jc(_$hash, id.hashCode);
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
            r'PostLedgersByLedgerIdTransactionsRequest')
          ..add('id', id)
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

class PostLedgersByLedgerIdTransactionsRequestBuilder
    implements
        Builder<PostLedgersByLedgerIdTransactionsRequest,
            PostLedgersByLedgerIdTransactionsRequestBuilder> {
  _$PostLedgersByLedgerIdTransactionsRequest? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  PostLedgersByLedgerIdTransactionsRequestTxTypeEnum? _txType;
  PostLedgersByLedgerIdTransactionsRequestTxTypeEnum? get txType =>
      _$this._txType;
  set txType(PostLedgersByLedgerIdTransactionsRequestTxTypeEnum? txType) =>
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

  PostLedgersByLedgerIdTransactionsRequestAaModeEnum? _aaMode;
  PostLedgersByLedgerIdTransactionsRequestAaModeEnum? get aaMode =>
      _$this._aaMode;
  set aaMode(PostLedgersByLedgerIdTransactionsRequestAaModeEnum? aaMode) =>
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

  PostLedgersByLedgerIdTransactionsRequestBuilder() {
    PostLedgersByLedgerIdTransactionsRequest._defaults(this);
  }

  PostLedgersByLedgerIdTransactionsRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
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
  void replace(PostLedgersByLedgerIdTransactionsRequest other) {
    _$v = other as _$PostLedgersByLedgerIdTransactionsRequest;
  }

  @override
  void update(
      void Function(PostLedgersByLedgerIdTransactionsRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostLedgersByLedgerIdTransactionsRequest build() => _build();

  _$PostLedgersByLedgerIdTransactionsRequest _build() {
    _$PostLedgersByLedgerIdTransactionsRequest _$result;
    try {
      _$result = _$v ??
          _$PostLedgersByLedgerIdTransactionsRequest._(
            id: id,
            txType: BuiltValueNullFieldError.checkNotNull(
                txType, r'PostLedgersByLedgerIdTransactionsRequest', 'txType'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'PostLedgersByLedgerIdTransactionsRequest', 'amount'),
            happenedAt: BuiltValueNullFieldError.checkNotNull(happenedAt,
                r'PostLedgersByLedgerIdTransactionsRequest', 'happenedAt'),
            note: note,
            categoryId: categoryId,
            excludeFromStats: excludeFromStats,
            currencyCode: BuiltValueNullFieldError.checkNotNull(currencyCode,
                r'PostLedgersByLedgerIdTransactionsRequest', 'currencyCode'),
            nativeAmount: BuiltValueNullFieldError.checkNotNull(nativeAmount,
                r'PostLedgersByLedgerIdTransactionsRequest', 'nativeAmount'),
            recurringId: recurringId,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: _splits?.build(),
            baseRevision: baseRevision,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splits';
        _splits?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostLedgersByLedgerIdTransactionsRequest',
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
