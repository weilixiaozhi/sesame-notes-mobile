// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of1_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_expense =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum._(
        'expense');
const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_income =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum._(
        'income');
const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_transfer =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum._(
        'transfer');

PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_expense;
    case 'income':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_income;
    case 'transfer':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_expense,
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_income,
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_transfer,
]);

const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n0 =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum._('n0');
const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n1 =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum._('n1');
const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n2 =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum._('n2');

PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumValueOf(
        String name) {
  switch (name) {
    case 'n0':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n0;
    case 'n1':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n1;
    case 'n2':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n2;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum>(const <PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n0,
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n1,
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n2,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload {
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum txType;
  @override
  final String amount;
  @override
  final DateTime happenedAt;
  @override
  final String? note;
  @override
  final String? categoryId;
  @override
  final bool excludeFromStats;
  @override
  final String currencyCode;
  @override
  final String nativeAmount;
  @override
  final String? recurringId;
  @override
  final String? payerMemberId;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum? aaMode;
  @override
  final BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? splits;
  @override
  final int? version;
  @override
  final DateTime? lastEditedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload._(
      {required this.txType,
      required this.amount,
      required this.happenedAt,
      this.note,
      this.categoryId,
      required this.excludeFromStats,
      required this.currencyCode,
      required this.nativeAmount,
      this.recurringId,
      this.payerMemberId,
      this.aaMode,
      this.splits,
      this.version,
      this.lastEditedAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload &&
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
        version == other.version &&
        lastEditedAt == other.lastEditedAt;
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
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, lastEditedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload')
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
          ..add('version', version)
          ..add('lastEditedAt', lastEditedAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload? _$v;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum? _txType;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum? get txType =>
      _$this._txType;
  set txType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum? _aaMode;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum? get aaMode =>
      _$this._aaMode;
  set aaMode(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum?
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

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  DateTime? _lastEditedAt;
  DateTime? get lastEditedAt => _$this._lastEditedAt;
  set lastEditedAt(DateTime? lastEditedAt) =>
      _$this._lastEditedAt = lastEditedAt;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder get _$this {
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
      _version = $v.version;
      _lastEditedAt = $v.lastEditedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload._(
            txType: BuiltValueNullFieldError.checkNotNull(txType,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload', 'txType'),
            amount: BuiltValueNullFieldError.checkNotNull(amount,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload', 'amount'),
            happenedAt: BuiltValueNullFieldError.checkNotNull(
                happenedAt,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload',
                'happenedAt'),
            note: note,
            categoryId: categoryId,
            excludeFromStats: BuiltValueNullFieldError.checkNotNull(
                excludeFromStats,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload',
                'excludeFromStats'),
            currencyCode: BuiltValueNullFieldError.checkNotNull(
                currencyCode,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload',
                'currencyCode'),
            nativeAmount: BuiltValueNullFieldError.checkNotNull(
                nativeAmount,
                r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload',
                'nativeAmount'),
            recurringId: recurringId,
            payerMemberId: payerMemberId,
            aaMode: aaMode,
            splits: _splits?.build(),
            version: version,
            lastEditedAt: lastEditedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'splits';
        _splits?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload',
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
