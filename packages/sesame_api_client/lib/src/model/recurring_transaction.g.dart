// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RecurringTransactionTxTypeEnum _$recurringTransactionTxTypeEnum_expense =
    const RecurringTransactionTxTypeEnum._('expense');
const RecurringTransactionTxTypeEnum _$recurringTransactionTxTypeEnum_income =
    const RecurringTransactionTxTypeEnum._('income');
const RecurringTransactionTxTypeEnum _$recurringTransactionTxTypeEnum_transfer =
    const RecurringTransactionTxTypeEnum._('transfer');

RecurringTransactionTxTypeEnum _$recurringTransactionTxTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'expense':
      return _$recurringTransactionTxTypeEnum_expense;
    case 'income':
      return _$recurringTransactionTxTypeEnum_income;
    case 'transfer':
      return _$recurringTransactionTxTypeEnum_transfer;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RecurringTransactionTxTypeEnum>
    _$recurringTransactionTxTypeEnumValues = BuiltSet<
        RecurringTransactionTxTypeEnum>(const <RecurringTransactionTxTypeEnum>[
  _$recurringTransactionTxTypeEnum_expense,
  _$recurringTransactionTxTypeEnum_income,
  _$recurringTransactionTxTypeEnum_transfer,
]);

const RecurringTransactionFrequencyEnum
    _$recurringTransactionFrequencyEnum_daily =
    const RecurringTransactionFrequencyEnum._('daily');
const RecurringTransactionFrequencyEnum
    _$recurringTransactionFrequencyEnum_weekly =
    const RecurringTransactionFrequencyEnum._('weekly');
const RecurringTransactionFrequencyEnum
    _$recurringTransactionFrequencyEnum_monthly =
    const RecurringTransactionFrequencyEnum._('monthly');
const RecurringTransactionFrequencyEnum
    _$recurringTransactionFrequencyEnum_yearly =
    const RecurringTransactionFrequencyEnum._('yearly');

RecurringTransactionFrequencyEnum _$recurringTransactionFrequencyEnumValueOf(
    String name) {
  switch (name) {
    case 'daily':
      return _$recurringTransactionFrequencyEnum_daily;
    case 'weekly':
      return _$recurringTransactionFrequencyEnum_weekly;
    case 'monthly':
      return _$recurringTransactionFrequencyEnum_monthly;
    case 'yearly':
      return _$recurringTransactionFrequencyEnum_yearly;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RecurringTransactionFrequencyEnum>
    _$recurringTransactionFrequencyEnumValues = BuiltSet<
        RecurringTransactionFrequencyEnum>(const <RecurringTransactionFrequencyEnum>[
  _$recurringTransactionFrequencyEnum_daily,
  _$recurringTransactionFrequencyEnum_weekly,
  _$recurringTransactionFrequencyEnum_monthly,
  _$recurringTransactionFrequencyEnum_yearly,
]);

Serializer<RecurringTransactionTxTypeEnum>
    _$recurringTransactionTxTypeEnumSerializer =
    _$RecurringTransactionTxTypeEnumSerializer();
Serializer<RecurringTransactionFrequencyEnum>
    _$recurringTransactionFrequencyEnumSerializer =
    _$RecurringTransactionFrequencyEnumSerializer();

class _$RecurringTransactionTxTypeEnumSerializer
    implements PrimitiveSerializer<RecurringTransactionTxTypeEnum> {
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
  final Iterable<Type> types = const <Type>[RecurringTransactionTxTypeEnum];
  @override
  final String wireName = 'RecurringTransactionTxTypeEnum';

  @override
  Object serialize(
          Serializers serializers, RecurringTransactionTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RecurringTransactionTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RecurringTransactionTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RecurringTransactionFrequencyEnumSerializer
    implements PrimitiveSerializer<RecurringTransactionFrequencyEnum> {
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
  final Iterable<Type> types = const <Type>[RecurringTransactionFrequencyEnum];
  @override
  final String wireName = 'RecurringTransactionFrequencyEnum';

  @override
  Object serialize(
          Serializers serializers, RecurringTransactionFrequencyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RecurringTransactionFrequencyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RecurringTransactionFrequencyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$RecurringTransaction extends RecurringTransaction {
  @override
  final String id;
  @override
  final String ledgerId;
  @override
  final RecurringTransactionTxTypeEnum txType;
  @override
  final String amount;
  @override
  final String currencyCode;
  @override
  final String? categoryId;
  @override
  final String? note;
  @override
  final RecurringTransactionFrequencyEnum frequency;
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
  @override
  final DateTime updatedAt;

  factory _$RecurringTransaction(
          [void Function(RecurringTransactionBuilder)? updates]) =>
      (RecurringTransactionBuilder()..update(updates))._build();

  _$RecurringTransaction._(
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
      required this.enabled,
      required this.updatedAt})
      : super._();
  @override
  RecurringTransaction rebuild(
          void Function(RecurringTransactionBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecurringTransactionBuilder toBuilder() =>
      RecurringTransactionBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecurringTransaction &&
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
        enabled == other.enabled &&
        updatedAt == other.updatedAt;
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
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecurringTransaction')
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
          ..add('enabled', enabled)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RecurringTransactionBuilder
    implements Builder<RecurringTransaction, RecurringTransactionBuilder> {
  _$RecurringTransaction? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  RecurringTransactionTxTypeEnum? _txType;
  RecurringTransactionTxTypeEnum? get txType => _$this._txType;
  set txType(RecurringTransactionTxTypeEnum? txType) => _$this._txType = txType;

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

  RecurringTransactionFrequencyEnum? _frequency;
  RecurringTransactionFrequencyEnum? get frequency => _$this._frequency;
  set frequency(RecurringTransactionFrequencyEnum? frequency) =>
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

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RecurringTransactionBuilder() {
    RecurringTransaction._defaults(this);
  }

  RecurringTransactionBuilder get _$this {
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
      _enabled = $v.enabled;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecurringTransaction other) {
    _$v = other as _$RecurringTransaction;
  }

  @override
  void update(void Function(RecurringTransactionBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecurringTransaction build() => _build();

  _$RecurringTransaction _build() {
    final _$result = _$v ??
        _$RecurringTransaction._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RecurringTransaction', 'id'),
          ledgerId: BuiltValueNullFieldError.checkNotNull(
              ledgerId, r'RecurringTransaction', 'ledgerId'),
          txType: BuiltValueNullFieldError.checkNotNull(
              txType, r'RecurringTransaction', 'txType'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'RecurringTransaction', 'amount'),
          currencyCode: BuiltValueNullFieldError.checkNotNull(
              currencyCode, r'RecurringTransaction', 'currencyCode'),
          categoryId: categoryId,
          note: note,
          frequency: BuiltValueNullFieldError.checkNotNull(
              frequency, r'RecurringTransaction', 'frequency'),
          interval: BuiltValueNullFieldError.checkNotNull(
              interval, r'RecurringTransaction', 'interval'),
          dayOfMonth: dayOfMonth,
          dayOfWeek: dayOfWeek,
          monthOfYear: monthOfYear,
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate, r'RecurringTransaction', 'startDate'),
          endDate: endDate,
          lastGeneratedDate: lastGeneratedDate,
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'RecurringTransaction', 'enabled'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'RecurringTransaction', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
