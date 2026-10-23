// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_calendar200_response_days_inner_workouts_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_scheduled =
    const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
        ._('scheduled');
const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_inProgress =
    const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
        ._('inProgress');
const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_completed =
    const GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
        ._('completed');

GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'scheduled':
      return _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_scheduled;
    case 'inProgress':
      return _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_inProgress;
    case 'completed':
      return _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_completed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum>(const <GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum>[
  _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_scheduled,
  _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_inProgress,
  _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum_completed,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'scheduled': 'scheduled',
    'inProgress': 'in_progress',
    'completed': 'completed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'scheduled': 'scheduled',
    'in_progress': 'inProgress',
    'completed': 'completed',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
    extends GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum
      status;
  @override
  final String scheduledDate;
  @override
  final String workoutDate;
  @override
  final String? sourcePlanId;
  @override
  final String? sourcePlanName;
  @override
  final int revision;

  factory _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner._(
      {required this.id,
      required this.name,
      required this.status,
      required this.scheduledDate,
      required this.workoutDate,
      this.sourcePlanId,
      this.sourcePlanName,
      required this.revision})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner &&
        id == other.id &&
        name == other.name &&
        status == other.status &&
        scheduledDate == other.scheduledDate &&
        workoutDate == other.workoutDate &&
        sourcePlanId == other.sourcePlanId &&
        sourcePlanName == other.sourcePlanName &&
        revision == other.revision;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, scheduledDate.hashCode);
    _$hash = $jc(_$hash, workoutDate.hashCode);
    _$hash = $jc(_$hash, sourcePlanId.hashCode);
    _$hash = $jc(_$hash, sourcePlanName.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner')
          ..add('id', id)
          ..add('name', name)
          ..add('status', status)
          ..add('scheduledDate', scheduledDate)
          ..add('workoutDate', workoutDate)
          ..add('sourcePlanId', sourcePlanId)
          ..add('sourcePlanName', sourcePlanName)
          ..add('revision', revision))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner,
            GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum?
      _status;
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum?
      get status => _$this._status;
  set status(
          GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerStatusEnum?
              status) =>
      _$this._status = status;

  String? _scheduledDate;
  String? get scheduledDate => _$this._scheduledDate;
  set scheduledDate(String? scheduledDate) =>
      _$this._scheduledDate = scheduledDate;

  String? _workoutDate;
  String? get workoutDate => _$this._workoutDate;
  set workoutDate(String? workoutDate) => _$this._workoutDate = workoutDate;

  String? _sourcePlanId;
  String? get sourcePlanId => _$this._sourcePlanId;
  set sourcePlanId(String? sourcePlanId) => _$this._sourcePlanId = sourcePlanId;

  String? _sourcePlanName;
  String? get sourcePlanName => _$this._sourcePlanName;
  set sourcePlanName(String? sourcePlanName) =>
      _$this._sourcePlanName = sourcePlanName;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _status = $v.status;
      _scheduledDate = $v.scheduledDate;
      _workoutDate = $v.workoutDate;
      _sourcePlanId = $v.sourcePlanId;
      _sourcePlanName = $v.sourcePlanName;
      _revision = $v.revision;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner
            ._(
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner',
              'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner',
              'name'),
          status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner',
              'status'),
          scheduledDate: BuiltValueNullFieldError.checkNotNull(
              scheduledDate,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner',
              'scheduledDate'),
          workoutDate: BuiltValueNullFieldError.checkNotNull(
              workoutDate,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner',
              'workoutDate'),
          sourcePlanId: sourcePlanId,
          sourcePlanName: sourcePlanName,
          revision: BuiltValueNullFieldError.checkNotNull(
              revision,
              r'GetFitnessSpacesByFitnessSpaceIdCalendar200ResponseDaysInnerWorkoutsInner',
              'revision'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
