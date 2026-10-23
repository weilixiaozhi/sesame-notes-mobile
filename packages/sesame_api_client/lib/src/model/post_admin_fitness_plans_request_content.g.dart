// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_fitness_plans_request_content.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PostAdminFitnessPlansRequestContentDifficultyEnum
    _$postAdminFitnessPlansRequestContentDifficultyEnum_beginner =
    const PostAdminFitnessPlansRequestContentDifficultyEnum._('beginner');
const PostAdminFitnessPlansRequestContentDifficultyEnum
    _$postAdminFitnessPlansRequestContentDifficultyEnum_intermediate =
    const PostAdminFitnessPlansRequestContentDifficultyEnum._('intermediate');
const PostAdminFitnessPlansRequestContentDifficultyEnum
    _$postAdminFitnessPlansRequestContentDifficultyEnum_advanced =
    const PostAdminFitnessPlansRequestContentDifficultyEnum._('advanced');

PostAdminFitnessPlansRequestContentDifficultyEnum
    _$postAdminFitnessPlansRequestContentDifficultyEnumValueOf(String name) {
  switch (name) {
    case 'beginner':
      return _$postAdminFitnessPlansRequestContentDifficultyEnum_beginner;
    case 'intermediate':
      return _$postAdminFitnessPlansRequestContentDifficultyEnum_intermediate;
    case 'advanced':
      return _$postAdminFitnessPlansRequestContentDifficultyEnum_advanced;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PostAdminFitnessPlansRequestContentDifficultyEnum>
    _$postAdminFitnessPlansRequestContentDifficultyEnumValues = BuiltSet<
        PostAdminFitnessPlansRequestContentDifficultyEnum>(const <PostAdminFitnessPlansRequestContentDifficultyEnum>[
  _$postAdminFitnessPlansRequestContentDifficultyEnum_beginner,
  _$postAdminFitnessPlansRequestContentDifficultyEnum_intermediate,
  _$postAdminFitnessPlansRequestContentDifficultyEnum_advanced,
]);

Serializer<PostAdminFitnessPlansRequestContentDifficultyEnum>
    _$postAdminFitnessPlansRequestContentDifficultyEnumSerializer =
    _$PostAdminFitnessPlansRequestContentDifficultyEnumSerializer();

class _$PostAdminFitnessPlansRequestContentDifficultyEnumSerializer
    implements
        PrimitiveSerializer<PostAdminFitnessPlansRequestContentDifficultyEnum> {
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
    PostAdminFitnessPlansRequestContentDifficultyEnum
  ];
  @override
  final String wireName = 'PostAdminFitnessPlansRequestContentDifficultyEnum';

  @override
  Object serialize(Serializers serializers,
          PostAdminFitnessPlansRequestContentDifficultyEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PostAdminFitnessPlansRequestContentDifficultyEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PostAdminFitnessPlansRequestContentDifficultyEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$PostAdminFitnessPlansRequestContent
    extends PostAdminFitnessPlansRequestContent {
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName name;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerName description;
  @override
  final PostAdminFitnessPlansRequestContentDifficultyEnum difficulty;
  @override
  final GetFitnessLibrary200ResponseTemplatesInnerGoals goals;
  @override
  final int cycleDays;
  @override
  final BuiltList<GetFitnessLibrary200ResponsePlansInnerDaysInner> days;

  factory _$PostAdminFitnessPlansRequestContent(
          [void Function(PostAdminFitnessPlansRequestContentBuilder)?
              updates]) =>
      (PostAdminFitnessPlansRequestContentBuilder()..update(updates))._build();

  _$PostAdminFitnessPlansRequestContent._(
      {required this.name,
      required this.description,
      required this.difficulty,
      required this.goals,
      required this.cycleDays,
      required this.days})
      : super._();
  @override
  PostAdminFitnessPlansRequestContent rebuild(
          void Function(PostAdminFitnessPlansRequestContentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminFitnessPlansRequestContentBuilder toBuilder() =>
      PostAdminFitnessPlansRequestContentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminFitnessPlansRequestContent &&
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
    return (newBuiltValueToStringHelper(r'PostAdminFitnessPlansRequestContent')
          ..add('name', name)
          ..add('description', description)
          ..add('difficulty', difficulty)
          ..add('goals', goals)
          ..add('cycleDays', cycleDays)
          ..add('days', days))
        .toString();
  }
}

class PostAdminFitnessPlansRequestContentBuilder
    implements
        Builder<PostAdminFitnessPlansRequestContent,
            PostAdminFitnessPlansRequestContentBuilder> {
  _$PostAdminFitnessPlansRequestContent? _$v;

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

  PostAdminFitnessPlansRequestContentDifficultyEnum? _difficulty;
  PostAdminFitnessPlansRequestContentDifficultyEnum? get difficulty =>
      _$this._difficulty;
  set difficulty(
          PostAdminFitnessPlansRequestContentDifficultyEnum? difficulty) =>
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

  PostAdminFitnessPlansRequestContentBuilder() {
    PostAdminFitnessPlansRequestContent._defaults(this);
  }

  PostAdminFitnessPlansRequestContentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
  void replace(PostAdminFitnessPlansRequestContent other) {
    _$v = other as _$PostAdminFitnessPlansRequestContent;
  }

  @override
  void update(
      void Function(PostAdminFitnessPlansRequestContentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminFitnessPlansRequestContent build() => _build();

  _$PostAdminFitnessPlansRequestContent _build() {
    _$PostAdminFitnessPlansRequestContent _$result;
    try {
      _$result = _$v ??
          _$PostAdminFitnessPlansRequestContent._(
            name: name.build(),
            description: description.build(),
            difficulty: BuiltValueNullFieldError.checkNotNull(difficulty,
                r'PostAdminFitnessPlansRequestContent', 'difficulty'),
            goals: goals.build(),
            cycleDays: BuiltValueNullFieldError.checkNotNull(
                cycleDays, r'PostAdminFitnessPlansRequestContent', 'cycleDays'),
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
        throw BuiltValueNestedFieldError(r'PostAdminFitnessPlansRequestContent',
            _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
