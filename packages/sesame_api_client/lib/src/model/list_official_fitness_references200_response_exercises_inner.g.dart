// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_official_fitness_references200_response_exercises_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListOfficialFitnessReferences200ResponseExercisesInner
    extends ListOfficialFitnessReferences200ResponseExercisesInner {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool isEnabled;

  factory _$ListOfficialFitnessReferences200ResponseExercisesInner(
          [void Function(
                  ListOfficialFitnessReferences200ResponseExercisesInnerBuilder)?
              updates]) =>
      (ListOfficialFitnessReferences200ResponseExercisesInnerBuilder()
            ..update(updates))
          ._build();

  _$ListOfficialFitnessReferences200ResponseExercisesInner._(
      {required this.id, required this.name, required this.isEnabled})
      : super._();
  @override
  ListOfficialFitnessReferences200ResponseExercisesInner rebuild(
          void Function(
                  ListOfficialFitnessReferences200ResponseExercisesInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListOfficialFitnessReferences200ResponseExercisesInnerBuilder toBuilder() =>
      ListOfficialFitnessReferences200ResponseExercisesInnerBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListOfficialFitnessReferences200ResponseExercisesInner &&
        id == other.id &&
        name == other.name &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'ListOfficialFitnessReferences200ResponseExercisesInner')
          ..add('id', id)
          ..add('name', name)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class ListOfficialFitnessReferences200ResponseExercisesInnerBuilder
    implements
        Builder<ListOfficialFitnessReferences200ResponseExercisesInner,
            ListOfficialFitnessReferences200ResponseExercisesInnerBuilder> {
  _$ListOfficialFitnessReferences200ResponseExercisesInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  ListOfficialFitnessReferences200ResponseExercisesInnerBuilder() {
    ListOfficialFitnessReferences200ResponseExercisesInner._defaults(this);
  }

  ListOfficialFitnessReferences200ResponseExercisesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListOfficialFitnessReferences200ResponseExercisesInner other) {
    _$v = other as _$ListOfficialFitnessReferences200ResponseExercisesInner;
  }

  @override
  void update(
      void Function(
              ListOfficialFitnessReferences200ResponseExercisesInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  ListOfficialFitnessReferences200ResponseExercisesInner build() => _build();

  _$ListOfficialFitnessReferences200ResponseExercisesInner _build() {
    final _$result = _$v ??
        _$ListOfficialFitnessReferences200ResponseExercisesInner._(
          id: BuiltValueNullFieldError.checkNotNull(id,
              r'ListOfficialFitnessReferences200ResponseExercisesInner', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name,
              r'ListOfficialFitnessReferences200ResponseExercisesInner',
              'name'),
          isEnabled: BuiltValueNullFieldError.checkNotNull(
              isEnabled,
              r'ListOfficialFitnessReferences200ResponseExercisesInner',
              'isEnabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
