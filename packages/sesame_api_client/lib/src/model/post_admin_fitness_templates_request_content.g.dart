// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_fitness_templates_request_content.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAdminFitnessTemplatesRequestContentDifficultyEnum
    _$postAdminFitnessTemplatesRequestContentDifficultyEnum_beginner =
    const PostAdminFitnessTemplatesRequestContentDifficultyEnum._('beginner');
const PostAdminFitnessTemplatesRequestContentDifficultyEnum
    _$postAdminFitnessTemplatesRequestContentDifficultyEnum_intermediate =
    const PostAdminFitnessTemplatesRequestContentDifficultyEnum._(
        'intermediate');
const PostAdminFitnessTemplatesRequestContentDifficultyEnum
    _$postAdminFitnessTemplatesRequestContentDifficultyEnum_advanced =
    const PostAdminFitnessTemplatesRequestContentDifficultyEnum._('advanced');

PostAdminFitnessTemplatesRequestContentDifficultyEnum
    _$postAdminFitnessTemplatesRequestContentDifficultyEnumValueOf(
        String name) {
  switch (name) {
    case 'beginner':
      return _$postAdminFitnessTemplatesRequestContentDifficultyEnum_beginner;
    case 'intermediate':
      return _$postAdminFitnessTemplatesRequestContentDifficultyEnum_intermediate;
    case 'advanced':
      return _$postAdminFitnessTemplatesRequestContentDifficultyEnum_advanced;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminFitnessTemplatesRequestContentDifficultyEnum>
    _$postAdminFitnessTemplatesRequestContentDifficultyEnumValues = BuiltSet<
        PostAdminFitnessTemplatesRequestContentDifficultyEnum>(const <PostAdminFitnessTemplatesRequestContentDifficultyEnum>[
  _$postAdminFitnessTemplatesRequestContentDifficultyEnum_beginner,
  _$postAdminFitnessTemplatesRequestContentDifficultyEnum_intermediate,
  _$postAdminFitnessTemplatesRequestContentDifficultyEnum_advanced,
]);

Serializer<PostAdminFitnessTemplatesRequestContentDifficultyEnum>
    _$postAdminFitnessTemplatesRequestContentDifficultyEnumSerializer =
    _$PostAdminFitnessTemplatesRequestContentDifficultyEnumSerializer();

class _$PostAdminFitnessTemplatesRequestContentDifficultyEnumSerializer
    implements
        PrimitiveSerializer<
            PostAdminFitnessTemplatesRequestContentDifficultyEnum> {
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
    PostAdminFitnessTemplatesRequestContentDifficultyEnum
  ];
  @override
  final String wireName =
      'PostAdminFitnessTemplatesRequestContentDifficultyEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminFitnessTemplatesRequestContentDifficultyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminFitnessTemplatesRequestContentDifficultyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminFitnessTemplatesRequestContentDifficultyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminFitnessTemplatesRequestContent
    extends PostAdminFitnessTemplatesRequestContent {
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName name;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName description;
  @override
  final PostAdminFitnessTemplatesRequestContentDifficultyEnum difficulty;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerGoals goals;
  @override
  final int durationMinutes;
  @override
  final BuiltSet<String> equipment;
  @override
  final BuiltList<GetFitnessLibrary200ResponseTemplatesInnerExercisesInner>
      exercises;

  factory _$PostAdminFitnessTemplatesRequestContent(
          [void Function(PostAdminFitnessTemplatesRequestContentBuilder)?
              updates]) =>
      (PostAdminFitnessTemplatesRequestContentBuilder()..update(updates))
          ._build();

  _$PostAdminFitnessTemplatesRequestContent._(
      {required this.name,
      required this.description,
      required this.difficulty,
      required this.goals,
      required this.durationMinutes,
      required this.equipment,
      required this.exercises})
      : super._();
  @override
  PostAdminFitnessTemplatesRequestContent rebuild(
          void Function(PostAdminFitnessTemplatesRequestContentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminFitnessTemplatesRequestContentBuilder toBuilder() =>
      PostAdminFitnessTemplatesRequestContentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminFitnessTemplatesRequestContent &&
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
            r'PostAdminFitnessTemplatesRequestContent')
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

class PostAdminFitnessTemplatesRequestContentBuilder
    implements
        Builder<PostAdminFitnessTemplatesRequestContent,
            PostAdminFitnessTemplatesRequestContentBuilder> {
  _$PostAdminFitnessTemplatesRequestContent? _$v;

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

  PostAdminFitnessTemplatesRequestContentDifficultyEnum? _difficulty;
  PostAdminFitnessTemplatesRequestContentDifficultyEnum? get difficulty =>
      _$this._difficulty;
  set difficulty(
          PostAdminFitnessTemplatesRequestContentDifficultyEnum? difficulty) =>
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

  PostAdminFitnessTemplatesRequestContentBuilder() {
    PostAdminFitnessTemplatesRequestContent._defaults(this);
  }

  PostAdminFitnessTemplatesRequestContentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(PostAdminFitnessTemplatesRequestContent other) {
    _$v = other as _$PostAdminFitnessTemplatesRequestContent;
  }

  @override
  void update(
      void Function(PostAdminFitnessTemplatesRequestContentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminFitnessTemplatesRequestContent build() => _build();

  _$PostAdminFitnessTemplatesRequestContent _build() {
    _$PostAdminFitnessTemplatesRequestContent _$result;
    try {
      _$result = _$v ??
          _$PostAdminFitnessTemplatesRequestContent._(
            name: name.build(),
            description: description.build(),
            difficulty: BuiltValueNullFieldError.checkNotNull(difficulty,
                r'PostAdminFitnessTemplatesRequestContent', 'difficulty'),
            goals: goals.build(),
            durationMinutes: BuiltValueNullFieldError.checkNotNull(
                durationMinutes,
                r'PostAdminFitnessTemplatesRequestContent',
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
            r'PostAdminFitnessTemplatesRequestContent',
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
