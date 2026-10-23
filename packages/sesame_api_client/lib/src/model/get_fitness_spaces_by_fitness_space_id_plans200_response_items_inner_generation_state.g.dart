// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_generation_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
    extends GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState {
  @override
  final String? nextCycleStartDate;
  @override
  final int nextCycleIndex;
  @override
  final BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>
      generatedCycles;

  factory _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState(
          [void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder)?
              updates]) =>
      (GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder()
            ..update(updates))
          ._build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState._(
      {this.nextCycleStartDate,
      required this.nextCycleIndex,
      required this.generatedCycles})
      : super._();
  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState rebuild(
          void Function(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
      toBuilder() =>
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState &&
        nextCycleStartDate == other.nextCycleStartDate &&
        nextCycleIndex == other.nextCycleIndex &&
        generatedCycles == other.generatedCycles;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, nextCycleStartDate.hashCode);
    _$hash = $jc(_$hash, nextCycleIndex.hashCode);
    _$hash = $jc(_$hash, generatedCycles.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState')
          ..add('nextCycleStartDate', nextCycleStartDate)
          ..add('nextCycleIndex', nextCycleIndex)
          ..add('generatedCycles', generatedCycles))
        .toString();
  }
}

class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
    implements
        Builder<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder> {
  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState?
      _$v;

  String? _nextCycleStartDate;
  String? get nextCycleStartDate => _$this._nextCycleStartDate;
  set nextCycleStartDate(String? nextCycleStartDate) =>
      _$this._nextCycleStartDate = nextCycleStartDate;

  int? _nextCycleIndex;
  int? get nextCycleIndex => _$this._nextCycleIndex;
  set nextCycleIndex(int? nextCycleIndex) =>
      _$this._nextCycleIndex = nextCycleIndex;

  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>?
      _generatedCycles;
  ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>
      get generatedCycles => _$this._generatedCycles ??= ListBuilder<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>();
  set generatedCycles(
          ListBuilder<
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateGeneratedCyclesInner>?
              generatedCycles) =>
      _$this._generatedCycles = generatedCycles;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder() {
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
        ._defaults(this);
  }

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder
      get _$this {
    final $v = _$v;
    if ($v != null) {
      _nextCycleStartDate = $v.nextCycleStartDate;
      _nextCycleIndex = $v.nextCycleIndex;
      _generatedCycles = $v.generatedCycles.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
          other) {
    _$v = other
        as _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState;
  }

  @override
  void update(
      void Function(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationStateBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
      build() => _build();

  _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
      _build() {
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
        _$result;
    try {
      _$result = _$v ??
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState
              ._(
            nextCycleStartDate: nextCycleStartDate,
            nextCycleIndex: BuiltValueNullFieldError.checkNotNull(
                nextCycleIndex,
                r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState',
                'nextCycleIndex'),
            generatedCycles: generatedCycles.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'generatedCycles';
        generatedCycles.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerGenerationState',
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
