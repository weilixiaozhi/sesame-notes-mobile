// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_fitness_spaces_by_fitness_space_id_plans_by_plan_id_command_request_plan.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum_inProgress =
    const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
        ._('inProgress');
const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum_closed =
    const PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
        ._('closed');

PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'inProgress':
      return _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum_inProgress;
    case 'closed':
      return _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum_closed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum>
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnumValues =
    BuiltSet<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum>(const <PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum>[
  _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum_inProgress,
  _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum_closed,
]);

Serializer<
        PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum>
    _$postFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnumSerializer =
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnumSerializer();

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnumSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'inProgress': 'in_progress',
    'closed': 'closed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'in_progress': 'inProgress',
    'closed': 'closed',
  };

  @override
  final Iterable<Type> types = const <Type>[
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
  ];
  @override
  final String wireName =
      'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan
    extends PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan {
  @override
  final String name;
  @override
  final GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin?
      catalogOrigin;
  @override
  final String? startDate;
  @override
  final PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum
      status;
  @override
  final int cycleDays;
  @override
  final BuiltList<
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner> days;
  @override
  final GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
      generationState;
  @override
  final GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingSchedule?
      pendingSchedule;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan(
          [void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder)?
              updates]) =>
      (PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder()
            ..update(updates))
          ._build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan._(
      {required this.name,
      this.catalogOrigin,
      this.startDate,
      required this.status,
      required this.cycleDays,
      required this.days,
      required this.generationState,
      this.pendingSchedule,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan rebuild(
          void Function(
                  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder
      toBuilder() =>
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan &&
        name == other.name &&
        catalogOrigin == other.catalogOrigin &&
        startDate == other.startDate &&
        status == other.status &&
        cycleDays == other.cycleDays &&
        days == other.days &&
        generationState == other.generationState &&
        pendingSchedule == other.pendingSchedule &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, catalogOrigin.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, cycleDays.hashCode);
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jc(_$hash, generationState.hashCode);
    _$hash = $jc(_$hash, pendingSchedule.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan')
          ..add('name', name)
          ..add('catalogOrigin', catalogOrigin)
          ..add('startDate', startDate)
          ..add('status', status)
          ..add('cycleDays', cycleDays)
          ..add('days', days)
          ..add('generationState', generationState)
          ..add('pendingSchedule', pendingSchedule)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder
    implements
        Builder<
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan,
            PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder> {
  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder?
      _catalogOrigin;
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder
      get catalogOrigin => _$this._catalogOrigin ??=
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder();
  set catalogOrigin(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOriginBuilder?
              catalogOrigin) =>
      _$this._catalogOrigin = catalogOrigin;

  String? _startDate;
  String? get startDate => _$this._startDate;
  set startDate(String? startDate) => _$this._startDate = startDate;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum?
      _status;
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum?
      get status => _$this._status;
  set status(
          PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanStatusEnum?
              status) =>
      _$this._status = status;

  int? _cycleDays;
  int? get cycleDays => _$this._cycleDays;
  set cycleDays(int? cycleDays) => _$this._cycleDays = cycleDays;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>?
      _days;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>
      get days => _$this._days ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>();
  set days(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInner>?
              days) =>
      _$this._days = days;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder?
      _generationState;
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
      get generationState => _$this._generationState ??=
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder();
  set generationState(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder?
              generationState) =>
      _$this._generationState = generationState;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder?
      _pendingSchedule;
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder
      get pendingSchedule => _$this._pendingSchedule ??=
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder();
  set pendingSchedule(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerPendingScheduleBuilder?
              pendingSchedule) =>
      _$this._pendingSchedule = pendingSchedule;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder() {
    PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan._defaults(
        this);
  }

  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _catalogOrigin = $v.catalogOrigin?.toBuilder();
      _startDate = $v.startDate;
      _status = $v.status;
      _cycleDays = $v.cycleDays;
      _days = $v.days.toBuilder();
      _generationState = $v.generationState.toBuilder();
      _pendingSchedule = $v.pendingSchedule?.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan other) {
    _$v = other
        as _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan;
  }

  @override
  void update(
      void Function(
              PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlanBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan build() =>
      _build();

  _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan _build() {
    _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan _$result;
    try {
      _$result = _$v ??
          _$PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan._(
            name: BuiltValueNullFieldError.checkNotNull(
                name,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan',
                'name'),
            catalogOrigin: _catalogOrigin?.build(),
            startDate: startDate,
            status: BuiltValueNullFieldError.checkNotNull(
                status,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan',
                'status'),
            cycleDays: BuiltValueNullFieldError.checkNotNull(
                cycleDays,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan',
                'cycleDays'),
            days: days.build(),
            generationState: generationState.build(),
            pendingSchedule: _pendingSchedule?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan',
                'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'catalogOrigin';
        _catalogOrigin?.build();

        _$failedField = 'days';
        days.build();
        _$failedField = 'generationState';
        generationState.build();
        _$failedField = 'pendingSchedule';
        _pendingSchedule?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostFitnessSpacesByFitnessSpaceIdPlansByPlanIdCommandRequestPlan',
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
