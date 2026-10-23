// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum_inProgress =
    const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
        ._('inProgress');
const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum_closed =
    const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
        ._('closed');

GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'inProgress':
      return _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum_inProgress;
    case 'closed':
      return _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum_closed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum>(const <GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum>[
  _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum_inProgress,
  _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum_closed,
]);

Serializer<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum>
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum> {
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
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner
    extends GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner {
  @override
  final String name;
  @override
  final GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerCatalogOrigin?
      catalogOrigin;
  @override
  final String? startDate;
  @override
  final GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum
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

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner._(
      {required this.name,
      this.catalogOrigin,
      this.startDate,
      required this.status,
      required this.cycleDays,
      required this.days,
      required this.generationState,
      this.pendingSchedule,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.fitnessSpaceId,
      required this.syncId,
      required this.revision,
      this.deletedAt})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner &&
        name == other.name &&
        catalogOrigin == other.catalogOrigin &&
        startDate == other.startDate &&
        status == other.status &&
        cycleDays == other.cycleDays &&
        days == other.days &&
        generationState == other.generationState &&
        pendingSchedule == other.pendingSchedule &&
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
    _$hash = $jc(_$hash, catalogOrigin.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, cycleDays.hashCode);
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jc(_$hash, generationState.hashCode);
    _$hash = $jc(_$hash, pendingSchedule.hashCode);
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
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner')
          ..add('name', name)
          ..add('catalogOrigin', catalogOrigin)
          ..add('startDate', startDate)
          ..add('status', status)
          ..add('cycleDays', cycleDays)
          ..add('days', days)
          ..add('generationState', generationState)
          ..add('pendingSchedule', pendingSchedule)
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

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder
    implements
        Builder<GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner? _$v;

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

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum? _status;
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum?
      get status => _$this._status;
  set status(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerStatusEnum?
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

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder get _$this {
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
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner other) {
    _$v = other as _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner._(
            name: BuiltValueNullFieldError.checkNotNull(
                name,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'name'),
            catalogOrigin: _catalogOrigin?.build(),
            startDate: startDate,
            status: BuiltValueNullFieldError.checkNotNull(
                status,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'status'),
            cycleDays: BuiltValueNullFieldError.checkNotNull(
                cycleDays,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'cycleDays'),
            days: days.build(),
            generationState: generationState.build(),
            pendingSchedule: _pendingSchedule?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'updatedAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'id'),
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'fitnessSpaceId'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'syncId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
                'revision'),
            deletedAt: deletedAt,
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
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInner',
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
