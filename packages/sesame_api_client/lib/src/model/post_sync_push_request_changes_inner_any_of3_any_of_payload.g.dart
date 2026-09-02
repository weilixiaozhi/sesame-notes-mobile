// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of3_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_expense =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum._(
        'expense');
const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_income =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum._(
        'income');
const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_transfer =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum._(
        'transfer');

PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_expense;
    case 'income':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_income;
    case 'transfer':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_expense,
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_income,
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_transfer,
]);

const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_daily =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum._(
        'daily');
const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_weekly =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum._(
        'weekly');
const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_monthly =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum._(
        'monthly');
const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_yearly =
    const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum._(
        'yearly');

PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumValueOf(
        String name) {
  switch (name) {
    case 'daily':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_daily;
    case 'weekly':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_weekly;
    case 'monthly':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_monthly;
    case 'yearly':
      return _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_yearly;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum>(const <PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum>[
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_daily,
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_weekly,
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_monthly,
  _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_yearly,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum>
    _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'daily': 'daily',
    'weekly': 'weekly',
    'monthly': 'monthly',
    'yearly': 'yearly',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'daily': 'daily',
    'weekly': 'weekly',
    'monthly': 'monthly',
    'yearly': 'yearly',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload {
  @override
  final PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum txType;
  @override
  final String amount;
  @override
  final String currencyCode;
  @override
  final String? categoryId;
  @override
  final String? note;
  @override
  final PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
      frequency;
  @override
  final int interval;
  @override
  final int? dayOfMonth;
  @override
  final int? dayOfWeek;
  @override
  final int? monthOfYear;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final DateTime? lastGeneratedDate;
  @override
  final bool enabled;

  factory _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload._(
      {required this.txType,
      required this.amount,
      required this.currencyCode,
      this.categoryId,
      this.note,
      required this.frequency,
      required this.interval,
      this.dayOfMonth,
      this.dayOfWeek,
      this.monthOfYear,
      required this.startDate,
      this.endDate,
      this.lastGeneratedDate,
      required this.enabled})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload &&
        txType == other.txType &&
        amount == other.amount &&
        currencyCode == other.currencyCode &&
        categoryId == other.categoryId &&
        note == other.note &&
        frequency == other.frequency &&
        interval == other.interval &&
        dayOfMonth == other.dayOfMonth &&
        dayOfWeek == other.dayOfWeek &&
        monthOfYear == other.monthOfYear &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        lastGeneratedDate == other.lastGeneratedDate &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, txType.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currencyCode.hashCode);
    _$hash = $jc(_$hash, categoryId.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, frequency.hashCode);
    _$hash = $jc(_$hash, interval.hashCode);
    _$hash = $jc(_$hash, dayOfMonth.hashCode);
    _$hash = $jc(_$hash, dayOfWeek.hashCode);
    _$hash = $jc(_$hash, monthOfYear.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, lastGeneratedDate.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload')
          ..add('txType', txType)
          ..add('amount', amount)
          ..add('currencyCode', currencyCode)
          ..add('categoryId', categoryId)
          ..add('note', note)
          ..add('frequency', frequency)
          ..add('interval', interval)
          ..add('dayOfMonth', dayOfMonth)
          ..add('dayOfWeek', dayOfWeek)
          ..add('monthOfYear', monthOfYear)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('lastGeneratedDate', lastGeneratedDate)
          ..add('enabled', enabled))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload? _$v;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum? _txType;
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum? get txType =>
      _$this._txType;
  set txType(
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum?
              txType) =>
      _$this._txType = txType;

  String? _amount;
  String? get amount => _$this._amount;
  set amount(String? amount) => _$this._amount = amount;

  String? _currencyCode;
  String? get currencyCode => _$this._currencyCode;
  set currencyCode(String? currencyCode) => _$this._currencyCode = currencyCode;

  String? _categoryId;
  String? get categoryId => _$this._categoryId;
  set categoryId(String? categoryId) => _$this._categoryId = categoryId;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum? _frequency;
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum?
      get frequency => _$this._frequency;
  set frequency(
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum?
              frequency) =>
      _$this._frequency = frequency;

  int? _interval;
  int? get interval => _$this._interval;
  set interval(int? interval) => _$this._interval = interval;

  int? _dayOfMonth;
  int? get dayOfMonth => _$this._dayOfMonth;
  set dayOfMonth(int? dayOfMonth) => _$this._dayOfMonth = dayOfMonth;

  int? _dayOfWeek;
  int? get dayOfWeek => _$this._dayOfWeek;
  set dayOfWeek(int? dayOfWeek) => _$this._dayOfWeek = dayOfWeek;

  int? _monthOfYear;
  int? get monthOfYear => _$this._monthOfYear;
  set monthOfYear(int? monthOfYear) => _$this._monthOfYear = monthOfYear;

  DateTime? _startDate;
  DateTime? get startDate => _$this._startDate;
  set startDate(DateTime? startDate) => _$this._startDate = startDate;

  DateTime? _endDate;
  DateTime? get endDate => _$this._endDate;
  set endDate(DateTime? endDate) => _$this._endDate = endDate;

  DateTime? _lastGeneratedDate;
  DateTime? get lastGeneratedDate => _$this._lastGeneratedDate;
  set lastGeneratedDate(DateTime? lastGeneratedDate) =>
      _$this._lastGeneratedDate = lastGeneratedDate;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _txType = $v.txType;
      _amount = $v.amount;
      _currencyCode = $v.currencyCode;
      _categoryId = $v.categoryId;
      _note = $v.note;
      _frequency = $v.frequency;
      _interval = $v.interval;
      _dayOfMonth = $v.dayOfMonth;
      _dayOfWeek = $v.dayOfWeek;
      _monthOfYear = $v.monthOfYear;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _lastGeneratedDate = $v.lastGeneratedDate;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload._(
          txType: BuiltValueNullFieldError.checkNotNull(txType,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload', 'txType'),
          amount: BuiltValueNullFieldError.checkNotNull(amount,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload', 'amount'),
          currencyCode: BuiltValueNullFieldError.checkNotNull(
              currencyCode,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload',
              'currencyCode'),
          categoryId: categoryId,
          note: note,
          frequency: BuiltValueNullFieldError.checkNotNull(
              frequency,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload',
              'frequency'),
          interval: BuiltValueNullFieldError.checkNotNull(interval,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload', 'interval'),
          dayOfMonth: dayOfMonth,
          dayOfWeek: dayOfWeek,
          monthOfYear: monthOfYear,
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload',
              'startDate'),
          endDate: endDate,
          lastGeneratedDate: lastGeneratedDate,
          enabled: BuiltValueNullFieldError.checkNotNull(enabled,
              r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
