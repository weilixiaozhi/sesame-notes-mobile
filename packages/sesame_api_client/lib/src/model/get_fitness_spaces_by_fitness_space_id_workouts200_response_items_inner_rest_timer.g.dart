// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_rest_timer.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_running =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
        ._('running');
const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_paused =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
        ._('paused');

GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'running':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_running;
    case 'paused':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_paused;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum>(const <GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum>[
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_running,
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum_paused,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'running': 'running',
    'paused': 'paused',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'running': 'running',
    'paused': 'paused',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
    extends GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer {
  @override
  final GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum
      status;
  @override
  final DateTime? endsAt;
  @override
  final int remainingSeconds;
  @override
  final int durationSeconds;
  @override
  final int? elapsedSeconds;
  @override
  final String? exerciseId;
  @override
  final String? setId;

  factory _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer._(
      {required this.status,
      this.endsAt,
      required this.remainingSeconds,
      required this.durationSeconds,
      this.elapsedSeconds,
      this.exerciseId,
      this.setId})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer &&
        status == other.status &&
        endsAt == other.endsAt &&
        remainingSeconds == other.remainingSeconds &&
        durationSeconds == other.durationSeconds &&
        elapsedSeconds == other.elapsedSeconds &&
        exerciseId == other.exerciseId &&
        setId == other.setId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, endsAt.hashCode);
    _$hash = $jc(_$hash, remainingSeconds.hashCode);
    _$hash = $jc(_$hash, durationSeconds.hashCode);
    _$hash = $jc(_$hash, elapsedSeconds.hashCode);
    _$hash = $jc(_$hash, exerciseId.hashCode);
    _$hash = $jc(_$hash, setId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer')
          ..add('status', status)
          ..add('endsAt', endsAt)
          ..add('remainingSeconds', remainingSeconds)
          ..add('durationSeconds', durationSeconds)
          ..add('elapsedSeconds', elapsedSeconds)
          ..add('exerciseId', exerciseId)
          ..add('setId', setId))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer? _$v;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum?
      _status;
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum?
      get status => _$this._status;
  set status(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerStatusEnum?
              status) =>
      _$this._status = status;

  DateTime? _endsAt;
  DateTime? get endsAt => _$this._endsAt;
  set endsAt(DateTime? endsAt) => _$this._endsAt = endsAt;

  int? _remainingSeconds;
  int? get remainingSeconds => _$this._remainingSeconds;
  set remainingSeconds(int? remainingSeconds) =>
      _$this._remainingSeconds = remainingSeconds;

  int? _durationSeconds;
  int? get durationSeconds => _$this._durationSeconds;
  set durationSeconds(int? durationSeconds) =>
      _$this._durationSeconds = durationSeconds;

  int? _elapsedSeconds;
  int? get elapsedSeconds => _$this._elapsedSeconds;
  set elapsedSeconds(int? elapsedSeconds) =>
      _$this._elapsedSeconds = elapsedSeconds;

  String? _exerciseId;
  String? get exerciseId => _$this._exerciseId;
  set exerciseId(String? exerciseId) => _$this._exerciseId = exerciseId;

  String? _setId;
  String? get setId => _$this._setId;
  set setId(String? setId) => _$this._setId = setId;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _endsAt = $v.endsAt;
      _remainingSeconds = $v.remainingSeconds;
      _durationSeconds = $v.durationSeconds;
      _elapsedSeconds = $v.elapsedSeconds;
      _exerciseId = $v.exerciseId;
      _setId = $v.setId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer
            ._(
          status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer',
              'status'),
          endsAt: endsAt,
          remainingSeconds: BuiltValueNullFieldError.checkNotNull(
              remainingSeconds,
              r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer',
              'remainingSeconds'),
          durationSeconds: BuiltValueNullFieldError.checkNotNull(
              durationSeconds,
              r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer',
              'durationSeconds'),
          elapsedSeconds: elapsedSeconds,
          exerciseId: exerciseId,
          setId: setId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
