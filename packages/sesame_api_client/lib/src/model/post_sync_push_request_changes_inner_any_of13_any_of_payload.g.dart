// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of13_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_blank =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum._(
        'blank');
const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_template =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum._(
        'template');
const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_plan =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum._(
        'plan');

PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumValueOf(
        String name) {
  switch (name) {
    case 'blank':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_blank;
    case 'template':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_template;
    case 'plan':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_plan;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum>(const <PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_blank,
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_template,
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum_plan,
]);

const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_scheduled =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum._(
        'scheduled');
const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_inProgress =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum._(
        'inProgress');
const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_completed =
    const PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum._(
        'completed');

PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'scheduled':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_scheduled;
    case 'inProgress':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_inProgress;
    case 'completed':
      return _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_completed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum>(const <PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum>[
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_scheduled,
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_inProgress,
  _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum_completed,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumSerializer();
Serializer<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum>
    _$postSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload {
  @override
  final String name;
  @override
  final String scheduledDate;
  @override
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum
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
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>
      exercises;
  @override
  final PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum status;
  @override
  final BuiltList<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>
      runSegments;
  @override
  final GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerRestTimer?
      restTimer;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload._(
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
      required this.updatedAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload &&
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
        updatedAt == other.updatedAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload')
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
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _scheduledDate;
  String? get scheduledDate => _$this._scheduledDate;
  set scheduledDate(String? scheduledDate) =>
      _$this._scheduledDate = scheduledDate;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum? _sourceKind;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum?
      get sourceKind => _$this._sourceKind;
  set sourceKind(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadSourceKindEnum?
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

  ListBuilder<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>?
      _exercises;
  ListBuilder<PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>
      get exercises => _$this._exercises ??= ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>();
  set exercises(
          ListBuilder<
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadExercisesInner>?
              exercises) =>
      _$this._exercises = exercises;

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum? _status;
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum? get status =>
      _$this._status;
  set status(
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadStatusEnum?
              status) =>
      _$this._status = status;

  ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>?
      _runSegments;
  ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>
      get runSegments => _$this._runSegments ??= ListBuilder<
          PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>();
  set runSegments(
          ListBuilder<
                  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadRunSegmentsInner>?
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

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf13AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload._(
            name: BuiltValueNullFieldError.checkNotNull(name,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload', 'name'),
            scheduledDate: BuiltValueNullFieldError.checkNotNull(
                scheduledDate,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload',
                'scheduledDate'),
            sourceKind: BuiltValueNullFieldError.checkNotNull(
                sourceKind,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload',
                'sourceKind'),
            sourcePlanId: sourcePlanId,
            sourcePlanName: sourcePlanName,
            sourceTemplateId: sourceTemplateId,
            occurrenceKey: occurrenceKey,
            exercises: exercises.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload',
                'status'),
            runSegments: runSegments.build(),
            restTimer: _restTimer?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload',
                'updatedAt'),
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
            r'PostSyncPushRequestChangesInnerAnyOf13AnyOfPayload',
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
