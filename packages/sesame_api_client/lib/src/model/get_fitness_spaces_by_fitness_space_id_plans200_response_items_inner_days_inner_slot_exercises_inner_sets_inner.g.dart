// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner_sets_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_warmup =
    const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
        ._('warmup');
const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_working =
    const GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
        ._('working');

GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'warmup':
      return _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_warmup;
    case 'working':
      return _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_working;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum>(const <GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum>[
  _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_warmup,
  _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum_working,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum> {
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
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
    extends GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum
      kind;
  @override
  final String? weight;
  @override
  final String? weightLeft;
  @override
  final String? weightRight;
  @override
  final int? reps;

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner._(
      {required this.id,
      required this.kind,
      this.weight,
      this.weightLeft,
      this.weightRight,
      this.reps})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner &&
        id == other.id &&
        kind == other.kind &&
        weight == other.weight &&
        weightLeft == other.weightLeft &&
        weightRight == other.weightRight &&
        reps == other.reps;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('weight', weight)
          ..add('weightLeft', weightLeft)
          ..add('weightRight', weightRight)
          ..add('reps', reps))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum?
      _kind;
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum?
      get kind => _$this._kind;
  set kind(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerKindEnum?
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

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _kind = $v.kind;
      _weight = $v.weight;
      _weightLeft = $v.weightLeft;
      _weightRight = $v.weightRight;
      _reps = $v.reps;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner
            ._(
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner',
              'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInnerSetsInner',
              'kind'),
          weight: weight,
          weightLeft: weightLeft,
          weightRight: weightRight,
          reps: reps,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
