// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of14_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload {
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

  factory _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload._(
      {required this.customExercises,
      required this.defaultRestSeconds,
      this.defaultWarmupRestSeconds,
      this.exerciseRestSettings,
      required this.soundEnabled,
      required this.vibrationEnabled,
      required this.pinnedExerciseIds,
      required this.exerciseWeightModes,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload &&
        customExercises == other.customExercises &&
        defaultRestSeconds == other.defaultRestSeconds &&
        defaultWarmupRestSeconds == other.defaultWarmupRestSeconds &&
        exerciseRestSettings == other.exerciseRestSettings &&
        soundEnabled == other.soundEnabled &&
        vibrationEnabled == other.vibrationEnabled &&
        pinnedExerciseIds == other.pinnedExerciseIds &&
        exerciseWeightModes == other.exerciseWeightModes &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload')
          ..add('customExercises', customExercises)
          ..add('defaultRestSeconds', defaultRestSeconds)
          ..add('defaultWarmupRestSeconds', defaultWarmupRestSeconds)
          ..add('exerciseRestSettings', exerciseRestSettings)
          ..add('soundEnabled', soundEnabled)
          ..add('vibrationEnabled', vibrationEnabled)
          ..add('pinnedExerciseIds', pinnedExerciseIds)
          ..add('exerciseWeightModes', exerciseWeightModes)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload? _$v;

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

  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder get _$this {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf14AnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload _build() {
    _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload._(
            customExercises: customExercises.build(),
            defaultRestSeconds: BuiltValueNullFieldError.checkNotNull(
                defaultRestSeconds,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload',
                'defaultRestSeconds'),
            defaultWarmupRestSeconds: defaultWarmupRestSeconds,
            exerciseRestSettings: _exerciseRestSettings?.build(),
            soundEnabled: BuiltValueNullFieldError.checkNotNull(
                soundEnabled,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload',
                'soundEnabled'),
            vibrationEnabled: BuiltValueNullFieldError.checkNotNull(
                vibrationEnabled,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload',
                'vibrationEnabled'),
            pinnedExerciseIds: pinnedExerciseIds.build(),
            exerciseWeightModes: exerciseWeightModes.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload',
                'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt,
                r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload',
                'updatedAt'),
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
            r'PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload',
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
