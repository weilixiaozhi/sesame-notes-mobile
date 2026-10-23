// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DayEventCategoryEnum _$dayEventCategoryEnum_birthday =
    const DayEventCategoryEnum._('birthday');
const DayEventCategoryEnum _$dayEventCategoryEnum_anniversary =
    const DayEventCategoryEnum._('anniversary');
const DayEventCategoryEnum _$dayEventCategoryEnum_countdown =
    const DayEventCategoryEnum._('countdown');
const DayEventCategoryEnum _$dayEventCategoryEnum_stage =
    const DayEventCategoryEnum._('stage');

DayEventCategoryEnum _$dayEventCategoryEnumValueOf(String name) {
  switch (name) {
    case 'birthday':
      return _$dayEventCategoryEnum_birthday;
    case 'anniversary':
      return _$dayEventCategoryEnum_anniversary;
    case 'countdown':
      return _$dayEventCategoryEnum_countdown;
    case 'stage':
      return _$dayEventCategoryEnum_stage;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DayEventCategoryEnum> _$dayEventCategoryEnumValues =
    BuiltSet<DayEventCategoryEnum>(const <DayEventCategoryEnum>[
  _$dayEventCategoryEnum_birthday,
  _$dayEventCategoryEnum_anniversary,
  _$dayEventCategoryEnum_countdown,
  _$dayEventCategoryEnum_stage,
]);

const DayEventCountdownModeEnum _$dayEventCountdownModeEnum_fixedDate =
    const DayEventCountdownModeEnum._('fixedDate');
const DayEventCountdownModeEnum _$dayEventCountdownModeEnum_intervalDays =
    const DayEventCountdownModeEnum._('intervalDays');

DayEventCountdownModeEnum _$dayEventCountdownModeEnumValueOf(String name) {
  switch (name) {
    case 'fixedDate':
      return _$dayEventCountdownModeEnum_fixedDate;
    case 'intervalDays':
      return _$dayEventCountdownModeEnum_intervalDays;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DayEventCountdownModeEnum> _$dayEventCountdownModeEnumValues =
    BuiltSet<DayEventCountdownModeEnum>(const <DayEventCountdownModeEnum>[
  _$dayEventCountdownModeEnum_fixedDate,
  _$dayEventCountdownModeEnum_intervalDays,
]);

const DayEventRepeatTypeEnum _$dayEventRepeatTypeEnum_none =
    const DayEventRepeatTypeEnum._('none');
const DayEventRepeatTypeEnum _$dayEventRepeatTypeEnum_yearly =
    const DayEventRepeatTypeEnum._('yearly');

DayEventRepeatTypeEnum _$dayEventRepeatTypeEnumValueOf(String name) {
  switch (name) {
    case 'none':
      return _$dayEventRepeatTypeEnum_none;
    case 'yearly':
      return _$dayEventRepeatTypeEnum_yearly;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DayEventRepeatTypeEnum> _$dayEventRepeatTypeEnumValues =
    BuiltSet<DayEventRepeatTypeEnum>(const <DayEventRepeatTypeEnum>[
  _$dayEventRepeatTypeEnum_none,
  _$dayEventRepeatTypeEnum_yearly,
]);

const DayEventStatisticTypeEnum _$dayEventStatisticTypeEnum_year =
    const DayEventStatisticTypeEnum._('year');
const DayEventStatisticTypeEnum _$dayEventStatisticTypeEnum_day =
    const DayEventStatisticTypeEnum._('day');

DayEventStatisticTypeEnum _$dayEventStatisticTypeEnumValueOf(String name) {
  switch (name) {
    case 'year':
      return _$dayEventStatisticTypeEnum_year;
    case 'day':
      return _$dayEventStatisticTypeEnum_day;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DayEventStatisticTypeEnum> _$dayEventStatisticTypeEnumValues =
    BuiltSet<DayEventStatisticTypeEnum>(const <DayEventStatisticTypeEnum>[
  _$dayEventStatisticTypeEnum_year,
  _$dayEventStatisticTypeEnum_day,
]);

Serializer<DayEventCategoryEnum> _$dayEventCategoryEnumSerializer =
    _$DayEventCategoryEnumSerializer();
Serializer<DayEventCountdownModeEnum> _$dayEventCountdownModeEnumSerializer =
    _$DayEventCountdownModeEnumSerializer();
Serializer<DayEventRepeatTypeEnum> _$dayEventRepeatTypeEnumSerializer =
    _$DayEventRepeatTypeEnumSerializer();
Serializer<DayEventStatisticTypeEnum> _$dayEventStatisticTypeEnumSerializer =
    _$DayEventStatisticTypeEnumSerializer();

class _$DayEventCategoryEnumSerializer
    implements PrimitiveSerializer<DayEventCategoryEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'birthday': 'birthday',
    'anniversary': 'anniversary',
    'countdown': 'countdown',
    'stage': 'stage',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'birthday': 'birthday',
    'anniversary': 'anniversary',
    'countdown': 'countdown',
    'stage': 'stage',
  };

  @override
  final Iterable<Type> types = const <Type>[DayEventCategoryEnum];
  @override
  final String wireName = 'DayEventCategoryEnum';

  @override
  Object serialize(Serializers serializers, DayEventCategoryEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DayEventCategoryEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DayEventCategoryEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DayEventCountdownModeEnumSerializer
    implements PrimitiveSerializer<DayEventCountdownModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'fixedDate': 'fixed_date',
    'intervalDays': 'interval_days',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'fixed_date': 'fixedDate',
    'interval_days': 'intervalDays',
  };

  @override
  final Iterable<Type> types = const <Type>[DayEventCountdownModeEnum];
  @override
  final String wireName = 'DayEventCountdownModeEnum';

  @override
  Object serialize(Serializers serializers, DayEventCountdownModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DayEventCountdownModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DayEventCountdownModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DayEventRepeatTypeEnumSerializer
    implements PrimitiveSerializer<DayEventRepeatTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'none': 'none',
    'yearly': 'yearly',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'none': 'none',
    'yearly': 'yearly',
  };

  @override
  final Iterable<Type> types = const <Type>[DayEventRepeatTypeEnum];
  @override
  final String wireName = 'DayEventRepeatTypeEnum';

  @override
  Object serialize(Serializers serializers, DayEventRepeatTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DayEventRepeatTypeEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DayEventRepeatTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DayEventStatisticTypeEnumSerializer
    implements PrimitiveSerializer<DayEventStatisticTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'year': 'year',
    'day': 'day',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'year': 'year',
    'day': 'day',
  };

  @override
  final Iterable<Type> types = const <Type>[DayEventStatisticTypeEnum];
  @override
  final String wireName = 'DayEventStatisticTypeEnum';

  @override
  Object serialize(Serializers serializers, DayEventStatisticTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DayEventStatisticTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DayEventStatisticTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DayEvent extends DayEvent {
  @override
  final String name;
  @override
  final DayEventCategoryEnum category;
  @override
  final DayEventCountdownModeEnum? countdownMode;
  @override
  final int? intervalDays;
  @override
  final DayEventRepeatTypeEnum repeatType;
  @override
  final DayEventStatisticTypeEnum statisticType;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? event;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? start;
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? end;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final String dayBookId;

  factory _$DayEvent([void Function(DayEventBuilder)? updates]) =>
      (DayEventBuilder()..update(updates))._build();

  _$DayEvent._(
      {required this.name,
      required this.category,
      this.countdownMode,
      this.intervalDays,
      required this.repeatType,
      required this.statisticType,
      this.event,
      this.start,
      this.end,
      required this.createdAt,
      required this.id,
      required this.syncId,
      required this.revision,
      required this.updatedAt,
      this.deletedAt,
      required this.dayBookId})
      : super._();
  @override
  DayEvent rebuild(void Function(DayEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DayEventBuilder toBuilder() => DayEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DayEvent &&
        name == other.name &&
        category == other.category &&
        countdownMode == other.countdownMode &&
        intervalDays == other.intervalDays &&
        repeatType == other.repeatType &&
        statisticType == other.statisticType &&
        event == other.event &&
        start == other.start &&
        end == other.end &&
        createdAt == other.createdAt &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        dayBookId == other.dayBookId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, countdownMode.hashCode);
    _$hash = $jc(_$hash, intervalDays.hashCode);
    _$hash = $jc(_$hash, repeatType.hashCode);
    _$hash = $jc(_$hash, statisticType.hashCode);
    _$hash = $jc(_$hash, event.hashCode);
    _$hash = $jc(_$hash, start.hashCode);
    _$hash = $jc(_$hash, end.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, dayBookId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DayEvent')
          ..add('name', name)
          ..add('category', category)
          ..add('countdownMode', countdownMode)
          ..add('intervalDays', intervalDays)
          ..add('repeatType', repeatType)
          ..add('statisticType', statisticType)
          ..add('event', event)
          ..add('start', start)
          ..add('end', end)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('dayBookId', dayBookId))
        .toString();
  }
}

class DayEventBuilder implements Builder<DayEvent, DayEventBuilder> {
  _$DayEvent? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DayEventCategoryEnum? _category;
  DayEventCategoryEnum? get category => _$this._category;
  set category(DayEventCategoryEnum? category) => _$this._category = category;

  DayEventCountdownModeEnum? _countdownMode;
  DayEventCountdownModeEnum? get countdownMode => _$this._countdownMode;
  set countdownMode(DayEventCountdownModeEnum? countdownMode) =>
      _$this._countdownMode = countdownMode;

  int? _intervalDays;
  int? get intervalDays => _$this._intervalDays;
  set intervalDays(int? intervalDays) => _$this._intervalDays = intervalDays;

  DayEventRepeatTypeEnum? _repeatType;
  DayEventRepeatTypeEnum? get repeatType => _$this._repeatType;
  set repeatType(DayEventRepeatTypeEnum? repeatType) =>
      _$this._repeatType = repeatType;

  DayEventStatisticTypeEnum? _statisticType;
  DayEventStatisticTypeEnum? get statisticType => _$this._statisticType;
  set statisticType(DayEventStatisticTypeEnum? statisticType) =>
      _$this._statisticType = statisticType;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder? _event;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder get event =>
      _$this._event ??=
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder();
  set event(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder?
              event) =>
      _$this._event = event;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder? _start;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder get start =>
      _$this._start ??=
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder();
  set start(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder?
              start) =>
      _$this._start = start;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder? _end;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder get end =>
      _$this._end ??=
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder();
  set end(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder? end) =>
      _$this._end = end;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  String? _dayBookId;
  String? get dayBookId => _$this._dayBookId;
  set dayBookId(String? dayBookId) => _$this._dayBookId = dayBookId;

  DayEventBuilder() {
    DayEvent._defaults(this);
  }

  DayEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _category = $v.category;
      _countdownMode = $v.countdownMode;
      _intervalDays = $v.intervalDays;
      _repeatType = $v.repeatType;
      _statisticType = $v.statisticType;
      _event = $v.event?.toBuilder();
      _start = $v.start?.toBuilder();
      _end = $v.end?.toBuilder();
      _createdAt = $v.createdAt;
      _id = $v.id;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _dayBookId = $v.dayBookId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DayEvent other) {
    _$v = other as _$DayEvent;
  }

  @override
  void update(void Function(DayEventBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DayEvent build() => _build();

  _$DayEvent _build() {
    _$DayEvent _$result;
    try {
      _$result = _$v ??
          _$DayEvent._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'DayEvent', 'name'),
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'DayEvent', 'category'),
            countdownMode: countdownMode,
            intervalDays: intervalDays,
            repeatType: BuiltValueNullFieldError.checkNotNull(
                repeatType, r'DayEvent', 'repeatType'),
            statisticType: BuiltValueNullFieldError.checkNotNull(
                statisticType, r'DayEvent', 'statisticType'),
            event: _event?.build(),
            start: _start?.build(),
            end: _end?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'DayEvent', 'createdAt'),
            id: BuiltValueNullFieldError.checkNotNull(id, r'DayEvent', 'id'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId, r'DayEvent', 'syncId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision, r'DayEvent', 'revision'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'DayEvent', 'updatedAt'),
            deletedAt: deletedAt,
            dayBookId: BuiltValueNullFieldError.checkNotNull(
                dayBookId, r'DayEvent', 'dayBookId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'event';
        _event?.build();
        _$failedField = 'start';
        _start?.build();
        _$failedField = 'end';
        _end?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'DayEvent', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
