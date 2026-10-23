// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_library200_response_templates_inner_exercises_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
    _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_total =
    const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
        ._('total');
const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
    _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_perSide =
    const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
        ._('perSide');
const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
    _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_bodyWeight =
    const GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
        ._('bodyWeight');

GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
    _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumValueOf(
        String name) {
  switch (name) {
    case 'total':
      return _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_total;
    case 'perSide':
      return _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_perSide;
    case 'bodyWeight':
      return _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_bodyWeight;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<
        GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum>
    _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumValues =
    BuiltSet<
        GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum>(const <GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum>[
  _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_total,
  _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_perSide,
  _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum_bodyWeight,
]);

Serializer<
        GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum>
    _$getFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumSerializer =
    _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumSerializer();

class _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'total': 'total',
    'perSide': 'per_side',
    'bodyWeight': 'body_weight',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'total': 'total',
    'per_side': 'perSide',
    'body_weight': 'bodyWeight',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
  ];
  @override
  final String wireName =
      'GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum';

  @override
  Object serialize(
          Serializers serializers,
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
              object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      deserialize(Serializers serializers, Object serialized,
              {FullType specifiedType = FullType.unspecified}) =>
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
              .valueOf(_fromWire[serialized] ??
                  (serialized is String ? serialized : ''));
}

class _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner
    extends GetFitnessLibrary200ResponseTemplatesInnerExercisesInner {
  @override
  final String exerciseId;
  @override
  final int sets;
  @override
  final int reps;
  @override
  final String? weightKg;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum
      weightMode;
  @override
  final int restSeconds;

  factory _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner(
          [void Function(
                  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder)?
              updates]) =>
      (GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner._(
      {required this.exerciseId,
      required this.sets,
      required this.reps,
      this.weightKg,
      required this.weightMode,
      required this.restSeconds})
      : super._();
  @override
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInner rebuild(
          void Function(
                  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder toBuilder() =>
      GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessLibrary200ResponseTemplatesInnerExercisesInner &&
        exerciseId == other.exerciseId &&
        sets == other.sets &&
        reps == other.reps &&
        weightKg == other.weightKg &&
        weightMode == other.weightMode &&
        restSeconds == other.restSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exerciseId.hashCode);
    _$hash = $jc(_$hash, sets.hashCode);
    _$hash = $jc(_$hash, reps.hashCode);
    _$hash = $jc(_$hash, weightKg.hashCode);
    _$hash = $jc(_$hash, weightMode.hashCode);
    _$hash = $jc(_$hash, restSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner')
          ..add('exerciseId', exerciseId)
          ..add('sets', sets)
          ..add('reps', reps)
          ..add('weightKg', weightKg)
          ..add('weightMode', weightMode)
          ..add('restSeconds', restSeconds))
        .toString();
  }
}

class GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder
    implements
        Builder<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner,
            GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder> {
  _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner? _$v;

  String? _exerciseId;
  String? get exerciseId => _$this._exerciseId;
  set exerciseId(String? exerciseId) => _$this._exerciseId = exerciseId;

  int? _sets;
  int? get sets => _$this._sets;
  set sets(int? sets) => _$this._sets = sets;

  int? _reps;
  int? get reps => _$this._reps;
  set reps(int? reps) => _$this._reps = reps;

  String? _weightKg;
  String? get weightKg => _$this._weightKg;
  set weightKg(String? weightKg) => _$this._weightKg = weightKg;

  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum?
      _weightMode;
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum?
      get weightMode => _$this._weightMode;
  set weightMode(
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerWeightModeEnum?
              weightMode) =>
      _$this._weightMode = weightMode;

  int? _restSeconds;
  int? get restSeconds => _$this._restSeconds;
  set restSeconds(int? restSeconds) => _$this._restSeconds = restSeconds;

  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder() {
    GetFitnessLibrary200ResponseTemplatesInnerExercisesInner._defaults(this);
  }

  GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exerciseId = $v.exerciseId;
      _sets = $v.sets;
      _reps = $v.reps;
      _weightKg = $v.weightKg;
      _weightMode = $v.weightMode;
      _restSeconds = $v.restSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessLibrary200ResponseTemplatesInnerExercisesInner other) {
    _$v = other as _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner;
  }

  @override
  void update(
      void Function(
              GetFitnessLibrary200ResponseTemplatesInnerExercisesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInnerExercisesInner build() => _build();

  _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner _build() {
    final _$result = _$v ??
        _$GetFitnessLibrary200ResponseTemplatesInnerExercisesInner._(
          exerciseId: BuiltValueNullFieldError.checkNotNull(
              exerciseId,
              r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner',
              'exerciseId'),
          sets: BuiltValueNullFieldError.checkNotNull(
              sets,
              r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner',
              'sets'),
          reps: BuiltValueNullFieldError.checkNotNull(
              reps,
              r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner',
              'reps'),
          weightKg: weightKg,
          weightMode: BuiltValueNullFieldError.checkNotNull(
              weightMode,
              r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner',
              'weightMode'),
          restSeconds: BuiltValueNullFieldError.checkNotNull(
              restSeconds,
              r'GetFitnessLibrary200ResponseTemplatesInnerExercisesInner',
              'restSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
