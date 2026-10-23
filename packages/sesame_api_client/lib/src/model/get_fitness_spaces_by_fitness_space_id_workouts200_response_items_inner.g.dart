// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_blank =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
        ._('blank');
const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_template =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
        ._('template');
const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_plan =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
        ._('plan');

GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumValueOf(
        String name) {
  switch (name) {
    case 'blank':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_blank;
    case 'template':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_template;
    case 'plan':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_plan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum>(const <GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum>[
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_blank,
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_template,
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum_plan,
]);

const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_scheduled =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
        ._('scheduled');
const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_inProgress =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
        ._('inProgress');
const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_completed =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
        ._('completed');

GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'scheduled':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_scheduled;
    case 'inProgress':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_inProgress;
    case 'completed':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_completed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum>(const <GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum>[
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_scheduled,
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_inProgress,
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum_completed,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumSerializer();
Serializer<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'blank': 'blank',
    'template': 'template',
    'plan': 'plan',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'blank': 'blank',
    'template': 'template',
    'plan': 'plan',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum> {
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
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner
    extends GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner {
  @override
  final String name;
  @override
  final String scheduledDate;
  @override
  final GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum
      sourceKind;
  @override
  final String? sourcePlanId;
  @override
  final String? sourcePlanName;
  @override
  final String? sourceTemplateId;
  @override
  final String? occurrenceKey;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>
      exercises;
  @override
  final GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum
      status;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>
      runSegments;
  @override
  final GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer?
      restTimer;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String id;
  @override
  final String fitnessSpaceId;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final String? deletedAt;

  factory _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner._(
      {required this.name,
      required this.scheduledDate,
      required this.sourceKind,
      this.sourcePlanId,
      this.sourcePlanName,
      this.sourceTemplateId,
      this.occurrenceKey,
      required this.exercises,
      required this.status,
      required this.runSegments,
      this.restTimer,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.fitnessSpaceId,
      required this.syncId,
      required this.revision,
      this.deletedAt})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner &&
        name == other.name &&
        scheduledDate == other.scheduledDate &&
        sourceKind == other.sourceKind &&
        sourcePlanId == other.sourcePlanId &&
        sourcePlanName == other.sourcePlanName &&
        sourceTemplateId == other.sourceTemplateId &&
        occurrenceKey == other.occurrenceKey &&
        exercises == other.exercises &&
        status == other.status &&
        runSegments == other.runSegments &&
        restTimer == other.restTimer &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        id == other.id &&
        fitnessSpaceId == other.fitnessSpaceId &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, scheduledDate.hashCode);
    _$hash = $jc(_$hash, sourceKind.hashCode);
    _$hash = $jc(_$hash, sourcePlanId.hashCode);
    _$hash = $jc(_$hash, sourcePlanName.hashCode);
    _$hash = $jc(_$hash, sourceTemplateId.hashCode);
    _$hash = $jc(_$hash, occurrenceKey.hashCode);
    _$hash = $jc(_$hash, exercises.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, runSegments.hashCode);
    _$hash = $jc(_$hash, restTimer.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fitnessSpaceId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner')
          ..add('name', name)
          ..add('scheduledDate', scheduledDate)
          ..add('sourceKind', sourceKind)
          ..add('sourcePlanId', sourcePlanId)
          ..add('sourcePlanName', sourcePlanName)
          ..add('sourceTemplateId', sourceTemplateId)
          ..add('occurrenceKey', occurrenceKey)
          ..add('exercises', exercises)
          ..add('status', status)
          ..add('runSegments', runSegments)
          ..add('restTimer', restTimer)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('id', id)
          ..add('fitnessSpaceId', fitnessSpaceId)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _scheduledDate;
  String? get scheduledDate => _$this._scheduledDate;
  set scheduledDate(String? scheduledDate) =>
      _$this._scheduledDate = scheduledDate;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum?
      _sourceKind;
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum?
      get sourceKind => _$this._sourceKind;
  set sourceKind(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerSourceKindEnum?
              sourceKind) =>
      _$this._sourceKind = sourceKind;

  String? _sourcePlanId;
  String? get sourcePlanId => _$this._sourcePlanId;
  set sourcePlanId(String? sourcePlanId) => _$this._sourcePlanId = sourcePlanId;

  String? _sourcePlanName;
  String? get sourcePlanName => _$this._sourcePlanName;
  set sourcePlanName(String? sourcePlanName) =>
      _$this._sourcePlanName = sourcePlanName;

  String? _sourceTemplateId;
  String? get sourceTemplateId => _$this._sourceTemplateId;
  set sourceTemplateId(String? sourceTemplateId) =>
      _$this._sourceTemplateId = sourceTemplateId;

  String? _occurrenceKey;
  String? get occurrenceKey => _$this._occurrenceKey;
  set occurrenceKey(String? occurrenceKey) =>
      _$this._occurrenceKey = occurrenceKey;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>?
      _exercises;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>
      get exercises => _$this._exercises ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>();
  set exercises(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInner>?
              exercises) =>
      _$this._exercises = exercises;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum?
      _status;
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum?
      get status => _$this._status;
  set status(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerStatusEnum?
              status) =>
      _$this._status = status;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>?
      _runSegments;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>
      get runSegments => _$this._runSegments ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>();
  set runSegments(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRunSegmentsInner>?
              runSegments) =>
      _$this._runSegments = runSegments;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder?
      _restTimer;
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder
      get restTimer => _$this._restTimer ??=
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder();
  set restTimer(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimerBuilder?
              restTimer) =>
      _$this._restTimer = restTimer;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fitnessSpaceId;
  String? get fitnessSpaceId => _$this._fitnessSpaceId;
  set fitnessSpaceId(String? fitnessSpaceId) =>
      _$this._fitnessSpaceId = fitnessSpaceId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _deletedAt;
  String? get deletedAt => _$this._deletedAt;
  set deletedAt(String? deletedAt) => _$this._deletedAt = deletedAt;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner._defaults(
        this);
  }

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _scheduledDate = $v.scheduledDate;
      _sourceKind = $v.sourceKind;
      _sourcePlanId = $v.sourcePlanId;
      _sourcePlanName = $v.sourcePlanName;
      _sourceTemplateId = $v.sourceTemplateId;
      _occurrenceKey = $v.occurrenceKey;
      _exercises = $v.exercises.toBuilder();
      _status = $v.status;
      _runSegments = $v.runSegments.toBuilder();
      _restTimer = $v.restTimer?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _id = $v.id;
      _fitnessSpaceId = $v.fitnessSpaceId;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner _build() {
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner._(
            name: BuiltValueNullFieldError.checkNotNull(
                name,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'name'),
            scheduledDate: BuiltValueNullFieldError.checkNotNull(
                scheduledDate,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'scheduledDate'),
            sourceKind: BuiltValueNullFieldError.checkNotNull(
                sourceKind,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'sourceKind'),
            sourcePlanId: sourcePlanId,
            sourcePlanName: sourcePlanName,
            sourceTemplateId: sourceTemplateId,
            occurrenceKey: occurrenceKey,
            exercises: exercises.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'status'),
            runSegments: runSegments.build(),
            restTimer: _restTimer?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'updatedAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'id'),
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'fitnessSpaceId'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'syncId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
                'revision'),
            deletedAt: deletedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'exercises';
        exercises.build();

        _$failedField = 'runSegments';
        runSegments.build();
        _$failedField = 'restTimer';
        _restTimer?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInner',
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
