// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
    extends GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner {
  @override
  final String id;
  @override
  final String exerciseId;
  @override
  final int restSeconds;
  @override
  final int? warmupRestSeconds;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>
      sets;

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner._(
      {required this.id,
      required this.exerciseId,
      required this.restSeconds,
      this.warmupRestSeconds,
      required this.sets})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner &&
        id == other.id &&
        exerciseId == other.exerciseId &&
        restSeconds == other.restSeconds &&
        warmupRestSeconds == other.warmupRestSeconds &&
        sets == other.sets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, exerciseId.hashCode);
    _$hash = $jc(_$hash, restSeconds.hashCode);
    _$hash = $jc(_$hash, warmupRestSeconds.hashCode);
    _$hash = $jc(_$hash, sets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner')
          ..add('id', id)
          ..add('exerciseId', exerciseId)
          ..add('restSeconds', restSeconds)
          ..add('warmupRestSeconds', warmupRestSeconds)
          ..add('sets', sets))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _exerciseId;
  String? get exerciseId => _$this._exerciseId;
  set exerciseId(String? exerciseId) => _$this._exerciseId = exerciseId;

  int? _restSeconds;
  int? get restSeconds => _$this._restSeconds;
  set restSeconds(int? restSeconds) => _$this._restSeconds = restSeconds;

  int? _warmupRestSeconds;
  int? get warmupRestSeconds => _$this._warmupRestSeconds;
  set warmupRestSeconds(int? warmupRestSeconds) =>
      _$this._warmupRestSeconds = warmupRestSeconds;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>?
      _sets;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>
      get sets => _$this._sets ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>();
  set sets(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner>?
              sets) =>
      _$this._sets = sets;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _exerciseId = $v.exerciseId;
      _restSeconds = $v.restSeconds;
      _warmupRestSeconds = $v.warmupRestSeconds;
      _sets = $v.sets.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner',
                'id'),
            exerciseId: BuiltValueNullFieldError.checkNotNull(
                exerciseId,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner',
                'exerciseId'),
            restSeconds: BuiltValueNullFieldError.checkNotNull(
                restSeconds,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner',
                'restSeconds'),
            warmupRestSeconds: warmupRestSeconds,
            sets: sets.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sets';
        sets.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner',
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
