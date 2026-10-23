// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of12_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_inProgress =
    const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum._(
        'inProgress');
const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_closed =
    const PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum._(
        'closed');

PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumValueOf(
        String name) {
  switch (name) {
    case 'inProgress':
      return _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_inProgress;
    case 'closed':
      return _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_closed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum>
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumValues =
    BuiltSet<
        PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum>(const <PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum>[
  _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_inProgress,
  _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum_closed,
]);

Serializer<PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum>
    _$postSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumSerializer =
    _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumSerializer();

class _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnumSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum> {
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
    PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum
  ];
  @override
  final String wireName =
      'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum';

  @override
  Object serialize(Serializers serializers,
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload {
  @override
  final String name;
  @override
  final PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin?
      catalogOrigin;
  @override
  final String? startDate;
  @override
  final PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum status;
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

  factory _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload._(
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
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload &&
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
            r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload')
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

class PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder?
      _catalogOrigin;
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
      get catalogOrigin => _$this._catalogOrigin ??=
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder();
  set catalogOrigin(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder?
              catalogOrigin) =>
      _$this._catalogOrigin = catalogOrigin;

  String? _startDate;
  String? get startDate => _$this._startDate;
  set startDate(String? startDate) => _$this._startDate = startDate;

  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum? _status;
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum? get status =>
      _$this._status;
  set status(
          PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadStatusEnum?
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

  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder get _$this {
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
  void replace(PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf12AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload._(
            name: BuiltValueNullFieldError.checkNotNull(name,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload', 'name'),
            catalogOrigin: _catalogOrigin?.build(),
            startDate: startDate,
            status: BuiltValueNullFieldError.checkNotNull(
                status,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload',
                'status'),
            cycleDays: BuiltValueNullFieldError.checkNotNull(
                cycleDays,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload',
                'cycleDays'),
            days: days.build(),
            generationState: generationState.build(),
            pendingSchedule: _pendingSchedule?.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload',
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
            r'PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload',
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
