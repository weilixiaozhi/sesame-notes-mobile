// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner
    extends GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner {
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>
      customExercises;
  @override
  final int defaultRestSeconds;
  @override
  final int? defaultWarmupRestSeconds;
  @override
  final BuiltMap<String,
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>?
      exerciseRestSettings;
  @override
  final bool soundEnabled;
  @override
  final bool vibrationEnabled;
  @override
  final BuiltSet<String> pinnedExerciseIds;
  @override
  final BuiltMap<String, bool> exerciseWeightModes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String id;
  @override
  final String fitnessSpaceId;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final String? deletedAt;

  factory _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner._(
      {required this.customExercises,
      required this.defaultRestSeconds,
      this.defaultWarmupRestSeconds,
      this.exerciseRestSettings,
      required this.soundEnabled,
      required this.vibrationEnabled,
      required this.pinnedExerciseIds,
      required this.exerciseWeightModes,
      required this.createdAt,
      required this.updatedAt,
      required this.id,
      required this.fitnessSpaceId,
      required this.syncId,
      required this.revision,
      this.deletedAt})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner &&
        customExercises == other.customExercises &&
        defaultRestSeconds == other.defaultRestSeconds &&
        defaultWarmupRestSeconds == other.defaultWarmupRestSeconds &&
        exerciseRestSettings == other.exerciseRestSettings &&
        soundEnabled == other.soundEnabled &&
        vibrationEnabled == other.vibrationEnabled &&
        pinnedExerciseIds == other.pinnedExerciseIds &&
        exerciseWeightModes == other.exerciseWeightModes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        id == other.id &&
        fitnessSpaceId == other.fitnessSpaceId &&
        syncId == other.syncId &&
        revision == other.revision &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, customExercises.hashCode);
    _$hash = $jc(_$hash, defaultRestSeconds.hashCode);
    _$hash = $jc(_$hash, defaultWarmupRestSeconds.hashCode);
    _$hash = $jc(_$hash, exerciseRestSettings.hashCode);
    _$hash = $jc(_$hash, soundEnabled.hashCode);
    _$hash = $jc(_$hash, vibrationEnabled.hashCode);
    _$hash = $jc(_$hash, pinnedExerciseIds.hashCode);
    _$hash = $jc(_$hash, exerciseWeightModes.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fitnessSpaceId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner')
          ..add('customExercises', customExercises)
          ..add('defaultRestSeconds', defaultRestSeconds)
          ..add('defaultWarmupRestSeconds', defaultWarmupRestSeconds)
          ..add('exerciseRestSettings', exerciseRestSettings)
          ..add('soundEnabled', soundEnabled)
          ..add('vibrationEnabled', vibrationEnabled)
          ..add('pinnedExerciseIds', pinnedExerciseIds)
          ..add('exerciseWeightModes', exerciseWeightModes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('id', id)
          ..add('fitnessSpaceId', fitnessSpaceId)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner? _$v;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>?
      _customExercises;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>
      get customExercises => _$this._customExercises ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>();
  set customExercises(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>?
              customExercises) =>
      _$this._customExercises = customExercises;

  int? _defaultRestSeconds;
  int? get defaultRestSeconds => _$this._defaultRestSeconds;
  set defaultRestSeconds(int? defaultRestSeconds) =>
      _$this._defaultRestSeconds = defaultRestSeconds;

  int? _defaultWarmupRestSeconds;
  int? get defaultWarmupRestSeconds => _$this._defaultWarmupRestSeconds;
  set defaultWarmupRestSeconds(int? defaultWarmupRestSeconds) =>
      _$this._defaultWarmupRestSeconds = defaultWarmupRestSeconds;

  MapBuilder<String,
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>?
      _exerciseRestSettings;
  MapBuilder<String,
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>
      get exerciseRestSettings => _$this._exerciseRestSettings ??= MapBuilder<
          String,
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>();
  set exerciseRestSettings(
          MapBuilder<String,
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>?
              exerciseRestSettings) =>
      _$this._exerciseRestSettings = exerciseRestSettings;

  bool? _soundEnabled;
  bool? get soundEnabled => _$this._soundEnabled;
  set soundEnabled(bool? soundEnabled) => _$this._soundEnabled = soundEnabled;

  bool? _vibrationEnabled;
  bool? get vibrationEnabled => _$this._vibrationEnabled;
  set vibrationEnabled(bool? vibrationEnabled) =>
      _$this._vibrationEnabled = vibrationEnabled;

  SetBuilder<String>? _pinnedExerciseIds;
  SetBuilder<String> get pinnedExerciseIds =>
      _$this._pinnedExerciseIds ??= SetBuilder<String>();
  set pinnedExerciseIds(SetBuilder<String>? pinnedExerciseIds) =>
      _$this._pinnedExerciseIds = pinnedExerciseIds;

  MapBuilder<String, bool>? _exerciseWeightModes;
  MapBuilder<String, bool> get exerciseWeightModes =>
      _$this._exerciseWeightModes ??= MapBuilder<String, bool>();
  set exerciseWeightModes(MapBuilder<String, bool>? exerciseWeightModes) =>
      _$this._exerciseWeightModes = exerciseWeightModes;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fitnessSpaceId;
  String? get fitnessSpaceId => _$this._fitnessSpaceId;
  set fitnessSpaceId(String? fitnessSpaceId) =>
      _$this._fitnessSpaceId = fitnessSpaceId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  String? _deletedAt;
  String? get deletedAt => _$this._deletedAt;
  set deletedAt(String? deletedAt) => _$this._deletedAt = deletedAt;

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner._defaults(
        this);
  }

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _customExercises = $v.customExercises.toBuilder();
      _defaultRestSeconds = $v.defaultRestSeconds;
      _defaultWarmupRestSeconds = $v.defaultWarmupRestSeconds;
      _exerciseRestSettings = $v.exerciseRestSettings?.toBuilder();
      _soundEnabled = $v.soundEnabled;
      _vibrationEnabled = $v.vibrationEnabled;
      _pinnedExerciseIds = $v.pinnedExerciseIds.toBuilder();
      _exerciseWeightModes = $v.exerciseWeightModes.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _id = $v.id;
      _fitnessSpaceId = $v.fitnessSpaceId;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner build() =>
      _build();

  _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner._(
            customExercises: customExercises.build(),
            defaultRestSeconds: BuiltValueNullFieldError.checkNotNull(
                defaultRestSeconds,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'defaultRestSeconds'),
            defaultWarmupRestSeconds: defaultWarmupRestSeconds,
            exerciseRestSettings: _exerciseRestSettings?.build(),
            soundEnabled: BuiltValueNullFieldError.checkNotNull(
                soundEnabled,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'soundEnabled'),
            vibrationEnabled: BuiltValueNullFieldError.checkNotNull(
                vibrationEnabled,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'vibrationEnabled'),
            pinnedExerciseIds: pinnedExerciseIds.build(),
            exerciseWeightModes: exerciseWeightModes.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'updatedAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'id'),
            fitnessSpaceId: BuiltValueNullFieldError.checkNotNull(
                fitnessSpaceId,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'fitnessSpaceId'),
            syncId: BuiltValueNullFieldError.checkNotNull(
                syncId,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'syncId'),
            revision: BuiltValueNullFieldError.checkNotNull(
                revision,
                r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
                'revision'),
            deletedAt: deletedAt,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'customExercises';
        customExercises.build();

        _$failedField = 'exerciseRestSettings';
        _exerciseRestSettings?.build();

        _$failedField = 'pinnedExerciseIds';
        pinnedExerciseIds.build();
        _$failedField = 'exerciseWeightModes';
        exerciseWeightModes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner',
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
