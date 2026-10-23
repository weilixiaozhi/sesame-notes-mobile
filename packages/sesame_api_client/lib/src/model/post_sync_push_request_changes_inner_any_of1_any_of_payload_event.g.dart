// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of1_any_of_payload_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_solar =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
        ._('solar');
const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_lunar =
    const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
        ._('lunar');

PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumValueOf(
        String name) {
  switch (name) {
    case 'solar':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_solar;
    case 'lunar':
      return _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_lunar;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum>(const <PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum>[
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_solar,
  _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_lunar,
]);

Serializer<
        PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum>
    _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'solar': 'solar',
    'lunar': 'lunar',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'solar': 'solar',
    'lunar': 'lunar',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent
    extends PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent {
  @override
  final PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
      calendarType;
  @override
  final int originalYear;
  @override
  final int originalMonth;
  @override
  final int originalDay;
  @override
  final bool isLeapMonth;
  @override
  final String solarDate;

  factory _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent._(
      {required this.calendarType,
      required this.originalYear,
      required this.originalMonth,
      required this.originalDay,
      required this.isLeapMonth,
      required this.solarDate})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent &&
        calendarType == other.calendarType &&
        originalYear == other.originalYear &&
        originalMonth == other.originalMonth &&
        originalDay == other.originalDay &&
        isLeapMonth == other.isLeapMonth &&
        solarDate == other.solarDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, calendarType.hashCode);
    _$hash = $jc(_$hash, originalYear.hashCode);
    _$hash = $jc(_$hash, originalMonth.hashCode);
    _$hash = $jc(_$hash, originalDay.hashCode);
    _$hash = $jc(_$hash, isLeapMonth.hashCode);
    _$hash = $jc(_$hash, solarDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent')
          ..add('calendarType', calendarType)
          ..add('originalYear', originalYear)
          ..add('originalMonth', originalMonth)
          ..add('originalDay', originalDay)
          ..add('isLeapMonth', isLeapMonth)
          ..add('solarDate', solarDate))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent,
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? _$v;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum?
      _calendarType;
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum?
      get calendarType => _$this._calendarType;
  set calendarType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum?
              calendarType) =>
      _$this._calendarType = calendarType;

  int? _originalYear;
  int? get originalYear => _$this._originalYear;
  set originalYear(int? originalYear) => _$this._originalYear = originalYear;

  int? _originalMonth;
  int? get originalMonth => _$this._originalMonth;
  set originalMonth(int? originalMonth) =>
      _$this._originalMonth = originalMonth;

  int? _originalDay;
  int? get originalDay => _$this._originalDay;
  set originalDay(int? originalDay) => _$this._originalDay = originalDay;

  bool? _isLeapMonth;
  bool? get isLeapMonth => _$this._isLeapMonth;
  set isLeapMonth(bool? isLeapMonth) => _$this._isLeapMonth = isLeapMonth;

  String? _solarDate;
  String? get solarDate => _$this._solarDate;
  set solarDate(String? solarDate) => _$this._solarDate = solarDate;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder() {
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _calendarType = $v.calendarType;
      _originalYear = $v.originalYear;
      _originalMonth = $v.originalMonth;
      _originalDay = $v.originalDay;
      _isLeapMonth = $v.isLeapMonth;
      _solarDate = $v.solarDate;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent;
  }

  @override
  void update(
      void Function(
              PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent._(
          calendarType: BuiltValueNullFieldError.checkNotNull(
              calendarType,
              r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent',
              'calendarType'),
          originalYear: BuiltValueNullFieldError.checkNotNull(
              originalYear,
              r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent',
              'originalYear'),
          originalMonth: BuiltValueNullFieldError.checkNotNull(
              originalMonth,
              r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent',
              'originalMonth'),
          originalDay: BuiltValueNullFieldError.checkNotNull(
              originalDay,
              r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent',
              'originalDay'),
          isLeapMonth: BuiltValueNullFieldError.checkNotNull(
              isLeapMonth,
              r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent',
              'isLeapMonth'),
          solarDate: BuiltValueNullFieldError.checkNotNull(
              solarDate,
              r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent',
              'solarDate'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
