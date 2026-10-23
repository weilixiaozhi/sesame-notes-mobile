// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_library200_response_plans_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum
    _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_beginner =
    const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum._('beginner');
const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum
    _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_intermediate =
    const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum._(
        'intermediate');
const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum
    _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_advanced =
    const GetFitnessLibrary200ResponsePlansInnerDifficultyEnum._('advanced');

GetFitnessLibrary200ResponsePlansInnerDifficultyEnum
    _$getFitnessLibrary200ResponsePlansInnerDifficultyEnumValueOf(String name) {
  switch (name) {
    case 'beginner':
      return _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_beginner;
    case 'intermediate':
      return _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_intermediate;
    case 'advanced':
      return _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_advanced;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetFitnessLibrary200ResponsePlansInnerDifficultyEnum>
    _$getFitnessLibrary200ResponsePlansInnerDifficultyEnumValues = BuiltSet<
        GetFitnessLibrary200ResponsePlansInnerDifficultyEnum>(const <GetFitnessLibrary200ResponsePlansInnerDifficultyEnum>[
  _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_beginner,
  _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_intermediate,
  _$getFitnessLibrary200ResponsePlansInnerDifficultyEnum_advanced,
]);

Serializer<GetFitnessLibrary200ResponsePlansInnerDifficultyEnum>
    _$getFitnessLibrary200ResponsePlansInnerDifficultyEnumSerializer =
    _$GetFitnessLibrary200ResponsePlansInnerDifficultyEnumSerializer();

class _$GetFitnessLibrary200ResponsePlansInnerDifficultyEnumSerializer
    implements
        PrimitiveSerializer<
            GetFitnessLibrary200ResponsePlansInnerDifficultyEnum> {
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
    GetFitnessLibrary200ResponsePlansInnerDifficultyEnum
  ];
  @override
  final String wireName =
      'GetFitnessLibrary200ResponsePlansInnerDifficultyEnum';

  @override
  Object serialize(Serializers serializers,
          GetFitnessLibrary200ResponsePlansInnerDifficultyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetFitnessLibrary200ResponsePlansInnerDifficultyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetFitnessLibrary200ResponsePlansInnerDifficultyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetFitnessLibrary200ResponsePlansInner
    extends GetFitnessLibrary200ResponsePlansInner {
  @override
  final String id;
  @override
  final int revision;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName name;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName description;
  @override
  final GetFitnessLibrary200ResponsePlansInnerDifficultyEnum difficulty;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerGoals goals;
  @override
  final int cycleDays;
  @override
  final BuiltList<GetFitnessLibrary200ResponsePlansInnerDaysInner> days;

  factory _$GetFitnessLibrary200ResponsePlansInner(
          [void Function(GetFitnessLibrary200ResponsePlansInnerBuilder)?
              updates]) =>
      (GetFitnessLibrary200ResponsePlansInnerBuilder()..update(updates))
          ._build();

  _$GetFitnessLibrary200ResponsePlansInner._(
      {required this.id,
      required this.revision,
      required this.name,
      required this.description,
      required this.difficulty,
      required this.goals,
      required this.cycleDays,
      required this.days})
      : super._();
  @override
  GetFitnessLibrary200ResponsePlansInner rebuild(
          void Function(GetFitnessLibrary200ResponsePlansInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessLibrary200ResponsePlansInnerBuilder toBuilder() =>
      GetFitnessLibrary200ResponsePlansInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetFitnessLibrary200ResponsePlansInner &&
        id == other.id &&
        revision == other.revision &&
        name == other.name &&
        description == other.description &&
        difficulty == other.difficulty &&
        goals == other.goals &&
        cycleDays == other.cycleDays &&
        days == other.days;
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
    _$hash = $jc(_$hash, cycleDays.hashCode);
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessLibrary200ResponsePlansInner')
          ..add('id', id)
          ..add('revision', revision)
          ..add('name', name)
          ..add('description', description)
          ..add('difficulty', difficulty)
          ..add('goals', goals)
          ..add('cycleDays', cycleDays)
          ..add('days', days))
        .toString();
  }
}

class GetFitnessLibrary200ResponsePlansInnerBuilder
    implements
        Builder<GetFitnessLibrary200ResponsePlansInner,
            GetFitnessLibrary200ResponsePlansInnerBuilder> {
  _$GetFitnessLibrary200ResponsePlansInner? _$v;

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

  GetFitnessLibrary200ResponsePlansInnerDifficultyEnum? _difficulty;
  GetFitnessLibrary200ResponsePlansInnerDifficultyEnum? get difficulty =>
      _$this._difficulty;
  set difficulty(
          GetFitnessLibrary200ResponsePlansInnerDifficultyEnum? difficulty) =>
      _$this._difficulty = difficulty;

  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder? _goals;
  GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder get goals =>
      _$this._goals ??=
          GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder();
  set goals(GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder? goals) =>
      _$this._goals = goals;

  int? _cycleDays;
  int? get cycleDays => _$this._cycleDays;
  set cycleDays(int? cycleDays) => _$this._cycleDays = cycleDays;

  ListBuilder<GetFitnessLibrary200ResponsePlansInnerDaysInner>? _days;
  ListBuilder<GetFitnessLibrary200ResponsePlansInnerDaysInner> get days =>
      _$this._days ??=
          ListBuilder<GetFitnessLibrary200ResponsePlansInnerDaysInner>();
  set days(
          ListBuilder<GetFitnessLibrary200ResponsePlansInnerDaysInner>? days) =>
      _$this._days = days;

  GetFitnessLibrary200ResponsePlansInnerBuilder() {
    GetFitnessLibrary200ResponsePlansInner._defaults(this);
  }

  GetFitnessLibrary200ResponsePlansInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _revision = $v.revision;
      _name = $v.name.toBuilder();
      _description = $v.description.toBuilder();
      _difficulty = $v.difficulty;
      _goals = $v.goals.toBuilder();
      _cycleDays = $v.cycleDays;
      _days = $v.days.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetFitnessLibrary200ResponsePlansInner other) {
    _$v = other as _$GetFitnessLibrary200ResponsePlansInner;
  }

  @override
  void update(
      void Function(GetFitnessLibrary200ResponsePlansInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessLibrary200ResponsePlansInner build() => _build();

  _$GetFitnessLibrary200ResponsePlansInner _build() {
    _$GetFitnessLibrary200ResponsePlansInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessLibrary200ResponsePlansInner._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GetFitnessLibrary200ResponsePlansInner', 'id'),
            revision: BuiltValueNullFieldError.checkNotNull(revision,
                r'GetFitnessLibrary200ResponsePlansInner', 'revision'),
            name: name.build(),
            description: description.build(),
            difficulty: BuiltValueNullFieldError.checkNotNull(difficulty,
                r'GetFitnessLibrary200ResponsePlansInner', 'difficulty'),
            goals: goals.build(),
            cycleDays: BuiltValueNullFieldError.checkNotNull(cycleDays,
                r'GetFitnessLibrary200ResponsePlansInner', 'cycleDays'),
            days: days.build(),
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

        _$failedField = 'days';
        days.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessLibrary200ResponsePlansInner',
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
