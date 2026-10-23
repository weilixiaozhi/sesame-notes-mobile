// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_fitness_exercises_request_content.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminFitnessExercisesRequestContent
    extends PostAdminFitnessExercisesRequestContent {
  @override
  final String nameZh;
  @override
  final String nameZhHant;
  @override
  final String nameEn;
  @override
  final String bodyPart;
  @override
  final String equipment;
  @override
  final String target;
  @override
  final BuiltList<String> secondaryMuscles;
  @override
  final BuiltList<String> instructionsZh;
  @override
  final BuiltList<String> instructionsZhHant;
  @override
  final BuiltList<String> instructionsEn;
  @override
  final String attribution;
  @override
  final String gifAsset;
  @override
  final String? mediaId;

  factory _$PostAdminFitnessExercisesRequestContent(
          [void Function(PostAdminFitnessExercisesRequestContentBuilder)?
              updates]) =>
      (PostAdminFitnessExercisesRequestContentBuilder()..update(updates))
          ._build();

  _$PostAdminFitnessExercisesRequestContent._(
      {required this.nameZh,
      required this.nameZhHant,
      required this.nameEn,
      required this.bodyPart,
      required this.equipment,
      required this.target,
      required this.secondaryMuscles,
      required this.instructionsZh,
      required this.instructionsZhHant,
      required this.instructionsEn,
      required this.attribution,
      required this.gifAsset,
      this.mediaId})
      : super._();
  @override
  PostAdminFitnessExercisesRequestContent rebuild(
          void Function(PostAdminFitnessExercisesRequestContentBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminFitnessExercisesRequestContentBuilder toBuilder() =>
      PostAdminFitnessExercisesRequestContentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminFitnessExercisesRequestContent &&
        nameZh == other.nameZh &&
        nameZhHant == other.nameZhHant &&
        nameEn == other.nameEn &&
        bodyPart == other.bodyPart &&
        equipment == other.equipment &&
        target == other.target &&
        secondaryMuscles == other.secondaryMuscles &&
        instructionsZh == other.instructionsZh &&
        instructionsZhHant == other.instructionsZhHant &&
        instructionsEn == other.instructionsEn &&
        attribution == other.attribution &&
        gifAsset == other.gifAsset &&
        mediaId == other.mediaId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nameZh.hashCode);
    _$hash = $jc(_$hash, nameZhHant.hashCode);
    _$hash = $jc(_$hash, nameEn.hashCode);
    _$hash = $jc(_$hash, bodyPart.hashCode);
    _$hash = $jc(_$hash, equipment.hashCode);
    _$hash = $jc(_$hash, target.hashCode);
    _$hash = $jc(_$hash, secondaryMuscles.hashCode);
    _$hash = $jc(_$hash, instructionsZh.hashCode);
    _$hash = $jc(_$hash, instructionsZhHant.hashCode);
    _$hash = $jc(_$hash, instructionsEn.hashCode);
    _$hash = $jc(_$hash, attribution.hashCode);
    _$hash = $jc(_$hash, gifAsset.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostAdminFitnessExercisesRequestContent')
          ..add('nameZh', nameZh)
          ..add('nameZhHant', nameZhHant)
          ..add('nameEn', nameEn)
          ..add('bodyPart', bodyPart)
          ..add('equipment', equipment)
          ..add('target', target)
          ..add('secondaryMuscles', secondaryMuscles)
          ..add('instructionsZh', instructionsZh)
          ..add('instructionsZhHant', instructionsZhHant)
          ..add('instructionsEn', instructionsEn)
          ..add('attribution', attribution)
          ..add('gifAsset', gifAsset)
          ..add('mediaId', mediaId))
        .toString();
  }
}

class PostAdminFitnessExercisesRequestContentBuilder
    implements
        Builder<PostAdminFitnessExercisesRequestContent,
            PostAdminFitnessExercisesRequestContentBuilder> {
  _$PostAdminFitnessExercisesRequestContent? _$v;

  String? _nameZh;
  String? get nameZh => _$this._nameZh;
  set nameZh(String? nameZh) => _$this._nameZh = nameZh;

  String? _nameZhHant;
  String? get nameZhHant => _$this._nameZhHant;
  set nameZhHant(String? nameZhHant) => _$this._nameZhHant = nameZhHant;

  String? _nameEn;
  String? get nameEn => _$this._nameEn;
  set nameEn(String? nameEn) => _$this._nameEn = nameEn;

  String? _bodyPart;
  String? get bodyPart => _$this._bodyPart;
  set bodyPart(String? bodyPart) => _$this._bodyPart = bodyPart;

  String? _equipment;
  String? get equipment => _$this._equipment;
  set equipment(String? equipment) => _$this._equipment = equipment;

  String? _target;
  String? get target => _$this._target;
  set target(String? target) => _$this._target = target;

  ListBuilder<String>? _secondaryMuscles;
  ListBuilder<String> get secondaryMuscles =>
      _$this._secondaryMuscles ??= ListBuilder<String>();
  set secondaryMuscles(ListBuilder<String>? secondaryMuscles) =>
      _$this._secondaryMuscles = secondaryMuscles;

  ListBuilder<String>? _instructionsZh;
  ListBuilder<String> get instructionsZh =>
      _$this._instructionsZh ??= ListBuilder<String>();
  set instructionsZh(ListBuilder<String>? instructionsZh) =>
      _$this._instructionsZh = instructionsZh;

  ListBuilder<String>? _instructionsZhHant;
  ListBuilder<String> get instructionsZhHant =>
      _$this._instructionsZhHant ??= ListBuilder<String>();
  set instructionsZhHant(ListBuilder<String>? instructionsZhHant) =>
      _$this._instructionsZhHant = instructionsZhHant;

  ListBuilder<String>? _instructionsEn;
  ListBuilder<String> get instructionsEn =>
      _$this._instructionsEn ??= ListBuilder<String>();
  set instructionsEn(ListBuilder<String>? instructionsEn) =>
      _$this._instructionsEn = instructionsEn;

  String? _attribution;
  String? get attribution => _$this._attribution;
  set attribution(String? attribution) => _$this._attribution = attribution;

  String? _gifAsset;
  String? get gifAsset => _$this._gifAsset;
  set gifAsset(String? gifAsset) => _$this._gifAsset = gifAsset;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  PostAdminFitnessExercisesRequestContentBuilder() {
    PostAdminFitnessExercisesRequestContent._defaults(this);
  }

  PostAdminFitnessExercisesRequestContentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _nameZh = $v.nameZh;
      _nameZhHant = $v.nameZhHant;
      _nameEn = $v.nameEn;
      _bodyPart = $v.bodyPart;
      _equipment = $v.equipment;
      _target = $v.target;
      _secondaryMuscles = $v.secondaryMuscles.toBuilder();
      _instructionsZh = $v.instructionsZh.toBuilder();
      _instructionsZhHant = $v.instructionsZhHant.toBuilder();
      _instructionsEn = $v.instructionsEn.toBuilder();
      _attribution = $v.attribution;
      _gifAsset = $v.gifAsset;
      _mediaId = $v.mediaId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminFitnessExercisesRequestContent other) {
    _$v = other as _$PostAdminFitnessExercisesRequestContent;
  }

  @override
  void update(
      void Function(PostAdminFitnessExercisesRequestContentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminFitnessExercisesRequestContent build() => _build();

  _$PostAdminFitnessExercisesRequestContent _build() {
    _$PostAdminFitnessExercisesRequestContent _$result;
    try {
      _$result = _$v ??
          _$PostAdminFitnessExercisesRequestContent._(
            nameZh: BuiltValueNullFieldError.checkNotNull(
                nameZh, r'PostAdminFitnessExercisesRequestContent', 'nameZh'),
            nameZhHant: BuiltValueNullFieldError.checkNotNull(nameZhHant,
                r'PostAdminFitnessExercisesRequestContent', 'nameZhHant'),
            nameEn: BuiltValueNullFieldError.checkNotNull(
                nameEn, r'PostAdminFitnessExercisesRequestContent', 'nameEn'),
            bodyPart: BuiltValueNullFieldError.checkNotNull(bodyPart,
                r'PostAdminFitnessExercisesRequestContent', 'bodyPart'),
            equipment: BuiltValueNullFieldError.checkNotNull(equipment,
                r'PostAdminFitnessExercisesRequestContent', 'equipment'),
            target: BuiltValueNullFieldError.checkNotNull(
                target, r'PostAdminFitnessExercisesRequestContent', 'target'),
            secondaryMuscles: secondaryMuscles.build(),
            instructionsZh: instructionsZh.build(),
            instructionsZhHant: instructionsZhHant.build(),
            instructionsEn: instructionsEn.build(),
            attribution: BuiltValueNullFieldError.checkNotNull(attribution,
                r'PostAdminFitnessExercisesRequestContent', 'attribution'),
            gifAsset: BuiltValueNullFieldError.checkNotNull(gifAsset,
                r'PostAdminFitnessExercisesRequestContent', 'gifAsset'),
            mediaId: mediaId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'secondaryMuscles';
        secondaryMuscles.build();
        _$failedField = 'instructionsZh';
        instructionsZh.build();
        _$failedField = 'instructionsZhHant';
        instructionsZhHant.build();
        _$failedField = 'instructionsEn';
        instructionsEn.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAdminFitnessExercisesRequestContent',
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
