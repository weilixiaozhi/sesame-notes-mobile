// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_full200_response_recurring_state_rules_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum_expense =
    const GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum._('expense');

GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum>
    _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumValues = BuiltSet<
        GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum>(const <GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum>[
  _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum_expense,
]);

const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_daily =
    const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum._(
        'daily');
const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_weekly =
    const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum._(
        'weekly');
const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_monthly =
    const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum._(
        'monthly');
const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_yearly =
    const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum._(
        'yearly');

GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumValueOf(
        String name) {
  switch (name) {
    case 'daily':
      return _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_daily;
    case 'weekly':
      return _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_weekly;
    case 'monthly':
      return _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_monthly;
    case 'yearly':
      return _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_yearly;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum>
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumValues =
    BuiltSet<
        GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum>(const <GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum>[
  _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_daily,
  _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_weekly,
  _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_monthly,
  _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_yearly,
]);

Serializer<GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum>
    _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumSerializer =
    _$GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumSerializer();
Serializer<GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum>
    _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumSerializer =
    _$GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumSerializer();

class _$GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum
  ];
  @override
  final String wireName =
      'GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumSerializer
    implements
        PrimitiveSerializer<
            GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum> {
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
    GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
  ];
  @override
  final String wireName =
      'GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncFull200ResponseRecurringStateRulesInner
    extends GetSyncFull200ResponseRecurringStateRulesInner {
  @override
  final String id;
  @override
  final String ledgerId;
  @override
  final GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum txType;
  @override
  final String amount;
  @override
  final String currencyCode;
  @override
  final String? categoryId;
  @override
  final String? note;
  @override
  final GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum frequency;
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
  final int protocolVersion;
  @override
  final String timeZone;
  @override
  final bool enabled;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  factory _$GetSyncFull200ResponseRecurringStateRulesInner(
          [void Function(GetSyncFull200ResponseRecurringStateRulesInnerBuilder)?
              updates]) =>
      (GetSyncFull200ResponseRecurringStateRulesInnerBuilder()..update(updates))
          ._build();

  _$GetSyncFull200ResponseRecurringStateRulesInner._(
      {required this.id,
      required this.ledgerId,
      required this.txType,
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
      required this.protocolVersion,
      required this.timeZone,
      required this.enabled,
      required this.updatedAt,
      this.deletedAt})
      : super._();
  @override
  GetSyncFull200ResponseRecurringStateRulesInner rebuild(
          void Function(GetSyncFull200ResponseRecurringStateRulesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFull200ResponseRecurringStateRulesInnerBuilder toBuilder() =>
      GetSyncFull200ResponseRecurringStateRulesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFull200ResponseRecurringStateRulesInner &&
        id == other.id &&
        ledgerId == other.ledgerId &&
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
        protocolVersion == other.protocolVersion &&
        timeZone == other.timeZone &&
        enabled == other.enabled &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
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
    _$hash = $jc(_$hash, protocolVersion.hashCode);
    _$hash = $jc(_$hash, timeZone.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetSyncFull200ResponseRecurringStateRulesInner')
          ..add('id', id)
          ..add('ledgerId', ledgerId)
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
          ..add('protocolVersion', protocolVersion)
          ..add('timeZone', timeZone)
          ..add('enabled', enabled)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class GetSyncFull200ResponseRecurringStateRulesInnerBuilder
    implements
        Builder<GetSyncFull200ResponseRecurringStateRulesInner,
            GetSyncFull200ResponseRecurringStateRulesInnerBuilder> {
  _$GetSyncFull200ResponseRecurringStateRulesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum? _txType;
  GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum? get txType =>
      _$this._txType;
  set txType(
          GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum? txType) =>
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

  GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum? _frequency;
  GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum? get frequency =>
      _$this._frequency;
  set frequency(
          GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum?
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

  int? _protocolVersion;
  int? get protocolVersion => _$this._protocolVersion;
  set protocolVersion(int? protocolVersion) =>
      _$this._protocolVersion = protocolVersion;

  String? _timeZone;
  String? get timeZone => _$this._timeZone;
  set timeZone(String? timeZone) => _$this._timeZone = timeZone;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  GetSyncFull200ResponseRecurringStateRulesInnerBuilder() {
    GetSyncFull200ResponseRecurringStateRulesInner._defaults(this);
  }

  GetSyncFull200ResponseRecurringStateRulesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ledgerId = $v.ledgerId;
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
      _protocolVersion = $v.protocolVersion;
      _timeZone = $v.timeZone;
      _enabled = $v.enabled;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFull200ResponseRecurringStateRulesInner other) {
    _$v = other as _$GetSyncFull200ResponseRecurringStateRulesInner;
  }

  @override
  void update(
      void Function(GetSyncFull200ResponseRecurringStateRulesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFull200ResponseRecurringStateRulesInner build() => _build();

  _$GetSyncFull200ResponseRecurringStateRulesInner _build() {
    final _$result = _$v ??
        _$GetSyncFull200ResponseRecurringStateRulesInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetSyncFull200ResponseRecurringStateRulesInner', 'id'),
          ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'ledgerId'),
          txType: BuiltValueNullFieldError.checkNotNull(txType,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'txType'),
          amount: BuiltValueNullFieldError.checkNotNull(amount,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'amount'),
          currencyCode: BuiltValueNullFieldError.checkNotNull(
              currencyCode,
              r'GetSyncFull200ResponseRecurringStateRulesInner',
              'currencyCode'),
          categoryId: categoryId,
          note: note,
          frequency: BuiltValueNullFieldError.checkNotNull(frequency,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'frequency'),
          interval: BuiltValueNullFieldError.checkNotNull(interval,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'interval'),
          dayOfMonth: dayOfMonth,
          dayOfWeek: dayOfWeek,
          monthOfYear: monthOfYear,
          startDate: BuiltValueNullFieldError.checkNotNull(startDate,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'startDate'),
          endDate: endDate,
          lastGeneratedDate: lastGeneratedDate,
          protocolVersion: BuiltValueNullFieldError.checkNotNull(
              protocolVersion,
              r'GetSyncFull200ResponseRecurringStateRulesInner',
              'protocolVersion'),
          timeZone: BuiltValueNullFieldError.checkNotNull(timeZone,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'timeZone'),
          enabled: BuiltValueNullFieldError.checkNotNull(enabled,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'enabled'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(updatedAt,
              r'GetSyncFull200ResponseRecurringStateRulesInner', 'updatedAt'),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
