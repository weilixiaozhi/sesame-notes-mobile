// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_workouts200_response_items_inner_exercises_inner_sets_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
        ._('warmup');
const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working =
    const GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
        ._('working');

GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'warmup':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup;
    case 'working':
      return _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>(const <GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>[
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup,
  _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'warmup': 'warmup',
    'working': 'working',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'warmup': 'warmup',
    'working': 'working',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
    extends GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      kind;
  @override
  final String? weight;
  @override
  final String? weightLeft;
  @override
  final String? weightRight;
  @override
  final int? reps;
  @override
  final bool completed;
  @override
  final BuiltList<int>? restDurationsSeconds;

  factory _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner._(
      {required this.id,
      required this.kind,
      this.weight,
      this.weightLeft,
      this.weightRight,
      this.reps,
      required this.completed,
      this.restDurationsSeconds})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner &&
        id == other.id &&
        kind == other.kind &&
        weight == other.weight &&
        weightLeft == other.weightLeft &&
        weightRight == other.weightRight &&
        reps == other.reps &&
        completed == other.completed &&
        restDurationsSeconds == other.restDurationsSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, weightLeft.hashCode);
    _$hash = $jc(_$hash, weightRight.hashCode);
    _$hash = $jc(_$hash, reps.hashCode);
    _$hash = $jc(_$hash, completed.hashCode);
    _$hash = $jc(_$hash, restDurationsSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('weight', weight)
          ..add('weightLeft', weightLeft)
          ..add('weightRight', weightRight)
          ..add('reps', reps)
          ..add('completed', completed)
          ..add('restDurationsSeconds', restDurationsSeconds))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner,
            GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum?
      _kind;
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum?
      get kind => _$this._kind;
  set kind(
          GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerKindEnum?
              kind) =>
      _$this._kind = kind;

  String? _weight;
  String? get weight => _$this._weight;
  set weight(String? weight) => _$this._weight = weight;

  String? _weightLeft;
  String? get weightLeft => _$this._weightLeft;
  set weightLeft(String? weightLeft) => _$this._weightLeft = weightLeft;

  String? _weightRight;
  String? get weightRight => _$this._weightRight;
  set weightRight(String? weightRight) => _$this._weightRight = weightRight;

  int? _reps;
  int? get reps => _$this._reps;
  set reps(int? reps) => _$this._reps = reps;

  bool? _completed;
  bool? get completed => _$this._completed;
  set completed(bool? completed) => _$this._completed = completed;

  ListBuilder<int>? _restDurationsSeconds;
  ListBuilder<int> get restDurationsSeconds =>
      _$this._restDurationsSeconds ??= ListBuilder<int>();
  set restDurationsSeconds(ListBuilder<int>? restDurationsSeconds) =>
      _$this._restDurationsSeconds = restDurationsSeconds;

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _weight = $v.weight;
      _weightLeft = $v.weightLeft;
      _weightRight = $v.weightRight;
      _reps = $v.reps;
      _completed = $v.completed;
      _restDurationsSeconds = $v.restDurationsSeconds?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner
              ._(
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner',
                'id'),
            kind: BuiltValueNullFieldError.checkNotNull(
                kind,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner',
                'kind'),
            weight: weight,
            weightLeft: weightLeft,
            weightRight: weightRight,
            reps: reps,
            completed: BuiltValueNullFieldError.checkNotNull(
                completed,
                r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner',
                'completed'),
            restDurationsSeconds: _restDurationsSeconds?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'restDurationsSeconds';
        _restDurationsSeconds?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdWorkouts200ResponseItemsInnerExercisesInnerSetsInner',
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
