// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_library200_response_templates_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
    _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_beginner =
    const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum._(
        'beginner');
const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
    _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_intermediate =
    const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum._(
        'intermediate');
const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
    _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_advanced =
    const GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum._(
        'advanced');

GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
    _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnumValueOf(
        String name) {
  switch (name) {
    case 'beginner':
      return _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_beginner;
    case 'intermediate':
      return _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_intermediate;
    case 'advanced':
      return _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_advanced;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum>
    _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnumValues = BuiltSet<
        GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum>(const <GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum>[
  _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_beginner,
  _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_intermediate,
  _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnum_advanced,
]);

Serializer<GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum>
    _$getFitnessLibrary200ResponseTemplatesInnerDifficultyEnumSerializer =
    _$GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnumSerializer();

class _$GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'beginner': 'beginner',
    'intermediate': 'intermediate',
    'advanced': 'advanced',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'beginner': 'beginner',
    'intermediate': 'intermediate',
    'advanced': 'advanced',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum
  ];
  @override
  final String wireName =
      'GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum';

  @override
  Object serialize(Serializers serializers,
          GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetFitnessLibrary200ResponseTemplatesInner
    extends GetFitnessLibrary200ResponseTemplatesInner {
  @override
  final String id;
  @override
  final int revision;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName name;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName description;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum difficulty;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerGoals goals;
  @override
  final int durationMinutes;
  @override
  final BuiltSet<String> equipment;
  @override
  final BuiltList<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>
      exercises;

  factory _$GetFitnessLibrary200ResponseTemplatesInner(
          [void Function(GetFitnessLibrary200ResponseTemplatesInnerBuilder)?
              updates]) =>
      (GetFitnessLibrary200ResponseTemplatesInnerBuilder()..update(updates))
          ._build();

  _$GetFitnessLibrary200ResponseTemplatesInner._(
      {required this.id,
      required this.revision,
      required this.name,
      required this.description,
      required this.difficulty,
      required this.goals,
      required this.durationMinutes,
      required this.equipment,
      required this.exercises})
      : super._();
  @override
  GetFitnessLibrary200ResponseTemplatesInner rebuild(
          void Function(GetFitnessLibrary200ResponseTemplatesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessLibrary200ResponseTemplatesInnerBuilder toBuilder() =>
      GetFitnessLibrary200ResponseTemplatesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessLibrary200ResponseTemplatesInner &&
        id == other.id &&
        revision == other.revision &&
        name == other.name &&
        description == other.description &&
        difficulty == other.difficulty &&
        goals == other.goals &&
        durationMinutes == other.durationMinutes &&
        equipment == other.equipment &&
        exercises == other.exercises;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, difficulty.hashCode);
    _$hash = $jc(_$hash, goals.hashCode);
    _$hash = $jc(_$hash, durationMinutes.hashCode);
    _$hash = $jc(_$hash, equipment.hashCode);
    _$hash = $jc(_$hash, exercises.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessLibrary200ResponseTemplatesInner')
          ..add('id', id)
          ..add('revision', revision)
          ..add('name', name)
          ..add('description', description)
          ..add('difficulty', difficulty)
          ..add('goals', goals)
          ..add('durationMinutes', durationMinutes)
          ..add('equipment', equipment)
          ..add('exercises', exercises))
        .toString();
  }
}

class GetFitnessLibrary200ResponseTemplatesInnerBuilder
    implements
        Builder<GetFitnessLibrary200ResponseTemplatesInner,
            GetFitnessLibrary200ResponseTemplatesInnerBuilder> {
  _$GetFitnessLibrary200ResponseTemplatesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  GetFitnessLibrary200ResponseTemplatesInnerNameBuilder? _name;
  GetFitnessLibrary200ResponseTemplatesInnerNameBuilder get name =>
      _$this._name ??= GetFitnessLibrary200ResponseTemplatesInnerNameBuilder();
  set name(GetFitnessLibrary200ResponseTemplatesInnerNameBuilder? name) =>
      _$this._name = name;

  GetFitnessLibrary200ResponseTemplatesInnerNameBuilder? _description;
  GetFitnessLibrary200ResponseTemplatesInnerNameBuilder get description =>
      _$this._description ??=
          GetFitnessLibrary200ResponseTemplatesInnerNameBuilder();
  set description(
          GetFitnessLibrary200ResponseTemplatesInnerNameBuilder? description) =>
      _$this._description = description;

  GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum? _difficulty;
  GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum? get difficulty =>
      _$this._difficulty;
  set difficulty(
          GetFitnessLibrary200ResponseTemplatesInnerDifficultyEnum?
              difficulty) =>
      _$this._difficulty = difficulty;

  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder? _goals;
  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder get goals =>
      _$this._goals ??=
          GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder();
  set goals(GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder? goals) =>
      _$this._goals = goals;

  int? _durationMinutes;
  int? get durationMinutes => _$this._durationMinutes;
  set durationMinutes(int? durationMinutes) =>
      _$this._durationMinutes = durationMinutes;

  SetBuilder<String>? _equipment;
  SetBuilder<String> get equipment =>
      _$this._equipment ??= SetBuilder<String>();
  set equipment(SetBuilder<String>? equipment) => _$this._equipment = equipment;

  ListBuilder<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>?
      _exercises;
  ListBuilder<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>
      get exercises => _$this._exercises ??= ListBuilder<
          GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>();
  set exercises(
          ListBuilder<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>?
              exercises) =>
      _$this._exercises = exercises;

  GetFitnessLibrary200ResponseTemplatesInnerBuilder() {
    GetFitnessLibrary200ResponseTemplatesInner._defaults(this);
  }

  GetFitnessLibrary200ResponseTemplatesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _revision = $v.revision;
      _name = $v.name.toBuilder();
      _description = $v.description.toBuilder();
      _difficulty = $v.difficulty;
      _goals = $v.goals.toBuilder();
      _durationMinutes = $v.durationMinutes;
      _equipment = $v.equipment.toBuilder();
      _exercises = $v.exercises.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessLibrary200ResponseTemplatesInner other) {
    _$v = other as _$GetFitnessLibrary200ResponseTemplatesInner;
  }

  @override
  void update(
      void Function(GetFitnessLibrary200ResponseTemplatesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInner build() => _build();

  _$GetFitnessLibrary200ResponseTemplatesInner _build() {
    _$GetFitnessLibrary200ResponseTemplatesInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessLibrary200ResponseTemplatesInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GetFitnessLibrary200ResponseTemplatesInner', 'id'),
            revision: BuiltValueNullFieldError.checkNotNull(revision,
                r'GetFitnessLibrary200ResponseTemplatesInner', 'revision'),
            name: name.build(),
            description: description.build(),
            difficulty: BuiltValueNullFieldError.checkNotNull(difficulty,
                r'GetFitnessLibrary200ResponseTemplatesInner', 'difficulty'),
            goals: goals.build(),
            durationMinutes: BuiltValueNullFieldError.checkNotNull(
                durationMinutes,
                r'GetFitnessLibrary200ResponseTemplatesInner',
                'durationMinutes'),
            equipment: equipment.build(),
            exercises: exercises.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'name';
        name.build();
        _$failedField = 'description';
        description.build();

        _$failedField = 'goals';
        goals.build();

        _$failedField = 'equipment';
        equipment.build();
        _$failedField = 'exercises';
        exercises.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessLibrary200ResponseTemplatesInner',
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
