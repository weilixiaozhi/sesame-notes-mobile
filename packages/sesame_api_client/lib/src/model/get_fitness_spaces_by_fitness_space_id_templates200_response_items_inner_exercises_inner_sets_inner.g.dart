// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner_sets_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup =
    const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
        ._('warmup');
const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working =
    const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
        ._('working');

GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValueOf(
        String name) {
  switch (name) {
    case 'warmup':
      return _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup;
    case 'working':
      return _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValues =
    BuiltSet<
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>(const <GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>[
  _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup,
  _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working,
]);

Serializer<
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
    _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer =
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer();

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum> {
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
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
  ];
  @override
  final String wireName =
      'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
    extends GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner {
  @override
  final String id;
  @override
  final GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      kind;
  @override
  final String? weight;
  @override
  final String? weightLeft;
  @override
  final String? weightRight;
  @override
  final int? reps;

  factory _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner._(
      {required this.id,
      required this.kind,
      this.weight,
      this.weightLeft,
      this.weightRight,
      this.reps})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner &&
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
            r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner')
          ..add('id', id)
          ..add('kind', kind)
          ..add('weight', weight)
          ..add('weightLeft', weightLeft)
          ..add('weightRight', weightRight)
          ..add('reps', reps))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner?
      _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum?
      _kind;
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum?
      get kind => _$this._kind;
  set kind(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum?
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

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder
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
      GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
            ._(
          id: BuiltValueNullFieldError.checkNotNull(
              id,
              r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner',
              'id'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind,
              r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner',
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
