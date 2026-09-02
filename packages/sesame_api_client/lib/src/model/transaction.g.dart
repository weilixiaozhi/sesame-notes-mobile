// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const TransactionTxTypeEnum _$transactionTxTypeEnum_expense =
    const TransactionTxTypeEnum._('expense');
const TransactionTxTypeEnum _$transactionTxTypeEnum_income =
    const TransactionTxTypeEnum._('income');
const TransactionTxTypeEnum _$transactionTxTypeEnum_transfer =
    const TransactionTxTypeEnum._('transfer');

TransactionTxTypeEnum _$transactionTxTypeEnumValueOf(String name) {
  switch (name) {
    case 'expense':
      return _$transactionTxTypeEnum_expense;
    case 'income':
      return _$transactionTxTypeEnum_income;
    case 'transfer':
      return _$transactionTxTypeEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TransactionTxTypeEnum> _$transactionTxTypeEnumValues =
    BuiltSet<TransactionTxTypeEnum>(const <TransactionTxTypeEnum>[
  _$transactionTxTypeEnum_expense,
  _$transactionTxTypeEnum_income,
  _$transactionTxTypeEnum_transfer,
]);

const TransactionCategoryKindEnum _$transactionCategoryKindEnum_expense =
    const TransactionCategoryKindEnum._('expense');
const TransactionCategoryKindEnum _$transactionCategoryKindEnum_income =
    const TransactionCategoryKindEnum._('income');
const TransactionCategoryKindEnum _$transactionCategoryKindEnum_transfer =
    const TransactionCategoryKindEnum._('transfer');

TransactionCategoryKindEnum _$transactionCategoryKindEnumValueOf(String name) {
  switch (name) {
    case 'expense':
      return _$transactionCategoryKindEnum_expense;
    case 'income':
      return _$transactionCategoryKindEnum_income;
    case 'transfer':
      return _$transactionCategoryKindEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TransactionCategoryKindEnum>
    _$transactionCategoryKindEnumValues =
    BuiltSet<TransactionCategoryKindEnum>(const <TransactionCategoryKindEnum>[
  _$transactionCategoryKindEnum_expense,
  _$transactionCategoryKindEnum_income,
  _$transactionCategoryKindEnum_transfer,
]);

const TransactionAaModeEnum _$transactionAaModeEnum_n0 =
    const TransactionAaModeEnum._('n0');
const TransactionAaModeEnum _$transactionAaModeEnum_n1 =
    const TransactionAaModeEnum._('n1');
const TransactionAaModeEnum _$transactionAaModeEnum_n2 =
    const TransactionAaModeEnum._('n2');

TransactionAaModeEnum _$transactionAaModeEnumValueOf(String name) {
  switch (name) {
    case 'n0':
      return _$transactionAaModeEnum_n0;
    case 'n1':
      return _$transactionAaModeEnum_n1;
    case 'n2':
      return _$transactionAaModeEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<TransactionAaModeEnum> _$transactionAaModeEnumValues =
    BuiltSet<TransactionAaModeEnum>(const <TransactionAaModeEnum>[
  _$transactionAaModeEnum_n0,
  _$transactionAaModeEnum_n1,
  _$transactionAaModeEnum_n2,
]);

Serializer<TransactionTxTypeEnum> _$transactionTxTypeEnumSerializer =
    _$TransactionTxTypeEnumSerializer();
Serializer<TransactionCategoryKindEnum>
    _$transactionCategoryKindEnumSerializer =
    _$TransactionCategoryKindEnumSerializer();
Serializer<TransactionAaModeEnum> _$transactionAaModeEnumSerializer =
    _$TransactionAaModeEnumSerializer();

class _$TransactionTxTypeEnumSerializer
    implements PrimitiveSerializer<TransactionTxTypeEnum> {
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
  final Iterable<Type> types = const <Type>[TransactionTxTypeEnum];
  @override
  final String wireName = 'TransactionTxTypeEnum';

  @override
  Object serialize(Serializers serializers, TransactionTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TransactionTxTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TransactionTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TransactionCategoryKindEnumSerializer
    implements PrimitiveSerializer<TransactionCategoryKindEnum> {
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
  final Iterable<Type> types = const <Type>[TransactionCategoryKindEnum];
  @override
  final String wireName = 'TransactionCategoryKindEnum';

  @override
  Object serialize(Serializers serializers, TransactionCategoryKindEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TransactionCategoryKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TransactionCategoryKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$TransactionAaModeEnumSerializer
    implements PrimitiveSerializer<TransactionAaModeEnum> {
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
  final Iterable<Type> types = const <Type>[TransactionAaModeEnum];
  @override
  final String wireName = 'TransactionAaModeEnum';

  @override
  Object serialize(Serializers serializers, TransactionAaModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  TransactionAaModeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      TransactionAaModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Transaction extends Transaction {
  @override
  final String id;
  @override
  final String ledgerId;
  @override
  final TransactionTxTypeEnum txType;
  @override
  final String amount;
  @override
  final DateTime happenedAt;
  @override
  final String? note;
  @override
  final String? categoryId;
  @override
  final String? categoryName;
  @override
  final TransactionCategoryKindEnum? categoryKind;
  @override
  final bool excludeFromStats;
  @override
  final String currencyCode;
  @override
  final String nativeAmount;
  @override
  final String? recurringId;
  @override
  final String? createdByMemberId;
  @override
  final String? lastEditedByMemberId;
  @override
  final String? payerMemberId;
  @override
  final TransactionAaModeEnum? aaMode;
  @override
  final BuiltList<TransactionSplit> splits;
  @override
  final int revision;
  @override
  final DateTime? lastEditedAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime createdAt;

  factory _$Transaction([void Function(TransactionBuilder)? updates]) =>
      (TransactionBuilder()..update(updates))._build();

  _$Transaction._(
      {required this.id,
      required this.ledgerId,
      required this.txType,
      required this.amount,
      required this.happenedAt,
      this.note,
      this.categoryId,
      this.categoryName,
      this.categoryKind,
      required this.excludeFromStats,
      required this.currencyCode,
      required this.nativeAmount,
      this.recurringId,
      this.createdByMemberId,
      this.lastEditedByMemberId,
      this.payerMemberId,
      this.aaMode,
      required this.splits,
      required this.revision,
      this.lastEditedAt,
      required this.updatedAt,
      required this.createdAt})
      : super._();
  @override
  Transaction rebuild(void Function(TransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TransactionBuilder toBuilder() => TransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Transaction &&
        id == other.id &&
        ledgerId == other.ledgerId &&
        txType == other.txType &&
        amount == other.amount &&
        happenedAt == other.happenedAt &&
        note == other.note &&
        categoryId == other.categoryId &&
        categoryName == other.categoryName &&
        categoryKind == other.categoryKind &&
        excludeFromStats == other.excludeFromStats &&
        currencyCode == other.currencyCode &&
        nativeAmount == other.nativeAmount &&
        recurringId == other.recurringId &&
        createdByMemberId == other.createdByMemberId &&
        lastEditedByMemberId == other.lastEditedByMemberId &&
        payerMemberId == other.payerMemberId &&
        aaMode == other.aaMode &&
        splits == other.splits &&
        revision == other.revision &&
        lastEditedAt == other.lastEditedAt &&
        updatedAt == other.updatedAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, txType.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, happenedAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, categoryName.hashCode);
    _$hash = $jc(_$hash, categoryKind.hashCode);
    _$hash = $jc(_$hash, excludeFromStats.hashCode);
    _$hash = $jc(_$hash, currencyCode.hashCode);
    _$hash = $jc(_$hash, nativeAmount.hashCode);
    _$hash = $jc(_$hash, recurringId.hashCode);
    _$hash = $jc(_$hash, createdByMemberId.hashCode);
    _$hash = $jc(_$hash, lastEditedByMemberId.hashCode);
    _$hash = $jc(_$hash, payerMemberId.hashCode);
    _$hash = $jc(_$hash, aaMode.hashCode);
    _$hash = $jc(_$hash, splits.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, lastEditedAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Transaction')
          ..add('id', id)
          ..add('ledgerId', ledgerId)
          ..add('txType', txType)
          ..add('amount', amount)
          ..add('happenedAt', happenedAt)
          ..add('note', note)
          ..add('categoryId', categoryId)
          ..add('categoryName', categoryName)
          ..add('categoryKind', categoryKind)
          ..add('excludeFromStats', excludeFromStats)
          ..add('currencyCode', currencyCode)
          ..add('nativeAmount', nativeAmount)
          ..add('recurringId', recurringId)
          ..add('createdByMemberId', createdByMemberId)
          ..add('lastEditedByMemberId', lastEditedByMemberId)
          ..add('payerMemberId', payerMemberId)
          ..add('aaMode', aaMode)
          ..add('splits', splits)
          ..add('revision', revision)
          ..add('lastEditedAt', lastEditedAt)
          ..add('updatedAt', updatedAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class TransactionBuilder implements Builder<Transaction, TransactionBuilder> {
  _$Transaction? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  TransactionTxTypeEnum? _txType;
  TransactionTxTypeEnum? get txType => _$this._txType;
  set txType(TransactionTxTypeEnum? txType) => _$this._txType = txType;

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

  String? _categoryName;
  String? get categoryName => _$this._categoryName;
  set categoryName(String? categoryName) => _$this._categoryName = categoryName;

  TransactionCategoryKindEnum? _categoryKind;
  TransactionCategoryKindEnum? get categoryKind => _$this._categoryKind;
  set categoryKind(TransactionCategoryKindEnum? categoryKind) =>
      _$this._categoryKind = categoryKind;

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

  String? _createdByMemberId;
  String? get createdByMemberId => _$this._createdByMemberId;
  set createdByMemberId(String? createdByMemberId) =>
      _$this._createdByMemberId = createdByMemberId;

  String? _lastEditedByMemberId;
  String? get lastEditedByMemberId => _$this._lastEditedByMemberId;
  set lastEditedByMemberId(String? lastEditedByMemberId) =>
      _$this._lastEditedByMemberId = lastEditedByMemberId;

  String? _payerMemberId;
  String? get payerMemberId => _$this._payerMemberId;
  set payerMemberId(String? payerMemberId) =>
      _$this._payerMemberId = payerMemberId;

  TransactionAaModeEnum? _aaMode;
  TransactionAaModeEnum? get aaMode => _$this._aaMode;
  set aaMode(TransactionAaModeEnum? aaMode) => _$this._aaMode = aaMode;

  ListBuilder<TransactionSplit>? _splits;
  ListBuilder<TransactionSplit> get splits =>
      _$this._splits ??= ListBuilder<TransactionSplit>();
  set splits(ListBuilder<TransactionSplit>? splits) => _$this._splits = splits;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  DateTime? _lastEditedAt;
  DateTime? get lastEditedAt => _$this._lastEditedAt;
  set lastEditedAt(DateTime? lastEditedAt) =>
      _$this._lastEditedAt = lastEditedAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  TransactionBuilder() {
    Transaction._defaults(this);
  }

  TransactionBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ledgerId = $v.ledgerId;
      _txType = $v.txType;
      _amount = $v.amount;
      _happenedAt = $v.happenedAt;
      _note = $v.note;
      _categoryId = $v.categoryId;
      _categoryName = $v.categoryName;
      _categoryKind = $v.categoryKind;
      _excludeFromStats = $v.excludeFromStats;
      _currencyCode = $v.currencyCode;
      _nativeAmount = $v.nativeAmount;
      _recurringId = $v.recurringId;
      _createdByMemberId = $v.createdByMemberId;
      _lastEditedByMemberId = $v.lastEditedByMemberId;
      _payerMemberId = $v.payerMemberId;
      _aaMode = $v.aaMode;
      _splits = $v.splits.toBuilder();
      _revision = $v.revision;
      _lastEditedAt = $v.lastEditedAt;
      _updatedAt = $v.updatedAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Transaction other) {
    _$v = other as _$Transaction;
  }

  @override
  void update(void Function(TransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Transaction build() => _build();

  _$Transaction _build() {
    _$Transaction _$result;
    try {
      _$result = _$v ??
          _$Transaction._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Transaction', 'id'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(
                ledgerId, r'Transaction', 'ledgerId'),
            txType: BuiltValueNullFieldError.checkNotNull(
                txType, r'Transaction', 'txType'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount, r'Transaction', 'amount'),
            happenedAt: BuiltValueNullFieldError.checkNotNull(
                happenedAt, r'Transaction', 'happenedAt'),
            note: note,
            categoryId: categoryId,
            categoryName: categoryName,
            categoryKind: categoryKind,
            excludeFromStats: BuiltValueNullFieldError.checkNotNull(
                excludeFromStats, r'Transaction', 'excludeFromStats'),
            currencyCode: BuiltValueNullFieldError.checkNotNull(
                currencyCode, r'Transaction', 'currencyCode'),
            nativeAmount: BuiltValueNullFieldError.checkNotNull(
                nativeAmount, r'Transaction', 'nativeAmount'),
            recurringId: recurringId,
            createdByMemberId: createdByMemberId,
            lastEditedByMemberId: lastEditedByMemberId,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: splits.build(),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'Transaction', 'revision'),
            lastEditedAt: lastEditedAt,
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'Transaction', 'updatedAt'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'Transaction', 'createdAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splits';
        splits.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Transaction', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
