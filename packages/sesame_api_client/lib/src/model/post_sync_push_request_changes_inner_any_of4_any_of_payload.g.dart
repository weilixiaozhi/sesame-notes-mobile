// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of4_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum_expense =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum._(
        'expense');

PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum_expense,
]);

const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n0 =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum._('n0');
const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n1 =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum._('n1');
const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n2 =
    const PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum._('n2');

PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnumValueOf(
        String name) {
  switch (name) {
    case 'n0':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n0;
    case 'n1':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n1;
    case 'n2':
      return _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum>(const <PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n0,
  _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n1,
  _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum_n2,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum>
    _$postSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload {
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum txType;
  @override
  final String amount;
  @override
  final DateTime happenedAt;
  @override
  final String? note;
  @override
  final String? categoryId;
  @override
  final String currencyCode;
  @override
  final String nativeAmount;
  @override
  final String? recurringId;
  @override
  final Date? occurrenceDate;
  @override
  final String? payerMemberId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum? aaMode;
  @override
  final BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? splits;
  @override
  final DateTime? lastEditedAt;
  @override
  final bool? initialHistory;

  factory _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._(
      {required this.txType,
      required this.amount,
      required this.happenedAt,
      this.note,
      this.categoryId,
      required this.currencyCode,
      required this.nativeAmount,
      this.recurringId,
      this.occurrenceDate,
      this.payerMemberId,
      this.aaMode,
      this.splits,
      this.lastEditedAt,
      this.initialHistory})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload &&
        txType == other.txType &&
        amount == other.amount &&
        happenedAt == other.happenedAt &&
        note == other.note &&
        categoryId == other.categoryId &&
        currencyCode == other.currencyCode &&
        nativeAmount == other.nativeAmount &&
        recurringId == other.recurringId &&
        occurrenceDate == other.occurrenceDate &&
        payerMemberId == other.payerMemberId &&
        aaMode == other.aaMode &&
        splits == other.splits &&
        lastEditedAt == other.lastEditedAt &&
        initialHistory == other.initialHistory;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, txType.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, happenedAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, currencyCode.hashCode);
    _$hash = $jc(_$hash, nativeAmount.hashCode);
    _$hash = $jc(_$hash, recurringId.hashCode);
    _$hash = $jc(_$hash, occurrenceDate.hashCode);
    _$hash = $jc(_$hash, payerMemberId.hashCode);
    _$hash = $jc(_$hash, aaMode.hashCode);
    _$hash = $jc(_$hash, splits.hashCode);
    _$hash = $jc(_$hash, lastEditedAt.hashCode);
    _$hash = $jc(_$hash, initialHistory.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload')
          ..add('txType', txType)
          ..add('amount', amount)
          ..add('happenedAt', happenedAt)
          ..add('note', note)
          ..add('categoryId', categoryId)
          ..add('currencyCode', currencyCode)
          ..add('nativeAmount', nativeAmount)
          ..add('recurringId', recurringId)
          ..add('occurrenceDate', occurrenceDate)
          ..add('payerMemberId', payerMemberId)
          ..add('aaMode', aaMode)
          ..add('splits', splits)
          ..add('lastEditedAt', lastEditedAt)
          ..add('initialHistory', initialHistory))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload? _$v;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum? _txType;
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum? get txType =>
      _$this._txType;
  set txType(
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadTxTypeEnum?
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

  String? _payerMemberId;
  String? get payerMemberId => _$this._payerMemberId;
  set payerMemberId(String? payerMemberId) =>
      _$this._payerMemberId = payerMemberId;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum? _aaMode;
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum? get aaMode =>
      _$this._aaMode;
  set aaMode(
          PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadAaModeEnum?
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

  DateTime? _lastEditedAt;
  DateTime? get lastEditedAt => _$this._lastEditedAt;
  set lastEditedAt(DateTime? lastEditedAt) =>
      _$this._lastEditedAt = lastEditedAt;

  bool? _initialHistory;
  bool? get initialHistory => _$this._initialHistory;
  set initialHistory(bool? initialHistory) =>
      _$this._initialHistory = initialHistory;

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _txType = $v.txType;
      _amount = $v.amount;
      _happenedAt = $v.happenedAt;
      _note = $v.note;
      _categoryId = $v.categoryId;
      _currencyCode = $v.currencyCode;
      _nativeAmount = $v.nativeAmount;
      _recurringId = $v.recurringId;
      _occurrenceDate = $v.occurrenceDate;
      _payerMemberId = $v.payerMemberId;
      _aaMode = $v.aaMode;
      _splits = $v.splits?.toBuilder();
      _lastEditedAt = $v.lastEditedAt;
      _initialHistory = $v.initialHistory;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf4AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload._(
            txType: BuiltValueNullFieldError.checkNotNull(txType,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload', 'txType'),
            amount: BuiltValueNullFieldError.checkNotNull(amount,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload', 'amount'),
            happenedAt: BuiltValueNullFieldError.checkNotNull(
                happenedAt,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload',
                'happenedAt'),
            note: note,
            categoryId: categoryId,
            currencyCode: BuiltValueNullFieldError.checkNotNull(
                currencyCode,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload',
                'currencyCode'),
            nativeAmount: BuiltValueNullFieldError.checkNotNull(
                nativeAmount,
                r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload',
                'nativeAmount'),
            recurringId: recurringId,
            occurrenceDate: occurrenceDate,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: _splits?.build(),
            lastEditedAt: lastEditedAt,
            initialHistory: initialHistory,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splits';
        _splits?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf4AnyOfPayload',
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
