// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of6_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum_expense =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum._(
        'expense');

PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'expense':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum_expense;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum_expense,
]);

const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_daily =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum._(
        'daily');
const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_weekly =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum._(
        'weekly');
const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_monthly =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum._(
        'monthly');
const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_yearly =
    const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum._(
        'yearly');

PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumValueOf(
        String name) {
  switch (name) {
    case 'daily':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_daily;
    case 'weekly':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_weekly;
    case 'monthly':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_monthly;
    case 'yearly':
      return _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_yearly;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum>(const <PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum>[
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_daily,
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_weekly,
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_monthly,
  _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_yearly,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum>
    _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'expense': 'expense',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'expense': 'expense',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload {
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum txType;
  @override
  final String amount;
  @override
  final String currencyCode;
  @override
  final String? categoryId;
  @override
  final String? note;
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
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
  final int protocolVersion;
  @override
  final String timeZone;
  @override
  final bool enabled;
  @override
  final PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState?
      initialState;

  factory _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload._(
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
      required this.protocolVersion,
      required this.timeZone,
      required this.enabled,
      this.initialState})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload &&
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
        protocolVersion == other.protocolVersion &&
        timeZone == other.timeZone &&
        enabled == other.enabled &&
        initialState == other.initialState;
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
    _$hash = $jc(_$hash, protocolVersion.hashCode);
    _$hash = $jc(_$hash, timeZone.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, initialState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload')
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
          ..add('protocolVersion', protocolVersion)
          ..add('timeZone', timeZone)
          ..add('enabled', enabled)
          ..add('initialState', initialState))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload? _$v;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum? _txType;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum? get txType =>
      _$this._txType;
  set txType(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum?
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

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum? _frequency;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum?
      get frequency => _$this._frequency;
  set frequency(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum?
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

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder?
      _initialState;
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder
      get initialState => _$this._initialState ??=
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder();
  set initialState(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateBuilder?
              initialState) =>
      _$this._initialState = initialState;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder get _$this {
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
      _protocolVersion = $v.protocolVersion;
      _timeZone = $v.timeZone;
      _enabled = $v.enabled;
      _initialState = $v.initialState?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload._(
            txType: BuiltValueNullFieldError.checkNotNull(txType,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload', 'txType'),
            amount: BuiltValueNullFieldError.checkNotNull(amount,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload', 'amount'),
            currencyCode: BuiltValueNullFieldError.checkNotNull(
                currencyCode,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'currencyCode'),
            categoryId: categoryId,
            note: note,
            frequency: BuiltValueNullFieldError.checkNotNull(
                frequency,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'frequency'),
            interval: BuiltValueNullFieldError.checkNotNull(
                interval,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'interval'),
            dayOfMonth: dayOfMonth,
            dayOfWeek: dayOfWeek,
            monthOfYear: monthOfYear,
            startDate: BuiltValueNullFieldError.checkNotNull(
                startDate,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'startDate'),
            endDate: endDate,
            protocolVersion: BuiltValueNullFieldError.checkNotNull(
                protocolVersion,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'protocolVersion'),
            timeZone: BuiltValueNullFieldError.checkNotNull(
                timeZone,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'timeZone'),
            enabled: BuiltValueNullFieldError.checkNotNull(
                enabled,
                r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
                'enabled'),
            initialState: _initialState?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'initialState';
        _initialState?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload',
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
