// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_full200_response_recurring_state_occurrences_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum_expense =
    const GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum._(
        'expense');

GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum>
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumValues =
    BuiltSet<
        GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum>(const <GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum>[
  _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum_expense,
]);

const GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum_expense =
    const GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
        ._('expense');

GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum>
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumValues =
    BuiltSet<
        GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum>(const <GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum>[
  _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum_expense,
]);

const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n0 =
    const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum._(
        'n0');
const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n1 =
    const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum._(
        'n1');
const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n2 =
    const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum._(
        'n2');

GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumValueOf(
        String name) {
  switch (name) {
    case 'n0':
      return _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n0;
    case 'n1':
      return _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n1;
    case 'n2':
      return _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum>
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumValues =
    BuiltSet<
        GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum>(const <GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum>[
  _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n0,
  _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n1,
  _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n2,
]);

Serializer<GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum>
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumSerializer =
    _$GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumSerializer();
Serializer<GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum>
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumSerializer =
    _$GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumSerializer();
Serializer<GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum>
    _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumSerializer =
    _$GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumSerializer();

class _$GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum
  ];
  @override
  final String wireName =
      'GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumSerializer
    implements
        PrimitiveSerializer<
            GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
  ];
  @override
  final String wireName =
      'GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumSerializer
    implements
        PrimitiveSerializer<
            GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum> {
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
    GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
  ];
  @override
  final String wireName =
      'GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncFull200ResponseRecurringStateOccurrencesInner
    extends GetSyncFull200ResponseRecurringStateOccurrencesInner {
  @override
  final String id;
  @override
  final String ledgerId;
  @override
  final GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum txType;
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
  final GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum?
      categoryKind;
  @override
  final String currencyCode;
  @override
  final String nativeAmount;
  @override
  final String? recurringId;
  @override
  final Date? occurrenceDate;
  @override
  final String? createdByMemberId;
  @override
  final String? lastEditedByMemberId;
  @override
  final String? payerMemberId;
  @override
  final GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum? aaMode;
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
  @override
  final DateTime? deletedAt;

  factory _$GetSyncFull200ResponseRecurringStateOccurrencesInner(
          [void Function(
                  GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder)?
              updates]) =>
      (GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetSyncFull200ResponseRecurringStateOccurrencesInner._(
      {required this.id,
      required this.ledgerId,
      required this.txType,
      required this.amount,
      required this.happenedAt,
      this.note,
      this.categoryId,
      this.categoryName,
      this.categoryKind,
      required this.currencyCode,
      required this.nativeAmount,
      this.recurringId,
      this.occurrenceDate,
      this.createdByMemberId,
      this.lastEditedByMemberId,
      this.payerMemberId,
      this.aaMode,
      required this.splits,
      required this.revision,
      this.lastEditedAt,
      required this.updatedAt,
      required this.createdAt,
      this.deletedAt})
      : super._();
  @override
  GetSyncFull200ResponseRecurringStateOccurrencesInner rebuild(
          void Function(
                  GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder toBuilder() =>
      GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFull200ResponseRecurringStateOccurrencesInner &&
        id == other.id &&
        ledgerId == other.ledgerId &&
        txType == other.txType &&
        amount == other.amount &&
        happenedAt == other.happenedAt &&
        note == other.note &&
        categoryId == other.categoryId &&
        categoryName == other.categoryName &&
        categoryKind == other.categoryKind &&
        currencyCode == other.currencyCode &&
        nativeAmount == other.nativeAmount &&
        recurringId == other.recurringId &&
        occurrenceDate == other.occurrenceDate &&
        createdByMemberId == other.createdByMemberId &&
        lastEditedByMemberId == other.lastEditedByMemberId &&
        payerMemberId == other.payerMemberId &&
        aaMode == other.aaMode &&
        splits == other.splits &&
        revision == other.revision &&
        lastEditedAt == other.lastEditedAt &&
        updatedAt == other.updatedAt &&
        createdAt == other.createdAt &&
        deletedAt == other.deletedAt;
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
    _$hash = $jc(_$hash, currencyCode.hashCode);
    _$hash = $jc(_$hash, nativeAmount.hashCode);
    _$hash = $jc(_$hash, recurringId.hashCode);
    _$hash = $jc(_$hash, occurrenceDate.hashCode);
    _$hash = $jc(_$hash, createdByMemberId.hashCode);
    _$hash = $jc(_$hash, lastEditedByMemberId.hashCode);
    _$hash = $jc(_$hash, payerMemberId.hashCode);
    _$hash = $jc(_$hash, aaMode.hashCode);
    _$hash = $jc(_$hash, splits.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, lastEditedAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetSyncFull200ResponseRecurringStateOccurrencesInner')
          ..add('id', id)
          ..add('ledgerId', ledgerId)
          ..add('txType', txType)
          ..add('amount', amount)
          ..add('happenedAt', happenedAt)
          ..add('note', note)
          ..add('categoryId', categoryId)
          ..add('categoryName', categoryName)
          ..add('categoryKind', categoryKind)
          ..add('currencyCode', currencyCode)
          ..add('nativeAmount', nativeAmount)
          ..add('recurringId', recurringId)
          ..add('occurrenceDate', occurrenceDate)
          ..add('createdByMemberId', createdByMemberId)
          ..add('lastEditedByMemberId', lastEditedByMemberId)
          ..add('payerMemberId', payerMemberId)
          ..add('aaMode', aaMode)
          ..add('splits', splits)
          ..add('revision', revision)
          ..add('lastEditedAt', lastEditedAt)
          ..add('updatedAt', updatedAt)
          ..add('createdAt', createdAt)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder
    implements
        Builder<GetSyncFull200ResponseRecurringStateOccurrencesInner,
            GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder> {
  _$GetSyncFull200ResponseRecurringStateOccurrencesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum? _txType;
  GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum? get txType =>
      _$this._txType;
  set txType(
          GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum?
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

  String? _categoryName;
  String? get categoryName => _$this._categoryName;
  set categoryName(String? categoryName) => _$this._categoryName = categoryName;

  GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum?
      _categoryKind;
  GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum?
      get categoryKind => _$this._categoryKind;
  set categoryKind(
          GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum?
              categoryKind) =>
      _$this._categoryKind = categoryKind;

  String? _currencyCode;
  String? get currencyCode => _$this._currencyCode;
  set currencyCode(String? currencyCode) => _$this._currencyCode = currencyCode;

  String? _nativeAmount;
  String? get nativeAmount => _$this._nativeAmount;
  set nativeAmount(String? nativeAmount) => _$this._nativeAmount = nativeAmount;

  String? _recurringId;
  String? get recurringId => _$this._recurringId;
  set recurringId(String? recurringId) => _$this._recurringId = recurringId;

  Date? _occurrenceDate;
  Date? get occurrenceDate => _$this._occurrenceDate;
  set occurrenceDate(Date? occurrenceDate) =>
      _$this._occurrenceDate = occurrenceDate;

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

  GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum? _aaMode;
  GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum? get aaMode =>
      _$this._aaMode;
  set aaMode(
          GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum?
              aaMode) =>
      _$this._aaMode = aaMode;

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

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder() {
    GetSyncFull200ResponseRecurringStateOccurrencesInner._defaults(this);
  }

  GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder get _$this {
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
      _currencyCode = $v.currencyCode;
      _nativeAmount = $v.nativeAmount;
      _recurringId = $v.recurringId;
      _occurrenceDate = $v.occurrenceDate;
      _createdByMemberId = $v.createdByMemberId;
      _lastEditedByMemberId = $v.lastEditedByMemberId;
      _payerMemberId = $v.payerMemberId;
      _aaMode = $v.aaMode;
      _splits = $v.splits.toBuilder();
      _revision = $v.revision;
      _lastEditedAt = $v.lastEditedAt;
      _updatedAt = $v.updatedAt;
      _createdAt = $v.createdAt;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFull200ResponseRecurringStateOccurrencesInner other) {
    _$v = other as _$GetSyncFull200ResponseRecurringStateOccurrencesInner;
  }

  @override
  void update(
      void Function(
              GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFull200ResponseRecurringStateOccurrencesInner build() => _build();

  _$GetSyncFull200ResponseRecurringStateOccurrencesInner _build() {
    _$GetSyncFull200ResponseRecurringStateOccurrencesInner _$result;
    try {
      _$result = _$v ??
          _$GetSyncFull200ResponseRecurringStateOccurrencesInner._(
            id: BuiltValueNullFieldError.checkNotNull(id,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner', 'id'),
            ledgerId: BuiltValueNullFieldError.checkNotNull(
                ledgerId,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'ledgerId'),
            txType: BuiltValueNullFieldError.checkNotNull(
                txType,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'txType'),
            amount: BuiltValueNullFieldError.checkNotNull(
                amount,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'amount'),
            happenedAt: BuiltValueNullFieldError.checkNotNull(
                happenedAt,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'happenedAt'),
            note: note,
            categoryId: categoryId,
            categoryName: categoryName,
            categoryKind: categoryKind,
            currencyCode: BuiltValueNullFieldError.checkNotNull(
                currencyCode,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'currencyCode'),
            nativeAmount: BuiltValueNullFieldError.checkNotNull(
                nativeAmount,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'nativeAmount'),
            recurringId: recurringId,
            occurrenceDate: occurrenceDate,
            createdByMemberId: createdByMemberId,
            lastEditedByMemberId: lastEditedByMemberId,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: splits.build(),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'revision'),
            lastEditedAt: lastEditedAt,
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'updatedAt'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
                'createdAt'),
            deletedAt: deletedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splits';
        splits.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncFull200ResponseRecurringStateOccurrencesInner',
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
