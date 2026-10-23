// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner_exercise_rest_settings_value.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
    extends GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue {
  @override
  final int restSeconds;
  @override
  final int warmupRestSeconds;

  factory _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue._(
      {required this.restSeconds, required this.warmupRestSeconds})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
      rebuild(
              void Function(
                      GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder)
                  updates) =>
          (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue &&
        restSeconds == other.restSeconds &&
        warmupRestSeconds == other.warmupRestSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, restSeconds.hashCode);
    _$hash = $jc(_$hash, warmupRestSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue')
          ..add('restSeconds', restSeconds)
          ..add('warmupRestSeconds', warmupRestSeconds))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue?
      _$v;

  int? _restSeconds;
  int? get restSeconds => _$this._restSeconds;
  set restSeconds(int? restSeconds) => _$this._restSeconds = restSeconds;

  int? _warmupRestSeconds;
  int? get warmupRestSeconds => _$this._warmupRestSeconds;
  set warmupRestSeconds(int? warmupRestSeconds) =>
      _$this._warmupRestSeconds = warmupRestSeconds;

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _restSeconds = $v.restSeconds;
      _warmupRestSeconds = $v.warmupRestSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
      _build() {
    final _$result = _$v ??
        _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
            ._(
          restSeconds: BuiltValueNullFieldError.checkNotNull(
              restSeconds,
              r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue',
              'restSeconds'),
          warmupRestSeconds: BuiltValueNullFieldError.checkNotNull(
              warmupRestSeconds,
              r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue',
              'warmupRestSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
